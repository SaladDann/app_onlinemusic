// lib/features/permissions/screens/permission_screen.dart
import 'package:flutter/material.dart';
import 'package:offline_music/core/log.dart';
import 'package:offline_music/core/strings/access_strings.dart';
import 'package:offline_music/core/theme.dart';
import 'package:offline_music/data/permissions/media_permission_gateway.dart';
import 'package:offline_music/features/dashboard/controllers/dashboard_controller.dart';
import 'package:offline_music/features/dashboard/screens/dashboard_screen.dart';
import '../controllers/access_controller.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({
    super.key,
    required this.dashboardController,
  });

  final DashboardController dashboardController;

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late final AccessController _controller;

  @override
  void initState() {
    super.initState();
    Log.library('Pantalla de permisos inicializada');
    _controller = AccessController(
      gateway: const MediaPermissionGateway(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRequest() async {
    final success = await _controller.requestAndProcessAccess();

    if (!mounted || !success) return;

    // Obtenemos el conteo real de pistas escaneadas por el controlador de acceso
    final scannedCount = _controller.scannedCount;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DashboardScreen(
          dashboardController: widget.dashboardController,
          scannedSongsCount: scannedCount,
          decoderStatus: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _BrandHeader(),
                const SizedBox(height: 64),
                _IconBadge(
                  color: colors.accent,
                  isProcessing: _controller.isProcessingBackground,
                ),
                const SizedBox(height: 32),
                Text(
                  _controller.isProcessingBackground
                      ? 'Optimizando Biblioteca'
                      : AccessStrings.title,
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  _controller.isProcessingBackground
                      ? '${_controller.processingMessage}\n(Pistas encontradas: ${_controller.scannedCount})'
                      : AccessStrings.description,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (_controller.wasDenied) ...[
                  const SizedBox(height: 20),
                  Text(
                    AccessStrings.denied,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                      color: colors.danger,
                    ),
                  ),
                ],
                const Spacer(),
                if (!_controller.isProcessingBackground)
                  _PrimaryButton(
                    label: _controller.wasDenied
                        ? AccessStrings.ctaRetry
                        : AccessStrings.ctaInitial,
                    isLoading: _controller.isRequesting,
                    accent: colors.accent,
                    onPressed: _onRequest,
                  )
                else
                  const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Text(
      AccessStrings.brand,
      style: TextStyle(
        fontSize: 26,
        letterSpacing: 8,
        fontWeight: FontWeight.w300,
        color: colors.accent,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.color, required this.isProcessing});

  final Color color;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isProcessing ? Icons.hourglass_top_rounded : Icons.library_music_rounded,
        size: 40,
        color: color,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.accent,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final Color accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Text(label),
      ),
    );
  }
}
