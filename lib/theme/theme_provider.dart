import 'package:flutter/material.dart';
import 'retro_theme.dart';

class ThemeProvider extends ChangeNotifier {
  RetroThemeData _currentTheme = RetroThemeData.deepNavy;

  RetroThemeData get currentTheme => _currentTheme;

  void setTheme(RetroThemeData theme) {
    if (_currentTheme.type != theme.type) {
      _currentTheme = theme;
      notifyListeners();
    }
  }

  void setThemeByType(RetroPaletteType type) {
    final selected = RetroThemeData.allThemes.firstWhere(
      (theme) => theme.type == type,
      orElse: () => RetroThemeData.deepNavy,
    );
    setTheme(selected);
  }
}
