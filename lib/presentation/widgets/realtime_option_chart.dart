import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/animated_wrappers.dart'; // For AnimatedInView ONLY
import '../widgets/app_glassy_card.dart';   // For AppGlassyCard ONLY
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

class RealtimeOptionChart extends StatefulWidget {
  final String stockSymbol;
  final bool isCallOption;

  const RealtimeOptionChart({
    super.key,
    required this.stockSymbol,
    required this.isCallOption,
  });

  @override
  State<RealtimeOptionChart> createState() => _RealtimeOptionChartState();
}

class _RealtimeOptionChartState extends State<RealtimeOptionChart> {
  late Timer _timer;
  List<double> _pricePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchLatestData());
  }

  void _fetchInitialData() {
    final market = context.read<MarketProvider>();
    final stock = market.stocks.firstWhere(
          (s) => s.symbol == widget.stockSymbol,
      orElse: () => Stock(
        symbol: widget.stockSymbol,
        company: widget.stockSymbol,
        price: 0,
        previousClose: 0,
        recentPrices: [],
      ),
    );

    final dynamic dynamicStock = stock;
    if (dynamicStock.recentPrices is List<double> && (dynamicStock.recentPrices as List).isNotEmpty) {
      _pricePoints = List<double>.from(dynamicStock.recentPrices);
    } else {
      _pricePoints = [stock.price];
    }
    setState(() {});
  }

  void _fetchLatestData() {
    final market = context.read<MarketProvider>();
    final stock = market.stocks.firstWhere(
          (s) => s.symbol == widget.stockSymbol,
      orElse: () => Stock(
        symbol: widget.stockSymbol,
        company: widget.stockSymbol,
        price: 0,
        previousClose: 0,
        recentPrices: [],
      ),
    );

    setState(() {
      _pricePoints.add(stock.price);
      if (_pricePoints.length > 60) {
        _pricePoints.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pricePoints.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final minPrice = _pricePoints.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxPrice = _pricePoints.reduce((a, b) => a > b ? a : b) * 1.05;

    final gradientColors = widget.isCallOption
        ? [Colors.blueAccent, Colors.lightBlueAccent]
        : [Colors.redAccent, Colors.orangeAccent];

    return AnimatedInView(
      index: 0, // Required index parameter added here
      child: AppGlassyCard(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(enabled: true),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (_pricePoints.length - 1).toDouble(),
              minY: minPrice,
              maxY: maxPrice,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    _pricePoints.length,
                        (i) => FlSpot(i.toDouble(), _pricePoints[i]),
                  ),
                  isCurved: true,
                  gradient: LinearGradient(colors: gradientColors),
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
