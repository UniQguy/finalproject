import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/models/stock.dart';
import '../../business_logic/models/trade_order.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/wallet_provider.dart';

class TradeDialog extends StatefulWidget {
  final Stock stock;

  const TradeDialog({Key? key, required this.stock}) : super(key: key);

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

  void placeOrder() {
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

    if (orderType == 'Buy' && totalPrice > wallet.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient wallet balance')),
      );
      return;
    }

    if (orderType == 'Buy') {
      final success = wallet.withdraw(totalPrice);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to withdraw from wallet')),
        );
        return;
      }
    } else {
      // TODO: Implement portfolio holdings check before selling
      // Possibly check if user owns enough shares to sell
    }

    portfolio.addOrder(TradeOrder(
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
              onPressed: placeOrder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
