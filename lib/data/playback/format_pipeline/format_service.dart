// lib/data/playback/format_pipeline/format_service.dart
import 'package:flutter/services.dart';
import '../../../core/log.dart';
import '../../song.dart';

class FormatInfo {
  const FormatInfo({
    required this.mimeType,
    required this.isAlac,
    required this.nativeDecoderAvailable,
  });

  final String mimeType;
  final bool isAlac;
  final bool nativeDecoderAvailable;

  bool get canPlayNatively => nativeDecoderAvailable;
  bool get canAttemptDirectPlayback => true;
}

class FormatService {
  FormatService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'offline_music/media';
  final MethodChannel _channel;

  final Map<String, String> _realMimeCache = <String, String>{};
  final Map<String, bool> _decoderCapabilityCache = <String, bool>{};

  bool _deviceCapabilitiesInitialized = false;
  Future<void>? _deviceCapabilitiesInitialization;

  bool get deviceCapabilitiesInitialized => _deviceCapabilitiesInitialized;

  Future<void> initializeDeviceCapabilities({
    required List<Song> probeSongs,
  }) async {
    if (_deviceCapabilitiesInitialized) return;

    final existing = _deviceCapabilitiesInitialization;
    if (existing != null) {
      await existing;
      return;
    }

    final initialization = _initializeDeviceCapabilities(probeSongs);
    _deviceCapabilitiesInitialization = initialization;

    try {
      await initialization;
    } finally {
      if (identical(_deviceCapabilitiesInitialization, initialization)) {
        _deviceCapabilitiesInitialization = null;
      }
    }
  }

  Future<void> _initializeDeviceCapabilities(List<Song> probeSongs) async {
    if (_deviceCapabilitiesInitialized) return;
    Log.format('Inicializando capacidades de decodificación');

    if (probeSongs.isEmpty) {
      _deviceCapabilitiesInitialized = true;
      return;
    }

    try {
      final candidates = <String, Song>{};
      for (final song in probeSongs) {
        final extension = _fileExtension(song.fileName);
        if (extension == 'm4a' || extension == 'mp4') {
          final mime = await getRealMimeType(song);
          if (mime.isNotEmpty) {
            candidates.putIfAbsent(mime, () => song);
          }
          continue;
        }
        final extensionMime = _mimeTypeFromFileName(song.fileName);
        if (extensionMime.isNotEmpty) {
          candidates.putIfAbsent(extensionMime, () => song);
        }
      }

      for (final entry in candidates.entries) {
        final mimeType = _normalizeMimeType(entry.key);
        if (mimeType.isEmpty || _decoderCapabilityCache.containsKey(mimeType)) {
          continue;
        }
        await _probeDecoder(entry.value, expectedMimeType: mimeType);
      }
      Log.format('Capacidades de decodificación inicializadas');
    } catch (e, stackTrace) {
      Log.format('Error inicializando capacidades: $e');
      Log.format('Stacktrace: $stackTrace');
    } finally {
      _deviceCapabilitiesInitialized = true;
    }
  }

  Future<bool> _probeDecoder(Song song, {required String expectedMimeType}) async {
    final mimeType = _normalizeMimeType(expectedMimeType);
    if (mimeType.isEmpty) return false;

    final cached = _decoderCapabilityCache[mimeType];
    if (cached != null) return cached;

    final physicalPath = _getPhysicalPath(song);
    if (physicalPath.isEmpty) return false;

    try {
      final nativeResult = await _channel.invokeMethod<dynamic>(
        'isAudioDecoderAvailable',
        <String, dynamic>{'path': physicalPath},
      );
      final available = _extractDecoderAvailability(nativeResult);
      _decoderCapabilityCache[mimeType] = available;
      return available;
    } catch (e) {
      _decoderCapabilityCache[mimeType] = false;
      return false;
    }
  }

