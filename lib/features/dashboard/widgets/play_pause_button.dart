// lib/widgets/tinted_background.dart
import 'package:flutter/material.dart';
import '../../../core/dashboard_layout.dart';
import '../../../core/log.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.color,
    required this.onTap,
  });

  final bool isPlaying;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        Log.library('[Dashboard] Tap en botón Play/Pause (estado actual isPlaying: $isPlaying)');
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey<bool>(isPlaying),
            size: DashboardLayout.playIconSize,
            color: color,
          ),
        ),
      ),
    );
  }
}
