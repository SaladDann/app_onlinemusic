// lib/services/artwork_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:offline_music/core/log.dart';

import '../data/song.dart';

class ArtworkService {
  static const MethodChannel _channel =
      MethodChannel('offline_music/media');

  /// Método principal para obtener la ruta de la carátula a partir de un objeto Song.
  Future<String?> getArtworkPath(Song song) async {
    final path = song.data?.trim() ?? '';
    if (path.isEmpty) return null;

    try {
      final result = await _channel
          .invokeMethod<String>(
            'getAudioArtwork',
            {'path': path},
          )
          .timeout(const Duration(seconds: 2));

      if (result == null || result.isEmpty) return null;
      if (!File(result).existsSync()) return null;

      return result;
    } on TimeoutException {
      Log.artwork('Timeout extrayendo artwork para ${song.fileName}');
      return null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Método de compatibilidad auxiliar por si se invoca con ID o directamente como getArtwork
  Future<String?> getArtwork(dynamic songOrId) async {
    if (songOrId is Song) {
      return getArtworkPath(songOrId);
    }
    // Si se pasa un ID o string plano, se maneja de forma segura o se retorna nulo si requiere el objeto Song completo
    return null;
  }

  Future<Color?> extractDominantColor(String path) async {
    ui.Codec? codec;
    ui.Image? image;

    try {
      final bytes = await File(path).readAsBytes();
      if (bytes.isEmpty) return null;

      codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 48,
        targetHeight: 48,
      );

      final frame = await codec.getNextFrame();
      image = frame.image;

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) return null;
      return _findDominantColor(byteData, image.width, image.height);
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  Color? _findDominantColor(
    ByteData pixels,
    int width,
    int height,
  ) {
    final histogram = <int, int>{};

    for (var i = 0; i < width * height; i++) {
      final offset = i * 4;
      final r = pixels.getUint8(offset);
      final g = pixels.getUint8(offset + 1);
      final b = pixels.getUint8(offset + 2);
      final a = pixels.getUint8(offset + 3);

      if (a < 180) continue;

      final maxChannel = [r, g, b].reduce((x, y) => x > y ? x : y);
      final minChannel = [r, g, b].reduce((x, y) => x < y ? x : y);

      if (maxChannel < 35 || minChannel > 235) continue;

      final key = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);
      histogram[key] = (histogram[key] ?? 0) + 1;
    }

    if (histogram.isEmpty) return null;

    final dominant = histogram.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    final r = ((dominant.key >> 8) & 0xF) * 16 + 8;
    final g = ((dominant.key >> 4) & 0xF) * 16 + 8;
    final b = (dominant.key & 0xF) * 16 + 8;

    return Color.fromARGB(255, r, g, b);
  }
}
