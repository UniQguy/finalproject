import 'package:flutter/material.dart';

class PortfolioHoldings extends StatelessWidget {
  final double scale;

  const PortfolioHoldings({Key? key, required this.scale}) : super(key: key);

  // Mock portfolio holdings data with dynamic change simulation
  static final List<Map<String, dynamic>> holdings = [
    {'symbol': 'AAPL', 'shares': 20, 'price': 153.23, 'change': 1.5},
    {'symbol': 'TSLA', 'shares': 12, 'price': 710.45, 'change': -0.8},
    {'symbol': 'MSFT', 'shares': 25, 'price': 300.01, 'change': 0.6},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: holdings.map((holding) {
          final double change = holding['change'] as double;
          final bool positive = change >= 0;
          final String symbol = holding['symbol'] as String;
          final int shares = holding['shares'] as int;
          final double price = holding['price'] as double;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 14 * scale),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24 * scale,
                  backgroundColor: Colors.deepPurple.shade700,
                  child: Text(
                    symbol.length >= 2 ? symbol.substring(0, 2).toUpperCase() : symbol.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * scale,
                    ),
                  ),
                ),
                SizedBox(width: 18 * scale),
                Expanded(
                  child: Text(
                    '$symbol • $shares shares',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18 * scale,
                      letterSpacing: 0.4,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          positive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: positive ? Colors.greenAccent : Colors.redAccent,
                          size: 18 * scale,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${positive ? '+' : ''}${change.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: positive ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
