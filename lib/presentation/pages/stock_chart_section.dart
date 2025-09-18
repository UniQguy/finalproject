import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../business_logic/providers/market_provider.dart';

class StockChartSection extends StatefulWidget {
  final double scale;

  const StockChartSection({super.key, required this.scale});

  @override
  State<StockChartSection> createState() => _StockChartSectionState();
}

class _StockChartSectionState extends State<StockChartSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Deliberate delay to simulate data loading and show shimmer effect
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;

    final marketProvider = context.watch<MarketProvider>();
    final stocks = marketProvider.stocks;

    final hasData = stocks.isNotEmpty;

    // If no data or empty, we prepare defaults to avoid errors in chart rendering
    final double minPrice =
    hasData ? stocks.map((s) => s.price).reduce((a, b) => a < b ? a : b) : 0;
    final double maxPrice =
    hasData ? stocks.map((s) => s.price).reduce((a, b) => a > b ? a : b) : 0;
    final double priceRange = maxPrice - minPrice;

    return Container(
      height: 280 * scale,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 9),
          )
        ],
      ),
      child: _isLoading
          ? Shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.white,
        enabled: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(24 * scale),
          ),
        ),
      )
          : !hasData
          ? Center(
        child: Text(
          'No stock data available',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 18 * scale,
          ),
        ),
      )
          : LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          minX: 0,
          maxX: stocks.length - 1.toDouble(),
          minY: minPrice,
          maxY: maxPrice,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: priceRange > 0 ? priceRange / 5 : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                stocks.length,
                    (index) =>
                    FlSpot(index.toDouble(), stocks[index].price),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: const LinearGradient(
                colors: [Colors.purpleAccent, Colors.pinkAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: const LinearGradient(
                  colors: [
                    Color(0x885a2a8e), // Semi-transparent purple
                    Color(0x44e91e63), // Lighter pink
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
