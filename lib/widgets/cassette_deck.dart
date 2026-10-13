import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/retro_theme.dart';
import 'retro_thumbnail.dart';

class ScrewPainter extends CustomPainter {
  final Color inkColor;
  final Color screwColor;

  ScrewPainter({required this.inkColor, required this.screwColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p = Paint()
      ..color = screwColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width / 2, p);

    final b = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(cx, cy), size.width / 2, b);
    canvas.drawLine(Offset(cx - 2.5, cy), Offset(cx + 2.5, cy), b);
    canvas.drawLine(Offset(cx, cy - 2.5), Offset(cx, cy + 2.5), b);
  }

  @override
  bool shouldRepaint(covariant ScrewPainter oldDelegate) => false;
}

class CassetteSpoolPainter extends CustomPainter {
  final Color reelColor;
  final Color hubColor;
  final Color inkColor;
  final double tapeRadius;

  CassetteSpoolPainter({
    required this.reelColor,
    required this.hubColor,
    required this.inkColor,
    this.tapeRadius = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    final tapePaint = Paint()
      ..color = const Color(0xFF2C1810)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, tapeRadius, tapePaint);

    final tapeBorder = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, tapeRadius, tapeBorder);

    final hubPaint = Paint()
      ..color = hubColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12.0, hubPaint);
    canvas.drawCircle(center, 12.0, tapeBorder);

    final spindlePaint = Paint()
      ..color = reelColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, spindlePaint);
    canvas.drawCircle(center, 5.0, tapeBorder);

    final toothPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final tx = cx + (8.5 * math.cos(angle));
      final ty = cy + (8.5 * math.sin(angle));
      canvas.drawCircle(Offset(tx, ty), 1.5, toothPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CassetteSpoolPainter oldDelegate) => false;
}

class CassetteDeck extends StatefulWidget {
  final RetroThemeData theme;
  final String title;
  final String artist;
  final bool isPlaying;
  final String? thumbnailUrl;
  final double height;

  const CassetteDeck({
    super.key,
    required this.theme,
    required this.title,
    required this.artist,
    required this.isPlaying,
    this.thumbnailUrl,
    this.height = 280,
  });

  @override
  State<CassetteDeck> createState() => _CassetteDeckState();
}

class _CassetteDeckState extends State<CassetteDeck>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _vuController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _vuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
      _vuController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CassetteDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
        _vuController.repeat(reverse: true);
      } else {
        _rotationController.stop();
        _vuController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _vuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: widget.theme.background,
        border: Border.all(color: widget.theme.ink, width: 2.5),
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: CustomPaint(
              size: const Size(10, 10),
              painter: ScrewPainter(
                inkColor: widget.theme.ink,
                screwColor: widget.theme.panel,
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: CustomPaint(
              size: const Size(10, 10),
              painter: ScrewPainter(
                inkColor: widget.theme.ink,
                screwColor: widget.theme.panel,
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 2,
            child: CustomPaint(
              size: const Size(10, 10),
              painter: ScrewPainter(
                inkColor: widget.theme.ink,
                screwColor: widget.theme.panel,
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: CustomPaint(
              size: const Size(10, 10),
              painter: ScrewPainter(
                inkColor: widget.theme.ink,
                screwColor: widget.theme.panel,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopRibbon(),
              _buildStickerLabel(),
              _buildReelWindow(),
              _buildBottomDeckBase(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopRibbon() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.theme.panel,
        border: Border.all(color: widget.theme.ink, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: widget.theme.accentCoral,
              border: Border.all(color: widget.theme.ink, width: 1),
            ),
            child: const Text(
              'SIDE A',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            'CHROME [CrO2] / C-90 HI-FI',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: widget.theme.ink,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: widget.theme.background,
              border: Border.all(color: widget.theme.ink, width: 1),
            ),
            child: Text(
              'DOLBY B-NR',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: widget.theme.inkDim,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerLabel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.theme.card,
        border: Border.all(color: widget.theme.ink, width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.theme.ink,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.theme.accentCoral,
                  widget.theme.accentTeal,
                  widget.theme.accentYellow,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                RetroThumbnail(
                  url: widget.thumbnailUrl,
                  width: 44,
                  height: 44,
                  theme: widget.theme,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: widget.theme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.shantellSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: widget.theme.accentCoral,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.theme.ink,
                    border: Border.all(color: widget.theme.ink, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'INDEX',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.background,
                        ),
                      ),
                      Text(
                        widget.isPlaying ? 'REC' : '024',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: widget.isPlaying ? widget.theme.accentCoral : widget.theme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelWindow() {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        color: widget.theme.background,
        border: Border.all(color: widget.theme.ink, width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 56,
            right: 56,
            top: 32,
            child: Container(
              height: 4,
              color: const Color(0xFF2C1810),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(11, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 1.5,
                    height: i == 5 ? 6 : 3,
                    color: widget.theme.inkMuted,
                  );
                }),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 8,
            child: _buildRotatingSpool(tapeRadius: 26.0),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.theme.panel,
                border: Border.all(color: widget.theme.ink, width: 1),
              ),
              child: Text(
                '100 50 0',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.inkDim,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 8,
            child: _buildRotatingSpool(tapeRadius: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingSpool({required double tapeRadius}) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, _) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: CustomPaint(
            size: const Size(52, 52),
            painter: CassetteSpoolPainter(
              reelColor: widget.theme.background,
              hubColor: const Color(0xFFFAF6EE),
              inkColor: widget.theme.ink,
              tapeRadius: tapeRadius,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomDeckBase() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.theme.panel,
        border: Border.all(color: widget.theme.ink, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isPlaying ? widget.theme.accentCoral : widget.theme.inkMuted,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'STEREO PEAK',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.ink,
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _vuController,
            builder: (context, _) {
              final v = widget.isPlaying ? _vuController.value : 0.0;
              final barsL = (v * 5).round().clamp(1, 5);
              final barsR = ((1.0 - v) * 5).round().clamp(1, 5);

              return Row(
                children: [
                  _vuBar('L', barsL),
                  const SizedBox(width: 6),
                  _vuBar('R', barsR),
                ],
              );
            },
          ),
          Text(
            '320K DIRECT DRIVE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: widget.theme.inkDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vuBar(String label, int level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 7,
            fontWeight: FontWeight.bold,
            color: widget.theme.inkDim,
          ),
        ),
        const SizedBox(width: 2),
        ...List.generate(5, (i) {
          final isLit = i < level;
          final color = i < 3
              ? widget.theme.accentTeal
              : i == 3
                  ? widget.theme.accentYellow
                  : widget.theme.accentCoral;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.8),
            width: 3,
            height: 8,
            decoration: BoxDecoration(
              color: isLit ? color : widget.theme.background,
              border: Border.all(color: widget.theme.ink, width: 0.6),
            ),
          );
        }),
      ],
    );
  }
}
