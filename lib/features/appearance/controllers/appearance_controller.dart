// lib/features/appearance/controllers/appearance_controller.dart
import 'package:flutter/material.dart';

enum AppearanceStyle { solid, frosted }

class AppearanceController extends ChangeNotifier {
  AppearanceStyle _style = AppearanceStyle.solid;
  Color? _artworkAccent;

  AppearanceStyle get style => _style;

  void setStyle(AppearanceStyle style) {
    _style = style;
    notifyListeners();
  }

  void setArtworkAccent(Color? color) {
    _artworkAccent = color;
    notifyListeners();
  }

  Color accentFor(bool isDark) {
    return _artworkAccent ?? (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5));
  }
}
