// lib/features/splash/screens/diagnostic_preview_screen.dart
import 'package:flutter/material.dart';
import '../controllers/splash_controller.dart';

class DiagnosticPreviewScreen extends StatelessWidget {
  const DiagnosticPreviewScreen({
    super.key,
    required this.result,
  });

  final SplashDiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico del Dispositivo (Previo)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultados del Arranque y Decoders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        result.decoderAvailable ? Icons.check_circle : Icons.error,
                        color: result.decoderAvailable ? Colors.green : Colors.red,
                      ),
                      title: const Text('Disponibilidad de Decoders'),
                      subtitle: Text(
                        result.decoderAvailable
                            ? 'Soportado correctamente por MediaCodec'
                            : 'Limitado o no disponible',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text('Canciones Locales Encontradas'),
                      subtitle: Text('${result.scannedSongsCount} pistas indexadas'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings_suggest),
                      title: const Text('Estrategia de Reproducción'),
                      subtitle: Text(result.strategyUsed),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Nota: Esta pantalla es un visor temporal de diagnóstico para validar el flujo del Splash antes de implementar el Dashboard definitivo.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
