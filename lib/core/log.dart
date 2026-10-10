// lib/core/log.dart
import 'package:flutter/foundation.dart';

class Log {
  const Log._();

  static void app(String message) => _write('App', message);
  static void splash(String message) => _write('Splash', message);
  static void playback(String message) => _write('Playback', message);
  static void queue(String message) => _write('Queue', message);
  static void native(String message) => _write('Native', message);
  static void library(String message) => _write('Library', message);
  static void artwork(String message) => _write('Artwork', message);
  static void format(String message) => _write('Format', message);
  static void drive(String message) => _write('Drive', message);
  static void theme(String message) => _write('Theme', message);

  static void warn(String module, String message) =>
      _write(module, 'AVISO: $message');

  static void error(String module, String message, [Object? error]) {
    _write(module, 'ERROR: $message');
    if (error != null) {
      _write(module, 'DETALLE: $error');
    }
  }

  static void _write(String module, String message) {
    if (!kDebugMode) return;
    debugPrint('[$module] $message');
  }
}
