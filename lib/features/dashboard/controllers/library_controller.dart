// lib/features/dashboard/controllers/library_controller.dart
import 'package:flutter/foundation.dart';
import 'package:offline_music/core/log.dart';
import 'package:offline_music/data/library_repository.dart';
import 'package:offline_music/data/song.dart';


enum LibraryMode { local, drive, fusion }

class LibraryController extends ChangeNotifier {
  LibraryController({
    required LibraryRepository localRepository,
    required LibraryRepository driveRepository,
    required LibraryRepository fusionRepository,
  })  : _localRepository = localRepository,
        _driveRepository = driveRepository,
        _fusionRepository = fusionRepository;

  final LibraryRepository _localRepository;
  final LibraryRepository _driveRepository;
  final LibraryRepository _fusionRepository;

  LibraryMode _currentMode = LibraryMode.local;
  List<Song> _songs = const [];
  bool _isLoading = false;
  bool _isDisposed = false;
  int _loadGeneration = 0;

  LibraryMode get currentMode => _currentMode;
  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;

  Future<void> setMode(LibraryMode mode) async {
    if (_currentMode == mode && _songs.isNotEmpty) return;

    _currentMode = mode;
    notifyListeners();

    await loadSongs();
  }

  /// Carga la caché inmediatamente y luego sincroniza el dispositivo.
  Future<void> loadSongs() async {
    final generation = ++_loadGeneration;
    final mode = _currentMode;
    final repository = _getRepositoryForMode(mode);

    _isLoading = true;
    notifyListeners();

    try {
      final cachedSongs = await repository.getCachedSongs();

      if (!_isCurrentLoad(generation, mode)) return;

      _songs = List<Song>.unmodifiable(cachedSongs);

      Log.library(
        'Biblioteca SQLite visible: ${_songs.length} canciones; modo=$mode',
      );

      notifyListeners();

      try {
        final updatedSongs = await repository.refreshSongs();

        if (!_isCurrentLoad(generation, mode)) return;

        _songs = List<Song>.unmodifiable(updatedSongs);

        Log.library(
          'Biblioteca sincronizada: ${_songs.length} canciones; modo=$mode',
        );

        notifyListeners();
      } catch (e) {
        Log.library(
          'Sincronización fallida; se conserva la biblioteca guardada: $e',
        );
      }
    } catch (e, stackTrace) {
      Log.library('Error cargando biblioteca: $e');
      Log.library('Stacktrace: $stackTrace');
    } finally {
      if (_isCurrentLoad(generation, mode)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _isCurrentLoad(int generation, LibraryMode mode) {
    return !_isDisposed &&
        generation == _loadGeneration &&
        mode == _currentMode;
  }

  LibraryRepository _getRepositoryForMode(LibraryMode mode) {
    switch (mode) {
      case LibraryMode.local:
        return _localRepository;
      case LibraryMode.drive:
        return _driveRepository;
      case LibraryMode.fusion:
        return _fusionRepository;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _loadGeneration++;
    super.dispose();
  }
}
