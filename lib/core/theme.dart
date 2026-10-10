// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'palette.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentPressed,
    required this.iconActive,
    required this.iconMuted,
    required this.trackInactive,
    required this.danger,
    required this.success,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentPressed;
  final Color iconActive;
  final Color iconMuted;
  final Color trackInactive;
  final Color danger;
  final Color success;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? accentPressed,
    Color? iconActive,
    Color? iconMuted,
    Color? trackInactive,
    Color? danger,
    Color? success,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      iconActive: iconActive ?? this.iconActive,
      iconMuted: iconMuted ?? this.iconMuted,
      trackInactive: trackInactive ?? this.trackInactive,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      iconActive: Color.lerp(iconActive, other.iconActive, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      trackInactive: Color.lerp(trackInactive, other.trackInactive, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData dark = _buildDark();
  static ThemeData light = _buildLight();

  static const AppColors darkColors = AppColors(
    background: Palette.darkBackground,
    surface: Palette.darkSurface,
    textPrimary: Palette.darkTextPrimary,
    textSecondary: Palette.darkTextSecondary,
    accent: Palette.darkAccent,
    accentPressed: Palette.darkAccentPressed,
    iconActive: Palette.darkTextPrimary,
    iconMuted: Palette.darkTextSecondary,
    trackInactive: Color(0x26FFFFFF),
    danger: Palette.danger,
    success: Palette.success,
  );

  static const AppColors lightColors = AppColors(
    background: Palette.lightBackground,
    surface: Palette.lightSurface,
    textPrimary: Palette.lightTextPrimary,
    textSecondary: Palette.lightTextSecondary,
    accent: Palette.lightAccent,
    accentPressed: Palette.lightAccentPressed,
    iconActive: Palette.lightTextPrimary,
    iconMuted: Palette.lightTextSecondary,
    trackInactive: Color(0x1A000000),
    danger: Palette.danger,
    success: Palette.success,
  );

  static ThemeData _buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: darkColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: darkColors.background,
        primary: darkColors.accent,
        onPrimary: darkColors.background,
        secondary: darkColors.accent,
        onSecondary: darkColors.background,
        error: darkColors.danger,
      ),
      textTheme: _textTheme(darkColors.textPrimary, darkColors.textSecondary),
      iconTheme: IconThemeData(color: darkColors.iconMuted),
      dividerColor: darkColors.textSecondary.withValues(alpha: 0.1),
      extensions: <ThemeExtension<dynamic>>[darkColors],
    );
  }

  static ThemeData _buildLight() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: lightColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: lightColors.background,
        primary: lightColors.accent,
        onPrimary: lightColors.background,
        secondary: lightColors.accent,
        onSecondary: lightColors.background,
        error: lightColors.danger,
      ),
      textTheme: _textTheme(lightColors.textPrimary, lightColors.textSecondary),
      iconTheme: IconThemeData(color: lightColors.iconMuted),
      dividerColor: lightColors.textSecondary.withValues(alpha: 0.1),
      extensions: <ThemeExtension<dynamic>>[lightColors],
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      displayMedium: TextStyle(color: primary, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: primary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: primary),
      bodyMedium: TextStyle(color: primary),
      bodySmall: TextStyle(color: secondary),
      labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: secondary),
      labelSmall: TextStyle(color: secondary),
    );
  }
}
