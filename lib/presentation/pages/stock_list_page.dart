import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/stock_provider.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  final List<String> symbols = ['AAPL', 'GOOGL', 'TSLA', 'MSFT'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().fetchStocks(symbols);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    if (stockProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child:
            CircularProgressIndicator(color: Colors.purpleAccent)),
      );
    }

    if (stockProvider.errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Error: ${stockProvider.errorMessage}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Stocks'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: stockProvider.stocks.length,
        separatorBuilder: (_, __) =>
        const Divider(color: Colors.white24, height: 1),
        itemBuilder: (context, index) {
          final stock = stockProvider.stocks[index];
          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              stock.symbol,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              stock.company,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            trailing: Text(
              '₹${stock.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
