import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/retro_theme.dart';

class RetroScrubber extends StatelessWidget {
  final RetroThemeData theme;
  final Duration currentPosition;
  final Duration totalDuration;
  final ValueChanged<Duration> onSeek;

  const RetroScrubber({
    super.key,
    required this.theme,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
  });

  String _formatTime(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = totalDuration.inMilliseconds;
    final currentMs = currentPosition.inMilliseconds.clamp(0, totalMs > 0 ? totalMs : 1);
    final progressFraction = totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Text(
          _formatTime(currentPosition),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.ink,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final tapFraction =
                      (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                  final targetMs = (tapFraction * totalMs).toInt();
                  onSeek(Duration(milliseconds: targetMs));
                },
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.background,
                    border: Border.all(color: theme.ink, width: 2),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progressFraction,
                        child: Container(
                          color: theme.accentCoral,
                        ),
                      ),
                      Positioned(
                        left: (constraints.maxWidth * progressFraction) - 4,
                        top: -3,
                        bottom: -3,
                        child: Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: theme.panel,
                            border: Border.all(color: theme.ink, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(totalDuration),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.ink,
          ),
        ),
      ],
    );
  }
}

class RetroVolumeControl extends StatelessWidget {
  final RetroThemeData theme;
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const RetroVolumeControl({
    super.key,
    required this.theme,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (volume * 100).round();
    final activeSegments = (volume * 5).round().clamp(0, 5);

    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border.all(color: theme.ink, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.ink,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onVolumeChanged((volume - 0.2).clamp(0.0, 1.0));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: theme.background,
                border: Border.all(color: theme.ink, width: 1.5),
              ),
              child: Text(
                '-',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final isLit = index < activeSegments;
              final segColor = index < 2
                  ? theme.accentTeal
                  : index < 4
                      ? theme.accentYellow
                      : theme.accentCoral;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onVolumeChanged(((index + 1) * 0.2).clamp(0.0, 1.0));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 8,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isLit ? segColor : theme.background,
                    border: Border.all(
                      color: isLit ? theme.ink : theme.inkDim.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onVolumeChanged((volume + 0.2).clamp(0.0, 1.0));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: theme.background,
                border: Border.all(color: theme.ink, width: 1.5),
              ),
              child: Text(
                '+',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.ink,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: theme.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolumeStepper extends StatelessWidget {
  final RetroThemeData theme;
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeStepper({
    super.key,
    required this.theme,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RetroVolumeControl(
      theme: theme,
      volume: volume,
      onVolumeChanged: onVolumeChanged,
    );
  }
}

