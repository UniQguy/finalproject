import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/theme_provider.dart';

class AppGlassyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;
  final Color? borderColor; // Made optional

  const AppGlassyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius,
    this.decoration,
    this.borderColor, // optional borderColor
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final radius = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: decoration ??
              BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: borderColor ?? themeProvider.primaryColor.withOpacity(0.25),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (borderColor ?? themeProvider.primaryColor).withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
          child: child,
        ),
      ),
    );
  }
}
