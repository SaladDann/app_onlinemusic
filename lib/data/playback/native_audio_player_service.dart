// lib/data/playback/native_audio_player_service.dart
import 'dart:async';
import 'package:flutter/services.dart';
import '../../core/log.dart';
import '../../data/play_mode.dart';
import '../../data/song.dart';
import '../../services/artwork_service.dart';
import 'audio_player_service.dart';

class NativeAudioPlayerService implements AudioPlayerService {
  NativeAudioPlayerService({ArtworkService? artworkService})
      : _artworkService = artworkService ?? ArtworkService() {
    _playerStateController = StreamController<PlayerStateEnum>.broadcast();
    _positionController = StreamController<Duration>.broadcast();
    _durationController = StreamController<Duration?>.broadcast();
    _currentSongController = StreamController<Song?>.broadcast();
    _favoriteToggledController = StreamController<FavoriteToggledFromNotification>.broadcast();

    _methodChannel.setMethodCallHandler(_handleNativeCallback);
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(_handleEventChannel, onError: (_) {});
  }

  // Canales oficiales definidos en MusicPlaybackConstants.kt
  static const MethodChannel _methodChannel = MethodChannel('offline_music/playback');
  static const EventChannel _eventChannel = EventChannel('offline_music/playback_events');

  final ArtworkService _artworkService;
  StreamSubscription<dynamic>? _eventSubscription;

  late final StreamController<PlayerStateEnum> _playerStateController;
  late final StreamController<Duration> _positionController;
  late final StreamController<Duration?> _durationController;
  late final StreamController<Song?> _currentSongController;
  late final StreamController<FavoriteToggledFromNotification> _favoriteToggledController;

  bool _isDisposed = false;
  Song? _currentSong;
  List<Song> _playlist = [];
  int _currentIndex = 0;

  @override
  Stream<PlayerStateEnum> get playerStateStream => _playerStateController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<Song?> get currentSongStream => _currentSongController.stream;

  @override
  Stream<FavoriteToggledFromNotification> get favoriteToggledStream => _favoriteToggledController.stream;

  Future<dynamic> _handleNativeCallback(MethodCall call) async {
    if (_isDisposed) return;
    switch (call.method) {
      case 'onFavoriteToggled':
        final args = call.arguments;
        if (args is Map) {
          final songId = args['id']?.toString() ?? '';
          final isFav = args['isFavorite'] as bool? ?? false;
          _favoriteToggledController.add(FavoriteToggledFromNotification(songId: songId, isFavorite: isFav));
        }
        break;
    }
  }

  void _handleEventChannel(dynamic event) {
    if (_isDisposed || event == null) return;
    if (event is Map) {
      // Sincronización con el estado emitido por MusicPlaybackService.kt (KEY: 'state')
      if (event.containsKey('state')) {
        final stateMap = event['state'];
        if (stateMap is Map) {
          final isPlaying = stateMap['isPlaying'] as bool? ?? false;
          final positionMs = stateMap['positionMs'] as int? ?? 0;
          final durationMs = stateMap['durationMs'] as int? ?? 0;
          final queueIndex = stateMap['index'] as int? ?? 0;

          _playerStateController.add(isPlaying ? PlayerStateEnum.playing : PlayerStateEnum.paused);
          _positionController.add(Duration(milliseconds: positionMs));
          _durationController.add(Duration(milliseconds: durationMs));

          if (_playlist.isNotEmpty && queueIndex >= 0 && queueIndex < _playlist.length) {
            if (_currentIndex != queueIndex) {
              _currentIndex = queueIndex;
              _currentSong = _playlist[_currentIndex];
              _resolveSongArtwork(_currentSong!).then((resolved) {
                if (!_isDisposed) {
                  _currentSong = resolved;
                  _currentSongController.add(_currentSong);
                }
              });
            }
          }
        }
      }

      // Manejo de eventos de favoritos si provienen del canal de eventos
      if (event.containsKey('favoriteToggled')) {
        final favMap = event['favoriteToggled'];
        if (favMap is Map) {
          final songId = favMap['id']?.toString() ?? '';
          final isFav = favMap['isFavorite'] as bool? ?? false;
          _favoriteToggledController.add(FavoriteToggledFromNotification(songId: songId, isFavorite: isFav));
        }
      }
    }
  }

  Future<Song> _resolveSongArtwork(Song song) async {
    try {
      final artworkPath = await _artworkService.getArtwork(song.id);
      if (artworkPath != null && artworkPath.isNotEmpty) {
        return song.copyWith(uri: artworkPath);
      }
    } catch (_) {}
    return song;
  }

  @override
  Future<void> initializeDeviceCapabilities(List<Song> songs) async {
    Log.playback('[NativeAudioPlayerService] Inicializando capacidades del dispositivo...');
  }

