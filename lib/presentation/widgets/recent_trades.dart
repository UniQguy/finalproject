import 'package:flutter/material.dart';

class RecentTrades extends StatefulWidget {
  final double scale;

  const RecentTrades({Key? key, required this.scale}) : super(key: key);

  @override
  State<RecentTrades> createState() => _RecentTradesState();
}

class _RecentTradesState extends State<RecentTrades> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Mock recent trade data
  final List<Map<String, dynamic>> trades = [
    {
      'symbol': 'AAPL',
      'quantity': 10,
      'type': 'Buy',
      'price': 151.50,
      'time': '3h ago',
      'positive': true,
    },
    {
      'symbol': 'TSLA',
      'quantity': 5,
      'type': 'Sell',
      'price': 705.00,
      'time': '1d ago',
      'positive': false,
    },
    {
      'symbol': 'MSFT',
      'quantity': 20,
      'type': 'Buy',
      'price': 296.30,
      'time': '2d ago',
      'positive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.15),
              blurRadius: 13,
              offset: const Offset(0, 5),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16 * scale, horizontal: 14 * scale),
        child: Column(
          children: trades.map((trade) {
            final bool positive = trade['positive'] as bool;
            final String symbol = trade['symbol'] as String;
            final int quantity = trade['quantity'] as int;
            final String type = trade['type'] as String;
            final double price = trade['price'] as double;
            final String time = trade['time'] as String;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20 * scale,
                    backgroundColor: positive
                        ? Colors.greenAccent.shade700
                        : Colors.redAccent.shade700,
                    child: Icon(
                      positive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 20 * scale,
                    ),
                  ),
                  SizedBox(width: 18 * scale),
                  Expanded(
                    child: Text(
                      '$type $quantity shares of $symbol',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * scale,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14 * scale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
