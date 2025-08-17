import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/neon_button.dart';

import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/models/trade_order.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final themeProvider = context.watch<ThemeProvider>();

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
                  text: 'Your Portfolio',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: LinearGradient(
                    colors: [themeProvider.primaryColor, Colors.purpleAccent],
                  ),
                ),
                const SizedBox(height: 20),

                // Total Portfolio Value
                AnimatedInView(
                  index: 0,
                  child: AppGlassyCard(
                    borderColor: themeProvider
                        .primaryColor, // ✅ required parameter added
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Value',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${portfolio.portfolioValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Holdings List
                if (portfolio.holdings.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "You don't have any holdings yet.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  ...portfolio.holdings.entries.toList().asMap().entries.map(
                        (mapEntry) {
                      final index = mapEntry.key;
                      final TradeOrder order = mapEntry.value.value;
                      final symbol = order.stockSymbol;
                      final qty = order.quantity;
                      final stockPrice = order.price;

                      final color = themeProvider.primaryColor;

                      return AnimatedInView(
                        index: index + 1,
                        child: AppGlassyCard(
                          padding: const EdgeInsets.all(12),
                          borderColor: themeProvider
                              .primaryColor, // ✅ required parameter added
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                symbol,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${stockPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Qty: $qty',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 30),

                // Add Funds / Trade Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NeonButton(
                      label: 'Add Funds',
                      onPressed: () {
                        // handle add funds
                      },
                      color: themeProvider.gainColor,
                      textColor: Colors.black,
                    ),
                    NeonButton(
                      label: 'Trade Now',
                      onPressed: () {
                        // navigate to trade page
                      },
                      color: themeProvider.primaryColor,
                      textColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
