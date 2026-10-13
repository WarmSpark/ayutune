import 'dart:math' as math;
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

class RetroSparklePainter extends CustomPainter {
  final Color color;
  final double size;

  RetroSparklePainter({
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = size / 2;
    final innerR = r * 0.28;

    final path = Path();
    path.moveTo(cx, cy - r);
    path.quadraticBezierTo(cx, cy, cx + innerR, cy);
    path.lineTo(cx + r, cy);
    path.quadraticBezierTo(cx, cy, cx, cy + innerR);
    path.lineTo(cx, cy + r);
    path.quadraticBezierTo(cx, cy, cx - innerR, cy);
    path.lineTo(cx - r, cy);
    path.quadraticBezierTo(cx, cy, cx, cy - innerR);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RetroSparklePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.size != size;
  }
}

class MiniEqualizerBars extends StatelessWidget {
  final Color color;
  final int step;

  const MiniEqualizerBars({
    super.key,
    required this.color,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    const matrix = [
      [3.0, 9.0, 5.0, 11.0, 4.0],
      [9.0, 4.0, 11.0, 5.0, 10.0],
      [5.0, 11.0, 4.0, 10.0, 3.0],
      [11.0, 6.0, 8.0, 3.0, 7.0],
    ];
    final heights = matrix[step % 4];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 3.5,
          height: heights[i],
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class SquigglyMarkerPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final Color shadowColor;
  final int frame;
  final double pulse;

  SquigglyMarkerPainter({
    required this.borderColor,
    required this.fillColor,
    required this.shadowColor,
    required this.frame,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + (pulse * 0.8)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    const frameOffsets = [
      [1.8, -1.4, -1.2, 1.5],
      [-1.5, 1.7, 1.4, -1.2],
      [1.2, 1.3, -1.5, -1.4],
      [-1.6, -1.1, 1.2, 1.6],
    ];
    final offsets = frameOffsets[frame % 4];

    final path = Path();
    path.moveTo(3.0 + offsets[0], 3.0);
    path.lineTo(size.width - 3.0, 3.0 + offsets[1]);
    path.lineTo(size.width - 3.0 + offsets[2], size.height - 3.0);
    path.lineTo(3.0, size.height - 3.0 + offsets[3]);
    path.close();

    canvas.save();
    canvas.translate(2.8 + (pulse * 1.2), 2.8 + (pulse * 1.2));
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SquigglyMarkerPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.pulse != pulse;
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
    with TickerProviderStateMixin {
  late AnimationController _steppedController;
  late AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _steppedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _currentFrame = (_currentFrame + 1) % 4;
            });
            _steppedController.forward(from: 0.0);
          }
        }
      });
    _steppedController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
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
    const itemEstimatedHeight = 62.0;
    final targetOffset = (widget.activeIndex * itemEstimatedHeight) -
        (widget.height / 2) +
        (itemEstimatedHeight / 2) +
        16.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _steppedController.dispose();
    _pulseController.dispose();
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
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final pulseVal = _pulseController.value;
              final sparkleSize = 10.0 + (pulseVal * 5.0);
              final sparkleRotation = pulseVal * math.pi;

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 12),
                itemCount: widget.lyrics.length,
                itemBuilder: (context, index) {
                  final line = widget.lyrics[index];
                  final distance = (index - widget.activeIndex).abs();
                  final isActive = index == widget.activeIndex;
                  final isNeighbor = distance == 1;

                  if (isActive) {
                    const transOffsets = [
                      [1.2, -0.9, 0.012],
                      [-1.0, 1.1, -0.010],
                      [0.8, 0.7, 0.008],
                      [-1.2, -0.8, -0.014],
                    ];
                    final cur = transOffsets[_currentFrame % 4];

                    return Center(
                      child: GestureDetector(
                        onTap: () => widget.onSeekLyric(line.timestamp),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: AnimatedScale(
                            scale: 1.04,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.rotate(
                                  angle: sparkleRotation,
                                  child: CustomPaint(
                                    painter: RetroSparklePainter(
                                      color: widget.theme.accentTeal,
                                      size: sparkleSize,
                                    ),
                                    size: const Size(18, 18),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                CustomPaint(
                                  painter: SquigglyMarkerPainter(
                                    borderColor: widget.theme.accentTeal,
                                    fillColor: widget.theme.accentCoral,
                                    shadowColor: widget.theme.ink,
                                    frame: _currentFrame,
                                    pulse: pulseVal,
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    child: Transform(
                                      transform: Matrix4.translationValues(
                                        cur[0],
                                        cur[1],
                                        0.0,
                                      )..rotateZ(cur[2]),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            line.text,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.shantellSans(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFFAF6EE),
                                              letterSpacing: 0.4,
                                              shadows: [
                                                Shadow(
                                                  offset: const Offset(1.8, 1.8),
                                                  color: widget.theme.ink,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          MiniEqualizerBars(
                                            color: const Color(0xFF00F0FF),
                                            step: _currentFrame,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Transform.rotate(
                                  angle: -sparkleRotation,
                                  child: CustomPaint(
                                    painter: RetroSparklePainter(
                                      color: widget.theme.accentTeal,
                                      size: sparkleSize,
                                    ),
                                    size: const Size(18, 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: GestureDetector(
                      onTap: () => widget.onSeekLyric(line.timestamp),
                      child: AnimatedScale(
                        scale: isNeighbor ? 0.94 : 0.86,
                        duration: const Duration(milliseconds: 240),
                        child: AnimatedOpacity(
                          opacity: isNeighbor ? 0.65 : 0.32,
                          duration: const Duration(milliseconds: 240),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              line.text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.shantellSans(
                                fontSize: isNeighbor ? 15 : 13.5,
                                fontWeight: FontWeight.w600,
                                color: widget.theme.inkDim,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
