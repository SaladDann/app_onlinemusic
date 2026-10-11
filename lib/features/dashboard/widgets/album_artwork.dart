// lib/widgets/tinted_background.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/dashboard_layout.dart';

class AlbumArtwork extends StatelessWidget {
  const AlbumArtwork({
    super.key,
    required this.surface,
    required this.iconColor,
    this.size = DashboardLayout.artworkSize,
    this.artworkPath,
    this.borderRadius = 24,
  });

  final Color surface;
  final Color iconColor;
  final double size;
  final String? artworkPath;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final path = artworkPath?.trim();

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: path != null && path.isNotEmpty
            ? Image.file(
                File(path),
                key: ValueKey(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(
          color: iconColor.withValues(alpha: 0.08),
        ),
      ),
      child: Center(
        child: Container(
          width: DashboardLayout.artworkInnerSize,
          height: DashboardLayout.artworkInnerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            Icons.music_note_rounded,
            size: DashboardLayout.artworkInnerIcon,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
