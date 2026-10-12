import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class CassetteDeck extends StatefulWidget {
  final RetroThemeData theme;
  final String title;
  final String artist;
  final bool isPlaying;

  const CassetteDeck({
    super.key,
    required this.theme,
    required this.title,
    required this.artist,
    required this.isPlaying,
  });

  @override
  State<CassetteDeck> createState() => _CassetteDeckState();
}

class _CassetteDeckState extends State<CassetteDeck>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CassetteDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: widget.theme.background,
        border: Border.all(color: widget.theme.ink, width: 2.5),
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.panel,
          border: Border.all(color: widget.theme.ink, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: widget.theme.card,
                border: Border.all(color: widget.theme.ink, width: 1.5),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.theme.accentCoral,
                        border: Border(
                          right: BorderSide(color: widget.theme.ink, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: widget.theme.inkDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 180,
              height: 44,
              decoration: BoxDecoration(
                color: widget.theme.background,
                border: Border.all(color: widget.theme.ink, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSpool(),
                  Container(
                    width: 44,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.theme.inkMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _buildSpool(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpool() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.theme.card,
              border: Border.all(color: widget.theme.ink, width: 1.5),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: widget.theme.ink, width: 1.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
