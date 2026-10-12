import 'package:flutter/material.dart';
import '../models/lyric_line.dart';
import '../theme/retro_theme.dart';

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
      duration: const Duration(milliseconds: 320),
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
    final targetOffset = widget.activeIndex * 56.0;
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
        height: 170,
        decoration: BoxDecoration(
          color: widget.theme.background,
          border: Border.all(color: widget.theme.ink, width: 2),
        ),
        child: Center(
          child: Text(
            'NO LYRICS AVAILABLE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: widget.theme.inkDim,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 170,
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
                final frame = (_jiggleController.value * 4).floor();
                final offsetX = (frame % 2 == 0) ? -2.0 : 2.0;
                final offsetY = (frame == 1 || frame == 3) ? 1.5 : -1.5;
                final rot = (frame % 2 == 0) ? 0.015 : -0.015;

                return Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: Transform.rotate(
                    angle: rot,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => widget.onSeekLyric(line.timestamp),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.theme.accentCoral,
                            border: Border.all(
                                color: widget.theme.accentTeal, width: 2),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: widget.theme.ink,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            line.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  line.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
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
}
