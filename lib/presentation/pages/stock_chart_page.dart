import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class StockChartPage extends StatefulWidget {
  final String stockSymbol;
  final List<double> prices;

  const StockChartPage({
    super.key,
    required this.stockSymbol,
    this.prices = const [150, 152, 148, 154, 156, 158, 160],
  });

  @override
  State<StockChartPage> createState() => _StockChartPageState();
}

class _StockChartPageState extends State<StockChartPage> {
  late List<double> currentPrices;
  String selectedPeriod = '1D';

  @override
  void initState() {
    super.initState();
    currentPrices = widget.prices;
    // TODO: Load actual data based on stockSymbol and initial period selected (1D)
  }

  double _responsiveScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1440) return 1.5;
    if (width >= 1024) return 1.2;
    if (width >= 720) return 1.0;
    if (width >= 420) return 0.85;
    return 0.7;
  }

  void _onPeriodSelected(String period) {
    setState(() {
      selectedPeriod = period;
      // TODO: Fetch and update currentPrices based on the selected period
      // Example: currentPrices = fetchPrices(stockSymbol, period);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _responsiveScale(context);

    final prices = currentPrices;
    final double lastPrice = prices.isNotEmpty ? prices.last : 0;
    final double prevPrice = prices.length > 1 ? prices[prices.length - 2] : lastPrice;
    final double change = lastPrice - prevPrice;
    final bool positive = change >= 0;
    final double percentChange = prevPrice != 0 ? (change / prevPrice) * 100 : 0;

    final double yMin = prices.isNotEmpty ? prices.reduce(min) : 0;
    final double yMax = prices.isNotEmpty ? prices.reduce(max) : 0;
    final double yRange = yMax - yMin;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.deepPurpleAccent,
            size: 24 * scale,
          ),
          onPressed: () => context.go('/home'),
          splashRadius: 22,
        ),
        title: Text(
          widget.stockSymbol,
          style: GoogleFonts.barlow(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24 * scale,
            letterSpacing: 1.3,
            shadows: [
              Shadow(
                color: Colors.deepPurpleAccent.withAlpha(150),
                blurRadius: 14,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "₹${lastPrice.toStringAsFixed(2)}",
              style: GoogleFonts.barlow(
                fontSize: 44 * scale,
                fontWeight: FontWeight.w900,
                color: positive ? Colors.greenAccent : Colors.redAccent,
                shadows: [
                  Shadow(
                    color: (positive ? Colors.greenAccent : Colors.redAccent).withOpacity(0.8),
                    blurRadius: 20,
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  positive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: positive ? Colors.greenAccent : Colors.redAccent,
                  size: 22 * scale,
                ),
                SizedBox(width: 4),
                Text(
                  "${positive ? '+' : ''}${percentChange.toStringAsFixed(2)}%",
                  style: GoogleFonts.barlow(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: positive ? Colors.greenAccent : Colors.redAccent,
                  ),
                )
              ],
            ),
            SizedBox(height: 24 * scale),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: prices.isNotEmpty ? (prices.length - 1).toDouble() : 0,
                  minY: yMin * 0.95,
                  maxY: yMax * 1.05,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: yRange > 0 ? yRange / 5 : 1,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Colors.white12,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: prices.length > 5 ? (prices.length / 5).floorToDouble() : 1,
                        reservedSize: 30,
                        getTitlesWidget: _bottomTitleWidgets,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yRange > 0 ? yRange / 5 : 1,
                        reservedSize: 40,
                        getTitlesWidget: _leftTitleWidgets,
                      ),
                    ),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: prices.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: positive ? Colors.greenAccent : Colors.redAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (positive ? Colors.greenAccent : Colors.redAccent).withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['1D', '5D', '1M', '6M', 'YTD', '1Y', '5Y', 'MAX']
                  .map((period) => _PeriodButton(
                label: period,
                isSelected: period == selectedPeriod,
                onTap: () => _onPeriodSelected(period),
              ))
                  .toList(),
            ),
            SizedBox(height: 24 * scale),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Sell functionality
                    },
                    icon: const Icon(Icons.sell, color: Colors.white),
                    label: const Text('Sell',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Buy functionality
                    },
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text('Buy',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index > meta.max.toInt()) return const SizedBox.shrink();
    final interval = (meta.max / 5).floor();
    if (interval == 0) return const SizedBox.shrink();
    if (index % interval != 0) return const SizedBox.shrink();

    final labelDate = DateTime.now().subtract(Duration(days: meta.max.toInt() - index));
    final label = '${labelDate.day}/${labelDate.month}';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }

  static Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurpleAccent : Colors.white12,
        foregroundColor: isSelected ? Colors.white : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
