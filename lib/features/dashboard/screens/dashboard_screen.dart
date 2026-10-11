// lib/features/dashboard/screens/dashboard_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/appearance_scope.dart';
import '../../../core/dashboard_layout.dart';
import '../../../core/log.dart';
import '../../../core/strings/dashboard_strings.dart';
import '../../../core/theme.dart';
import '../../../data/song.dart';
import '../../../services/artwork_service.dart';
import '../../appearance/controllers/appearance_controller.dart';
import '../../appearance/widgets/appearance_settings_sheet.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/album_artwork.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/playback_progress.dart';
import '../widgets/player_controls_row.dart';
import '../widgets/tinted_background.dart';
import '../widgets/track_info_row.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.dashboardController,
    required this.scannedSongsCount,
    required this.decoderStatus,
  });

  final DashboardController dashboardController;
  final int scannedSongsCount;
  final bool decoderStatus;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;
  late AppearanceController _appearanceController;

  static final ArtworkService _artworkService = ArtworkService();

  String? _artworkPath;
  String? _requestedArtworkSongId;

  @override
  void initState() {
    super.initState();
    _controller = widget.dashboardController;
    Log.library('DashboardScreen ("Coraza Base") inicializada. Pistas: ${widget.scannedSongsCount}, Decodificador OK: ${widget.decoderStatus}');

    _controller.addListener(_onControllerChanged);
    unawaited(_initializeDashboard());
  }

  Future<void> _initializeDashboard() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      _syncArtwork();
    } catch (e, stackTrace) {
      Log.library('Error inicializando el dashboard base: $e');
      Log.library('STACK: $stackTrace');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appearanceController = AppearanceScope.of(context);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _syncArtwork();
  }

  void _syncArtwork() {
    final song = _controller.currentSong;
    final songId = song?.id;

    if (songId == _requestedArtworkSongId) return;
    _requestedArtworkSongId = songId;

    if (song == null) {
      setStateIfMounted(() {
        _artworkPath = null;
      });
      _appearanceController.setArtworkAccent(null);
      return;
    }

    _artworkPath = null;
    _appearanceController.setArtworkAccent(null);
    unawaited(_loadArtwork(song));
  }

  Future<void> _loadArtwork(Song song) async {
    final songId = song.id;
    final path = await _artworkService.getArtworkPath(song);
    if (!mounted || _controller.currentSong?.id != songId) return;

    Color? dominantColor;
    if (path != null) {
      dominantColor = await _artworkService.extractDominantColor(path);
    }

    if (!mounted || _controller.currentSong?.id != songId) return;

    setState(() {
      _artworkPath = path;
    });

    _appearanceController.setArtworkAccent(dominantColor);
  }

  void setStateIfMounted(VoidCallback callback) {
    if (mounted) setState(callback);
  }

  Future<void> _onPlayPause() async {
    Log.library('[Dashboard] Acción de Play/Pause principal invocada');
    try {
      await _controller.onPlayPressed();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DashboardStrings.playbackError)),
      );
    }
  }

  void _openAllSongs() {
    Log.library('[Dashboard] Acción de abrir todas las canciones (Sección aislada pendiente de enlace).');
  }

  void _openAppearanceSettings() {
    Log.library('[Dashboard] Abriendo panel flotante de ajustes de apariencia');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
      barrierColor: Colors.black.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => AppearanceSettingsSheet(
        controller: _appearanceController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _controller.currentSong;
    final isLoading = _controller.isLoading;
    final appearance = AppearanceScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).extension<AppColors>();

    final backgroundBase = colors?.background ?? (isDark ? const Color(0xFF0A0A0F) : const Color(0xFFFAFAFA));
    final surfaceColor = colors?.surface ?? (isDark ? const Color(0xFF16161D) : Colors.white);
    final textPrimaryColor = colors?.textPrimary ?? (isDark ? Colors.white : const Color(0xFF1A1A1A));
    final textSecondaryColor = colors?.textSecondary ?? (isDark ? Colors.white70 : const Color(0xFF6B6B6B));
    final accentColor = appearance.accentFor(isDark);

    return Scaffold(
      backgroundColor: backgroundBase,
      body: TintedBackground(
        baseColor: backgroundBase,
        tintColor: accentColor,
        frosted: appearance.style == AppearanceStyle.frosted,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DashboardLayout.horizontalPadding,
              vertical: DashboardLayout.verticalPadding,
            ),
            child: Column(
              children: [
                DashboardHeader(
                  iconColor: textSecondaryColor.withValues(alpha: 0.6),
                  onSettings: _openAppearanceSettings,
                  onSearch: () {
                    Log.library('[Dashboard] Acción de búsqueda global invocada (Módulo aislado pendiente).');
                  },
                ),
                const Spacer(),
                if (isLoading && currentSong == null)
                  const CircularProgressIndicator()
                else ...[
                  AlbumArtwork(
                    surface: surfaceColor,
                    iconColor: textSecondaryColor.withValues(alpha: 0.5),
                    size: DashboardLayout.artworkSize,
                    artworkPath: _artworkPath,
                  ),
                  const SizedBox(height: DashboardLayout.gapXl),
                  TrackInfoRow(
                    title: currentSong?.title ?? DashboardStrings.noTrack,
                    artist: currentSong?.artist ?? DashboardStrings.unknownArtist,
                    isFavorite: _controller.isFavorite,
                    textPrimary: textPrimaryColor,
                    textSecondary: textSecondaryColor,
                    accent: accentColor,
                    onFavoriteToggle: _controller.onFavoritePressed,
                  ),
                  const SizedBox(height: DashboardLayout.gapMd),
                  PlaybackProgress(
                    position: _controller.position,
                    duration: currentSong?.durationAsDuration ?? _controller.duration,
                    progress: 0.0,
                    accent: accentColor,
                    labelColor: textSecondaryColor.withValues(alpha: 0.6),
                    inactiveTrackColor: textSecondaryColor.withValues(alpha: 0.15),
                    isEnabled: currentSong != null,
                    onSeek: _controller.seek,
                  ),
                  const SizedBox(height: DashboardLayout.gapLg),
                  PlayerControlsRow(
                    playMode: _controller.playMode,
                    isPlaying: _controller.isPlaying,
                    accent: accentColor,
                    primaryColor: textPrimaryColor.withValues(alpha: 0.85),
                    mutedColor: textSecondaryColor.withValues(alpha: 0.5),
                    onCyclePlayMode: _controller.cyclePlayMode,
                    onPrevious: _controller.onPreviousPressed,
                    onNext: _controller.onNextPressed,
                    onPlayPause: _onPlayPause,
                    onOpenAllSongs: _openAllSongs,
                    onRewindStart: _controller.startRewind,
                    onRewindEnd: _controller.stopRewind,
                    onFastForwardStart: _controller.startFastForward,
                    onFastForwardEnd: _controller.stopFastForward,
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
