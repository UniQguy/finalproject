import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/models/trade_order.dart';
import 'package:go_router/go_router.dart';

class TradingHistoryPage extends StatelessWidget {
  const TradingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final List<TradeOrder> history = portfolio.tradeHistory;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Page heading with gradient text
                GradientText(
                  text: '📜 Trading History',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: const LinearGradient(
                    colors: [Colors.amberAccent, Colors.tealAccent],
                  ),
                ),
                const SizedBox(height: 20),
                if (history.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No past trades found.",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...history.asMap().entries.map((entry) {
                    final index = entry.key;
                    final TradeOrder order = entry.value;
                    final bool isBuy = order.type == OrderType.call;
                    final String typeLabel = isBuy ? "Buy" : "Sell";
                    final Color typeColor = isBuy ? Colors.greenAccent : Colors.redAccent;

                    return AnimatedInView(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppGlassyCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: typeColor,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Indicator icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: typeColor.withOpacity(0.2),
                                  border: Border.all(color: typeColor, width: 1.5),
                                ),
                                child: Icon(
                                  isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: typeColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Trade details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${order.stockSymbol} $typeLabel ${order.quantity} @ ₹${order.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatDate(order.timestamp),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year  $hour:$minute';
  }
}
