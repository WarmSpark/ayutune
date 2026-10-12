import 'package:flutter/material.dart';
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
    final int step = (volume * 5).round().clamp(1, 5);

    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border.all(color: theme.ink, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'VOL',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: theme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onVolumeChanged((volume - 0.2).clamp(0.0, 1.0)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.ink, width: 1),
                  ),
                  child: Text(
                    '<',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.background,
                  border: Border.all(color: theme.ink, width: 1),
                ),
                child: Center(
                  child: Container(
                    width: 3.0 + (step * 2.2),
                    height: 3.0 + (step * 2.2),
                    color: theme.ink,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onVolumeChanged((volume + 0.2).clamp(0.0, 1.0)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.ink, width: 1),
                  ),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
