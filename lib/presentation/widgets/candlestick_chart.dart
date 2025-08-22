import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import '../../business_logic/models/stock.dart';

class CandlestickChartWidget extends StatefulWidget {
  final Stock stock;

  const CandlestickChartWidget({Key? key, required this.stock}) : super(key: key);

  @override
  State<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends State<CandlestickChartWidget> {
  List<Candle> candles = [];

  @override
  void initState() {
    super.initState();
    _generateCandles();
  }

  void _generateCandles() {
    final prices = widget.stock.recentPrices;
    List<Candle> data = [];
    final now = DateTime.now();
    final len = prices.length;

    for (int i = 0; i < len; i++) {
      double open = prices[i] * (0.98 + (i % 3) * 0.01); // simulate variability
      double close = prices[i];
      double high =
          (open > close ? open : close) * (1 + 0.02 * (i % 2)); // higher of open/close with a % up
      double low =
          (open < close ? open : close) * (1 - 0.02 * ((i + 1) % 2)); // lower of open/close with % down
      double volume = 1000 + 500 * (i % 5); // simulated volume

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

    setState(() => candles = data);
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
      child: Candlesticks(
        candles: candles,
        onLoadMoreCandles: () async {
          // Optional: Fetch and append more candle data here
          await Future.delayed(const Duration(seconds: 1));
        },
      ),
    );
  }
}
