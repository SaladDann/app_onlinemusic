// lib/services/library_service.dart
import 'package:flutter/services.dart';

import '../core/log.dart';

abstract interface class LibraryService {
  Future<List<Map<String, dynamic>>> scan();
}

class NativeLibraryService implements LibraryService {
  const NativeLibraryService();

  static const MethodChannel _channel =
      MethodChannel('offline_music/media');

  @override
  Future<List<Map<String, dynamic>>> scan() async {
    Log.library('Iniciando escaneo nativo');

    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('scan');

      if (raw == null) {
        throw StateError(
          'El escaneo nativo devolvió null; no se modificará la biblioteca.',
        );
      }

      final songs = <Map<String, dynamic>>[];

      for (final item in raw) {
        if (item is Map) {
          songs.add(Map<String, dynamic>.from(item));
        }
      }

      Log.library('Escaneo devolvió ${songs.length} canciones');
      return songs;
    } on PlatformException catch (e) {
      Log.library(
        'Error de plataforma en scan: ${e.code} ${e.message}',
      );
      rethrow;
    } catch (e) {
      Log.library('Error inesperado en scan: $e');
      rethrow;
    }
  }
}
