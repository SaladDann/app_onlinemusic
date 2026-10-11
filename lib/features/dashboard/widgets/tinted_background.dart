// lib/widgets/tinted_background.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class TintedBackground extends StatelessWidget {
  const TintedBackground({
    super.key,
    required this.baseColor,
    required this.tintColor,
    required this.child,
    this.frosted = false,
    this.duration = const Duration(milliseconds: 600),
  });

  final Color baseColor;
  final Color tintColor;
  final Widget child;
  final bool frosted;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          color: baseColor,
        ),
        if (frosted) ...[
          Positioned(
            top: -100,
            left: -70,
            child: _Glow(color: tintColor.withValues(alpha: 0.24)),
          ),
          Positioned(
            bottom: -120,
            right: -80,
            child: _Glow(color: tintColor.withValues(alpha: 0.16)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: ColoredBox(
                  color: baseColor.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
        ] else ...[
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      tintColor.withValues(alpha: 0.09),
                      baseColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
