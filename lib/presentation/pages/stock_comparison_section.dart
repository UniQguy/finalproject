import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_glassy_card.dart';

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
    final double cardWidth = 140 * scale;
    final double cardMargin = 12 * scale;

    return AppGlassyCard(
      borderRadius: BorderRadius.circular(22 * scale),
      padding: EdgeInsets.symmetric(vertical: 22 * scale, horizontal: 14 * scale),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compared with',
              style: GoogleFonts.barlow(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 16 * scale),
            SizedBox(
              height: null, // No fixed height, content dictates!
              child: Row(
                children: comparisons.map((stock) {
                  final bool isPositive = stock['change']!.startsWith('+');
                  return Container(
                    width: cardWidth,
                    margin: EdgeInsets.only(right: cardMargin),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.14),
                          Colors.black.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(17 * scale),
                      border: Border.all(color: Colors.white30, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16 * scale, horizontal: 7 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stock['symbol']!,
                          style: GoogleFonts.barlow(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          stock['name']!,
                          style: GoogleFonts.barlow(
                            fontSize: 12 * scale,
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                        SizedBox(height: 4 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                          decoration: BoxDecoration(
                            color: isPositive ? Colors.greenAccent.withOpacity(0.14) : Colors.redAccent.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            stock['change']!,
                            style: GoogleFonts.barlow(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
