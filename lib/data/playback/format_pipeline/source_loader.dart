// ignore_for_file: avoid_slow_async_io
// lib/data/playback/format_pipeline/source_loader.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/log.dart';
import '../../song.dart';
import 'alac_converter.dart';
import 'format_service.dart';

enum SourceType { native, alacWav, convertedWav }

class SourcePreparation {
  const SourcePreparation({
    required this.song,
    required this.sourceUri,
    required this.type,
    required this.mimeType,
    required this.nativeDecoderAvailable,
    required this.convertedWavPath,
  });

  final Song song;
  final Uri sourceUri;
  final SourceType type;
  final String? mimeType;
  final bool nativeDecoderAvailable;
  final String? convertedWavPath;

  bool get isNative => type == SourceType.native;
  bool get isAlacWav => type == SourceType.alacWav;
  bool get isConvertedWav => type == SourceType.convertedWav;
  bool get usesConvertedWav =>
      convertedWavPath != null && convertedWavPath!.isNotEmpty;

  @override
  String toString() {
    return 'SourcePreparation('
        'song: ${song.fileName}, '
        'type: $type, '
        'mimeType: $mimeType, '
        'nativeDecoderAvailable: $nativeDecoderAvailable, '
        'convertedWavPath: $convertedWavPath'
        ')';
  }
}

class SourceLoader {
  SourceLoader({
    FormatService? formatService,
    AlacConverter? alacConverter,
    MethodChannel? nativeChannel,
  })  : _formatService = formatService ?? FormatService(),
        _alacConverter = alacConverter ?? AlacConverter(),
        _nativeChannel =
            nativeChannel ?? const MethodChannel('offline_music/media');

  final FormatService _formatService;
  final AlacConverter _alacConverter;
  final MethodChannel _nativeChannel;

  bool _isDisposed = false;
  final Map<String, Future<String?>> _nativeWavInFlight =
      <String, Future<String?>>{};

  bool get isDisposed => _isDisposed;
  int get inFlightNativeWavConversions => _nativeWavInFlight.length;
  FormatService get formatService => _formatService;

  Future<SourcePreparation?> prepareSource(Song song) async {
    if (_isDisposed) return null;

    try {
      final formatInfo = await _formatService.analyze(song);
      if (_isDisposed) return null;

      final normalSource = _createNormalPreparation(
        song,
        mimeType: formatInfo.mimeType,
        nativeDecoderAvailable: formatInfo.nativeDecoderAvailable,
      );

      if (normalSource != null) {
        Log.format('Fuente original preparada: ${song.fileName}');
        return normalSource;
      }

      Log.format('No se pudo preparar la fuente original: ${song.fileName}');

      if (formatInfo.isAlac || !formatInfo.nativeDecoderAvailable) {
        return await prepareFallbackSource(song, formatInfo: formatInfo);
      }

      return null;
    } catch (e, stackTrace) {
      Log.format('Error preparando fuente: $e');
      Log.format('Stacktrace: $stackTrace');
      return null;
    }
  }

  Future<SourcePreparation?> prepareFallbackSource(
    Song song, {
    FormatInfo? formatInfo,
  }) async {
    if (_isDisposed) return null;

    try {
      final info = formatInfo ?? await _formatService.analyze(song);
      if (_isDisposed) return null;

      if (info.isAlac) {
        return await prepareAlacSource(
          song,
          mimeType: info.mimeType,
          nativeDecoderAvailable: info.nativeDecoderAvailable,
        );
      }

      final physicalPath = _physicalPath(song);
      if (physicalPath == null || physicalPath.isEmpty) return null;

      final convertedPath = await _getOrCreateNativeWav(physicalPath);
      if (_isDisposed || convertedPath == null || convertedPath.isEmpty) {
        return null;
      }

      final wavFile = File(convertedPath);
      if (!await wavFile.exists() || await wavFile.length() <= 44) return null;

      return SourcePreparation(
        song: song,
        sourceUri: Uri.file(convertedPath),
        type: SourceType.convertedWav,
        mimeType: info.mimeType,
        nativeDecoderAvailable: info.nativeDecoderAvailable,
        convertedWavPath: convertedPath,
      );
    } catch (e, stackTrace) {
      Log.format('Error preparando fallback: $e');
      Log.format('Stacktrace: $stackTrace');
      return null;
    }
  }

