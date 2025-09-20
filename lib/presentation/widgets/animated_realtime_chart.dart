import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';
import 'candlestick_chart.dart'; // Import your candlestick widget here

class AnimatedRealtimeChart extends StatefulWidget {
  final Color accentColor;
  final String? initialSymbol;
  final ValueChanged<String>? onSymbolChanged;

  const AnimatedRealtimeChart({
    super.key,
    required this.accentColor,
    this.initialSymbol,
    this.onSymbolChanged,
  });

  @override
  State<AnimatedRealtimeChart> createState() => _AnimatedRealtimeChartState();
}

class _AnimatedRealtimeChartState extends State<AnimatedRealtimeChart> with SingleTickerProviderStateMixin {
  late String selectedSymbol;
  List<double> prices = [];
  List<FlSpot> spots = [];
  int touchedIndex = -1;
  late final AnimationController _pulseController;

  bool _showCandlestick = false;

  @override
  void initState() {
    super.initState();

    selectedSymbol = widget.initialSymbol ?? '';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketProvider = context.read<MarketProvider>();
      marketProvider.addListener(_updatePrices);
    });

    _updatePrices();
  }

  @override
  void didUpdateWidget(covariant AnimatedRealtimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialSymbol != null && widget.initialSymbol != selectedSymbol) {
      selectedSymbol = widget.initialSymbol!;
      _updatePrices();
    }
  }

  void _updatePrices() {
    if (selectedSymbol.isEmpty) return;

    final marketProvider = context.read<MarketProvider>();
    final stock = marketProvider.stocks.firstWhere(
          (s) => s.symbol == selectedSymbol,
      orElse: () => Stock(
        symbol: selectedSymbol,
        company: '',
        price: 0,
        previousClose: 0,
        recentPrices: [],
      ),
    );

    setState(() {
      prices = stock.recentPrices.isNotEmpty ? stock.recentPrices : _simulatePrices();
      spots = List.generate(prices.length, (i) => FlSpot(i.toDouble(), prices[i]));
      touchedIndex = -1;
    });
  }

  List<double> _simulatePrices() {
    final rand = Random();
    return List.generate(30, (i) => 100 + 10 * sin(i * pi / 15) + rand.nextDouble() * 4 - 2);
  }

  void _onSymbolChanged(String? newSymbol) {
    if (newSymbol == null) return;

    if (newSymbol != selectedSymbol) {
      setState(() {
        selectedSymbol = newSymbol;
        touchedIndex = -1;
      });

      _updatePrices();

      widget.onSymbolChanged?.call(newSymbol);
    }
  }

  void _onTouchCallback(FlTouchEvent event, LineTouchResponse? touch) {
    if (touch == null || touch.lineBarSpots == null || touch.lineBarSpots!.isEmpty) {
      setState(() => touchedIndex = -1);
      return;
    }

    final index = touch.lineBarSpots!.first.spotIndex;
    if (index != touchedIndex) {
      HapticFeedback.lightImpact();
      setState(() => touchedIndex = index);
    }
  }

  @override
  void dispose() {
    final marketProvider = context.read<MarketProvider>();
    marketProvider.removeListener(_updatePrices);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;
    final marketProvider = context.watch<MarketProvider>();
    final glowColor = widget.accentColor;

    final selectedStock = marketProvider.stocks.firstWhere(
          (s) => s.symbol == selectedSymbol,
      orElse: () => Stock(symbol: selectedSymbol, company: '', price: 0, previousClose: 0, recentPrices: []),
    );

    final minY = prices.isNotEmpty ? prices.reduce(min) * 0.95 : 0.0;
    final maxY = prices.isNotEmpty ? prices.reduce(max) * 1.05 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Stock",
                    labelStyle: TextStyle(color: glowColor, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: glowColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: glowColor, width: 2)),
                  ),
                  dropdownColor: Colors.grey.shade900,
                  value: selectedSymbol.isEmpty ? null : selectedSymbol,
                  items: marketProvider.stocks.map((stock) {
                    return DropdownMenuItem(
                      value: stock.symbol,
                      child: Text(stock.symbol, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: _onSymbolChanged,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: [
                    Text("Candlestick", style: TextStyle(color: glowColor, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _showCandlestick,
                      onChanged: (val) {
                        setState(() {
                          _showCandlestick = val;
                          touchedIndex = -1;
                        });
                      },
                      activeColor: glowColor,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _showCandlestick
              ? CandlestickChartWidget(stockSymbol: selectedStock.symbol)

              : Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: prices.length > 0 ? (prices.length - 1).toDouble() : 30.0,
                      minY: minY,
                      maxY: maxY,
                      clipData: FlClipData.all(),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchCallback: _onTouchCallback,
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 12,
                          tooltipBgColor: glowColor.withOpacity(0.8),
                          getTooltipItems: (spots) {
                            return spots.map((spot) => LineTooltipItem(
                              spot.y.toStringAsFixed(2),
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            )).toList();
                          },
                        ),
                        touchSpotThreshold: 20.0,
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: glowColor,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                glowColor.withOpacity(0.3),
                                glowColor.withOpacity(0.8),
                                glowColor.withOpacity(0.3),
                              ],
                              stops: const [0.2, 0.5, 0.8],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              final isNewest = index == spots.length - 1;
                              final double pulse = isNewest ? 7 + 3 * _pulseController.value : 6;
                              final double opacity = isNewest ? 0.8 + 0.2 * _pulseController.value : 1;
                              return FlDotCirclePainter(
                                radius: pulse,
                                color: glowColor.withOpacity(opacity),
                                strokeWidth: isNewest ? 3 : 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (val) => FlLine(
                          color: Colors.white.withOpacity(0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text('Time'),
                          axisNameSize: 16,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 28,
                            getTitlesWidget: (val, _) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(val.toInt().toString(), style: const TextStyle(color: Colors.white70)),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text('Price'),
                          axisNameSize: 16,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            reservedSize: 42,
                            getTitlesWidget: (val, _) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(val.toInt().toString(), style: const TextStyle(color: Colors.white54)),
                            ),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Text(
                  selectedSymbol.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: glowColor,
                    shadows: [
                      Shadow(
                        color: glowColor.withOpacity(0.7),
                        blurRadius: 5,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Price: ${prices.isNotEmpty ? prices.last.toStringAsFixed(2) : "--"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: glowColor,
                ),
              ),
              _showCandlestick
                  ? const SizedBox.shrink()
                  : (touchedIndex >= 0 && touchedIndex < prices.length
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Price: ${prices[touchedIndex].toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: glowColor),
                  ),
                  if (touchedIndex > 0)
                    Text(
                      'Δ: ${(prices[touchedIndex] - prices[touchedIndex - 1]).toStringAsFixed(2)}'
                          ' (${((prices[touchedIndex] - prices[touchedIndex - 1]) / prices[touchedIndex - 1] * 100).toStringAsFixed(2)}%)',
                      style: TextStyle(color: glowColor.withOpacity(0.8)),
                    ),
                ],
              )
                  : const Text('Touch the chart for details', style: TextStyle(color: Colors.white54))),
            ],
          ),
        ),
      ],
    );
  }
}
