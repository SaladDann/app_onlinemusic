// lib/app.dart
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/splash/screens/splash_screen.dart';

class OfflineMusicApp extends StatelessWidget {
  const OfflineMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
