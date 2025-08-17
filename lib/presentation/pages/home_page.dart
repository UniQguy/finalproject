// lib/presentation/pages/home_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../business_logic/models/stock.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/portfolio_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../routes/app_routes.dart';

// =============================================================
//                      HOME PAGE
// =============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Futuristic dynamic gradient sets
  final List<List<Color>> _gradients = [
    [const Color(0xFF071A2F), const Color(0xFF0B3D91), const Color(0xFF000000)],
    [const Color(0xFF120E43), const Color(0xFF0D7377), const Color(0xFF000000)],
    [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)],
  ];
  int _currentGradientIndex = 0;
  Timer? _bgTimer;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Auto change background every 6s
    _bgTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        _currentGradientIndex =
            (_currentGradientIndex + 1) % _gradients.length;
      });
    });

    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final portfolio = context.watch<PortfolioProvider>();

    // Calculate portfolio performance dynamically
    double startVal = 0.0, currentVal = 0.0;
    for (var entry in portfolio.holdings.entries) {
      final symbol = entry.key;
      final order = entry.value;
      final stock = market.stocks.firstWhere(
            (s) => s.symbol == symbol,
        orElse: () => Stock(
          symbol: symbol,
          name: symbol,
          price: order.price,
          previousClose: order.price,
        ),
      );
      if (stock.recentPrices.isNotEmpty) {
        startVal += stock.recentPrices.first * order.quantity;
        currentVal += stock.price * order.quantity;
      }
    }
    final changePct =
    startVal > 0 ? ((currentVal - startVal) / startVal) * 100 : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: GoRouter.of(context).canPop(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.orbitron(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.tealAccent),
              onPressed: () => context.push(AppRoutes.search)),
          IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: Colors.tealAccent),
              onPressed: () => context.push(AppRoutes.notifications)),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.tealAccent),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradients[_currentGradientIndex],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          blendMode: BlendMode.plus,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 20),
            children: [
              HeroChartCard(animationController: _controller, market: market),
              const SizedBox(height: 20),
              MarketTicker(items: market.stocks
                  .map((s) =>
              "${s.symbol} ₹${s.price.toStringAsFixed(2)} ${s.isUp ? '▲' : '▼'}")
                  .toList()),
              const SizedBox(height: 20),
              PortfolioSection(
                  value: currentVal, changePct: changePct, animated: true),
              const SizedBox(height: 24),
              SectionHeader(
                  title: 'Market Movers',
                  onViewAll: () => context.push(AppRoutes.marketMovers)),
              const SizedBox(height: 10),
              MarketMoversHorizontal(stocks: market.stocks.take(8).toList()),
              const SizedBox(height: 24),
              SectionHeader(
                  title: 'Recent Trades',
                  onViewAll: () => context.push(AppRoutes.tradingHistory)),
              const SizedBox(height: 10),
              RecentTradesTicker(),
              const SizedBox(height: 24),
              SectionHeader(
                  title: 'Latest News',
                  onViewAll: () => context.push(AppRoutes.news)),
              const SizedBox(height: 10),
              NewsCarousel(),
              const SizedBox(height: 24),
              SectionHeader(title: 'Quick Actions', onViewAll: () {}),
              const SizedBox(height: 10),
              QuickActionsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
//                  HERO CHART CARD (Dynamic Data)
// =============================================================
class HeroChartCard extends StatelessWidget {
  final AnimationController animationController;
  final MarketProvider market;
  const HeroChartCard(
      {super.key, required this.animationController, required this.market});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    final random = Random();
    double base = 1000;
    for (int i = 0; i < 20; i++) {
      base += random.nextDouble() * 20 - 10;
      spots.add(FlSpot(i.toDouble(), base));
    }

    return SizedBox(
      height: 260,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final tilt = sin(animationController.value * 2 * pi) * 0.02;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tilt)
              ..rotateY(-tilt),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6))
                ],
              ),
              child: LineChart(LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.tealAccent,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true,
                            color: Colors.tealAccent.withOpacity(0.1))),
                  ])),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================
