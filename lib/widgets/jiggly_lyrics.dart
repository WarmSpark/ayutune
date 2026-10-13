import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lyric_line.dart';
import '../theme/retro_theme.dart';

class RetroDotGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  RetroDotGridPainter({
    required this.dotColor,
    this.spacing = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RetroDotGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}

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

    final double jx = frame == 0 ? 1.6 : -1.6;
    final double jy = frame == 0 ? -1.4 : 1.4;

    final path = Path();
    path.moveTo(3.0 + jx, 3.0);
    path.lineTo(size.width - 3.0, 3.0 + jy);
    path.lineTo(size.width - 3.0 - jx, size.height - 3.0);
    path.lineTo(3.0, size.height - 3.0 - jy);
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
    this.height = 280,
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
    const itemEstimatedHeight = 60.0;
    final targetOffset = (widget.activeIndex * itemEstimatedHeight) -
        (widget.height / 2) +
        (itemEstimatedHeight / 2) +
        20.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
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
            style: GoogleFonts.shantellSans(
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
      height: widget.height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: widget.theme.background,
        border: Border.all(color: widget.theme.ink, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: RetroDotGridPainter(
                dotColor: widget.theme.inkMuted.withValues(alpha: 0.35),
                spacing: 12.0,
              ),
            ),
          ),
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 12),
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
                          constraints: const BoxConstraints(maxWidth: 340),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Transform(
                            transform: Matrix4.translationValues(
                              _currentFrame == 0 ? 1.2 : -1.2,
                              _currentFrame == 0 ? -0.8 : 0.8,
                              0.0,
                            )..rotateZ(_currentFrame == 0 ? 0.012 : -0.012),
                            alignment: Alignment.center,
                            child: Text(
                              line.text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.shantellSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFAF6EE),
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1.5, 1.5),
                                    color: widget.theme.ink,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                    constraints: const BoxConstraints(maxWidth: 340),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      line.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shantellSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.theme.inkDim.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
