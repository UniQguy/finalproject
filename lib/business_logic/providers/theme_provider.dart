import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = Colors.tealAccent; // Default accent

  Color get primaryColor => _primaryColor;

  // Adaptive Gain/Loss Colors
  Color get gainColor => _primaryColor; // direct accent for 'Up'

  Color get lossColor {
    // Convert primary accent to HSL for analysis
    final hsl = HSLColor.fromColor(_primaryColor);

    // If primary is in green-blue range, use vivid red for loss
    if (hsl.hue >= 90 && hsl.hue <= 180) {
      return Colors.redAccent;
    }

    // Otherwise, create a complementary tone
    final downHSL = hsl
        .withHue((hsl.hue + 180) % 360)
        .withSaturation(0.7)
        .withLightness(0.5);
    return downHSL.toColor();
  }

  ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _primaryColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _primaryColor,
        selectionColor: _primaryColor.withOpacity(0.4),
        selectionHandleColor: _primaryColor,
      ),
    );
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}
