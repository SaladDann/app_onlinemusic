// lib/data/playback/format_pipeline/alac_converter.dart
// ignore_for_file: avoid_slow_async_io
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:offline_music/data/playback/format_pipeline/alac_cache.dart';
import '../../../core/log.dart';
import '../../song.dart';

class AlacConverter {
  AlacConverter({AlacCache? cache}) : _cache = cache ?? AlacCache();

  static const MethodChannel _nativeChannel = MethodChannel('offline_music/media');
  final AlacCache _cache;
  final Map<String, Future<String?>> _inFlight = <String, Future<String?>>{};
  bool _isDisposed = false;

  int get inFlightConversionCount => _inFlight.length;
  bool get isDisposed => _isDisposed;

  Future<String?> getOrCreateWav(Song song, String inputPath) async {
    if (_isDisposed) return null;
    final normalizedInput = inputPath.trim();
    if (normalizedInput.isEmpty) return null;

    final inputFile = File(normalizedInput);
    if (!await inputFile.exists()) return null;

    final songId = song.id.trim();
    final key = songId.isNotEmpty ? songId : normalizedInput;

    final existing = _inFlight[key];
    if (existing != null) return existing;

    final future = _convertIfNecessary(song, normalizedInput);
    _inFlight[key] = future;

    try {
      return await future;
    } finally {
      if (identical(_inFlight[key], future)) {
        _inFlight.removeWhere((entryKey, _) => entryKey == key);
      }
    }
  }

  Future<String?> _convertIfNecessary(Song song, String inputPath) async {
    if (_isDisposed) return null;
    
    try {
      await _cache.ensureCacheDirectory();
      if (_isDisposed) return null;

      final outputPath = _cache.getCachePathForSongSync(song.id, inputPath);
      final outputFile = File(outputPath);

      if (await _cache.containsValidWav(outputPath)) {
        if (_isDisposed) return null;
        await _touchFile(outputFile);
        return outputPath;
      }

      if (await outputFile.exists()) {
        await _deleteIfExists(outputFile);
      }

      if (_isDisposed) return null;
      _cache.protectPath(outputPath);

      try {
        await _cache.cleanup(additionalProtectedPaths: <String>[outputPath]);
        if (_isDisposed) return null;

        final inputFile = File(inputPath);
        if (!await inputFile.exists()) return null;

        final convertedPath = await _nativeChannel.invokeMethod<String>(
          'convertAudioToWav',
          <String, String>{'path': inputPath, 'outputPath': outputPath},
        );

        if (_isDisposed || convertedPath == null || convertedPath.trim().isEmpty) {
          await _deleteIfExists(outputFile);
          return null;
        }

        if (!await outputFile.exists()) return null;
        final outputLength = await outputFile.length();

        if (outputLength <= _cache.minimumValidWavBytes) {
          await _deleteIfExists(outputFile);
          return null;
        }

        await _touchFile(outputFile);
        return outputPath;
      } finally {
        _cache.unprotectPath(outputPath);
      }
    } catch (e, stackTrace) {
      Log.format('Error durante conversión ALAC: $e');
      Log.format('Stacktrace: $stackTrace');
      return null;
    }
  }

  Future<void> _touchFile(File file) async {
    try {
      if (await file.exists()) {
        await file.setLastModified(DateTime.now());
      }
    } catch (_) {}
  }

  Future<void> _deleteIfExists(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _inFlight.clear();
  }
}
