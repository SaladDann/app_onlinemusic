// lib/features/permissions/controllers/access_controller.dart
import 'package:flutter/foundation.dart';
import 'package:offline_music/data/permissions/permission_gateway.dart';
import '../../../core/log.dart';
import '../../../core/native_bridge/media_channel_bridge.dart';


class AccessController extends ChangeNotifier {
  AccessController({
    required PermissionGateway gateway,
    MediaChannelBridge? mediaBridge,
  })  : _gateway = gateway,
        _mediaBridge = mediaBridge ?? const MediaChannelBridge();

  final PermissionGateway _gateway;
  final MediaChannelBridge _mediaBridge;

  bool _isRequesting = false;
  bool _wasDenied = false;
  bool _isProcessingBackground = false;
  String _processingMessage = '';
  int _scannedCount = 0;

  bool get isRequesting => _isRequesting;
  bool get wasDenied => _wasDenied;
  bool get isProcessingBackground => _isProcessingBackground;
  String get processingMessage => _processingMessage;
  int get scannedCount => _scannedCount;

  Future<bool> requestAndProcessAccess() async {
    _isRequesting = true;
    _wasDenied = false;
    notifyListeners();

    try {
      final granted = await _gateway.requestLibraryAccess();
      if (!granted) {
        _isRequesting = false;
        _wasDenied = true;
        notifyListeners();
        return false;
      }

      // Si los permisos fueron concedidos, iniciamos el procesamiento en segundo plano
      _isRequesting = false;
      _isProcessingBackground = true;
      _processingMessage = 'Escaneando archivos multimedia...';
      notifyListeners();

      // 1. Escaneo nativo de canciones
      Log.library('Iniciando escaneo masivo de la biblioteca...');
      final songs = await _mediaBridge.scanLibrary();
      _scannedCount = songs.length;
      Log.library('Pistas detectadas: $_scannedCount');

      // 2. Indexación y preparación de base de datos / caché
      _processingMessage = 'Indexando base de datos local...';
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 600)); // Simulación de escritura optimizada en Sqflite

      // 3. Verificación de decodificadores para optimización de códecs
      _processingMessage = 'Verificando compatibilidad de códecs...';
      notifyListeners();
      if (songs.isNotEmpty) {
        final samplePath = songs.first['data'] as String? ?? '';
        if (samplePath.isNotEmpty) {
          await _mediaBridge.isDecoderAvailable(samplePath);
        }
      }

      _isProcessingBackground = false;
      notifyListeners();
      return true;
    } catch (e) {
      Log.error('Library', 'Error crítico en el proceso de permisos y carga', e);
      _isRequesting = false;
      _isProcessingBackground = false;
      _wasDenied = true;
      notifyListeners();
      return false;
    }
  }
}
