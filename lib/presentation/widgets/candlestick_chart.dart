import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:provider/provider.dart';
import '../../business_logic/models/stock.dart';
import '../../business_logic/providers/stock_provider.dart';

class CandlestickChartWidget extends StatefulWidget {
  final String stockSymbol;

  const CandlestickChartWidget({Key? key, required this.stockSymbol}) : super(key: key);

  @override
  State<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends State<CandlestickChartWidget> {
  List<Candle> candles = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCandles();
  }

  Future<void> _fetchCandles() async {
    final stockProvider = context.read<StockProvider>();
    await stockProvider.fetchStocks([widget.stockSymbol]);
    if (!mounted) return;

    // Find the stock by symbol
    Stock? stock;
    for (final s in stockProvider.stocks) {
      if (s.symbol == widget.stockSymbol) {
        stock = s;
        break;
      }
    }

    if (stock == null) {
      setState(() {
        errorMessage = "No stock found for symbol: ${widget.stockSymbol}";
        isLoading = false;
      });
      return;
    }

    // Use available price data (recentPrices is just a List<double>)
    final prices = stock.recentPrices ?? [];
    if (prices.isEmpty) {
      setState(() {
        errorMessage = "No price data available.";
        isLoading = false;
      });
      return;
    }

    List<Candle> data = [];
    final now = DateTime.now();
    final len = prices.length;

    for (int i = 0; i < len; i++) {
      double open = prices[i] * (0.98 + (i % 3) * 0.01);
      double close = prices[i];
      double high = (open > close ? open : close) * (1 + 0.02 * (i % 2));
      double low = (open < close ? open : close) * (1 - 0.02 * ((i + 1) % 2));
      double volume = 1000 + 500 * (i % 5);

      data.add(
        Candle(
          date: now.subtract(Duration(days: len - i)),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );
    }

    setState(() {
      candles = data;
      isLoading = false;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF071A3F), Color(0xFF203663)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Candlesticks(
        candles: candles,
        onLoadMoreCandles: () async {
          // Optionally implement fetching more data here
        },
      ),
    );
  }
}