  Future<SourcePreparation?> prepareAlacSource(
    Song song, {
    String? mimeType,
    bool nativeDecoderAvailable = false,
  }) async {
    if (_isDisposed) return null;

    try {
      final physicalPath = _physicalPath(song);
      if (physicalPath == null || physicalPath.isEmpty) return null;

      final outputPath = await _alacConverter.getOrCreateWav(song, physicalPath);
      if (_isDisposed || outputPath == null || outputPath.isEmpty) return null;

      final outputFile = File(outputPath);
      if (!await outputFile.exists() || await outputFile.length() <= 44) {
        return null;
      }

      return SourcePreparation(
        song: song,
        sourceUri: Uri.file(outputPath),
        type: SourceType.alacWav,
        mimeType: mimeType,
        nativeDecoderAvailable: nativeDecoderAvailable,
        convertedWavPath: outputPath,
      );
    } catch (e, stackTrace) {
      Log.format('Error procesando ALAC: $e');
      Log.format('Stacktrace: $stackTrace');
      return null;
    }
  }

  SourcePreparation? createNormalSource(
    Song song, {
    String? mimeType,
    bool nativeDecoderAvailable = true,
  }) {
    return _createNormalPreparation(
      song,
      mimeType: mimeType,
      nativeDecoderAvailable: nativeDecoderAvailable,
    );
  }

  SourcePreparation? _createNormalPreparation(
    Song song, {
    String? mimeType,
    required bool nativeDecoderAvailable,
  }) {
    if (_isDisposed) return null;

    final path = _songPath(song);
    if (path.isEmpty) return null;

    final normalizedPath = _normalizePlayablePath(path);
    if (normalizedPath == null || normalizedPath.isEmpty) return null;

    final uri = _buildSourceUri(normalizedPath);
    if (uri == null) return null;

    return SourcePreparation(
      song: song,
      sourceUri: uri,
      type: SourceType.native,
      mimeType: mimeType,
      nativeDecoderAvailable: nativeDecoderAvailable,
      convertedWavPath: null,
    );
  }

  Future<String?> _getOrCreateNativeWav(String inputPath) async {
    if (_isDisposed) return null;
    final normalizedPath = inputPath.trim();
    if (normalizedPath.isEmpty) return null;

    final existing = _nativeWavInFlight[normalizedPath];
    if (existing != null) return existing;

    final future = _convertAudioToWav(normalizedPath);
    _nativeWavInFlight[normalizedPath] = future;

    try {
      return await future;
    } finally {
      if (identical(_nativeWavInFlight[normalizedPath], future)) {
        await _nativeWavInFlight.remove(normalizedPath);
      }
    }
  }

  Future<String?> _convertAudioToWav(String inputPath) async {
    if (_isDisposed) return null;

    try {
      final result = await _nativeChannel.invokeMethod<String>(
        'convertAudioToWav',
        <String, dynamic>{'path': inputPath},
      );
      return result?.trim();
    } on PlatformException catch (e) {
      Log.format('Error de plataforma en conversión WAV: ${e.code}');
      return null;
    } catch (e, stackTrace) {
      Log.format('Error desconocido en conversión WAV: $e');
      Log.format('Stacktrace: $stackTrace');
      return null;
    }
  }

  String _songPath(Song song) {
    final data = song.data?.trim();
    if (data != null && data.isNotEmpty) return data;
    return song.uri.trim();
  }

  String? _physicalPath(Song song) {
    final data = song.data?.trim();
    if (data != null && data.isNotEmpty && !data.startsWith('content://')) {
      if (data.startsWith('file://')) {
        try {
          return Uri.parse(data).toFilePath();
        } catch (_) {
          return null;
        }
      }
      return data;
    }

    final uri = song.uri.trim();
    if (uri.isEmpty || uri.startsWith('content://')) return null;

    if (uri.startsWith('file://')) {
      try {
        return Uri.parse(uri).toFilePath();
      } catch (_) {
        return null;
      }
    }

    if (uri.startsWith('/')) return uri;
    return null;
  }

  String? _normalizePlayablePath(String path) {
    final normalized = path.trim();
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('file://')) {
      try {
        return Uri.parse(normalized).toFilePath();
      } catch (_) {
        return null;
      }
    }
    return normalized;
  }

  Uri? _buildSourceUri(String path) {
    try {
      if (path.startsWith('content://') || path.startsWith('file://')) {
        return Uri.parse(path);
      }
      return Uri.file(path);
    } catch (e) {
      Log.format('Error creando URI: $e');
      return null;
    }
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _nativeWavInFlight.clear();
  }
}
