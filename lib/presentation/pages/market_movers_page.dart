import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/models/stock.dart';

class MarketMoversPage extends StatelessWidget {
  const MarketMoversPage({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final List<Stock> movers = market.stocks; // Or sort by price change if needed

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                GradientText(
                  text: '🔥 Market Movers',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: LinearGradient(
                    colors: [themeProvider.gainColor, themeProvider.lossColor],
                  ),
                ),
                const SizedBox(height: 20),

                if (movers.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No market data available.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  ...movers.asMap().entries.map(
                        (entry) {
                      final index = entry.key;
                      final stock = entry.value;
                      final change = stock.price - stock.previousClose;
                      final isUp = change >= 0;
                      final color =
                      isUp ? themeProvider.gainColor : themeProvider.lossColor;

                      return AnimatedInView(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppGlassyCard(
                            padding: const EdgeInsets.all(14),
                            borderColor: color, // ✅ Added required borderColor
                            child: Row(
                              children: [
                                // Stock Symbol & Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stock.symbol,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        stock.name,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price & Change
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${stock.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${isUp ? '+' : ''}${change.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