  Future<String> getRealMimeType(Song song) async {
    final id = song.id.trim();
    final cacheKey = id.isNotEmpty ? id : _songKeyData(song);

    if (cacheKey.isNotEmpty && _realMimeCache.containsKey(cacheKey)) {
      return _realMimeCache[cacheKey]!;
    }

    final physicalPath = _getPhysicalPath(song);
    if (physicalPath.isNotEmpty) {
      try {
        final nativeMime = _extractMimeType(
          await _channel.invokeMethod<dynamic>(
            'getAudioMimeType',
            <String, dynamic>{'path': physicalPath},
          ),
        );
        if (_isSpecificAudioMimeType(nativeMime)) {
          _cacheRealMime(cacheKey, nativeMime);
          return nativeMime;
        }
      } catch (_) {}
    }

    final declaredMime = _normalizeMimeType(song.mimeType);
    if (_isSpecificAudioMimeType(declaredMime)) {
      _cacheRealMime(cacheKey, declaredMime);
      return declaredMime;
    }

    final extensionMime = _mimeTypeFromFileName(song.fileName);
    final fallback = extensionMime.isNotEmpty ? extensionMime : 'audio/mpeg';
    _cacheRealMime(cacheKey, fallback);
    return fallback;
  }

  bool isAlacMimeType(String? mimeType) {
    final normalized = _normalizeMimeType(mimeType);
    return normalized.contains('alac') ||
        normalized == 'audio/quicktime' ||
        normalized == 'audio/alac' ||
        normalized == 'audio/x-alac' ||
        normalized == 'audio/alac-lossless';
  }

  Future<bool> isAlac(Song song) async {
    return isAlacMimeType(await getRealMimeType(song));
  }

  Future<FormatInfo> analyze(Song song) async {
    final mimeType = await getRealMimeType(song);
    final alac = isAlacMimeType(mimeType);

    var nativeAvailable = _decoderCapabilityCache[mimeType] ?? false;
    if (!_decoderCapabilityCache.containsKey(mimeType)) {
      nativeAvailable = await _probeDecoder(song, expectedMimeType: mimeType);
    }

    return FormatInfo(
      mimeType: mimeType,
      isAlac: alac,
      nativeDecoderAvailable: nativeAvailable,
    );
  }

  void _cacheRealMime(String key, String mime) {
    if (key.isNotEmpty && mime.isNotEmpty) {
      _realMimeCache[key] = _normalizeMimeType(mime);
    }
  }

  String _getPhysicalPath(Song song) {
    final data = song.data?.trim() ?? '';
    if (data.isNotEmpty && !data.startsWith('content://')) {
      return _normalizePhysicalPath(data);
    }
    final uri = song.uri.trim();
    if (uri.isNotEmpty && !uri.startsWith('content://')) {
      return _normalizePhysicalPath(uri);
    }
    return '';
  }

  String _normalizePhysicalPath(String path) {
    if (!path.startsWith('file://')) return path;
    try {
      return Uri.parse(path).toFilePath();
    } catch (_) {
      return '';
    }
  }

  String _extractMimeType(dynamic result) => result is String ? _normalizeMimeType(result) : '';

  bool _extractDecoderAvailability(dynamic result) {
    if (result is bool) return result;
    if (result is Map) {
      final value = result['available'] ?? result['isAvailable'];
      if (value is bool) return value;
    }
    return false;
  }

  String _normalizeMimeType(String? mime) => mime?.trim().toLowerCase() ?? '';

  bool _isSpecificAudioMimeType(String mime) {
    return mime.startsWith('audio/') &&
        !<String>{'audio/*', 'audio/octet-stream'}.contains(mime);
  }

  String _fileExtension(String name) {
    final index = name.lastIndexOf('.');
    return index < 0 ? '' : name.substring(index + 1).toLowerCase();
  }

  String _mimeTypeFromFileName(String name) {
    switch (_fileExtension(name)) {
      case 'mp3': return 'audio/mpeg';
      case 'm4a':
      case 'mp4': return 'audio/mp4';
      case 'aac': return 'audio/aac';
      case 'wav': return 'audio/wav';
      case 'flac': return 'audio/flac';
      case 'ogg': return 'audio/ogg';
      case 'alac': return 'audio/alac';
      default: return '';
    }
  }

  String _songKeyData(Song song) {
    final data = song.data?.trim() ?? '';
    return data.isNotEmpty ? data : song.uri.trim();
  }
}
