// lib/app.dart
import 'package:flutter/material.dart';
import 'core/appearance_scope.dart';
import 'core/theme.dart';
import 'features/appearance/controllers/appearance_controller.dart';
import 'features/splash/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appearanceController = AppearanceController();

    return AppearanceScope(
      controller: appearanceController,
      child: AnimatedBuilder(
        animation: appearanceController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Offline Music',
            debugShowCheckedModeBanner: false,

            // Tema Claro
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4F46E5),
                brightness: Brightness.light,
              ),
              extensions: const [
                AppColors(
                  background: Color(0xFFFAFAFA),
                  surface: Colors.white,
                  textPrimary: Color(0xFF1A1A1A),
                  textSecondary: Color(0xFF6B6B6B),
                  accent: Color(0xFF4F46E5),
                  accentPressed: Color(0xFF4338CA),
                  iconActive: Color(0xFF4F46E5),
                  iconMuted: Color(0xFF9CA3AF),
                  success: Color(0xFF10B981),
                  danger: Colors.redAccent,
                  trackInactive: Color(0xFFE5E7EB),
                ),
              ],
            ),

            // Tema Oscuro
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0A0A0F),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.dark,
              ),
              extensions: const [
                AppColors(
                  background: Color(0xFF0A0A0F),
                  surface: Color(0xFF16161D),
                  textPrimary: Colors.white,
                  textSecondary: Colors.white70,
                  accent: Color(0xFF6366F1),
                  accentPressed: Color(0xFF4F46E5),
                  iconActive: Color(0xFF6366F1),
                  iconMuted: Color(0xFF6B7280),
                  success: Color(0xFF34D399),
                  danger: Color(0xFFEF4444),
                  trackInactive: Color(0xFF27272A),
                ),
              ],
            ),

            // Detección automática del tema del sistema operativo
            themeMode: ThemeMode.system,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
