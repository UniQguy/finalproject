import 'package:flutter/material.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';

class MarketMoversWidget extends StatelessWidget {
  final double scale;

  const MarketMoversWidget({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    // Sample movers data with price change percentage
    final List<Map<String, dynamic>> movers = [
      {'symbol': 'TCS', 'price': 4300.50, 'change': 1.5},
      {'symbol': 'RELIANCE', 'price': 2490.75, 'change': -0.8},
      {'symbol': 'HDFCBANK', 'price': 1595.40, 'change': 2.1},
      {'symbol': 'INFY', 'price': 1625.20, 'change': -1.3},
      {'symbol': 'SBIN', 'price': 585.35, 'change': 0.7},
    ];

    return SizedBox(
      height: 140 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: movers.length,
        padding: EdgeInsets.symmetric(horizontal: 14 * scale),
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          final mover = movers[index];
          final bool positive = mover['change'] >= 0;

          return AnimatedInView(
            index: index,
            child: AppGlassyCard(
              padding: EdgeInsets.all(18 * scale),
              borderRadius: BorderRadius.circular(18 * scale),
              child: SizedBox(
                width: 140 * scale,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mover['symbol'],
                      style: TextStyle(
                        color: positive ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * scale,
                        shadows: [
                          Shadow(
                            color: positive
                                ? Colors.greenAccent.withOpacity(0.5)
                                : Colors.redAccent.withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${mover['price'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          positive ? Icons.trending_up : Icons.trending_down,
                          color: positive ? Colors.greenAccent : Colors.redAccent,
                          size: 18 * scale,
                          shadows: [
                            Shadow(
                              color: positive
                                  ? Colors.greenAccent.withOpacity(0.8)
                                  : Colors.redAccent.withOpacity(0.8),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        SizedBox(width: 6 * scale),
                        Text(
                          '${positive ? "+" : ""}${mover['change'].toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: positive ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * scale,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
