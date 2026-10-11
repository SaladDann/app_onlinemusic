// lib/data/playback/format_pipeline/preloader.dart
import 'dart:async';
import '../../song.dart';
import 'format_service.dart';

class Preloader {
  Preloader({FormatService? formatService})
      : _formatService = formatService ?? FormatService();

  static const int defaultLookAheadSongs = 5;
  static const int defaultMaxAlacPreloads = 2;

  static const Set<String> _nonAlacExtensions = <String>{
    'mp3', 'flac', 'wav', 'wave', 'ogg', 'oga', 'opus', 'aac', 'amr', '3gp', 'aiff', 'aif', 'webm',
  };

  final FormatService _formatService;
  final Map<String, bool> _alacDetectionCache = <String, bool>{};

  bool _isDisposed = false;
  Future<void>? _upcomingPreloadInFlight;

  bool get isDisposed => _isDisposed;
  bool get isUpcomingPreloadRunning => _upcomingPreloadInFlight != null;

  void scheduleUpcomingAlacPreload({
    required List<Song> upcomingSongs,
    int maxSongsToInspect = defaultLookAheadSongs,
    int maxAlacToPreload = defaultMaxAlacPreloads,
  }) {
    if (_isDisposed || upcomingSongs.isEmpty) return;
    if (_upcomingPreloadInFlight != null) return;

    final future = _inspectUpcomingSongs(
      songs: upcomingSongs,
      maxSongsToInspect: maxSongsToInspect.clamp(1, upcomingSongs.length),
      maxAlacToPreload: maxAlacToPreload.clamp(1, upcomingSongs.length),
    );

    _upcomingPreloadInFlight = future;
    unawaited(future.whenComplete(() {
      if (identical(_upcomingPreloadInFlight, future)) {
        _upcomingPreloadInFlight = null;
      }
    }));
  }

  Future<void> _inspectUpcomingSongs({
    required List<Song> songs,
    required int maxSongsToInspect,
    required int maxAlacToPreload,
  }) async {
    if (_isDisposed) return;
    var inspected = 0;
    var alacFound = 0;

    try {
      for (final song in songs) {
        if (_isDisposed || inspected >= maxSongsToInspect || alacFound >= maxAlacToPreload) break;
        inspected++;

        if (await _isAlac(song)) {
          alacFound++;
        }
      }
    } catch (_) {}
  }

  Future<bool> _isAlac(Song song) async {
    if (_isDisposed) return false;
    final key = _songKey(song);
    if (_alacDetectionCache.containsKey(key)) return _alacDetectionCache[key]!;

    final extension = _fileExtension(song.fileName);
    if (_nonAlacExtensions.contains(extension)) {
      _alacDetectionCache[key] = false;
      return false;
    }

    try {
      final mimeType = await _formatService.getRealMimeType(song);
      if (_isDisposed) return false;
      final isAlac = _formatService.isAlacMimeType(mimeType);
      _alacDetectionCache[key] = isAlac;
      return isAlac;
    } catch (_) {
      if (!_isDisposed) _alacDetectionCache[key] = false;
      return false;
    }
  }

  String _fileExtension(String fileName) {
    final normalized = fileName.trim().toLowerCase();
    final dotIndex = normalized.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == normalized.length - 1) return '';
    return normalized.substring(dotIndex + 1);
  }

  String _songKey(Song song) {
    final id = song.id.trim();
    if (id.isNotEmpty) return id;
    final data = song.data?.trim();
    if (data != null && data.isNotEmpty) return data;
    return song.uri.trim();
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _upcomingPreloadInFlight = null;
    _alacDetectionCache.clear();
  }
}
