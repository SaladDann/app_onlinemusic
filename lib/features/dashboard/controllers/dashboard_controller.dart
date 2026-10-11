// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:flutter/foundation.dart';
import '../../../core/log.dart';

class DashboardController extends ChangeNotifier {
  DashboardController() {
    Log.library('DashboardController inicializado en modo de prueba');
  }

  // Métodos de control base para futuras iteraciones de reproducción
  void refreshState() {
    notifyListeners();
  }
}
