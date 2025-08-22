import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/enhanced_realtime_chart.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';
import '../../business_logic/models/trade_order.dart';
import '../widgets/animated_gradient_widget.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/theme_provider.dart';

class DemoTradingScreen extends StatefulWidget {
  const DemoTradingScreen({super.key});

  @override
  State<DemoTradingScreen> createState() => _DemoTradingScreenState();
}

class _DemoTradingScreenState extends State<DemoTradingScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Stock? _selectedStock;
  int _quantity = 1;
  bool _isCall = true;

  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonScale =
        CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut);
    _buttonController.forward();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.tealAccent),
      filled: true,
      fillColor: Colors.white10,
      prefixIcon: icon != null ? Icon(icon, color: Colors.tealAccent) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.tealAccent.shade700,
        content: const Text('Order placed successfully!'),
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stocks = context.watch<MarketProvider>().stocks;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: GradientText(
                      text: "Demo Trading Pro",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 6,
                      ),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.purpleAccent,
                          Colors.tealAccent,
                        ],
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.deepPurple, Colors.black],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    AnimatedInView(
                      index: 0,
                      child: AppGlassyCard(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(16),
                        borderColor: themeProvider.primaryColor,
                        child: DropdownButtonFormField<Stock>(
                          decoration:
                          _inputDecoration('Select Stock', icon: Icons.show_chart),
                          value: _selectedStock,
                          dropdownColor: Colors.black87,
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                          items: stocks
                              .map((stock) => DropdownMenuItem(
                            value: stock,
                            child: Text(
                                '${stock.symbol} - ₹${stock.price.toStringAsFixed(2)}'),
                          ))
                              .toList(),
                          onChanged: (s) => setState(() => _selectedStock = s),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedInView(
                      index: 1,
                      child: AppGlassyCard(
                        borderRadius: BorderRadius.circular(24),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        borderColor: themeProvider.primaryColor,
                        child: TextFormField(
                          initialValue: '1',
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.tealAccent, fontWeight: FontWeight.bold),
                          decoration:
                          _inputDecoration('Quantity', icon: Icons.confirmation_number),
                          onChanged: (v) =>
                              setState(() => _quantity = int.tryParse(v) ?? 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedInView(
                      index: 2,
                      child: AppGlassyCard(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        borderColor: themeProvider.primaryColor,
                        child: ToggleButtons(
                          fillColor: Colors.tealAccent,
                          color: Colors.black,
                          selectedColor: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          constraints:
                          const BoxConstraints(minHeight: 48, minWidth: 130),
                          isSelected: [_isCall, !_isCall],
                          onPressed: (i) => setState(() => _isCall = i == 0),
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.arrow_upward, color: Colors.greenAccent),
                                SizedBox(width: 8),
                                Text('Call', style: TextStyle(fontWeight: FontWeight.w900)),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.arrow_downward, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Put', style: TextStyle(fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (_selectedStock != null)
                      EnhancedRealtimeChart(
                        stockSymbol: _selectedStock!.symbol,
                        isCallOption: _isCall,
                      )
                    else
                      Center(
                        child: Text(
                          'Select a stock to see live trend chart.',
                          style: TextStyle(
                            color: Colors.tealAccent.withOpacity(0.6),
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    const SizedBox(height: 38),
                    AnimatedInView(
                      index: 3,
                      child: ScaleTransition(
                        scale: _buttonScale,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ElevatedButton(
                            onPressed: _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                              elevation: 14,
                              shadowColor: Colors.tealAccent.withOpacity(0.7),
                            ),
                            child: Shimmer(
                              duration: const Duration(seconds: 3),
                              color: Colors.white,
                              colorOpacity: 0.3,
                              enabled: true,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'PLACE ORDER',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
