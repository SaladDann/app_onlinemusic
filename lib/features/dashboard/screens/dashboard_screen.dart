// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:offline_music/core/theme.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.dashboardController,
    this.scannedSongsCount = 0,
    this.decoderStatus = true,
  });

  final DashboardController dashboardController;
  final int scannedSongsCount;
  final bool decoderStatus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Dashboard - Offline Music'),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido a tu Reproductor!',
              style: text.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'El precalentamiento y la indexación inicial se han completado con éxito.',
              style: text.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 32),
            Card(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        decoderStatus ? Icons.check_circle_rounded : Icons.warning_rounded,
                        color: decoderStatus ? Colors.green : Colors.orange,
                        size: 28,
                      ),
                      title: const Text('Estado de Decodificadores'),
                      subtitle: Text(
                        decoderStatus
                            ? 'Códecs nativos validados (MediaCodec / ExoPlayer)'
                            : 'Verificación parcial de códecs',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.library_music_rounded,
                        color: colors.accent,
                        size: 28,
                      ),
                      title: const Text('Biblioteca Local Indexada'),
                      subtitle: Text('$scannedSongsCount pistas de audio listas para reproducir'),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Próximamente: Controles de reproducción, listas y soporte para Google Drive.',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
