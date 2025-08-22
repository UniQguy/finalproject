import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_glassy_card.dart';

/// Displays a compact, neat comparison of selected stocks with price and daily percentage change,
/// optimized spacing and responsive design.
class StockComparisonSection extends StatelessWidget {
  final double scale;
  const StockComparisonSection({super.key, this.scale = 1.0});

  static const List<Map<String, String>> comparisons = [
    {'name': 'Bukalapak Tbk', 'symbol': 'BUKA', 'price': 'Rp276.00', 'change': '+2.82%'},
    {'name': 'Bank Rakyat Indonesia', 'symbol': 'BBRI', 'price': 'Rp4,630.00', 'change': '+0.82%'},
    {'name': 'PT Industri', 'symbol': 'SIDO', 'price': 'Rp740.00', 'change': '-0.15%'},
  ];

  @override
  Widget build(BuildContext context) {
    final double cardHorizontalMargin = 8 * scale;

    return AppGlassyCard(
      borderRadius: BorderRadius.circular(22 * scale),
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compared with',
            style: GoogleFonts.barlow(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 18 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: comparisons.map((stock) {
              final bool isPositive = stock['change']!.startsWith('+');
              return Flexible(
                fit: FlexFit.tight,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: cardHorizontalMargin / 2),
                  padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 12 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(18 * scale),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stock['symbol']!,
                        style: GoogleFonts.barlow(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        stock['name']!,
                        style: GoogleFonts.barlow(
                          fontSize: 13 * scale,
                          color: Colors.white54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        stock['price']!,
                        style: GoogleFonts.barlow(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        stock['change']!,
                        style: GoogleFonts.barlow(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
