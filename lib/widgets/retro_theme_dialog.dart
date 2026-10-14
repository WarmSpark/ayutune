import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';
import '../theme/theme_provider.dart';
import 'retro_button.dart';

class RetroThemeDialog extends StatefulWidget {
  final RetroThemeData theme;
  final ThemeProvider themeProvider;

  const RetroThemeDialog({
    super.key,
    required this.theme,
    required this.themeProvider,
  });

  @override
  State<RetroThemeDialog> createState() => _RetroThemeDialogState();
}

class _RetroThemeDialogState extends State<RetroThemeDialog> {
  static const List<Color> _primarySwatches = [
    Color(0xFF0C1626),
    Color(0xFF141C10),
    Color(0xFF1A0B2E),
    Color(0xFF1E120B),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFFF5E8C7),
    Color(0xFF200D16),
  ];

  static const List<Color> _secondarySwatches = [
    Color(0xFF142238),
    Color(0xFF26361C),
    Color(0xFF2E144D),
    Color(0xFF2E1F18),
    Color(0xFF1A1A1A),
    Color(0xFFEAEAEA),
    Color(0xFFEEDDB3),
    Color(0xFF3B1425),
  ];

  static const List<Color> _accentSwatches = [
    Color(0xFF00F0FF),
    Color(0xFF3A86FF),
    Color(0xFFFF007F),
    Color(0xFFFFD166),
    Color(0xFF00FF66),
    Color(0xFFFF5500),
    Color(0xFFE2F0FF),
    Color(0xFFA855F7),
  ];

  late Color _primary;
  late Color _secondary;
  late Color _accent;

  @override
  void initState() {
    super.initState();
    _primary = widget.themeProvider.customPrimary ?? widget.theme.background;
    _secondary = widget.themeProvider.customSecondary ?? widget.theme.panel;
    _accent = widget.themeProvider.customAccent ?? widget.theme.accentTeal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return AlertDialog(
      backgroundColor: theme.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: theme.ink, width: 3),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'CUSTOM PALETTE CREATOR',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.ink,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              '[X]',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.accentCoral,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary,
                border: Border.all(color: _accent, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _secondary,
                      border: Border.all(color: _accent, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREVIEW: VELVETUNE TAPE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _accent,
                              ),
                              child: Text(
                                'PLAY 320K',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '1. PRIMARY (BACKGROUND)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.ink,
              ),
            ),
            const SizedBox(height: 6),
            _buildSwatchRow(_primarySwatches, _primary, (c) => setState(() => _primary = c)),
            const SizedBox(height: 12),
            Text(
              '2. SECONDARY (PANEL / CARD)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.ink,
              ),
            ),
            const SizedBox(height: 6),
            _buildSwatchRow(_secondarySwatches, _secondary, (c) => setState(() => _secondary = c)),
            const SizedBox(height: 12),
            Text(
              '3. ACCENT (BUTTONS & HIGHLIGHTS)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.ink,
              ),
            ),
            const SizedBox(height: 6),
            _buildSwatchRow(_accentSwatches, _accent, (c) => setState(() => _accent = c)),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RetroButton(
              label: 'CANCEL',
              theme: theme,
              fontSize: 11,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onTap: () => Navigator.of(context).pop(),
            ),
            RetroButton(
              label: 'APPLY COMBO',
              theme: theme,
              fontSize: 11,
              backgroundColor: theme.accentTeal,
              textColor: const Color(0xFF0C1626),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () {
                widget.themeProvider.setCustomTheme(
                  primary: _primary,
                  secondary: _secondary,
                  accent: _accent,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwatchRow(
    List<Color> swatches,
    Color selectedColor,
    ValueChanged<Color> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: swatches.map((color) {
        final isSelected = selectedColor.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => onSelect(color),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.black45,
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      const BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 2,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
