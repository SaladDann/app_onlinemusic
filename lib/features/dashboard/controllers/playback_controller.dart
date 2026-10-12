// lib/features/dashboard/controllers/playback_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/log.dart';
import '../../../data/play_mode.dart';
import '../../../data/playback/audio_player_service.dart';
import '../../../data/playback/native_audio_player_service.dart';
import '../../../data/song.dart';

class PlaybackController extends ChangeNotifier {
  PlaybackController({AudioPlayerService? audioService})
      : _audio = audioService ?? NativeAudioPlayerService() {
    _listenToPlayer();
  }

  final AudioPlayerService _audio;

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayMode _playMode = PlayMode.order;
  bool _isQueuePrepared = false;
  bool _isDisposed = false;

  StreamSubscription<PlayerStateEnum>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Song?>? _currentSongSub;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  PlayMode get playMode => _playMode;

  void _listenToPlayer() {
    _playerStateSub = _audio.playerStateStream.listen((state) {
      _isPlaying = state == PlayerStateEnum.playing;
      _notify();
    });

    _positionSub = _audio.positionStream.listen((pos) {
      _position = pos;
      _notify();
    });

    _durationSub = _audio.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      _notify();
    });

    _currentSongSub = _audio.currentSongStream.listen((song) {
      _currentSong = song;
      Log.playback('[PlaybackController] Pista actual cambiada: ${song?.title}');
      _notify();
    });
  }

  Future<void> preparePlaylist(List<Song> songs, int initialIndex) async {
    if (songs.isEmpty || _isDisposed) return;
    Log.playback('[PlaybackController] Preparando cola: ${songs.length} pistas');
    await _audio.setPlaylist(songs, initialIndex: initialIndex);
    _isQueuePrepared = true;
  }

  Future<void> togglePlayPause(List<Song> songs) async {
    if (songs.isEmpty || _isDisposed) return;

    if (_isPlaying) {
      Log.playback('[PlaybackController] Pausando reproducción');
      await _audio.pause();
    } else {
      Log.playback('[PlaybackController] Iniciando reproducción');
      if (!_isQueuePrepared) {
        await preparePlaylist(songs, 0);
      }
      await _audio.play();
    }
  }

  Future<void> skipToNext() async {
    if (_isDisposed) return;
    Log.playback('[PlaybackController] Saltando a pista siguiente');
    await _audio.skipToNext();
  }

  Future<void> skipToPrevious() async {
    if (_isDisposed) return;
    Log.playback('[PlaybackController] Saltando a pista anterior');
    await _audio.skipToPrevious();
  }

  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    _position = position;
    _notify();
    try {
      await _audio.seek(position);
    } catch (e) {
      Log.playback('[PlaybackController] Error en seek: $e');
    }
  }

  void cyclePlayMode() {
    if (_isDisposed) return;
    _playMode = _playMode.next;
    _audio.setPlayMode(_playMode);
    Log.playback('[PlaybackController] Modo de reproducción cambiado a: ${_playMode.label}');
    _notify();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _currentSongSub?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
