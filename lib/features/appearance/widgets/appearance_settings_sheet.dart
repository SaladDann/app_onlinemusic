// lib/features/appearance/widgets/appearance_settings_sheet.dart
import 'package:flutter/material.dart';
import '../controllers/appearance_controller.dart';

class AppearanceSettingsSheet extends StatelessWidget {
  const AppearanceSettingsSheet({
    super.key,
    required this.controller,
  });

  final AppearanceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajustes de Apariencia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Estilo de Fondo'),
            subtitle: Text(controller.style == AppearanceStyle.solid ? 'Sólido' : 'Difuminado (Frosted)'),
            trailing: Switch(
              value: controller.style == AppearanceStyle.frosted,
              onChanged: (value) {
                controller.setStyle(value ? AppearanceStyle.frosted : AppearanceStyle.solid);
              },
            ),
          ),
        ],
      ),
    );
  }
}
