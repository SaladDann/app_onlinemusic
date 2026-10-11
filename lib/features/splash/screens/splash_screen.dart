// lib/features/splash/screens/splash_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:offline_music/data/library_repository.dart';
import 'package:offline_music/features/dashboard/controllers/dashboard_controller.dart';
import 'package:offline_music/features/dashboard/controllers/library_controller.dart';
import 'package:offline_music/features/dashboard/screens/dashboard_screen.dart';
import 'package:offline_music/features/permissions/screens/permission_screen.dart';

import '../../../../core/log.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _pulseDuration = Duration(milliseconds: 1500);
  static const Color _pulseStart = Color(0xFF4A5C7A);
  static const Color _pulseEnd = Color(0xFFFFFFFF);

  final SplashController _controller = const SplashController();
  late final AnimationController _pulse;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: _pulseDuration,
    )..repeat(reverse: true);

    _color = ColorTween(
      begin: _pulseStart,
      end: _pulseEnd,
    ).animate(
      CurvedAnimation(
        parent: _pulse,
        curve: Curves.easeInOut,
      ),
    );

    Log.splash('Splash visual iniciado con control de persistencia');
    unawaited(_runStartupSequence());
  }

  Future<void> _runStartupSequence() async {
    // Evaluamos si ya existen permisos y datos en caché
    final diagnosticResult = await _controller.initializeApp();
    if (!mounted) return;

    // Instanciamos los repositorios y el LibraryController requerido por el DashboardController
    final localRepo = LocalLibraryRepository();
    const driveRepo = DriveLibraryRepository();
    final fusionRepo = FusionLibraryRepository(
      localRepository: localRepo,
      driveRepository: driveRepo,
    );

    final libraryController = LibraryController(
      localRepository: localRepo,
      driveRepository: driveRepo,
      fusionRepository: fusionRepo,
    );

    final dashboardController = DashboardController(
      libraryController: libraryController,
    );

    // Dependiendo del resultado, decidimos a dónde navegar
    if (diagnosticResult.destination == StartupDestination.dashboard) {
      Log.splash('Redirigiendo directamente al Dashboard (Permisos ya concedidos).');
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DashboardScreen(
            dashboardController: dashboardController,
            scannedSongsCount: diagnosticResult.scannedSongsCount,
            decoderStatus: diagnosticResult.decoderAvailable,
          ),
        ),
      );
    } else {
      Log.splash('Redirigiendo a la pantalla de Permisos.');
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PermissionScreen(
            dashboardController: dashboardController,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _color,
          builder: (_, __) {
            return SvgPicture.asset(
              'assets/logo/app_logo.svg',
              width: 160,
              height: 160,
              colorFilter: ColorFilter.mode(
                _color.value ?? _pulseStart,
                BlendMode.srcIn,
              ),
            );
          },
        ),
      ),
    );
  }
}
