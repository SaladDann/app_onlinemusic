// lib/widgets/tinted_background.dart
import 'package:flutter/material.dart';
import '../../../core/strings/dashboard_strings.dart';
import 'icon_action_button.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.iconColor,
    this.onSettings,
    this.onSearch,
  });

  final Color iconColor;
  final VoidCallback? onSettings;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconActionButton(
          icon: Icons.settings_outlined,
          color: iconColor,
          tooltip: DashboardStrings.settings,
          onTap: onSettings,
          size: 20,
          actionName: 'Ajustes de Apariencia',
        ),
        IconActionButton(
          icon: Icons.search_rounded,
          color: iconColor,
          tooltip: DashboardStrings.search,
          onTap: onSearch,
          size: 20,
          actionName: 'Búsqueda Global',
        ),
      ],
    );
  }
}
