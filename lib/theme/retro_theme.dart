import 'package:flutter/material.dart';

enum RetroPaletteType {
  paperBlue,
  deepNavy,
  parchment,
  gameBoy,
  macintoshMono,
  amberCrt,
  synthwave,
  tokyoNight,
  sunsetTape,
  hackerMatrix,
  vaporwave,
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

  static const RetroThemeData paperBlue = RetroThemeData(
    name: 'Paper Blue',
    type: RetroPaletteType.paperBlue,
    background: Color(0xFFFFFFFF),
    panel: Color(0xFFF2F2F2),
    card: Color(0xFFFAFAFA),
    ink: Color(0xFF0A0A0A),
    inkDim: Color(0xFF4A4A4A),
    inkMuted: Color(0xFF888888),
    accentCoral: Color(0xFF3A86FF),
    accentTeal: Color(0xFF00B4D8),
    accentYellow: Color(0xFFFFD166),
  );

  static const RetroThemeData deepNavy = RetroThemeData(
    name: 'Midnight Navy',
    type: RetroPaletteType.deepNavy,
    background: Color(0xFF0A1224),
    panel: Color(0xFF132240),
    card: Color(0xFF1A2E56),
    ink: Color(0xFFF0F6FC),
    inkDim: Color(0xFF88A9CC),
    inkMuted: Color(0xFF436084),
    accentCoral: Color(0xFFFF5376),
    accentTeal: Color(0xFF00E5FF),
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
    accentTeal: Color(0xFF2A9D8F),
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
    name: 'Paper Mono',
    type: RetroPaletteType.macintoshMono,
    background: Color(0xFFFFFFFF),
    panel: Color(0xFFF2F2F2),
    card: Color(0xFFFAFAFA),
    ink: Color(0xFF000000),
    inkDim: Color(0xFF444444),
    inkMuted: Color(0xFF888888),
    accentCoral: Color(0xFFE74C3C),
    accentTeal: Color(0xFF0984E3),
    accentYellow: Color(0xFFF1C40F),
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

  static const RetroThemeData tokyoNight = RetroThemeData(
    name: 'Tokyo Night',
    type: RetroPaletteType.tokyoNight,
    background: Color(0xFF1A1B26),
    panel: Color(0xFF24283B),
    card: Color(0xFF2F354F),
    ink: Color(0xFFC0CAF5),
    inkDim: Color(0xFF7AA2F7),
    inkMuted: Color(0xFF414868),
    accentCoral: Color(0xFFF7768E),
    accentTeal: Color(0xFF7DCFFF),
    accentYellow: Color(0xFFE0AF68),
  );

  static const RetroThemeData sunsetTape = RetroThemeData(
    name: 'Sunset 80s',
    type: RetroPaletteType.sunsetTape,
    background: Color(0xFF2B1824),
    panel: Color(0xFF3E2335),
    card: Color(0xFF522E46),
    ink: Color(0xFFFDE8E9),
    inkDim: Color(0xFFD49AAB),
    inkMuted: Color(0xFF7A485C),
    accentCoral: Color(0xFFFF6B81),
    accentTeal: Color(0xFF2ED573),
    accentYellow: Color(0xFFFFA502),
  );

  static const RetroThemeData hackerMatrix = RetroThemeData(
    name: 'Hacker CRT',
    type: RetroPaletteType.hackerMatrix,
    background: Color(0xFF041008),
    panel: Color(0xFF0A1E11),
    card: Color(0xFF102E1B),
    ink: Color(0xFF39FF14),
    inkDim: Color(0xFF28B80E),
    inkMuted: Color(0xFF196609),
    accentCoral: Color(0xFFFF3366),
    accentTeal: Color(0xFF00FFCC),
    accentYellow: Color(0xFFCCFF00),
  );

  static const RetroThemeData vaporwave = RetroThemeData(
    name: 'Vaporwave',
    type: RetroPaletteType.vaporwave,
    background: Color(0xFF2E174D),
    panel: Color(0xFF3E2066),
    card: Color(0xFF4F2B82),
    ink: Color(0xFFFEE1FF),
    inkDim: Color(0xFFC890E0),
    inkMuted: Color(0xFF7B4D9B),
    accentCoral: Color(0xFFFF71CE),
    accentTeal: Color(0xFF01CDFE),
    accentYellow: Color(0xFFFFFB96),
  );

  static List<RetroThemeData> get allThemes => [
    paperBlue,
    deepNavy,
    parchment,
    gameBoy,
    macintoshMono,
    amberCrt,
    synthwave,
    tokyoNight,
    sunsetTape,
    hackerMatrix,
    vaporwave,
  ];
}
