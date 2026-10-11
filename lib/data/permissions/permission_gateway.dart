// lib/data/permissions/permission_gateway.dart
abstract interface class PermissionGateway {
  Future<bool> hasLibraryAccess();
  Future<bool> requestLibraryAccess();
}
