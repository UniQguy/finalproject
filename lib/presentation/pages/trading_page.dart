import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- REQUIRED for FlSpot, LineChart, etc.

import '../../business_logic/models/stock.dart';
import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/portfolio_provider.dart';

import '../widgets/animated_wrappers.dart';
import '../widgets/interactive_call_put_toggle.dart';
import '../widgets/parallax_card.dart';
import 'order_confirmation_page.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});
  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage>
    with SingleTickerProviderStateMixin {
  Stock? _selectedStock;
  int _quantity = 1;
  bool _isCall = true;

  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;

  @override
  void initState() {
    super.initState();
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonScaleAnim = CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.elasticOut,
    );
    _buttonAnimController.forward();
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (_selectedStock == null || _quantity <= 0) return;
    final order = TradeOrder(
      stockSymbol: _selectedStock!.symbol,
      type: _isCall ? OrderType.call : OrderType.put,
      price: _selectedStock!.price,
      quantity: _quantity,
      timestamp: DateTime.now(),
    );
    context.read<PortfolioProvider>().addOrder(order);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, anim, _) => FadeTransition(
          opacity: anim,
          child: OrderConfirmationPage(
            stock: _selectedStock!,
            quantity: _quantity,
            isCall: _isCall,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: Colors.white10,
      prefixIcon: icon != null ? Icon(icon, color: Colors.purpleAccent) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stocks = context.watch<MarketProvider>().stocks;
    final Color accent = Colors.purpleAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Trade',
          style: TextStyle(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 10,
        shadowColor: Colors.purpleAccent.withOpacity(0.18),
        actions: [
          Icon(Icons.flash_on, color: Colors.purpleAccent.shade100, size: 26),
          const SizedBox(width: 14),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ParticlePainter(accent: accent)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ListView(
              children: [
                AnimatedInView(
                  index: 0,
                  child: ParallaxCard(
                    child: _GlowingCard(
                      borderColor: accent,
                      child: DropdownButtonFormField<Stock>(
                        decoration: _inputDeco('Select Stock', icon: Icons.timeline),
                        value: _selectedStock,
                        dropdownColor: Colors.deepPurple.shade900,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        items: stocks
                            .map((stock) => DropdownMenuItem(
                          value: stock,
                          child: Text(
                            '${stock.symbol} - ₹${stock.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedStock = val),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedInView(
                  index: 1,
                  child: _GlowingCard(
                    borderColor: accent,
                    child: TextFormField(
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: _inputDeco('Quantity'),
                      onChanged: (val) =>
                          setState(() => _quantity = int.tryParse(val) ?? 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedInView(
                  index: 2,
                  child: InteractiveCallPutToggle(
                    isCall: _isCall,
                    onChanged: (val) => setState(() => _isCall = val),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedInView(
                  index: 3,
                  child: _GlowingCard(
                    borderColor: accent,
                    padding: const EdgeInsets.all(12),
                    child: _selectedStock != null
                        ? AnimatedRealtimeChart(
                      stock: _selectedStock!,
                      isCall: _isCall,
                      accentColor: accent,
                    )
                        : const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Select a stock to view chart',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedInView(
                  index: 4,
                  child: Hero(
                    tag: 'place-order-button',
                    child: ScaleTransition(
                      scale: _buttonScaleAnim,
                      child: GestureDetector(
                        onTap: _placeOrder,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [accent, Colors.pinkAccent.withOpacity(0.9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.6),
                                blurRadius: 24,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Place Order',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Glassmorphic glowing card component
class _GlowingCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;

  const _GlowingCard({
    required this.child,
    required this.borderColor,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  State<_GlowingCard> createState() => _GlowingCardState();
}

class _GlowingCardState extends State<_GlowingCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.borderColor.withOpacity(_pressed ? 0.7 : 1.0),
            width: _pressed ? 2 : 3.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.borderColor.withOpacity(_pressed ? 0.3 : 0.18),
              blurRadius: _pressed ? 15 : 30,
              spreadRadius: _pressed ? 3 : 8,
              offset: const Offset(0, 5),
            ),
          ],
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(255, 255, 255, 0.06),
              Color.fromRGBO(255, 255, 255, 0.015),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: widget.padding ?? const EdgeInsets.all(14),
        child: widget.child,
      ),
    );
  }
}

// Particle painter for background sparkle
class _ParticlePainter extends CustomPainter {
  final Color accent;

  _ParticlePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withOpacity(0.13)
      ..style = PaintingStyle.fill;
    final rnd = Random();
    for (int i = 0; i < 36; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 2.8 + 1.2;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Animated Realtime Chart Widget (built-in)
class AnimatedRealtimeChart extends StatefulWidget {
  final Stock stock;
  final bool isCall;
  final Color accentColor;

  const AnimatedRealtimeChart({
    required this.stock,
    required this.isCall,
    required this.accentColor,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedRealtimeChart> createState() => _AnimatedRealtimeChartState();
}

class _AnimatedRealtimeChartState extends State<AnimatedRealtimeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<FlSpot> spots;
  late Color glowColor;

  @override
  void initState() {
    super.initState();
    glowColor = widget.isCall ? Colors.greenAccent : Colors.redAccent;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

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
      builder: (_, __) {
        return SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: spots.length - 1.toDouble(),
              minY: 30,
              maxY: 90,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
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
