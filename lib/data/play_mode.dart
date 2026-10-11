// lib/data/play_mode.dart
import 'package:flutter/material.dart';

enum PlayMode {
  order(
    icon: Icons.repeat_outlined,
    label: 'En orden',
    isActive: false,
  ),
  repeatAll(
    icon: Icons.repeat_outlined,
    label: 'Repetir todo',
    isActive: true,
  ),
  repeatOne(
    icon: Icons.repeat_one_outlined,
    label: 'Repetir una',
    isActive: true,
  ),
  shuffle(
    icon: Icons.shuffle_outlined,
    label: 'Aleatorio',
    isActive: true,
  );

  const PlayMode({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  PlayMode get next => PlayMode.values[(index + 1) % PlayMode.values.length];
}
