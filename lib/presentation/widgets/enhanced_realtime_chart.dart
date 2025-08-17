import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'animated_in_view.dart';
import 'app_glassy_card.dart';
import 'gradient_text.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/models/stock.dart';

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({super.key, required this.color, this.size = 14});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _animation =
        Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.7),
              blurRadius: 8,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedRealtimeChart extends StatelessWidget {
  final String stockSymbol;
  final bool isCallOption;

  const EnhancedRealtimeChart({
    super.key,
    required this.stockSymbol,
    required this.isCallOption,
  });

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final stock = marketProvider.stocks.firstWhere(
          (s) => s.symbol == stockSymbol,
      orElse: () =>
          Stock(symbol: stockSymbol, name: '', price: 0, previousClose: 0),
    );

    if (stock.recentPrices.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    final spots = [
      for (int i = 0; i < stock.recentPrices.length; i++)
        FlSpot(i.toDouble(), stock.recentPrices[i])
    ];

    final minPrice = stock.recentPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = stock.recentPrices.reduce((a, b) => a > b ? a : b);

    final gradientColors = [
      themeProvider.primaryColor, // dynamic primary
      themeProvider.primaryColor.withOpacity(0.6),
    ];

    List<LineChartBarData> glowBars() {
      final bars = <LineChartBarData>[];
      for (int i = 3; i >= 1; i--) {
        bars.add(LineChartBarData(
          spots: spots,
          isCurved: true,
          color: gradientColors.first.withOpacity(0.1 * i),
          barWidth: 4.0 + 3.0 * i.toDouble(),
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ));
      }
      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors.map((c) => c.withOpacity(0.9)).toList(),
          ),
          barWidth: 4.0,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.4)).toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
      return bars;
    }

    return AnimatedInView(
      child: AppGlassyCard(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(20),
        borderColor: themeProvider.primaryColor, // dynamic border
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isCallOption ? Icons.arrow_upward : Icons.arrow_downward,
                    color: themeProvider.primaryColor,
                    shadows: [
                      Shadow(
                        color: themeProvider.primaryColor.withOpacity(0.85),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GradientText(
                    text: '$stockSymbol ${isCallOption ? "Call" : "Put"} Trend',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  PulsingDot(color: themeProvider.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "₹${stock.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: themeProvider.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxPrice - minPrice) / 5,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white12,
                        strokeWidth: 1,
                        dashArray: [5, 10],
                      ),
                    ),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(enabled: true),
                    minX: 0,
                    maxX: spots.last.x,
                    minY: minPrice * 0.95,
                    maxY: maxPrice * 1.05,
                    lineBarsData: glowBars(),
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
