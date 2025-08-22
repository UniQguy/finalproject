import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';

class TrendingSection extends StatelessWidget {
  final double scale;

  const TrendingSection({Key? key, required this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final stocks = marketProvider.stocks;

    if (stocks.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Text(
          "No trending stocks available.",
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SizedBox(
      height: 195 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18 * scale),
        itemCount: stocks.length,
        separatorBuilder: (_, __) => SizedBox(width: 14 * scale),
        itemBuilder: (context, index) {
          final stock = stocks[index];
          final changePercent = marketProvider.getPriceChangePercent(stock.symbol);
          final isPositive = changePercent >= 0;

          return AnimatedInView(
            index: index,
            child: AppGlassyCard(
              borderRadius: BorderRadius.circular(20),
              padding: EdgeInsets.all(16 * scale),
              child: SizedBox(
                width: 160 * scale,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: TextStyle(
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.greenAccent : Colors.redAccent,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: isPositive
                                ? Colors.greenAccent.withOpacity(0.6)
                                : Colors.redAccent.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      stock.company,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14 * scale,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₹${stock.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.black45,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPositive ? Colors.greenAccent : Colors.redAccent,
                          size: 18 * scale,
                        ),
                        SizedBox(width: 6 * scale),
                        Text(
                          '${isPositive ? "+" : ""}${changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.greenAccent : Colors.redAccent,
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
