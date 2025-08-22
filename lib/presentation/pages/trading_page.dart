import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/interactive_call_put_toggle.dart';
import '../../business_logic/models/stock.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  Stock? _selectedStock;
  int _quantity = 1;
  bool _isCall = true;

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
        content: Text('Order placed: $_quantity shares of ${_selectedStock!.symbol}'),
        backgroundColor: Colors.purpleAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;
    final accent = Colors.purpleAccent;
    final stocks = context.watch<MarketProvider>().stocks;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trade'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 28 * scale),
        child: ListView(
          children: [
            AnimatedInView(
              index: 0,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20 * scale),
                padding: EdgeInsets.all(16 * scale),
                child: DropdownButtonFormField<Stock>(
                  decoration: InputDecoration(
                    labelText: 'Select Stock',
                    labelStyle: TextStyle(color: accent),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                      borderSide: BorderSide(color: accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                  ),
                  dropdownColor: Colors.deepPurple.shade900,
                  value: _selectedStock,
                  items: stocks
                      .map(
                        (stock) => DropdownMenuItem(
                      value: stock,
                      child: Text(
                        '${stock.symbol} - ₹${stock.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedStock = val),
                ),
              ),
            ),
            SizedBox(height: 20 * scale),
            AnimatedInView(
              index: 1,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20 * scale),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: TextFormField(
                  initialValue: '1',
                  style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(color: accent),
                    border: InputBorder.none,
                    hintText: 'Enter quantity',
                    hintStyle: TextStyle(color: Colors.white54),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                  ),
                  onChanged: (val) {
                    final q = int.tryParse(val);
                    if (q != null && q > 0) {
                      setState(() {
                        _quantity = q;
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20 * scale),
            AnimatedInView(
              index: 2,
              child: InteractiveCallPutToggle(
                isCall: _isCall,
                onChanged: (val) => setState(() => _isCall = val),
              ),
            ),
            SizedBox(height: 20 * scale),
            AnimatedButton(
              onTap: _placeOrder,
              child: Container(
                height: 56 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18 * scale),
                  gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.pinkAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.6),
                      blurRadius: 24,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
