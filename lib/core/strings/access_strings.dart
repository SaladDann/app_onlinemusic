// lib/core/strings/access_strings.dart
class AccessStrings {
  const AccessStrings._();

  static const String brand = 'OFFLINE MUSIC';
  static const String title = 'Acceso a la Biblioteca';
  static const String description =
      'Para reproducir tu música local y ofrecerte la mejor experiencia, necesitamos permiso para acceder a los archivos de audio de tu dispositivo.';
  static const String denied =
      'El acceso fue denegado. Por favor, habilítalo en los ajustes o inténtalo de nuevo.';
  static const String ctaInitial = 'CONCEDER PERMISOS';
  static const String ctaRetry = 'REINTENTAR ACCESO';

  // Nuevos estados de procesamiento en segundo plano
  static const String scanning = 'Escaneando archivos multimedia...';
  static const String indexing = 'Indexando base de datos local...';
  static const String checkingDecoders = 'Verificando compatibilidad de códecs...';
}
