// lib/core/palette.dart
import 'package:flutter/material.dart';

class Palette {
  const Palette._();

  // Modo oscuro
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF16161D);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkAccent = Color(0xFF6B7FA8);
  static const Color darkAccentPressed = Color(0xFF7E91B8);

  // Modo claro
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightAccent = Color(0xFF4A6FA5);
  static const Color lightAccentPressed = Color(0xFF5A7FB5);

  // Compartidos
  static const Color danger = Color(0xFFE57373);
  static const Color dangerPressed = Color(0xFFC62828);
  static const Color success = Color(0xFF81C784);
  static const Color successPressed = Color(0xFF2E7D32);
  static const Color trackInactive = Color(0x26FFFFFF);
}
