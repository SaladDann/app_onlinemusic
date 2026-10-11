// lib/widgets/tinted_background.dart
import 'package:flutter/material.dart';
import '../../../core/dashboard_layout.dart';
import '../../../core/log.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.tooltip,
    this.size = DashboardLayout.controlIconSize,
    this.padding = 10,
    this.actionName = 'Acción',
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final String? tooltip;
  final double size;
  final double padding;
  final String actionName;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onLongPressStart: onLongPressStart != null
          ? (_) {
              Log.library('[Dashboard] LongPress start en $actionName');
              onLongPressStart!();
            }
          : null,
      onLongPressEnd: onLongPressEnd != null
          ? (_) {
              Log.library('[Dashboard] LongPress end en $actionName');
              onLongPressEnd!();
            }
          : null,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Log.library('[Dashboard] Tap en botón: $actionName');
          onTap?.call();
        },
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}
