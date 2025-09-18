import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_glassy_card.dart';

/// A stylish balance card showing portfolio summary without deposit and withdraw actions.
class BalanceCard extends StatelessWidget {
  final double scale;

  const BalanceCard({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return AppGlassyCard(
      borderRadius: BorderRadius.circular(28 * scale),
      padding: EdgeInsets.all(28 * scale),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 52 * scale,
            color: Colors.deepPurpleAccent,
          ),
          SizedBox(width: 24 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portfolio Balance',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w600,
                  fontSize: 18 * scale,
                  color: Colors.white70,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                '₹2,125,000',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w900,
                  fontSize: 36 * scale,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 12,
                      color: Colors.deepPurpleAccent,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                '+ ₹206,920 (10.6%)',
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Removed Deposit and Withdraw buttons as per requirements
        ],
      ),
    );
  }
}
