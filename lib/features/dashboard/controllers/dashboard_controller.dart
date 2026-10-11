// lib/features/dashboard/controllers/dashboard_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/log.dart';
import '../../../data/play_mode.dart';
import '../../../data/song.dart';

class DashboardController extends ChangeNotifier {
  DashboardController() {
    Log.library('DashboardController inicializado en modo base (coraza)');
  }

  // Estados simulados / base para la interfaz
  Song? _currentSong;
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  final Duration _duration = const Duration(minutes: 3, seconds: 30);
  PlayMode _playMode = PlayMode.order;
  bool _isFavorite = false;

  // Getters requeridos por la vista del Dashboard
  Song? get currentSong => _currentSong;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  PlayMode get playMode => _playMode;
  bool get isFavorite => _isFavorite;

  // Método de inicialización base
  Future<void> initialize() async {
    Log.library('[DashboardController] Inicializando controlador base...');
    _isLoading = true;
    notifyListeners();

    // Simulamos una carga rápida o inicialización de la coraza
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _isLoading = false;
    Log.library('[DashboardController] Inicialización base completada.');
    notifyListeners();
  }

  // Acciones de reproducción (preparadas con logs)
  Future<void> onPlayPressed() async {
    _isPlaying = !_isPlaying;
    Log.playback('[DashboardController] Acción Play/Pause presionada. Estado isPlaying: $_isPlaying');
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    _position = position;
    Log.playback('[DashboardController] Seek aplicado a: ${position.inSeconds}s');
    notifyListeners();
  }

  void onFavoritePressed() {
    _isFavorite = !_isFavorite;
    Log.library('[DashboardController] Favorito cambiado: $_isFavorite');
    notifyListeners();
  }

  void cyclePlayMode() {
    _playMode = _playMode.next;
    Log.library('[DashboardController] Ciclando modo de reproducción a: ${_playMode.label}');
    notifyListeners();
  }

  Future<void> onPreviousPressed() async {
    Log.playback('[DashboardController] Acción Pista Anterior invocada');
  }

  Future<void> onNextPressed() async {
    Log.playback('[DashboardController] Acción Pista Siguiente invocada');
  }

  void startRewind() {
    Log.playback('[DashboardController] Inicio de retroceso rápido (Rewind)');
  }

  void stopRewind() {
    Log.playback('[DashboardController] Fin de retroceso rápido (Rewind)');
  }

  void startFastForward() {
    Log.playback('[DashboardController] Inicio de avance rápido (FastForward)');
  }

  void stopFastForward() {
    Log.playback('[DashboardController] Fin de avance rápido (FastForward)');
  }

  void refreshState() {
    notifyListeners();
  }
}
