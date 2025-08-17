import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/animated_wrappers.dart'; // AnimatedInView + AppGlassyCard
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

class RealtimeChart extends StatelessWidget {
  final String stockSymbol;
  final bool isCallOption; // true = Call, false = Put

  const RealtimeChart({
    super.key,
    required this.stockSymbol,
    required this.isCallOption,
  });

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final stock = marketProvider.stocks.firstWhere(
          (s) => s.symbol == stockSymbol,
      orElse: () => Stock(
        symbol: stockSymbol,
        name: '',
        price: 0,
        previousClose: 0,
      ),
    );

    if (stock.recentPrices.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.purpleAccent,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < stock.recentPrices.length; i++) {
      spots.add(FlSpot(i.toDouble(), stock.recentPrices[i]));
    }

    final minPrice = stock.recentPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = stock.recentPrices.reduce((a, b) => a > b ? a : b);

    final gradientColors = isCallOption
        ? [Colors.blueAccent, Colors.lightBlueAccent]
        : [Colors.redAccent, Colors.orangeAccent];

    return AnimatedInView(
      child: AppGlassyCard(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCallOption ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isCallOption ? Colors.greenAccent : Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$stockSymbol ${isCallOption ? 'Call' : 'Put'} Trend",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "₹${stock.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isCallOption ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxPrice - minPrice) / 4,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white12,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        // Remove tooltipBgColor and tooltipStyle entirely!
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              "₹${spot.y.toStringAsFixed(2)}",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    minX: 0,
                    maxX: spots.last.x,
                    minY: minPrice * 0.97,
                    maxY: maxPrice * 1.03,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: LinearGradient(colors: gradientColors),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: gradientColors
                                .map((c) => c.withOpacity(0.15))
                                .toList(),
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
