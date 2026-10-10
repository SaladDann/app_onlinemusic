// lib/features/splash/controllers/splash_controller.dart
import '../../../../core/log.dart';
import '../../../../core/native_bridge/media_channel_bridge.dart';

class SplashDiagnosticResult {
  const SplashDiagnosticResult({
    required this.decoderAvailable,
    required this.scannedSongsCount,
    required this.strategyUsed,
  });

  final bool decoderAvailable;
  final int scannedSongsCount;
  final String strategyUsed;
}

class SplashController {
  const SplashController({
    MediaChannelBridge? mediaBridge,
  }) : _mediaBridge = mediaBridge ?? const MediaChannelBridge();

  final MediaChannelBridge _mediaBridge;

  Future<SplashDiagnosticResult> initializeApp() async {
    Log.splash('Iniciando diagnóstico real del dispositivo y decoders...');

    // 1. Escaneo nativo de la biblioteca local (MediaStore)
    final songs = await _mediaBridge.scanLibrary();
    final hasSongs = songs.isNotEmpty;

    // 2. Determinar estrategia de reproducción según el entorno
    final strategy = hasSongs
        ? 'Estrategia nativa Media3 / ExoPlayer directa'
        : 'Biblioteca local vacía - Modo espera / Sincronización';

    // 3. Comprobar disponibilidad de decoder en la primera pista disponible (si existe)
    bool decoderOk = false;
    if (hasSongs) {
      final firstPath = songs.first['data'] as String? ?? '';
      if (firstPath.isNotEmpty) {
        decoderOk = await _mediaBridge.isDecoderAvailable(firstPath);
      }
    } else {
      decoderOk = true; // Por defecto válido si no hay archivos que decodificar aún
    }

    Log.splash('Diagnóstico completado. Canciones: ${songs.length}, Decoder OK: $decoderOk');

    return SplashDiagnosticResult(
      decoderAvailable: decoderOk,
      scannedSongsCount: songs.length,
      strategyUsed: strategy,
    );
  }
}
