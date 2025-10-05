import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/wallet_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

import '../widgets/app_glassy_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/animated_in_view.dart';

class TradingPage extends StatefulWidget {
  final String? symbol;

  const TradingPage({super.key, this.symbol});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  Stock? _selectedStock;
  int _quantity = 1;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketStocks = context.read<MarketProvider>().stocks;
      List<Stock> availableStocks;

      // If symbol passed, default to it if it's in market stocks
      if (widget.symbol != null) {
        availableStocks = marketStocks.where((s) => s.symbol == widget.symbol).toList();
      } else {
        availableStocks = List.from(marketStocks);
      }

      if (availableStocks.isEmpty && marketStocks.isNotEmpty) {
        availableStocks = List.from(marketStocks);
      }

      setState(() {
        _selectedStock = availableStocks.isNotEmpty ? availableStocks.first : null;
      });
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  /// Sets quantity to max possible for selling the selected stock.
  void _setMaxQuantityForSell() {
    if (_selectedStock == null) return;

    final portfolioProvider = context.read<PortfolioProvider>();
    final holding = portfolioProvider.holdingFor(_selectedStock!.symbol);

    if (holding != null) {
      setState(() {
        _quantity = holding.quantity;
        _quantityController.text = _quantity.toString();
      });
    }
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

    // Show confirmation dialog before wallet deduction
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel", style: TextStyle(color: Colors.deepPurpleAccent)),
          ),
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

    if (!await walletProvider.deduct(totalPrice)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient wallet balance.")));
      return;
    }

    await portfolioProvider.addOrder(TradeOrder(
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

  Future<void> _confirmAndSellOrder() async {
    if (_selectedStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a stock.")));
      return;
    }
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid quantity.")));
      return;
    }

    final portfolioProvider = context.read<PortfolioProvider>();
    final walletProvider = context.read<WalletProvider>();

    final holding = portfolioProvider.holdingFor(_selectedStock!.symbol);
    if (holding == null || holding.quantity < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough shares to sell.")));
      return;
    }

    final avgBuyPrice = holding.price;
    final currentPrice = _selectedStock!.price;
    final totalSellValue = currentPrice * _quantity;
    final pnl = (currentPrice - avgBuyPrice) * _quantity;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.deepPurple[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Sell Confirmation", style: TextStyle(color: Colors.deepPurpleAccent)),
        content: Text(
          "Confirm selling $_quantity shares of ${_selectedStock!.symbol} for ₹${totalSellValue.toStringAsFixed(2)}?\nP&L: ₹${pnl.toStringAsFixed(2)}",
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

    await walletProvider.credit(totalSellValue);
    await portfolioProvider.sellOrder(_selectedStock!.symbol, _quantity, currentPrice);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.deepPurple[800],
      content: Text(
        "Successfully sold $_quantity shares of ${_selectedStock!.symbol}. P&L: ₹${pnl.toStringAsFixed(2)}",
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
                child: Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _setMaxQuantityForSell,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Max"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36 * scale),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
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
                const SizedBox(width: 18),
                Expanded(
                  child: AnimatedButton(
                    onTap: (_quantity > 0 && _selectedStock != null) ? _confirmAndSellOrder : null,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.6),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Sell",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48 * scale),
          ],
        ),
      ),
    );
  }
}
