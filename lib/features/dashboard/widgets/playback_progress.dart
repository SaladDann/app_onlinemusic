// lib/widgets/tinted_background.dart
import 'package:flutter/material.dart';
import '../../../core/dashboard_layout.dart';
import '../../../core/format.dart';
import '../../../core/log.dart';

class PlaybackProgress extends StatefulWidget {
  const PlaybackProgress({
    super.key,
    required this.position,
    required this.duration,
    required this.progress,
    required this.accent,
    required this.labelColor,
    required this.inactiveTrackColor,
    required this.onSeek,
    required this.isEnabled,
  });

  final Duration position;
  final Duration duration;
  final double progress;
  final Color accent;
  final Color labelColor;
  final Color inactiveTrackColor;
  final ValueChanged<Duration> onSeek;
  final bool isEnabled;

  @override
  State<PlaybackProgress> createState() => _PlaybackProgressState();
}

class _PlaybackProgressState extends State<PlaybackProgress> {
  double? _draggingValue;

  double get _displayValue => _draggingValue ?? widget.progress;

  Duration get _displayPosition {
    if (_draggingValue == null) return widget.position;
    return Duration(
      milliseconds: (_draggingValue! * widget.duration.inMilliseconds).round(),
    );
  }

  void _onChanged(double value) {
    if (!widget.isEnabled) return;
    setState(() => _draggingValue = value);
  }

  void _onChangeEnd(double value) {
    if (!widget.isEnabled) return;
    final target = Duration(
      milliseconds: (value * widget.duration.inMilliseconds).round(),
    );
    Log.library('[Dashboard] Seek en barra de progreso hacia: ${target.inSeconds}s');
    setState(() => _draggingValue = null);
    widget.onSeek(target);
  }

  @override
  Widget build(BuildContext context) {
    final activeThumbRadius = _draggingValue != null
        ? DashboardLayout.progressThumbRadiusActive
        : DashboardLayout.progressThumbRadius;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeLabel(
                text: Format.duration(_displayPosition),
                color: widget.labelColor,
              ),
              _TimeLabel(
                text: Format.duration(widget.duration),
                color: widget.labelColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: DashboardLayout.gapXs),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: DashboardLayout.progressTrackHeight,
            activeTrackColor: widget.accent.withValues(alpha: 0.85),
            inactiveTrackColor: widget.inactiveTrackColor,
            thumbColor: widget.accent,
            overlayColor: Colors.transparent,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: activeThumbRadius,
              elevation: 0,
              pressedElevation: 0,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: _displayValue.clamp(0.0, 1.0),
            onChanged: widget.isEnabled ? _onChanged : null,
            onChangeEnd: widget.isEnabled ? _onChangeEnd : null,
          ),
        ),
      ],
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
