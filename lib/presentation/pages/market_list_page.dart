import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

/// Page that displays a scrollable list of market movers with price changes indicated.
class MarketListPage extends StatelessWidget {
  const MarketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final stocks = marketProvider.stocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Movers'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          final prevPrice = marketProvider.previousPrice(stock.symbol) ?? stock.price;
          final priceUp = stock.price >= prevPrice;

          return ListTile(
            title: Text(
              stock.symbol,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              stock.company,
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${stock.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: priceUp ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  priceUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: priceUp ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
