import 'package:flutter/material.dart';

/// Provides app theming with dynamic primary color, dark mode, and system theme support.
class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = Colors.tealAccent; // Default primary accent color

  bool _isDarkMode = true;
  bool _useSystemTheme = false;

  /// Current primary color used throughout the app.
  Color get primaryColor => _primaryColor;

  /// Indicates if dark mode is active.
  bool get isDarkMode => _isDarkMode;

  /// Indicates if app uses system theme preference.
  bool get useSystemTheme => _useSystemTheme;

  /// Returns the color used to indicate gains (positive changes) in trading.
  Color get gainColor => _primaryColor;

  /// Returns the color used to indicate losses (negative changes) in trading.
  /// This calculates a complementary hue and adjusts saturation and lightness.
  Color get lossColor {
    final hsl = HSLColor.fromColor(_primaryColor);
    if (hsl.hue >= 90 && hsl.hue <= 180) {
      return Colors.redAccent;
    }

    final complementaryHue = (hsl.hue + 180) % 360;
    final downHSL = hsl.withHue(complementaryHue).withSaturation(0.7).withLightness(0.5);
    return downHSL.toColor();
  }

  /// Generates a [ThemeData] object based on current settings for use in MaterialApp.
  ThemeData get themeData {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: brightness,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _primaryColor,
        selectionColor: _primaryColor.withOpacity(0.4),
        selectionHandleColor: _primaryColor,
      ),
      fontFamily: 'Barlow',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: brightness == Brightness.dark ? 10 : 6,
        ),
      ),
    );
  }

  /// Updates the primary accent color and notifies listeners.
  void setPrimaryColor(Color color) {
    if (_primaryColor != color) {
      _primaryColor = color;
      notifyListeners();
    }
  }

  /// Toggles dark mode on or off.
  void toggleDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  /// Toggles usage of the system theme preference.
  void toggleUseSystemTheme(bool value) {
    if (_useSystemTheme != value) {
      _useSystemTheme = value;
      notifyListeners();
    }
  }
}
