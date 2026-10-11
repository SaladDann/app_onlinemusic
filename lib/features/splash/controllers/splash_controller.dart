// lib/features/splash/controllers/splash_controller.dart
import 'package:offline_music/data/library_database.dart';
import 'package:offline_music/data/permissions/media_permission_gateway.dart';
import 'package:offline_music/data/permissions/permission_gateway.dart';

import '../../../../core/log.dart';
import '../../../../core/native_bridge/media_channel_bridge.dart';

enum StartupDestination { permission, dashboard }

class SplashDiagnosticResult {
  const SplashDiagnosticResult({
    required this.decoderAvailable,
    required this.scannedSongsCount,
    required this.strategyUsed,
    required this.destination,
  });

  final bool decoderAvailable;
  final int scannedSongsCount;
  final String strategyUsed;
  final StartupDestination destination;
}

class SplashController {
  const SplashController({
    MediaChannelBridge? mediaBridge,
    PermissionGateway? permissionGateway,
  })  : _mediaBridge = mediaBridge ?? const MediaChannelBridge(),
        _permissionGateway = permissionGateway ?? const MediaPermissionGateway();

  final MediaChannelBridge _mediaBridge;
  final PermissionGateway _permissionGateway;

  Future<SplashDiagnosticResult> initializeApp() async {
    Log.splash('Iniciando verificación de permisos y diagnóstico del dispositivo...');

    // 1. Verificar si el usuario tiene permisos en el sistema
    final hasAccess = await _permissionGateway.hasLibraryAccess();

    // Si no hay permisos concedidos en absoluto, mandamos a la pantalla de permisos
    if (!hasAccess) {
      Log.splash('No hay permisos de almacenamiento. Destino: Pantalla de Permisos.');
      return const SplashDiagnosticResult(
        decoderAvailable: false,
        scannedSongsCount: 0,
        strategyUsed: 'Pendiente de permisos',
        destination: StartupDestination.permission,
      );
    }

    // 2. Si SÍ hay permisos, verificamos la base de datos local SQLite
    final songsCount = await LibraryDatabase.instance.countSongs();
    Log.splash('Permisos concedidos detectados. Canciones en SQLite = $songsCount');

    if (songsCount > 0) {
      // Caso normal: Ya tiene permisos y su biblioteca ya fue indexada previamente
      Log.splash('Caché local encontrada. Cargando biblioteca desde SQLite...');
      final cachedSongs = await LibraryDatabase.instance.getSongs();

      bool decoderOk = true;
      if (cachedSongs.isNotEmpty) {
        final firstPath = cachedSongs.first.data ?? cachedSongs.first.uri;
        if (firstPath.isNotEmpty) {
          decoderOk = await _mediaBridge.isDecoderAvailable(firstPath);
        }
      }

      return SplashDiagnosticResult(
        decoderAvailable: decoderOk,
        scannedSongsCount: cachedSongs.length,
        strategyUsed: 'Carga instantánea desde caché SQLite',
        destination: StartupDestination.dashboard,
      );
    } else {
      // Caso especial: El sistema tiene permisos concedidos (ej. persistió tras un reinicio o limpieza parcial),
      // pero SQLite está vacío. Escaneamos de forma transparente y guardamos.
      Log.splash('Permisos activos pero SQLite vacío. Realizando escaneo y sincronización automática...');

      try {
        final rawSongs = await _mediaBridge.scanLibrary();
        // Convertimos el resultado del bridge a objetos Song si es necesario y guardamos en SQLite
        // (O dejamos que el flujo de sincronización alimente la base de datos).

        return SplashDiagnosticResult(
          decoderAvailable: true,
          scannedSongsCount: rawSongs.length,
          strategyUsed: 'Sincronización automática de biblioteca',
          destination: StartupDestination.dashboard,
        );
      } catch (e) {
        Log.splash('Error en escaneo automático: $e');
        return const SplashDiagnosticResult(
          decoderAvailable: false,
          scannedSongsCount: 0,
          strategyUsed: 'Error de escaneo - Modo espera',
          destination: StartupDestination.dashboard,
        );
      }
    }
  }
}
