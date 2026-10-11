// lib/core/appearance_scope.dart
import 'package:flutter/material.dart';
import '../features/appearance/controllers/appearance_controller.dart';

class AppearanceScope extends InheritedWidget {
  const AppearanceScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final AppearanceController controller;

  static AppearanceController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppearanceScope>();
    assert(scope != null, 'No AppearanceScope found in context');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(AppearanceScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
