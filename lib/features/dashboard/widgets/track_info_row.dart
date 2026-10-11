// lib/widgets/tinted_background.dart
import 'package:flutter/material.dart';
import '../../../core/strings/dashboard_strings.dart';
import 'icon_action_button.dart';

class TrackInfoRow extends StatelessWidget {
  const TrackInfoRow({
    super.key,
    required this.title,
    required this.artist,
    required this.isFavorite,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onFavoriteToggle,
    this.onFavoriteLongPress,
  });

  final String? title;
  final String? artist;
  final bool isFavorite;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onFavoriteLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? DashboardStrings.noTrack,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textPrimary.withValues(alpha: 0.9),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                artist ?? DashboardStrings.unknownArtist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        IconActionButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isFavorite
              ? accent
              : textSecondary.withValues(alpha: 0.35),
          tooltip: isFavorite
              ? DashboardStrings.unfavorite
              : DashboardStrings.favorite,
          onTap: onFavoriteToggle,
          onLongPressStart: onFavoriteLongPress,
          size: 22,
          actionName: 'Marcar Favorito',
        ),
      ],
    );
  }
}
