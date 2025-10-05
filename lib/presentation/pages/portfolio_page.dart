import 'package:finalproject/business_logic/models/stock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/wallet_provider.dart';
import '../../business_logic/models/trade_order.dart';

/// Displays the user's portfolio including holdings, total value, and integrated Sell action.
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.watch<PortfolioProvider>();
    final marketProvider = context.watch<MarketProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final userId = portfolioProvider.userId;

    if (userId.isEmpty) {
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
            onPressed: () => context.go('/home'),
          ),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            'Please login to view your portfolio.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    final holdings = portfolioProvider.currentHoldings;
    final portfolioValue = portfolioProvider.portfolioValue;
    final walletBalance = walletProvider.balance;
    final netWorth = portfolioValue + walletBalance;

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
          onPressed: () => context.go('/home'),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: holdings.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No holdings yet.',
                style: GoogleFonts.barlow(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/trade'),
                child: const Text('Buy Stocks'),
              )
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}',
                style: GoogleFonts.barlow(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Portfolio Value: ₹${portfolioValue.toStringAsFixed(2)}',
                style: GoogleFonts.barlow(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Net Worth: ₹${netWorth.toStringAsFixed(2)}',
                style: GoogleFonts.barlow(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: holdings.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    final TradeOrder holding = holdings[index];
                    final currentMarketStock = marketProvider.stocks.firstWhere(
                          (s) => s.symbol == holding.stockSymbol,
                      orElse: () => Stock(
                        symbol: holding.stockSymbol,
                        company: '',
                        price: holding.price,
                        previousClose: holding.price,
                        recentPrices: [],
                        candles: [],
                      ),
                    );
                    final currentPrice = currentMarketStock.price;
                    final quantity = holding.quantity;
                    final holdingValue = currentPrice * quantity;
                    final pnl = ((currentPrice - holding.price) * quantity);

                    return _PortfolioItem(
                      stockSymbol: holding.stockSymbol,
                      quantity: quantity,
                      avgPrice: holding.price,
                      currentPrice: currentPrice,
                      value: holdingValue,
                      pnl: pnl,
                    );
                  },
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
  final String stockSymbol;
  final int quantity;
  final double avgPrice;
  final double currentPrice;
  final double value;
  final double pnl;

  const _PortfolioItem({
    required this.stockSymbol,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    required this.value,
    required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.read<PortfolioProvider>();

    final pnlColor = pnl >= 0 ? Colors.greenAccent : Colors.redAccent;
    final pnlText = pnl >= 0 ? '+₹${pnl.toStringAsFixed(2)}' : '₹${pnl.toStringAsFixed(2)}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        stockSymbol,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        'Qty: $quantity | Avg Buy Price: ₹${avgPrice.toStringAsFixed(2)} | Current Price: ₹${currentPrice.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Container(
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.purpleAccent,
                  ),
                ),
                Text(
                  pnlText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pnlColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.sell, color: Colors.amberAccent),
              tooltip: 'Sell $stockSymbol',
              onPressed: () {
                // Navigate to trading page prefilled for selling this stock
                context.go('/trade', extra: stockSymbol);
              },
            ),
          ],
        ),
      ),
    );
  }
}
