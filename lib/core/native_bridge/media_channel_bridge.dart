// lib/core/native_bridge/media_channel_bridge.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../log.dart';

class MediaChannelBridge {
  const MediaChannelBridge();

  // Debe coincidir estrictamente con MediaConstants.CHANNEL en Kotlin
  static const MethodChannel _channel = MethodChannel('offline_music/media');

  /// Comprueba mediante MediaCodec si el dispositivo soporta el decoder del archivo
  Future<bool> isDecoderAvailable(String path) async {
    try {
      final result = await _channel.invokeMethod<dynamic>(
        'isAudioDecoderAvailable',
        <String, dynamic>{'path': path},
      );

      if (result is bool) return result;
      if (result is Map) {
        final available = result['available'] ?? result['isAvailable'];
        if (available is bool) return available;
      }
      return false;
    } catch (e) {
      Log.native('Error al comprobar decoder nativo para $path: $e');
      return false;
    }
  }

  /// Ejecuta el escaneo nativo de la biblioteca multimedia (MediaStore)
  Future<List<Map<String, dynamic>>> scanLibrary() async {
    try {
      Log.library('Solicitando escaneo nativo de canciones al sistema...');
      final result = await _channel.invokeMethod<List<Object?>>('scan');

      if (result == null) {
        Log.warn('Library', 'El escaneo nativo retornó una lista nula.');
        return [];
      }

      final songs = result
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      Log.library('Escaneo nativo completado. Se encontraron ${songs.length} pistas.');
      return songs;
    } catch (e, stackTrace) {
      Log.error('Library', 'Error crítico durante el escaneo nativo de la biblioteca', e);
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      return [];
    }
  }
}