// MARKET TICKER (Auto Scroll)
// =============================================================
class MarketTicker extends StatefulWidget {
  final List<String> items;
  const MarketTicker({super.key, required this.items});
  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker> {
  final ScrollController _controller = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.offset + 1);
        if (_controller.offset >= _controller.position.maxScrollExtent) {
          _controller.jumpTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return SizedBox(
      height: 28,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length * 3,
        itemBuilder: (context, index) {
          final item = widget.items[index % widget.items.length];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(item,
                style: TextStyle(
                    color: item.contains('▲')
                        ? Colors.greenAccent
                        : item.contains('▼')
                        ? Colors.redAccent
                        : theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          );
        },
      ),
    );
  }
}

// =============================================================
// PORTFOLIO SECTION WITH ANIMATION
// =============================================================
class PortfolioSection extends StatefulWidget {
  final double value;
  final double changePct;
  final bool animated;
  const PortfolioSection(
      {super.key,
        required this.value,
        required this.changePct,
        this.animated = false});
  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection>
    with SingleTickerProviderStateMixin {
  double oldVal = 0;
  @override
  void didUpdateWidget(covariant PortfolioSection oldWidget) {
    if (widget.animated) oldVal = oldWidget.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isUp = widget.changePct >= 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: oldVal, end: widget.value),
      duration: const Duration(seconds: 1),
      builder: (context, val, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primaryColor),
            color: Colors.white.withOpacity(0.05)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Value',
                style: GoogleFonts.orbitron(
                    fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('₹${val.toStringAsFixed(2)}',
                    style: GoogleFonts.orbitron(
                        fontSize: 30, color: Colors.white)),
                const SizedBox(width: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isUp
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          color:
                          isUp ? Colors.greenAccent : Colors.redAccent,
                          size: 14),
                      Text('${widget.changePct.toStringAsFixed(2)}%',
                          style: TextStyle(
                              color: isUp
                                  ? Colors.greenAccent
                                  : Colors.redAccent)),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// OTHER SECTIONS (REUSED WITH MINOR TWEAKS)
// =============================================================

// MarketMoversHorizontal, RecentTradesTicker, NewsCarousel,
// QuickActionsRow, SectionHeader remain the same as your code.



// MARKET MOVERS HORIZONTAL
class MarketMoversHorizontal extends StatelessWidget {
  final List<Stock> stocks;
  const MarketMoversHorizontal({super.key, required this.stocks});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stocks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stock = stocks[index];
          final isUp = stock.isUp;
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isUp ? Colors.greenAccent : Colors.redAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.symbol,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUp
                            ? Colors.greenAccent
                            : Colors.redAccent)),
                const Spacer(),
                Text('₹${stock.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// RECENT TRADES TICKER
class RecentTradesTicker extends StatelessWidget {
  const RecentTradesTicker({super.key});
  @override
  Widget build(BuildContext context) {
    final trades = [
      'AAPL Buy 2 @ ₹150',
      'TSLA Sell 1 @ ₹700',
      'GOOG Buy 3 @ ₹2500'
    ];
    return Column(
      children: trades
          .map((t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(t, style: const TextStyle(color: Colors.white)),
      ))
          .toList(),
    );
  }
}

// NEWS CAROUSEL
class NewsCarousel extends StatelessWidget {
  const NewsCarousel({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Breaking News Headline",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Spacer(),
                Text("2h ago",
                    style:
                    TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ));
  }
}

// QUICK ACTIONS ROW
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});
  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      {'icon': Icons.swap_vert, 'label': 'Trade', 'route': AppRoutes.trading},
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Portfolio',
        'route': AppRoutes.portfolio
      },
      {
        'icon': Icons.history,
        'label': 'History',
        'route': AppRoutes.tradingHistory
      },
      {'icon': Icons.settings, 'label': 'Settings', 'route': AppRoutes.settings}
    ];
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: shortcuts
            .map((s) => GestureDetector(
          onTap: () => context.push(s['route'] as String),
          child: Column(
            children: [
              Icon(s['icon'] as IconData,
                  color: Colors.tealAccent, size: 28),
              const SizedBox(height: 6),
              Text(s['label'] as String,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
        ))
            .toList());
  }
}

// SECTION HEADER
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const SectionHeader({super.key, required this.title, required this.onViewAll});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white)),
        const Spacer(),
        TextButton(
            onPressed: onViewAll,
            child: const Text("View All",
                style: TextStyle(color: Colors.white54)))
      ],
    );
  }
}
