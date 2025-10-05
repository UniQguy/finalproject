import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/app_glassy_card.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/models/trade_order.dart';

class BalanceCard extends StatelessWidget {
  final double scale;
  const BalanceCard({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.watch<PortfolioProvider>();

    // Get total value of current portfolio holdings (real-time)
    double currentPortfolioValue = portfolioProvider.portfolioValue;

    // Calculate initial investment by summing all buy order values
    double initialInvestment = portfolioProvider.tradeHistory.fold<double>(
      0,
          (previousValue, TradeOrder order) {
        return order.type == OrderType.call // Use enum comparison for buys
            ? previousValue + order.price * order.quantity
            : previousValue;
      },
    );

    // Calculate profit or loss amount and percent (handle division by zero)
    double profitLossAmount = currentPortfolioValue - initialInvestment;
    double profitLossPercent = initialInvestment > 0
        ? (profitLossAmount / initialInvestment) * 100
        : 0;

    Color profitLossColor =
    profitLossAmount >= 0 ? Colors.greenAccent : Colors.redAccent;

    String formattedValue = '₹${currentPortfolioValue.toStringAsFixed(2)}';
    String formattedProfitLoss =
        '${profitLossAmount >= 0 ? '+' : '-'} ₹${profitLossAmount.abs().toStringAsFixed(2)} '
        '(${profitLossPercent.abs().toStringAsFixed(2)}%)';

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
                formattedValue,
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
                formattedProfitLoss,
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: profitLossColor,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
