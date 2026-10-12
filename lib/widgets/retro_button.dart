import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class RetroButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final RetroThemeData theme;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;

  const RetroButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.theme,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? widget.theme.panel;
    final fg = widget.textColor ?? widget.theme.ink;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: widget.theme.ink, width: 2.5),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.theme.ink,
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: widget.fontSize + 2, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: fg,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
