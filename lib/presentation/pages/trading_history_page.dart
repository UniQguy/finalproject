import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/models/trade_order.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_gradient_widget.dart';

class TradingHistoryPage extends StatelessWidget {
  const TradingHistoryPage({super.key});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final history = portfolio.tradeHistory;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: history.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: GradientText(
                      text: '📜 Trading History',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                      gradient: LinearGradient(
                        colors: [Colors.amberAccent, Colors.tealAccent],
                      ),
                    ),
                  );
                }
                final order = history[index - 1];
                final isBuy = order.type == OrderType.call;
                final accent = isBuy ? Colors.greenAccent : Colors.redAccent;

                return AnimatedInView(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppGlassyCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: accent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: accent, width: 1.5),
                            ),
                            child: Icon(
                              isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                              color: accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${order.stockSymbol} ${isBuy ? 'Buy' : 'Sell'} ${order.quantity} @ ₹${order.price.toStringAsFixed(2)}',
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
