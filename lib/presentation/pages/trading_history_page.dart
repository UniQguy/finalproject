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
                // Page heading
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
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ...history.asMap().entries.map((entry) {
                    final index = entry.key;
                    final TradeOrder order = entry.value;
                    final bool isBuy = order.type == OrderType.call;
                    final String typeLabel = isBuy ? "Buy" : "Sell";
                    final Color typeColor =
                    isBuy ? Colors.greenAccent : Colors.redAccent;

                    return AnimatedInView(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppGlassyCard(
                          padding: const EdgeInsets.all(14),
                          borderColor: typeColor, // ✅ Added required borderColor
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon / indicator
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: typeColor.withOpacity(0.15),
                                  border:
                                  Border.all(color: typeColor, width: 1.5),
                                ),
                                child: Icon(
                                  isBuy
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: typeColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(order.timestamp),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
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
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}  ${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}
