import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lyric_line.dart';
import '../theme/retro_theme.dart';

class SquigglyMarkerPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final Color shadowColor;
  final int frame;

  SquigglyMarkerPainter({
    required this.borderColor,
    required this.fillColor,
    required this.shadowColor,
    required this.frame,
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

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final double jitter = frame == 0 ? 1.4 : -1.4;

    path.moveTo(2.0, 2.0);
    path.lineTo(size.width - 2.0 + (frame == 0 ? 1.0 : -1.0), 2.0 + jitter);
    path.lineTo(size.width - 2.0 + jitter, size.height - 2.0 - jitter);
    path.lineTo(2.0 - jitter, size.height - 2.0 + (frame == 0 ? -1.0 : 1.0));
    path.close();

    canvas.save();
    canvas.translate(2.5, 2.5);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SquigglyMarkerPainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}

class JigglyLyricsView extends StatefulWidget {
  final RetroThemeData theme;
  final List<LyricLine> lyrics;
  final int activeIndex;
  final ValueChanged<Duration> onSeekLyric;
  final double height;

  const JigglyLyricsView({
    super.key,
    required this.theme,
    required this.lyrics,
    required this.activeIndex,
    required this.onSeekLyric,
    this.height = 240,
  });

  @override
  State<JigglyLyricsView> createState() => _JigglyLyricsViewState();
}

class _JigglyLyricsViewState extends State<JigglyLyricsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _steppedController;
  final ScrollController _scrollController = ScrollController();
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _steppedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentFrame = (_currentFrame + 1) % 2;
          });
          _steppedController.forward(from: 0.0);
        }
      });
    _steppedController.forward();
  }

  @override
  void didUpdateWidget(covariant JigglyLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _scrollToActive();
    }
  }

  void _scrollToActive() {
    if (!_scrollController.hasClients) return;
    final targetOffset = widget.activeIndex * 64.0;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _steppedController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyrics.isEmpty) {
      return Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.theme.background,
          border: Border.all(color: widget.theme.ink, width: 2),
        ),
        child: Center(
          child: Text(
            'NO SYNCHRONIZED LYRICS FOUND',
            style: GoogleFonts.gaegu(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.theme.inkDim,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: widget.height,
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
            return Center(
              child: GestureDetector(
                onTap: () => widget.onSeekLyric(line.timestamp),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CustomPaint(
                    painter: SquigglyMarkerPainter(
                      borderColor: widget.theme.accentTeal,
                      fillColor: widget.theme.accentCoral,
                      shadowColor: widget.theme.ink,
                      frame: _currentFrame,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: _buildSteppedJigglyText(line.text, _currentFrame),
                    ),
                  ),
                ),
              ),
            );
          }

          return Center(
            child: GestureDetector(
              onTap: () => widget.onSeekLyric(line.timestamp),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  line.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.gaegu(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.inkDim.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSteppedJigglyText(String text, int frame) {
    final words = text.split(' ');
    int charCounter = 0;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.0,
      runSpacing: 4.0,
      children: words.map((word) {
        final chars = word.split('');
        final wordWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(chars.length, (ci) {
            final idx = charCounter + ci;
            final ch = chars[ci];

            final double dx = frame == 0
                ? (((idx * 7) % 5) - 2.0) * 0.8
                : (-(((idx * 7) % 5) - 2.0)) * 0.8;

            final double dy = frame == 0
                ? (((idx * 11) % 5) - 2.0) * 1.0
                : (-(((idx * 11) % 5) - 2.0)) * 1.0;

            final double rot = frame == 0
                ? (((idx * 13) % 7) - 3.0) * 0.015
                : (-(((idx * 13) % 7) - 3.0)) * 0.015;

            return Transform(
              transform: Matrix4.translationValues(dx, dy, 0.0)..rotateZ(rot),
              alignment: Alignment.center,
              child: Text(
                ch,
                style: GoogleFonts.gaegu(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            );
          }),
        );
        charCounter += word.length + 1;
        return wordWidget;
      }).toList(),
    );
  }
}
