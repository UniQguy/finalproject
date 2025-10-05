import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/stock.dart';
import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/wallet_provider.dart';

class TradeDialog extends StatefulWidget {
  final Stock stock;

  const TradeDialog({super.key, required this.stock});

  @override
  State<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> {
  late String orderType;
  late int quantity;
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    orderType = 'Buy';
    quantity = 1;
    quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  Future<void> placeOrder() async {
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final portfolio = Provider.of<PortfolioProvider>(context, listen: false);

    final qty = int.tryParse(quantityController.text) ?? 1;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity should be greater than zero')),
      );
      return;
    }

    final totalPrice = widget.stock.price * qty;

    if (orderType == 'Buy') {
      if (totalPrice > wallet.balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient wallet balance')),
        );
        return;
      }
      final success = await wallet.deduct(totalPrice);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to deduct from wallet')),
        );
        return;
      }
    } else {
      // SELL logic

      // Check holding quantity
      final holding = portfolio.holdingFor(widget.stock.symbol);
      if (holding == null || holding.quantity < qty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough shares to sell')),
        );
        return;
      }

      // Calculate P&L
      final avgBuyPrice = holding.price;
      final pnl = (widget.stock.price - avgBuyPrice) * qty;
      final creditAmount = widget.stock.price * qty;

      // Credit wallet with sell amount
      await wallet.credit(creditAmount);

      // Update portfolio
      await portfolio.sellOrder(widget.stock.symbol, qty, widget.stock.price);

      // Optionally: Show P&L notification here if you want
    }

    await portfolio.addOrder(TradeOrder(
      stockSymbol: widget.stock.symbol,
      type: orderType == 'Buy' ? OrderType.call : OrderType.put,
      price: widget.stock.price,
      quantity: qty,
      timestamp: DateTime.now(),
    ));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed: $orderType ${widget.stock.symbol} x $qty')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('Trade ${widget.stock.symbol}', style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: orderType,
              decoration: const InputDecoration(
                labelText: 'Order Type',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white),
              items: ['Buy', 'Sell'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) => setState(() => orderType = val ?? 'Buy'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final intVal = int.tryParse(val) ?? 1;
                setState(() => quantity = intVal);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async => await placeOrder(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
