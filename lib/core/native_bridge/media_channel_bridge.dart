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
      Log.native('Verificando decoder nativo para el archivo: $path');
      final result = await _channel.invokeMethod<bool>(
        'isAudioDecoderAvailable',
        {'path': path},
      );
      final isAvailable = result ?? false;
      Log.format('Decoder disponible para $path: $isAvailable');
      return isAvailable;
    } catch (e, stackTrace) {
      Log.error('Native', 'Error al comprobar decoder nativo para $path', e);
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
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
