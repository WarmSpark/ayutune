import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lyric_line.dart';
import '../theme/retro_theme.dart';

class SquigglyBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final double phase;

  SquigglyBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    const double step = 6.0;

    path.moveTo(0, 0);

    for (double x = 0; x <= size.width; x += step) {
      final y = math.sin((x / 10.0) + phase) * 1.8;
      path.lineTo(x, y);
    }

    for (double y = 0; y <= size.height; y += step) {
      final x = size.width + math.sin((y / 10.0) + phase * 1.3) * 1.8;
      path.lineTo(x, y);
    }

    for (double x = size.width; x >= 0; x -= step) {
      final y = size.height + math.sin((x / 10.0) + phase * 1.7) * 1.8;
      path.lineTo(x, y);
    }

    for (double y = size.height; y >= 0; y -= step) {
      final x = math.sin((y / 10.0) + phase * 2.1) * 1.8;
      path.lineTo(x, y);
    }

    path.close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(2.5, 2.5);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SquigglyBorderPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

class JigglyLyricsView extends StatefulWidget {
  final RetroThemeData theme;
  final List<LyricLine> lyrics;
  final int activeIndex;
  final ValueChanged<Duration> onSeekLyric;

  const JigglyLyricsView({
    super.key,
    required this.theme,
    required this.lyrics,
    required this.activeIndex,
    required this.onSeekLyric,
  });

  @override
  State<JigglyLyricsView> createState() => _JigglyLyricsViewState();
}

class _JigglyLyricsViewState extends State<JigglyLyricsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _jiggleController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant JigglyLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex &&
        widget.activeIndex >= 0 &&
        widget.activeIndex < widget.lyrics.length) {
      _scrollToActive();
    }
  }

  void _scrollToActive() {
    if (!_scrollController.hasClients) return;
    final targetOffset = widget.activeIndex * 60.0;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyrics.isEmpty) {
      return Container(
        width: double.infinity,
        height: 175,
        decoration: BoxDecoration(
          color: widget.theme.background,
          border: Border.all(color: widget.theme.ink, width: 2),
        ),
        child: Center(
          child: Text(
            'NO LYRICS AVAILABLE',
            style: GoogleFonts.gaegu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.theme.inkDim,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: widget.theme.background,
        border: Border.all(color: widget.theme.ink, width: 2),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        itemCount: widget.lyrics.length,
        itemBuilder: (context, index) {
          final line = widget.lyrics[index];
          final isActive = index == widget.activeIndex;

          if (isActive) {
            return AnimatedBuilder(
              animation: _jiggleController,
              builder: (context, child) {
                final t = _jiggleController.value * 2 * math.pi;

                return Center(
                  child: GestureDetector(
                    onTap: () => widget.onSeekLyric(line.timestamp),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: CustomPaint(
                        painter: SquigglyBorderPainter(
                          borderColor: widget.theme.accentTeal,
                          fillColor: widget.theme.accentCoral,
                          phase: t,
                        ),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 310),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: _buildJigglyText(line.text, t),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: GestureDetector(
              onTap: () => widget.onSeekLyric(line.timestamp),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  line.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gaegu(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.inkDim.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJigglyText(String text, double phase) {
    final words = text.split(' ');
    int charIndex = 0;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.0,
      runSpacing: 4.0,
      children: words.map((word) {
        final wordChars = word.split('');
        final wordWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(wordChars.length, (ci) {
            final idx = charIndex + ci;
            final ch = wordChars[ci];
            final dy = math.sin(phase * 1.6 + idx * 0.7) * 2.2;
            final dx = math.cos(phase * 1.2 + idx * 0.9) * 1.0;
            final rot = math.sin(phase * 1.4 + idx * 0.5) * 0.05;

            return Transform(
              transform: Matrix4.translationValues(dx, dy, 0.0)..rotateZ(rot),
              alignment: Alignment.center,
              child: Text(
                ch,
                style: GoogleFonts.gaegu(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            );
          }),
        );
        charIndex += word.length + 1;
        return wordWidget;
      }).toList(),
    );
  }
}
