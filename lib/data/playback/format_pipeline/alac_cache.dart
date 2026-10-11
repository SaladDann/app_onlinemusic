// ignore_for_file: avoid_slow_async_io
// lib/data/playback/format_pipeline/alac_cache.dart
import 'dart:io';
import '../../../core/log.dart';

class AlacCache {
  AlacCache({
    String? baseDirectoryPath,
    int maxCacheBytes = _defaultMaxCacheBytes,
    int minimumValidWavBytes = _defaultMinimumValidWavBytes,
  }) : _baseDirectoryPath = baseDirectoryPath,
       _maxCacheBytes = maxCacheBytes,
       _minimumValidWavBytes = minimumValidWavBytes;

  static const String cacheDirectoryName = 'offline_music_alac';
  static const int _defaultMaxCacheBytes = 256 * 1024 * 1024;
  static const int _defaultMinimumValidWavBytes = 44;

  final String? _baseDirectoryPath;
  final int _maxCacheBytes;
  final int _minimumValidWavBytes;

  final Set<String> _protectedPaths = <String>{};

  Directory get cacheDirectory {
    final basePath = _baseDirectoryPath ?? Directory.systemTemp.path;
    return Directory('$basePath/$cacheDirectoryName');
  }

  String get cacheDirectoryPath => cacheDirectory.path;
  int get maxCacheBytes => _maxCacheBytes;
  int get minimumValidWavBytes => _minimumValidWavBytes;
  int get protectedPathCount => _protectedPaths.length;
  Set<String> get protectedPaths => Set<String>.unmodifiable(_protectedPaths);

  Future<Directory> ensureCacheDirectory() async {
    final directory = cacheDirectory;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      Log.format('Directorio de cache creado: ${directory.path}');
    }
    return directory;
  }

  Future<String> getCachePathForSong(String songId, String inputPath) async {
    final directory = await ensureCacheDirectory();
    return _buildCachePath(directory.path, songId, inputPath);
  }

  String getCachePathForSongSync(String songId, String inputPath) {
    return _buildCachePath(cacheDirectory.path, songId, inputPath);
  }

  String _buildCachePath(String directoryPath, String songId, String inputPath) {
    final rawId = songId.trim().isNotEmpty
        ? songId.trim()
        : inputPath.hashCode.abs().toString();
    final safeId = rawId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '$directoryPath/alac_$safeId.wav';
  }

  Future<bool> isValidWavFile(File file) async {
    try {
      if (!await file.exists()) return false;
      final length = await file.length();
      return length > _minimumValidWavBytes;
    } catch (e) {
      Log.format('No se pudo validar ${file.path}: $e');
      return false;
    }
  }

  Future<bool> isValidWavPath(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return false;
    return isValidWavFile(File(normalized));
  }

  Future<bool> containsValidWav(String path, {bool deleteInvalid = true}) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return false;

    final file = File(normalized);
    if (!await file.exists()) return false;

    if (await isValidWavFile(file)) return true;

    Log.format('WAV invalido detectado: $normalized');
    if (deleteInvalid && !_isProtectedPath(normalized)) {
      try {
        await file.delete();
        Log.format('WAV invalido eliminado');
      } catch (e) {
        Log.format('No se pudo eliminar WAV invalido: $e');
      }
    }
    return false;
  }

  Future<int?> getFileSize(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return null;

    try {
      final file = File(normalized);
      if (!await file.exists()) return null;
      return await file.length();
    } catch (e) {
      Log.format('No se pudo obtener tamano de $normalized: $e');
      return null;
    }
  }

  void protectPath(String? path) {
    final normalized = _normalizePath(path);
    if (normalized.isEmpty) return;
    _protectedPaths.add(normalized);
  }

  void unprotectPath(String? path) {
    final normalized = _normalizePath(path);
    if (normalized.isEmpty) return;
    _protectedPaths.remove(normalized);
  }

  Future<void> cleanup({Iterable<String> additionalProtectedPaths = const <String>[]}) async {
    try {
      final directory = await ensureCacheDirectory();
      final temporary = additionalProtectedPaths
          .map(_normalizePath)
          .where((path) => path.isNotEmpty)
          .toSet();

      final wavFiles = await _getWavFiles(directory);
      if (wavFiles.isEmpty) return;

      final validFiles = <File>[];
      var totalBytes = 0;

      for (final file in wavFiles) {
        try {
          final length = await file.length();
          if (length <= _minimumValidWavBytes) {
            final protected = _isProtectedPath(file.path) || temporary.contains(_normalizePath(file.path));
            if (protected) continue;
            await file.delete();
            continue;
          }
          validFiles.add(file);
          totalBytes += length;
        } catch (_) {}
      }

      if (validFiles.isEmpty || totalBytes <= _maxCacheBytes) return;

      validFiles.sort((a, b) => _safeLastModified(a).compareTo(_safeLastModified(b)));

      for (final file in validFiles) {
        if (totalBytes <= _maxCacheBytes) break;
        final normalized = _normalizePath(file.path);
        if (_isProtectedPath(normalized) || temporary.contains(normalized)) continue;

        try {
          final length = await file.length();
          await file.delete();
          totalBytes -= length;
        } catch (_) {}
      }
    } catch (e) {
      Log.format('Error limpiando cache ALAC: $e');
    }
  }

  Future<List<File>> _getWavFiles(Directory directory) async {
    final wavFiles = <File>[];
    final entities = await directory.list(followLinks: false).toList();
    for (final entity in entities) {
      if (entity is File && entity.path.toLowerCase().endsWith('.wav')) {
        wavFiles.add(entity);
      }
    }
    return wavFiles;
  }

  bool _isProtectedPath(String path) {
    final normalized = _normalizePath(path);
    if (normalized.isEmpty) return false;
    return _protectedPaths.contains(normalized);
  }

  String _normalizePath(String? path) => path?.trim().toLowerCase() ?? '';

  DateTime _safeLastModified(File file) {
    try {
      return file.lastModifiedSync();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
