import 'package:flutter/material.dart';
import '../../business_logic/models/stock.dart';

class OrderConfirmationPage extends StatelessWidget {
  final Stock stock;
  final int quantity;
  final bool isCall;

  const OrderConfirmationPage({
    super.key,
    required this.stock,
    required this.quantity,
    required this.isCall,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isCall ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: 'place-order-button',
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCall ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 48,
                  color: accent,
                ),
                const SizedBox(height: 12),
                Text(
                  '${isCall ? "Call" : "Put"} Order Placed!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Stock: ${stock.symbol}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                Text(
                  'Price: ₹${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Back to Trading',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
