// lib/features/dashboard/controllers/dashboard_controller.dart
// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/foundation.dart';
import 'package:offline_music/features/dashboard/controllers/library_controller.dart';
import '../../../core/log.dart';
import '../../../data/play_mode.dart';
import '../../../data/song.dart';

import 'playback_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required LibraryController libraryController,
    PlaybackController? playbackController,
  })  : _library = libraryController,
        _playback = playbackController ?? PlaybackController() {
    _library.addListener(_onLibraryOrPlaybackChanged);
    _playback.addListener(_onLibraryOrPlaybackChanged);
    Log.library('[DashboardController] Inicializado como orquestador modular.');
  }

  final LibraryController _library;
  final PlaybackController _playback;

  // Delegaciones hacia los controladores especializados
  List<Song> get songs => _library.songs;
  bool get isLoading => _library.isLoading;

  Song? get currentSong => _playback.currentSong ?? (_library.songs.isNotEmpty ? _library.songs.first : null);
  bool get isPlaying => _playback.isPlaying;
  Duration get position => _playback.position;
  Duration get duration => _playback.duration;
  PlayMode get playMode => _playback.playMode;
  bool get isFavorite => false; // Se conectará con FavoritesController próximamente

  /// Inicializa la biblioteca y prepara la cola de audio de forma real
  Future<void> initialize() async {
    Log.library('[DashboardController] Inicializando datos desde la biblioteca...');
    await _library.loadSongs();

    if (_library.songs.isNotEmpty) {
      await _playback.preparePlaylist(_library.songs, 0);
    }
    notifyListeners();
  }

  void _onLibraryOrPlaybackChanged() {
    notifyListeners();
  }

  // --- Acciones de Botones Reales ---

  Future<void> onPlayPressed() async {
    Log.playback('[Dashboard] Tap en Play/Pause');
    await _playback.togglePlayPause(_library.songs);
  }

  Future<void> onNextPressed() async {
    Log.playback('[Dashboard] Tap en Pista Siguiente');
    await _playback.skipToNext();
  }

  Future<void> onPreviousPressed() async {
    Log.playback('[Dashboard] Tap en Pista Anterior');
    await _playback.skipToPrevious();
  }

  Future<void> seek(Duration position) async {
    Log.playback('[Dashboard] Tap en Barra de Progreso (Seek): ${position.inSeconds}s');
    await _playback.seek(position);
  }

  void cyclePlayMode() {
    Log.library('[Dashboard] Tap en Modo de Reproducción');
    _playback.cyclePlayMode();
  }

  void onFavoritePressed() {
    Log.library('[Dashboard] Tap en Favorito');
    // Se delegará al módulo de favoritos
  }

  void startRewind() {
    Log.playback('[Dashboard] Inicio de retroceso rápido');
  }

  void stopRewind() {
    Log.playback('[Dashboard] Fin de retroceso rápido');
  }

  void startFastForward() {
    Log.playback('[Dashboard] Inicio de avance rápido');
  }

  void stopFastForward() {
    Log.playback('[Dashboard] Fin de avance rápido');
  }

  @override
  void dispose() {
    _library.removeListener(_onLibraryOrPlaybackChanged);
    _playback.removeListener(_onLibraryOrPlaybackChanged);
    _playback.dispose();
    super.dispose();
  }
}
