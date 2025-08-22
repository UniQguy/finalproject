import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final int year = DateTime.now().year;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            color: Colors.white24,
            thickness: 1.0,
          ),
          const SizedBox(height: 6),
          Text(
            '© $year DemoTrader. All rights reserved.',
            textAlign: TextAlign.center,
            style: GoogleFonts.barlow(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crafted with 💜 using Flutter & Provider',
            textAlign: TextAlign.center,
            style: GoogleFonts.barlow(
              fontSize: 12,
              color: Colors.white38,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
