import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/theme_provider.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient? gradient; // Optional override

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Default gradient uses the primaryColor as first color
    final defaultGradient = LinearGradient(
      colors: [
        themeProvider.primaryColor,
        Colors.purpleAccent,
      ],
    );

    return ShaderMask(
      shaderCallback: (bounds) => (gradient ?? defaultGradient)
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}
