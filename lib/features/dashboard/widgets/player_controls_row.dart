// lib/features/appearance/controllers/appearance_controller.dart
import 'package:flutter/material.dart';
import '../../../core/dashboard_layout.dart';
import '../../../core/strings/dashboard_strings.dart';
import '../../../data/play_mode.dart';
import 'icon_action_button.dart';
import 'play_pause_button.dart';

class PlayerControlsRow extends StatelessWidget {
  const PlayerControlsRow({
    super.key,
    required this.playMode,
    required this.isPlaying,
    required this.accent,
    required this.primaryColor,
    required this.mutedColor,
    required this.onCyclePlayMode,
    required this.onPrevious,
    required this.onNext,
    required this.onPlayPause,
    required this.onOpenAllSongs,
    this.onRewindStart,
    this.onRewindEnd,
    this.onFastForwardStart,
    this.onFastForwardEnd,
  });

  final PlayMode playMode;
  final bool isPlaying;
  final Color accent;
  final Color primaryColor;
  final Color mutedColor;
  final VoidCallback onCyclePlayMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenAllSongs;
  final VoidCallback? onRewindStart;
  final VoidCallback? onRewindEnd;
  final VoidCallback? onFastForwardStart;
  final VoidCallback? onFastForwardEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Slot(
          child: IconActionButton(
            icon: playMode.icon,
            color: playMode.isActive ? accent : mutedColor,
            tooltip: playMode.label,
            onTap: onCyclePlayMode,
            size: DashboardLayout.controlIconSize,
            actionName: 'Modo de Reproducción',
          ),
        ),
        _Slot(
          child: IconActionButton(
            icon: Icons.skip_previous_outlined,
            color: primaryColor,
            tooltip: DashboardStrings.previous,
            onTap: onPrevious,
            onLongPressStart: onRewindStart,
            onLongPressEnd: onRewindEnd,
            size: DashboardLayout.navIconSize,
            actionName: 'Pista Anterior / Rewind',
          ),
        ),
        _Slot(
          child: PlayPauseButton(
            isPlaying: isPlaying,
            color: primaryColor,
            onTap: onPlayPause,
          ),
        ),
        _Slot(
          child: IconActionButton(
            icon: Icons.skip_next_outlined,
            color: primaryColor,
            tooltip: DashboardStrings.next,
            onTap: onNext,
            onLongPressStart: onFastForwardStart,
            onLongPressEnd: onFastForwardEnd,
            size: DashboardLayout.navIconSize,
            actionName: 'Pista Siguiente / FastForward',
          ),
        ),
        _Slot(
          child: IconActionButton(
            icon: Icons.queue_music_outlined,
            color: mutedColor,
            tooltip: DashboardStrings.allSongs,
            onTap: onOpenAllSongs,
            size: DashboardLayout.controlIconSize,
            actionName: 'Abrir Todas las Canciones',
          ),
        ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Center(child: child));
  }
}
