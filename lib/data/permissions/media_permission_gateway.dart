// lib/data/permissions/media_permission_gateway.dart
import 'package:permission_handler/permission_handler.dart';
import '../../core/log.dart';
import 'permission_gateway.dart';

class MediaPermissionGateway implements PermissionGateway {
  const MediaPermissionGateway();

  @override
  Future<bool> hasLibraryAccess() async {
    final audio = await Permission.audio.status;
    if (audio.isGranted) return true;

    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;

    return false;
  }

  @override
  Future<bool> requestLibraryAccess() async {
    Log.library('Solicitando permisos de audio al sistema');

    final audio = await Permission.audio.request();
    if (audio.isGranted) {
      Log.library('Permiso de audio concedido');
      return true;
    }

    Log.library('Permiso de audio no concedido, probando almacenamiento general');
    final storage = await Permission.storage.request();
    if (storage.isGranted) {
      Log.library('Permiso de storage concedido');
      return true;
    }

    Log.library('Permisos denegados por el usuario');
    return false;
  }
}
