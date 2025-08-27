import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/wallet_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/interactive_call_put_toggle.dart';
import '../../business_logic/models/stock.dart';

class TradingPage extends StatefulWidget {
  final String? symbol;

  const TradingPage({Key? key, this.symbol}) : super(key: key);

  @override
  State<TradingPage> createState() => _TradingPageState();
}


class _TradingPageState extends State<TradingPage> {
  Stock? _selectedStock;
  int _quantity = 1;
  bool _isCall = true;

  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (_selectedStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a stock.")),
      );
      return;
    }
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity.")),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final portfolioProvider = context.read<PortfolioProvider>();

    final double totalPrice = _selectedStock!.price * _quantity;

    if (_isCall) {
      // Buy operation: Check and deduct wallet balance
      if (!walletProvider.deduct(totalPrice)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Insufficient wallet balance.")),
        );
        return;
      }
    } else {
      // Sell operation: Add money to wallet (assuming valid holdings)
      walletProvider.add(totalPrice);
    }

    // Add trade order
    portfolioProvider.addOrder(
      TradeOrder(
        stockSymbol: _selectedStock!.symbol,
        type: _isCall ? OrderType.call : OrderType.put,
        price: _selectedStock!.price,
        quantity: _quantity,
        timestamp: DateTime.now(),
      ),
    );

    // Show confirmation and reset quantity field
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${_isCall ? 'Bought' : 'Sold'} $_quantity shares of ${_selectedStock!.symbol}",
        ),
      ),
    );

    setState(() {
      _quantity = 1;
      _quantityController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;
    final accentColor = Colors.purpleAccent;
    final walletBalance = context.watch<WalletProvider>().balance;
    final stocks = context.watch<MarketProvider>().stocks;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Trade"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 28),
        child: ListView(
          children: [
            AnimatedInView(
              index: 0,
              child: Text(
                "Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedInView(
              index: 1,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20 * scale),
                padding: EdgeInsets.all(16 * scale),
                child: DropdownButtonFormField<Stock>(
                  value: _selectedStock,
                  decoration: InputDecoration(
                    labelText: "Select Stock",
                    labelStyle: TextStyle(color: accentColor),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: Colors.deepPurple.shade900,
                  items: stocks.map((stock) {
                    return DropdownMenuItem<Stock>(
                      value: stock,
                      child: Text(
                        "${stock.symbol} - ₹${stock.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (selection) => setState(() => _selectedStock = selection),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedInView(
              index: 2,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(20 * scale),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: TextFormField(
                  controller: _quantityController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    labelStyle: TextStyle(color: accentColor),
                    border: InputBorder.none,
                    hintText: "Enter quantity",
                    hintStyle: const TextStyle(color: Colors.white54),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    final qty = int.tryParse(value);
                    setState(() {
                      _quantity = (qty != null && qty > 0) ? qty : 0;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedInView(
              index: 3,
              child: InteractiveCallPutToggle(
                isCall: _isCall,
                onChanged: (val) => setState(() => _isCall = val),
              ),
            ),
            const SizedBox(height: 30),
            AnimatedButton(
              onTap:
              (_quantity > 0 && _selectedStock != null) ? _placeOrder : null,
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
                      color: Colors.purpleAccent.withAlpha((0.6 * 255).toInt()),
                      spreadRadius: 5,
                      blurRadius: 24,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    "Place Order",
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
