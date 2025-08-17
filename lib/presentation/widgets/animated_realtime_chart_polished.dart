import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedRealtimeChart extends StatefulWidget {
  final String stockSymbol;
  final bool isCallOption;
  final Color accentColor;

  const AnimatedRealtimeChart({
    Key? key,
    required this.stockSymbol,
    required this.isCallOption,
    required this.accentColor,
  }) : super(key: key);

  @override
  _AnimatedRealtimeChartState createState() => _AnimatedRealtimeChartState();
}

class _AnimatedRealtimeChartState extends State<AnimatedRealtimeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<FlSpot> spots;
  late Color glowColor;

  @override
  void initState() {
    super.initState();

    glowColor = widget.isCallOption ? Colors.greenAccent : Colors.redAccent;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Sample data: sine wave spots to simulate live data
    spots = List.generate(30, (index) {
      return FlSpot(index.toDouble(), 50 + 10 * sin(index * pi / 15));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  LinearGradient _glowGradient(double animationValue) {
    return LinearGradient(
      colors: [
        glowColor.withOpacity(0.3),
        glowColor,
        glowColor.withOpacity(0.3),
      ],
      stops: [
        (animationValue - 0.2).clamp(0, 1),
        animationValue.clamp(0, 1),
        (animationValue + 0.2).clamp(0, 1),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        return SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: spots.length - 1.toDouble(),
              minY: 30,
              maxY: 90,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  // Removed preventCurveOvershooting to fix the error
                  barWidth: 4,
                  isStrokeCapRound: true,
                  color: glowColor,
                  gradient: _glowGradient(_animationController.value),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: _glowGradient(_animationController.value),
                  ),
                  dotData: FlDotData(show: false),
                ),
              ],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
