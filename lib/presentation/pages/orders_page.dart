import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Example order model (customize as needed)
class Order {
  final String symbol;
  final String type; // "Buy" or "Sell"
  final int quantity;
  final double price;
  final DateTime date;

  Order({
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
  });
}

// Dummy orders for demonstration
final List<Order> demoOrders = [
  Order(symbol: "AAPL", type: "Buy", quantity: 10, price: 229.99, date: DateTime.now().subtract(Duration(days: 1))),
  Order(symbol: "GOOGL", type: "Sell", quantity: 5, price: 207.21, date: DateTime.now().subtract(Duration(days: 2))),
  Order(symbol: "MSFT", type: "Buy", quantity: 2, price: 506.22, date: DateTime.now().subtract(Duration(hours: 8))),
];

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Orders",
          style: GoogleFonts.barlow(),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),  // Navigate to homepage on back
        ),
      ),
      body: demoOrders.isEmpty
          ? Center(
        child: Text(
          "No Orders Found",
          style: GoogleFonts.barlow(color: Colors.white70, fontSize: 20),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: demoOrders.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          final order = demoOrders[index];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${order.type} ${order.quantity} x ${order.symbol}",
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Price: ₹${order.price.toStringAsFixed(2)}",
                  style: GoogleFonts.barlow(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Date: ${order.date.toLocal().toString().split(' ')[0]}",
                  style: GoogleFonts.barlow(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
