// lib/data/library_repository.dart
import '../core/log.dart';
import '../services/library_service.dart';
import 'library_database.dart';
import 'song.dart';

abstract interface class LibraryRepository {
  Future<List<Song>> getSongs();

  Future<List<Song>> getCachedSongs();

  Future<List<Song>> refreshSongs();
}

class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository({
    LibraryService? service,
    LibraryDatabase? database,
  })  : _service = service ?? const NativeLibraryService(),
        _database = database ?? LibraryDatabase.instance;

  final LibraryService _service;
  final LibraryDatabase _database;

  @override
  Future<List<Song>> getSongs() => getCachedSongs();

  @override
  Future<List<Song>> getCachedSongs() async {
    try {
      final songs = await _database.getSongs();
      Log.library('Biblioteca SQLite cargada: ${songs.length} canciones');
      return songs;
    } catch (e) {
      Log.library('Error leyendo biblioteca SQLite: $e');
      rethrow;
    }
  }

  @override
  Future<List<Song>> refreshSongs() async {
    final rawSongs = await _service.scan();

    final songs = rawSongs
        .map(Song.fromMap)
        .where((song) => song.id.isNotEmpty)
        .toList(growable: false);

    await _database.replaceSongs(songs);

    Log.library('Biblioteca SQLite sincronizada: ${songs.length} canciones');

    return _database.getSongs();
  }
}

class DriveLibraryRepository implements LibraryRepository {
  const DriveLibraryRepository();

  @override
  Future<List<Song>> getSongs() async => const [];

  @override
  Future<List<Song>> getCachedSongs() async => const [];

  @override
  Future<List<Song>> refreshSongs() async => const [];
}

class FusionLibraryRepository implements LibraryRepository {
  const FusionLibraryRepository({
    required LibraryRepository localRepository,
    required LibraryRepository driveRepository,
  })  : _localRepository = localRepository,
        _driveRepository = driveRepository;

  final LibraryRepository _localRepository;
  final LibraryRepository _driveRepository;

  List<Song> _merge(List<Song> local, List<Song> drive) {
    final byId = <String, Song>{};

    for (final song in [...local, ...drive]) {
      byId.putIfAbsent(song.id, () => song);
    }

    return byId.values.toList(growable: false);
  }

  @override
  Future<List<Song>> getSongs() async {
    return _merge(
      await _localRepository.getSongs(),
      await _driveRepository.getSongs(),
    );
  }

  @override
  Future<List<Song>> getCachedSongs() async {
    return _merge(
      await _localRepository.getCachedSongs(),
      await _driveRepository.getCachedSongs(),
    );
  }

  @override
  Future<List<Song>> refreshSongs() async {
    return _merge(
      await _localRepository.refreshSongs(),
      await _driveRepository.refreshSongs(),
    );
  }
}
