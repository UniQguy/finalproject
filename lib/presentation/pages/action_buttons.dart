import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A pair of styled action buttons for buying and selling stocks, with responsive scaling.
class ActionButtons extends StatelessWidget {
  final double scale;

  const ActionButtons({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: Colors.redAccent.withOpacity(0.6),
            ),
            icon: Icon(Icons.sell, color: Colors.white, size: 22 * scale),
            label: Text(
              'Sell',
              style: GoogleFonts.barlow(
                fontWeight: FontWeight.bold,
                fontSize: 20 * scale,
              ),
            ),
            onPressed: () {
              // TODO: Implement Sell functionality
            },
          ),
        ),
        SizedBox(width: 22 * scale),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: Colors.greenAccent.withOpacity(0.6),
            ),
            icon: Icon(Icons.shopping_cart, color: Colors.white, size: 22 * scale),
            label: Text(
              'Buy',
              style: GoogleFonts.barlow(
                fontWeight: FontWeight.bold,
                fontSize: 20 * scale,
              ),
            ),
            onPressed: () {
              // TODO: Implement Buy functionality
            },
          ),
        ),
      ],
    );
  }
}
