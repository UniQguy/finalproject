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
  late final AnimationController _animationController;
  late final List<FlSpot> spots;
  late final Color glowColor;

  @override
  void initState() {
    super.initState();

    glowColor = widget.isCallOption ? Colors.greenAccent : Colors.redAccent;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Generate sine wave data to simulate live price movement
    spots = List.generate(
      30,
          (i) => FlSpot(i.toDouble(), 50 + 10 * sin(i * pi / 15)),
    );
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
        (animationValue - 0.2).clamp(0.0, 1.0),
        animationValue.clamp(0.0, 1.0),
        (animationValue + 0.2).clamp(0.0, 1.0),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: spots.length - 1,
              minY: 30,
              maxY: 90,
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
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
            ),
          ),
        );
      },
    );
  }
}
