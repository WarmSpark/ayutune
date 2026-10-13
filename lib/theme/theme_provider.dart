import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'retro_theme.dart';

class ThemeProvider extends ChangeNotifier {
  RetroThemeData _currentTheme = RetroThemeData.paperBlue;
  Color? _customPrimary;
  Color? _customSecondary;
  Color? _customAccent;

  RetroThemeData get currentTheme => _currentTheme;
  Color? get customPrimary => _customPrimary;
  Color? get customSecondary => _customSecondary;
  Color? get customAccent => _customAccent;
  bool get hasCustomTheme => _customPrimary != null;

  ThemeProvider() {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pInt = prefs.getInt('custom_primary');
      final sInt = prefs.getInt('custom_secondary');
      final aInt = prefs.getInt('custom_accent');

      if (pInt != null && sInt != null && aInt != null) {
        _customPrimary = Color(pInt);
        _customSecondary = Color(sInt);
        _customAccent = Color(aInt);
      }

      final savedTypeName = prefs.getString('saved_theme_type');
      if (savedTypeName == 'custom' && _customPrimary != null) {
        _currentTheme = RetroThemeData.custom(
          primary: _customPrimary!,
          secondary: _customSecondary!,
          accent: _customAccent!,
        );
      } else if (savedTypeName != null && savedTypeName != 'deepNavy') {
        for (final t in RetroThemeData.allThemes) {
          if (t.type.name == savedTypeName) {
            _currentTheme = t;
            break;
          }
        }
      } else {
        _currentTheme = RetroThemeData.paperBlue;
      }
      notifyListeners();
    } catch (_) {}
  }

  void setTheme(RetroThemeData theme) {
    _currentTheme = theme;
    _saveTheme();
    notifyListeners();
  }

  void setCustomTheme({
    required Color primary,
    required Color secondary,
    required Color accent,
  }) {
    _customPrimary = primary;
    _customSecondary = secondary;
    _customAccent = accent;
    _currentTheme = RetroThemeData.custom(
      primary: primary,
      secondary: secondary,
      accent: accent,
    );
    _saveCustomTheme();
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveCustomTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_customPrimary != null && _customSecondary != null && _customAccent != null) {
        await prefs.setInt('custom_primary', _customPrimary!.toARGB32());
        await prefs.setInt('custom_secondary', _customSecondary!.toARGB32());
        await prefs.setInt('custom_accent', _customAccent!.toARGB32());
      }
    } catch (_) {}
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_theme_type', _currentTheme.type.name);
    } catch (_) {}
  }

  void setThemeByType(RetroPaletteType type) {
    if (type == RetroPaletteType.custom && _customPrimary != null) {
      setCustomTheme(
        primary: _customPrimary!,
        secondary: _customSecondary!,
        accent: _customAccent!,
      );
      return;
    }
    final selected = RetroThemeData.allThemes.firstWhere(
      (theme) => theme.type == type,
      orElse: () => RetroThemeData.paperBlue,
    );
    setTheme(selected);
  }
}
