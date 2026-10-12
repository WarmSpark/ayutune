import 'package:flutter/material.dart';

enum RetroPaletteType {
  deepNavy,
  parchment,
  gameBoy,
  macintoshMono,
  amberCrt,
  synthwave,
  custom,
}

class RetroThemeData {
  final String name;
  final RetroPaletteType type;
  final Color background;
  final Color panel;
  final Color card;
  final Color ink;
  final Color inkDim;
  final Color inkMuted;
  final Color accentCoral;
  final Color accentTeal;
  final Color accentYellow;

  const RetroThemeData({
    required this.name,
    required this.type,
    required this.background,
    required this.panel,
    required this.card,
    required this.ink,
    required this.inkDim,
    required this.inkMuted,
    required this.accentCoral,
    required this.accentTeal,
    required this.accentYellow,
  });

  factory RetroThemeData.custom({
    required Color primary,
    required Color secondary,
    required Color accent,
    String name = 'Custom Tape',
  }) {
    final isDark = primary.computeLuminance() < 0.5;
    final ink = isDark ? const Color(0xFFFAF6EE) : const Color(0xFF0A0A0A);
    final inkDim = isDark ? ink.withValues(alpha: 0.7) : ink.withValues(alpha: 0.65);
    final inkMuted = isDark ? ink.withValues(alpha: 0.4) : ink.withValues(alpha: 0.35);

    return RetroThemeData(
      name: name,
      type: RetroPaletteType.custom,
      background: primary,
      panel: secondary,
      card: isDark
          ? Color.alphaBlend(Colors.white.withValues(alpha: 0.08), secondary)
          : Color.alphaBlend(Colors.black.withValues(alpha: 0.05), secondary),
      ink: ink,
      inkDim: inkDim,
      inkMuted: inkMuted,
      accentCoral: accent,
      accentTeal: isDark ? const Color(0xFF00F0FF) : accent,
      accentYellow: const Color(0xFFFFD166),
    );
  }

  static const RetroThemeData deepNavy = RetroThemeData(
    name: 'Deep Navy',
    type: RetroPaletteType.deepNavy,
    background: Color(0xFF0C1626),
    panel: Color(0xFF142238),
    card: Color(0xFF182842),
    ink: Color(0xFFE2F0FF),
    inkDim: Color(0xFF7D9BBD),
    inkMuted: Color(0xFF3B5373),
    accentCoral: Color(0xFF3A86FF),
    accentTeal: Color(0xFF00F0FF),
    accentYellow: Color(0xFFFFD166),
  );

  static const RetroThemeData parchment = RetroThemeData(
    name: 'Parchment',
    type: RetroPaletteType.parchment,
    background: Color(0xFFF5E8C7),
    panel: Color(0xFFEEDDB3),
    card: Color(0xFFFAF6EE),
    ink: Color(0xFF1E1713),
    inkDim: Color(0xFF6C5A4D),
    inkMuted: Color(0xFFA39284),
    accentCoral: Color(0xFFE76F51),
    accentTeal: Color(0xFF4A9B94),
    accentYellow: Color(0xFFE9C46A),
  );

  static const RetroThemeData gameBoy = RetroThemeData(
    name: 'Game Boy',
    type: RetroPaletteType.gameBoy,
    background: Color(0xFF8BAC0F),
    panel: Color(0xFF9BBC0F),
    card: Color(0xFFA3C412),
    ink: Color(0xFF0F380F),
    inkDim: Color(0xFF306230),
    inkMuted: Color(0xFF557C30),
    accentCoral: Color(0xFF306230),
    accentTeal: Color(0xFF0F380F),
    accentYellow: Color(0xFF8BAC0F),
  );

  static const RetroThemeData macintoshMono = RetroThemeData(
    name: 'Mac 1-Bit',
    type: RetroPaletteType.macintoshMono,
    background: Color(0xFFFFFFFF),
    panel: Color(0xFFEBEBEB),
    card: Color(0xFFF5F5F5),
    ink: Color(0xFF000000),
    inkDim: Color(0xFF444444),
    inkMuted: Color(0xFF888888),
    accentCoral: Color(0xFF000000),
    accentTeal: Color(0xFF222222),
    accentYellow: Color(0xFFE0E0E0),
  );

  static const RetroThemeData amberCrt = RetroThemeData(
    name: 'Amber CRT',
    type: RetroPaletteType.amberCrt,
    background: Color(0xFF1A1208),
    panel: Color(0xFF261B0B),
    card: Color(0xFF32230E),
    ink: Color(0xFFFFB000),
    inkDim: Color(0xFFC88400),
    inkMuted: Color(0xFF855700),
    accentCoral: Color(0xFFFF7700),
    accentTeal: Color(0xFFFFCC33),
    accentYellow: Color(0xFFFFEE88),
  );

  static const RetroThemeData synthwave = RetroThemeData(
    name: 'Synthwave',
    type: RetroPaletteType.synthwave,
    background: Color(0xFF2A1B40),
    panel: Color(0xFF392456),
    card: Color(0xFF4A2F70),
    ink: Color(0xFF00FFF5),
    inkDim: Color(0xFFB862FF),
    inkMuted: Color(0xFF7928CA),
    accentCoral: Color(0xFFFF007F),
    accentTeal: Color(0xFF00FFF5),
    accentYellow: Color(0xFFFFE600),
  );

  static List<RetroThemeData> get allThemes => [
    deepNavy,
    parchment,
    gameBoy,
    macintoshMono,
    amberCrt,
    synthwave,
  ];
}
