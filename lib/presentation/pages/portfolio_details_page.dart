import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Models
import '../../business_logic/models/trade_order.dart';
import '../../business_logic/models/stock.dart';

// Animated Wrappers
import '../widgets/animated_wrappers.dart'; // For AnimatedInView ONLY
import '../widgets/app_glassy_card.dart';   // For AppGlassyCard ONLY

/// Displays detailed information about a portfolio position and provides sell/close actions.
class PortfolioDetailsPage extends StatelessWidget {
  final TradeOrder order;
  final Stock marketStock;
  final double profit;
  final double profitPercent;

  const PortfolioDetailsPage({
    super.key,
    required this.order,
    required this.marketStock,
    required this.profit,
    required this.profitPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = profit >= 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.purpleAccent,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${order.stockSymbol} Details',
          style: const TextStyle(color: Colors.purpleAccent),
        ),
        backgroundColor: Colors.black,
        elevation: 2,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // Stock overview card with color-coded border
          AnimatedInView(
            index: 0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isProfit ? Colors.greenAccent : Colors.redAccent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.stockSymbol,
                      style: TextStyle(
                        color: isProfit ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      marketStock.company,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Current Price:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '₹${marketStock.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Bought At:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '₹${order.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Investment overview card
          AnimatedInView(
            index: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purpleAccent, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Investment Overview',
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Quantity:',
                            style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const Spacer(),
                        Text(
                          '${order.quantity}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Profit / Loss:',
                            style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const Spacer(),
                        Text(
                          '${isProfit ? '+' : ''}${profit.toStringAsFixed(2)}  (${profitPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: isProfit ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          AnimatedInView(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sell action coming soon...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Sell',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
