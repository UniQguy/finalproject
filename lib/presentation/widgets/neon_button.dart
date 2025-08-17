import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/theme_provider.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color; // Optional override
  final Color? textColor;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final buttonColor = color ?? themeProvider.primaryColor;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        shadowColor: buttonColor.withOpacity(0.7),
        elevation: 14,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
