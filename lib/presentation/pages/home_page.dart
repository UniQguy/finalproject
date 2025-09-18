import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/news_provider.dart';

import '../widgets/animated_gradient_widget.dart';
import '../widgets/fade_slide_in_view.dart';
import '../widgets/section_header.dart';
import 'balance_card.dart';
import 'compact_news_section.dart';
import 'compact_watchlist_section.dart';
import 'filter_chips.dart';
import 'market_tabs.dart';
import 'stock_comparison_section.dart';
import 'trending_section.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/app_footer.dart';
import '../widgets/animated_realtime_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/trade');
        break;
      case 1:
        context.go('/portfolio');
        break;
      case 2:
        context.go('/orders');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  Widget _buildHeroSection(double scale, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.9),
            // Smooth gradient blend
            primaryColor.withOpacity(0.75),
            Colors.tealAccent.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 36 * scale, vertical: 28 * scale),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideInView(
                  index: 0,
                  child: Text(
                    'Welcome to DemoTrader',
                    style: GoogleFonts.barlow(
                      fontSize: 38 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          color: Colors.black.withOpacity(0.85),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18 * scale),
                FadeSlideInView(
                  index: 1,
                  child: Text(
                    'Trade the market, learn, compete, and grow your wealth with live data.',
                    style: GoogleFonts.barlow(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 26 * scale),
                ElevatedButton.icon(
                  onPressed: () => context.go('/trade'),
                  icon: Icon(Icons.trending_up, color: primaryColor),
                  label: Text(
                    'Start Trading',
                    style: GoogleFonts.barlow(
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30 * scale, vertical: 18 * scale),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 14,
                    shadowColor: primaryColor.withOpacity(0.3),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 28 * scale),
          Expanded(
            flex: 4,
            child: FadeSlideInView(
              index: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'lib/assets/images/logo_.png',
                  height: 190 * scale, // Increased size for better visibility
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required double scale,
    required Widget child,
    VoidCallback? onViewAll,
    required int animationIndex,
    double? height,
  }) {
    final content = height != null ? SizedBox(height: height, child: child) : child;
    return FadeSlideInView(
      key: ValueKey(animationIndex),
      index: animationIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, scale: scale, onViewAll: onViewAll),
          SizedBox(height: 12 * scale),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final scale = MediaQuery.of(context).size.width / 900;
    final primaryColor = Colors.deepPurpleAccent;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black87;

    final newsProvider = context.watch<NewsProvider>();

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white70,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.person, color: primaryColor, size: 32 * scale),
          onPressed: () => context.go('/profile'),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'Demo',
                  style: GoogleFonts.barlow(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.orangeAccent)),
              TextSpan(
                  text: 'Trader',
                  style: GoogleFonts.barlow(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.purpleAccent)),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.notifications_none, color: iconColor, size: 29 * scale),
              onPressed: () => context.go('/notifications')),
          IconButton(
              icon: Icon(Icons.search, color: iconColor, size: 29 * scale),
              onPressed: () => context.go('/search')),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          children: [
            _buildHeroSection(scale, primaryColor),
            SizedBox(height: 36 * scale),
            FadeSlideInView(index: 3, child: WalletBalanceCard(scale: scale)),
            SizedBox(height: 18 * scale),
            FadeSlideInView(index: 4, child: BalanceCard(scale: scale)),
            SizedBox(height: 30 * scale),
            FadeSlideInView(
                index: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: MarketTabs(),
                )),
            SizedBox(height: 18 * scale),
            FadeSlideInView(index: 6, child: FilterChips()),
            SizedBox(height: 28 * scale),
            _buildSection(
              title: 'Trending Stocks',
              scale: scale,
              animationIndex: 7,
              child: TrendingSection(scale: scale),
              onViewAll: () => context.go('/market-movers'),
              height: 210 * scale,
            ),
            SizedBox(height: 28 * scale),
            _buildSection(
              title: 'Latest News',
              scale: scale,
              animationIndex: 8,
              child: CompactNewsSection(
                scale: scale,
                newsList: newsProvider.newsList
                    .map((article) => {
                  'title': article.headline,
                  'summary': article.summary,
                  'imageUrl': article.imageUrl,
                })
                    .toList(),
              ),
              onViewAll: () => context.go('/news'),
              height: 250 * scale,
            ),
            SizedBox(height: 28 * scale),
            _buildSection(
              title: 'Live Stock Chart',
              scale: scale,
              animationIndex: 9,
              child: AnimatedRealtimeChartWithSelector(accentColor: primaryColor),
              onViewAll: () => context.go('/stock-chart'),
              height: 270 * scale,
            ),
            SizedBox(height: 28 * scale),
            _buildSection(
              title: 'Compare Stocks',
              scale: scale,
              animationIndex: 10,
              child: StockComparisonSection(scale: scale),
              onViewAll: () => context.go('/stock-comparison'),
              height: 150 * scale,
            ),
            SizedBox(height: 24 * scale),
            _buildSection(
              title: 'Watchlist',
              scale: scale,
              animationIndex: 11,
              child: CompactWatchlistSection(scale: scale),
              onViewAll: () => context.go('/watchlist'),
              height: 190 * scale,
            ),
            SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/trade'),
        icon: Icon(Icons.trending_up, color: Colors.white),
        label: Text('Trade', style: GoogleFonts.barlow(fontWeight: FontWeight.w600)),
        backgroundColor: primaryColor,
        elevation: 8,
        hoverElevation: 12,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: backgroundColor,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Trade'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class AnimatedRealtimeChartWithSelector extends StatefulWidget {
  final Color accentColor;

  const AnimatedRealtimeChartWithSelector({
    super.key,
    required this.accentColor,
  });

  @override
  State<AnimatedRealtimeChartWithSelector> createState() =>
      _AnimatedRealtimeChartWithSelectorState();
}

class _AnimatedRealtimeChartWithSelectorState
    extends State<AnimatedRealtimeChartWithSelector> {
  String? selectedSymbol;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final marketProvider = context.read<MarketProvider>();
    selectedSymbol ??= marketProvider.stocks.isNotEmpty ? marketProvider.stocks.first.symbol : null;
  }

  void onSymbolChanged(String symbol) {
    setState(() {
      selectedSymbol = symbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedSymbol == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return AnimatedRealtimeChart(
      key: ValueKey(selectedSymbol),
      accentColor: widget.accentColor,
      initialSymbol: selectedSymbol,
      onSymbolChanged: onSymbolChanged,
    );
  }
}