  @override
  Future<void> setPlaylist(
    List<Song> playlist, {
    int initialIndex = 0,
    Duration startPosition = Duration.zero,
  }) async {
    if (_isDisposed || playlist.isEmpty) return;
    _playlist = List<Song>.from(playlist);
    _currentIndex = initialIndex.clamp(0, _playlist.length - 1);

    _currentSong = await _resolveSongArtwork(_playlist[_currentIndex]);
    _currentSongController.add(_currentSong);
    _durationController.add(_currentSong!.durationAsDuration);

    try {
      final songsMapList = _playlist.map((s) => {
        'id': s.id,
        'title': s.title,
        'artist': s.artist,
        'album': s.album,
        'uri': s.uri,
        'data': s.data,
        'duration': s.duration,
        'mimeType': s.mimeType,
      }).toList();

      // Envío de la cola usando 'setQueue' que procesa MusicPlaybackService.kt
      await _methodChannel.invokeMethod('setQueue', {
        'songs': songsMapList,
        'initialIndex': _currentIndex,
        'startPositionMs': startPosition.inMilliseconds,
      });
      Log.playback('[NativeAudioPlayerService] Cola enviada al puente nativo: ${_playlist.length} pistas.');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error configurando cola nativa: $e');
    }
  }

  @override
  Future<void> play() async {
    if (_isDisposed) return;
    try {
      await _methodChannel.invokeMethod('play');
      Log.playback('[NativeAudioPlayerService] Comando play enviado al nativo.');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error en play nativo: $e');
    }
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    try {
      await _methodChannel.invokeMethod('pause');
      Log.playback('[NativeAudioPlayerService] Comando pause enviado al nativo.');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error en pause nativo: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    try {
      await _methodChannel.invokeMethod('stop');
      _playerStateController.add(PlayerStateEnum.stopped);
      Log.playback('[NativeAudioPlayerService] Comando stop enviado al nativo.');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error en stop nativo: $e');
    }
  }

  @override
  Future<void> playSong(Song song) async {
    final index = _playlist.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _currentIndex = index;
      await setPlaylist(_playlist, initialIndex: _currentIndex);
      await play();
    } else {
      await setPlaylist([song], initialIndex: 0);
      await play();
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_isDisposed || _playlist.isEmpty) return;
    try {
      await _methodChannel.invokeMethod('skipToNext');
      Log.playback('[NativeAudioPlayerService] Skip to next enviado al nativo.');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error skipToNext: $e');
      _currentIndex = (_currentIndex + 1) % _playlist.length;
      await playSong(_playlist[_currentIndex]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_isDisposed || _playlist.isEmpty) return;
    try {
      await _methodChannel.invokeMethod('skipToPrevious');
      Log.playback('[NativeAudioPlayerService] Skip to previous enviado al nativo.');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error skipToPrevious: $e');
      _currentIndex = (_currentIndex - 1 < 0) ? _playlist.length - 1 : _currentIndex - 1;
      await playSong(_playlist[_currentIndex]);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    try {
      await _methodChannel.invokeMethod('seek', {'positionMs': position.inMilliseconds});
      _positionController.add(position);
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error en seek nativo: $e');
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    if (_isDisposed) return;
    try {
      await _methodChannel.invokeMethod('setSpeed', {'speed': speed});
      Log.playback('[NativeAudioPlayerService] Velocidad configurada a ${speed}x');
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error configurando velocidad: $e');
    }
  }

  @override
  Future<void> setPlayMode(PlayMode mode) async {
    try {
      // Usamos el nombre del enum o comparaciones seguras de PlayMode
      final modeStr = mode.name.toLowerCase();
      String nativeMode = 'order';

      if (modeStr.contains('shuffle')) {
        nativeMode = 'shuffle';
      } else if (modeStr.contains('one')) {
        nativeMode = 'repeatOne';
      } else if (modeStr.contains('all') || modeStr.contains('loop') || modeStr.contains('repeat')) {
        nativeMode = 'repeatAll';
      }

      await _methodChannel.invokeMethod('setPlayMode', {'playMode': nativeMode});
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error configurando modo de reproducción: $e');
    }
  }

  @override
  Future<void> setFavorite(bool isFavorite) async {
    try {
      await _methodChannel.invokeMethod('setFavorite', {'isFavorite': isFavorite});
    } catch (_) {}
  }

  @override
  Future<void> updatePlaylistOrder(List<Song> orderedSongs) async {
    if (orderedSongs.isEmpty) return;
    _playlist = List<Song>.from(orderedSongs);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _methodChannel.invokeMethod('stop');
    } catch (_) {}
    await _eventSubscription?.cancel();
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _currentSongController.close();
    await _favoriteToggledController.close();
  }
}
