import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class WigglyWaveform extends StatefulWidget {
  final RetroThemeData theme;
  final bool isPlaying;

  const WigglyWaveform({
    super.key,
    required this.theme,
    required this.isPlaying,
  });

  @override
  State<WigglyWaveform> createState() => _WigglyWaveformState();
}

class _WigglyWaveformState extends State<WigglyWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isPlaying) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WigglyWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: widget.theme.background,
        border: Border.all(color: widget.theme.ink, width: 2),
      ),
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaveformPainter(
              theme: widget.theme,
              isPlaying: widget.isPlaying,
              phase: _waveController.value * 2 * math.pi,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final RetroThemeData theme;
  final bool isPlaying;
  final double phase;

  _WaveformPainter({
    required this.theme,
    required this.isPlaying,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int barCount = 36;
    final double barWidth = size.width / barCount;
    final double midY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      double h = 6.0;
      if (isPlaying) {
        final val = math.sin(i * 0.45 + phase) * 12.0 +
            math.cos(i * 0.85 - phase * 0.7) * 8.0;
        h = 6.0 + val.abs();
      }

      final double x = i * barWidth;
      final double y = midY - (h / 2);

      final paint = Paint()
        ..color = (i % 2 == 0) ? theme.accentTeal : theme.accentCoral;

      canvas.drawRect(
        Rect.fromLTWH(x + 2, y, barWidth - 3, h),
        paint,
      );
    }

    final linePaint = Paint()
      ..color = theme.ink
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return isPlaying || oldDelegate.isPlaying != isPlaying;
  }
}
