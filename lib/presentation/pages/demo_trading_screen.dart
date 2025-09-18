import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/enhanced_realtime_chart.dart';
import '../widgets/animated_gradient_widget.dart';

import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/theme_provider.dart';

import '../../business_logic/models/stock.dart';
import '../../business_logic/models/trade_order.dart';

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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade700,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
      ),
    );
  }

  void _placeOrder() {
    if (_selectedStock == null) {
      _showSnackBar('Please select a stock before placing an order.');
      return;
    }
    if (_quantity <= 0) {
      _showSnackBar('Please enter a valid quantity.');
      return;
    }

    final order = TradeOrder(
      stockSymbol: _selectedStock!.symbol,
      type: OrderType.call, // default or only option now as put/call removed
      price: _selectedStock!.price,
      quantity: _quantity,
      timestamp: DateTime.now(),
    );

    context.read<PortfolioProvider>().addOrder(order);

    _showSnackBar('Purchased!');
  }

  bool get _isOrderButtonEnabled => _selectedStock != null && _quantity > 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final stocks = context.watch<MarketProvider>().stocks;

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
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 24),

                      // Stock selection dropdown
                      AnimatedInView(
                        index: 0,
                        child: AppGlassyCard(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.all(16),
                          borderColor: themeProvider.primaryColor,
                          child: DropdownButtonFormField<Stock>(
                            decoration: _inputDecoration(
                                'Select Stock', icon: Icons.show_chart),
                            value: _selectedStock,
                            dropdownColor: Colors.black87,
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                            items: stocks.map((stock) => DropdownMenuItem(
                              value: stock,
                              child: Text(
                                  '${stock.symbol} - ₹${stock.price.toStringAsFixed(2)}'),
                            )).toList(),
                            onChanged: (stock) {
                              setState(() {
                                _selectedStock = stock;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quantity input
                      AnimatedInView(
                        index: 1,
                        child: AppGlassyCard(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          borderColor: themeProvider.primaryColor,
                          child: TextFormField(
                            initialValue: '1',
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.tealAccent, fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(
                                'Quantity', icon: Icons.confirmation_number),
                            onChanged: (value) {
                              int? val = int.tryParse(value);
                              setState(() {
                                _quantity = (val != null && val > 0) ? val : 1;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Show chart or prompt
                      if (_selectedStock != null)
                        EnhancedRealtimeChart(
                          stockSymbol: _selectedStock!.symbol,
                          isCallOption: true,
                        )
                      else
                        Center(
                          child: Text(
                            'Select a stock to see the live trend.',
                            style: TextStyle(
                              color: Colors.tealAccent.withOpacity(0.6),
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                      const SizedBox(height: 38),

                      // Place order button with solid styling
                      AnimatedInView(
                        index: 2,
                        child: ScaleTransition(
                          scale: _buttonScale,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ElevatedButton(
                              onPressed: _isOrderButtonEnabled ? _placeOrder : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isOrderButtonEnabled
                                    ? Colors.tealAccent.shade700
                                    : Colors.tealAccent.shade200.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: _isOrderButtonEnabled ? 16 : 0,
                                shadowColor: Colors.tealAccent.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: Text(
                                'PLACE ORDER',
                                style: TextStyle(
                                  color: _isOrderButtonEnabled ? Colors.black : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
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
