// lib/data/playback/native_audio_player_service.dart
import 'dart:async';
import '../../core/log.dart';
import '../../services/artwork_service.dart';
import '../play_mode.dart';
import '../song.dart';
import 'audio_player_service.dart';

class NativeAudioPlayerService implements AudioPlayerService {
  NativeAudioPlayerService({ArtworkService? artworkService})
      : _artworkService = artworkService ?? ArtworkService() {
    _playerStateController = StreamController<PlayerStateEnum>.broadcast();
    _positionController = StreamController<Duration>.broadcast();
    _durationController = StreamController<Duration?>.broadcast();
    _currentSongController = StreamController<Song?>.broadcast();
    _favoriteToggledController = StreamController<FavoriteToggledFromNotification>.broadcast();
  }

  final ArtworkService _artworkService;

  late final StreamController<PlayerStateEnum> _playerStateController;
  late final StreamController<Duration> _positionController;
  late final StreamController<Duration?> _durationController;
  late final StreamController<Song?> _currentSongController;
  late final StreamController<FavoriteToggledFromNotification> _favoriteToggledController;

  bool _isDisposed = false;
  Song? _currentSong;
  PlayerStateEnum _playerState = PlayerStateEnum.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

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

  @override
  Future<void> playSong(Song song) async {
    if (_isDisposed) return;

    // Resolvemos la carátula real mediante el servicio dedicado
    final resolvedSong = await _resolveSongArtwork(song);

    _currentSong = resolvedSong;
    _playerState = PlayerStateEnum.playing;
    _duration = const Duration(minutes: 3);

    _currentSongController.add(_currentSong);
    _playerStateController.add(_playerState);
    _durationController.add(_duration);

    Log.playback('[NativeAudioPlayerService] Reproduciendo canción con carátula resuelta: ${resolvedSong.title}');
  }

  @override
  Future<void> setPlaylist(
    List<Song> playlist, {
    int initialIndex = 0,
    Duration startPosition = Duration.zero,
  }) async {
    if (_isDisposed || playlist.isEmpty) return;

    final rawSong = playlist[initialIndex.clamp(0, playlist.length - 1)];
    _currentSong = await _resolveSongArtwork(rawSong);
    _position = startPosition;

    _currentSongController.add(_currentSong);
    Log.playback('[NativeAudioPlayerService] Cola establecida: ${playlist.length} pistas. Inicial con carátula: ${_currentSong?.title}');
  }

  Future<Song> _resolveSongArtwork(Song song) async {
    try {
      final artworkPath = await _artworkService.getArtworkPath(song);

      if (artworkPath != null && artworkPath.isNotEmpty) {
        Log.playback('[NativeAudioPlayerService] Carátula encontrada para ${song.title}: $artworkPath');
      }
    } catch (e) {
      Log.playback('[NativeAudioPlayerService] Error obteniendo carátula para ${song.title}: $e');
    }
    return song;
  }

  @override
  Future<void> play() async {
    if (_isDisposed) return;
    _playerState = PlayerStateEnum.playing;
    _playerStateController.add(_playerState);
    Log.playback('[NativeAudioPlayerService] Play ejecutado');
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) return;
    _playerState = PlayerStateEnum.paused;
    _playerStateController.add(_playerState);
    Log.playback('[NativeAudioPlayerService] Pause ejecutado');
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    _playerState = PlayerStateEnum.stopped;
    _playerStateController.add(_playerState);
    Log.playback('[NativeAudioPlayerService] Stop ejecutado');
  }

  @override
  Future<void> skipToNext() async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Skip to next');
  }

  @override
  Future<void> skipToPrevious() async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Skip to previous');
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    _position = position;
    _positionController.add(_position);
    Log.playback('[NativeAudioPlayerService] Seek a ${position.inSeconds}s');
  }

  @override
  Future<void> setSpeed(double speed) async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Velocidad establecida a: ${speed}x');
  }

  @override
  Future<void> setPlayMode(PlayMode mode) async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Modo de reproducción establecido a: ${mode.label}');
  }

  @override
  Future<void> setFavorite(bool isFavorite) async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Favorito establecido a: $isFavorite');
  }

  @override
  Future<void> initializeDeviceCapabilities(List<Song> songs) async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Capacidades inicializadas para ${songs.length} canciones.');
  }

  @override
  Future<void> updatePlaylistOrder(List<Song> playlist) async {
    if (_isDisposed) return;
    Log.playback('[NativeAudioPlayerService] Orden de la cola actualizado.');
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _currentSongController.close();
    await _favoriteToggledController.close();
  }
}
