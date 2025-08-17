import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Custom Widgets
import '../widgets/animated_gradient_widget.dart';
import '../widgets/gradient_text.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/enhanced_realtime_chart.dart';

// Business Logic Models and Providers
import '../../business_logic/models/stock.dart';
import '../../business_logic/providers/theme_provider.dart';

class StockChartPage extends StatelessWidget {
  final String stockSymbol;
  final Stock? stock; // Optional: pass actual stock object if already loaded

  const StockChartPage({
    super.key,
    required this.stockSymbol,
    this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Stack(
        children: [
          /// Animated gradient background for a futuristic feel
          const AnimatedGradientWidget(),

          /// Main content
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                /// Futuristic gradient title
                GradientText(
                  text: '📊 $stockSymbol Chart',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.primaryColor,
                      Colors.purpleAccent,
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// Live Realtime Chart Section
                AnimatedInView(
                  index: 0,
                  child: AppGlassyCard(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(12),
                    borderColor: themeProvider.primaryColor,
                    child: EnhancedRealtimeChart(
                      stockSymbol: stockSymbol,
                      isCallOption: stock?.isUp ?? true, // dynamically decide styling
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// About Section from Stock Info
                AnimatedInView(
                  index: 1,
                  child: AppGlassyCard(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(14),
                    borderColor: themeProvider.primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stock?.name ??
                              'Stock name info unavailable. Please refresh or check your network.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (stock?.description != null)
                          Text(
                            stock!.description!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
