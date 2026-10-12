import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class RetroThumbnail extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final RetroThemeData theme;
  final String? badgeText;

  const RetroThumbnail({
    super.key,
    this.url,
    required this.width,
    required this.height,
    required this.theme,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.background,
        border: Border.all(color: theme.ink, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.ink,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url!.isNotEmpty)
            Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.accentTeal,
                    ),
                  ),
                );
              },
            )
          else
            _buildFallback(),
          if (badgeText != null && badgeText!.isNotEmpty)
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.ink,
                  border: Border.all(color: theme.accentTeal, width: 1),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: theme.accentTeal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: theme.card,
      child: Center(
        child: Container(
          width: width * 0.5,
          height: height * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.panel,
            border: Border.all(color: theme.ink, width: 2),
          ),
          child: Center(
            child: Container(
              width: width * 0.16,
              height: height * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentCoral,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
