import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';
import 'retro_thumbnail.dart';

class CassetteDeck extends StatefulWidget {
  final RetroThemeData theme;
  final String title;
  final String artist;
  final bool isPlaying;
  final String? thumbnailUrl;

  const CassetteDeck({
    super.key,
    required this.theme,
    required this.title,
    required this.artist,
    required this.isPlaying,
    this.thumbnailUrl,
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
      height: 175,
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
              height: 56,
              decoration: BoxDecoration(
                color: widget.theme.card,
                border: Border.all(color: widget.theme.ink, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.theme.accentCoral,
                      border: Border(
                        right: BorderSide(color: widget.theme.ink, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  RetroThumbnail(
                    url: widget.thumbnailUrl,
                    width: 44,
                    height: 44,
                    theme: widget.theme,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
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
