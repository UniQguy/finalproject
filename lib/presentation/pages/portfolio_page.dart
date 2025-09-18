import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/models/trade_order.dart';

/// Displays the user’s portfolio including holdings, total value, and clear action.
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.watch<PortfolioProvider>();
    final holdings = portfolioProvider.holdings.values.toList();
    final totalValue = portfolioProvider.portfolioValue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Portfolio',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
            color: Colors.purpleAccent,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Navigate back to homepage
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: holdings.isEmpty
              ? Center(
            child: Text(
              'No holdings yet.',
              style: GoogleFonts.barlow(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Value: ₹${totalValue.toStringAsFixed(2)}',
                style: GoogleFonts.barlow(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: holdings.length,
                  separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    final TradeOrder order = holdings[index];
                    return _PortfolioItem(order: order);
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.barlow(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => portfolioProvider.clearPortfolio(),
                  child: const Text('Clear Portfolio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioItem extends StatelessWidget {
  final TradeOrder order;

  const _PortfolioItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.read<PortfolioProvider>();
    final holdingValue = order.price * order.quantity;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      title: Text(
        order.stockSymbol,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        'Quantity: ${order.quantity} | Type: ${order.type}',
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '₹${holdingValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.purpleAccent,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => portfolioProvider.removeHolding(order.stockSymbol),
            tooltip: 'Remove ${order.stockSymbol} from portfolio',
          ),
        ],
      ),
    );
  }
}
