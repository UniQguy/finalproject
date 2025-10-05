import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/models/trade_order.dart';
import 'package:provider/provider.dart';

/// Displays a dynamic list of trade orders made by the user with sorting and filtering.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.watch<PortfolioProvider>();
    final List<TradeOrder> tradeHistory = List.from(portfolioProvider.tradeHistory);

    tradeHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Orders",
          style: GoogleFonts.barlow(),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: tradeHistory.isEmpty
          ? Center(
        child: Text(
          "No Orders Found",
          style: GoogleFonts.barlow(color: Colors.white70, fontSize: 20),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: tradeHistory.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          final order = tradeHistory[index];
          final isBuy = order.type == OrderType.call;
          final typeText = isBuy ? 'Buy' : 'Sell';
          final typeColor = isBuy ? Colors.greenAccent : Colors.redAccent;

          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$typeText ${order.quantity} x ${order.stockSymbol}",
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: typeColor,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Price: ₹${order.price.toStringAsFixed(2)}",
                  style: GoogleFonts.barlow(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Date: ${order.timestamp.toLocal().toString().split(' ')[0]}",
                  style: GoogleFonts.barlow(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
