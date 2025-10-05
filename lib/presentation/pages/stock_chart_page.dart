import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

class StockChartPage extends StatefulWidget {
  final String? stockSymbol;

  const StockChartPage({super.key, this.stockSymbol});

  @override
  State<StockChartPage> createState() => _StockChartPageState();
}

class _StockChartPageState extends State<StockChartPage> {
  String selectedPeriod = '1D';
  String? selectedStockSymbol;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedStockSymbol = widget.stockSymbol;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPrices();
    });
  }

  Future<void> _fetchPrices() async {
    if (selectedStockSymbol == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      final marketProvider = context.read<MarketProvider>();
      await marketProvider.fetchPriceHistory(selectedStockSymbol!, selectedPeriod);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch price data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onPeriodSelected(String period) {
    if (period == selectedPeriod) return;
    setState(() {
      selectedPeriod = period;
    });
    _fetchPrices();
  }

  void _onStockChanged(String? symbol) {
    if (symbol == null || symbol == selectedStockSymbol) return;
    setState(() {
      selectedStockSymbol = symbol;
    });
    _fetchPrices();
  }

  double _responsiveScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1440) return 1.5;
    if (width >= 1024) return 1.2;
    if (width >= 720) return 1.0;
    if (width >= 420) return 0.85;
    return 0.7;
  }

  void _handleBuy(Stock stock, double lastPrice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bought 1 share of ${stock.symbol} @ ₹${lastPrice.toStringAsFixed(2)}')),
    );
    // TODO: Add real buy logic to update portfolio or backend
  }

  void _handleSell(Stock stock, double lastPrice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sold 1 share of ${stock.symbol} @ ₹${lastPrice.toStringAsFixed(2)}')),
    );
    // TODO: Add real sell logic to update portfolio or backend
  }

  @override
  Widget build(BuildContext context) {
    final scale = _responsiveScale(context);
    final marketProvider = context.watch<MarketProvider>();
    final stocks = marketProvider.stocks;
    final stockSymbols = stocks.map((s) => s.symbol).toList();

    final currentSymbol = selectedStockSymbol ?? (stockSymbols.isNotEmpty ? stockSymbols[0] : '');

    final Stock stock = stocks.firstWhere(
          (s) => s.symbol == currentSymbol,
      orElse: () => Stock(
        symbol: currentSymbol,
        company: '',
        price: 0.0,
        previousClose: 0.0,
        recentPrices: [],
        candles: [],
      ),
    );

    final currentPrices = stock.recentPrices;
    final lastPrice = currentPrices.isNotEmpty ? (currentPrices.last as num).toDouble() : 0.0;
    final prevPrice = currentPrices.length > 1 ? (currentPrices[currentPrices.length - 2] as num).toDouble() : lastPrice;
    final change = lastPrice - prevPrice;
    final positive = change >= 0;
    final percentChange = prevPrice != 0 ? (change / prevPrice) * 100 : 0;

    final yMin = currentPrices.isNotEmpty ? currentPrices.reduce(min).toDouble() : 0.0;
    final yMax = currentPrices.isNotEmpty ? currentPrices.reduce(max).toDouble() : 0.0;
    final yRange = yMax - yMin;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.deepPurpleAccent, size: 24 * scale),
          onPressed: () => context.go('/home'),
          splashRadius: 22,
        ),
        title: Text(
          "CHARTS",
          style: GoogleFonts.barlow(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28 * scale,
            letterSpacing: 1.3,
            shadows: [Shadow(color: Colors.deepPurpleAccent.withAlpha(150), blurRadius: 14)],
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stockSymbols.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16 * scale),
                child: DropdownButton<String>(
                  value: currentSymbol,
                  dropdownColor: Colors.black87,
                  iconEnabledColor: Colors.deepPurpleAccent,
                  style: GoogleFonts.barlow(
                    color: Colors.deepPurpleAccent,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                  onChanged: _onStockChanged,
                  items: stockSymbols
                      .map((sym) => DropdownMenuItem(
                    value: sym,
                    child: Text(sym, style: const TextStyle(letterSpacing: 1.2)),
                  ))
                      .toList(),
                ),
              ),
            if (isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
                ),
              )
            else ...[
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
              SizedBox(height: 8),
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
                  ),
                ],
              ),
              SizedBox(height: 24 * scale),
              Expanded(
                child: currentPrices.isEmpty
                    ? Center(
                  child: Text(
                    "No price data available",
                    style: GoogleFonts.barlow(color: Colors.white70, fontSize: 18),
                  ),
                )
                    : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (currentPrices.length - 1).toDouble(),
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
                          interval: currentPrices.length > 5
                              ? (currentPrices.length / 5).floorToDouble()
                              : 1,
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
                        spots: currentPrices
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble()))
                            .toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: positive ? Colors.greenAccent : Colors.redAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (positive ? Colors.greenAccent : Colors.redAccent)
                              .withAlpha((0.3 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final period in ['1D', '5D', '1M', '6M', 'YTD', '1Y', '5Y', 'MAX'])
                    _PeriodButton(
                      label: period,
                      isSelected: selectedPeriod == period,
                      onTap: () => _onPeriodSelected(period),
                    ),
                ],
              ),
              SizedBox(height: 24 * scale),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleSell(stock, lastPrice),
                      icon: const Icon(Icons.sell, color: Colors.white),
                      label: const Text('Sell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleBuy(stock, lastPrice),
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text('Buy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
