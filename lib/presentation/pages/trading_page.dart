import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/wallet_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

import '../widgets/app_glassy_card.dart';  // fixed import for glassy card widget
import '../widgets/animated_button.dart';
import '../widgets/animated_in_view.dart';

class TradingPage extends StatefulWidget {
  final String? symbol;

  const TradingPage({super.key, this.symbol});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> with SingleTickerProviderStateMixin {
  Stock? _selectedStock;
  int _quantity = 1;

  late final TextEditingController _quantityController;
  late AnimationController _animController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonScale = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stocks = context.read<MarketProvider>().stocks;
      if (widget.symbol != null && stocks.isNotEmpty) {
        final matches = stocks.where((s) => s.symbol == widget.symbol).toList();
        setState(() {
          _selectedStock = matches.isNotEmpty ? matches.first : stocks.first;
        });
      } else if (stocks.isNotEmpty) {
        setState(() {
          _selectedStock = stocks.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndPlaceOrder() async {
    if (_selectedStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a stock.")));
      return;
    }
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid quantity.")));
      return;
    }

    final totalPrice = _selectedStock!.price * _quantity;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.deepPurple[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Purchase Confirmation", style: TextStyle(color: Colors.deepPurpleAccent)),
        content: Text(
          "Confirm buying $_quantity shares of ${_selectedStock!.symbol} for ₹${totalPrice.toStringAsFixed(2)}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel", style: TextStyle(color: Colors.deepPurpleAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final walletProvider = context.read<WalletProvider>();
    final portfolioProvider = context.read<PortfolioProvider>();

    if (!walletProvider.deduct(totalPrice)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient wallet balance.")));
      return;
    }

    portfolioProvider.addOrder(TradeOrder(
      stockSymbol: _selectedStock!.symbol,
      type: OrderType.call,
      price: _selectedStock!.price,
      quantity: _quantity,
      timestamp: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.deepPurple[800],
      content: Text(
        "Successfully purchased $_quantity shares of ${_selectedStock!.symbol}",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    setState(() {
      _quantity = 1;
      _quantityController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;
    final accentColor = Colors.deepPurpleAccent;
    final walletTextColor = Colors.deepPurpleAccent.shade100;
    final walletBackground = Colors.deepPurple[900]!;
    final cardBackground = Colors.deepPurple[800]!;
    final cardBorderColor = Colors.deepPurpleAccent.withOpacity(0.7);

    final walletBalance = context.watch<WalletProvider>().balance;
    final stocks = context.watch<MarketProvider>().stocks;

    if (stocks.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.deepPurple[900],
        appBar: AppBar(
          title: const Text("Trade"),
          backgroundColor: Colors.deepPurple[900],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        elevation: 0,
        title: const Text("Trade"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          color: Colors.deepPurpleAccent,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 28),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            AnimatedInView(
              index: 0,
              child: Text(
                "Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                  color: walletTextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 24 * scale),
            AnimatedInView(
              index: 1,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(16),
                padding: EdgeInsets.all(16),
                borderColor: cardBorderColor,
                child: DropdownButtonFormField<Stock>(
                  value: _selectedStock,
                  dropdownColor: walletBackground,
                  elevation: 8,
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "Select Stock",
                    labelStyle: TextStyle(color: walletTextColor),
                    filled: true,
                    fillColor: cardBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  items: stocks.map((stock) {
                    return DropdownMenuItem(
                      value: stock,
                      child: Text('${stock.symbol} - ₹${stock.price.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStock = val;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24 * scale),
            AnimatedInView(
              index: 2,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderColor: cardBorderColor,
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor),
                  decoration: InputDecoration(
                    hintText: "Quantity",
                    hintStyle: TextStyle(color: walletTextColor.withOpacity(0.7)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    int? quantity = int.tryParse(val);
                    setState(() {
                      _quantity = (quantity != null && quantity > 0) ? quantity : 0;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 36 * scale),
            AnimatedInView(
              index: 3,
              child: AnimatedButton(
                onTap: (_quantity > 0 && _selectedStock != null) ? _confirmAndPlaceOrder : null,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Buy Now",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Colors.purpleAccent[900],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 48 * scale),
          ],
        ),
      ),
    );
  }
}
