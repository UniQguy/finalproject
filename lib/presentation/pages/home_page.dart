import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../business_logic/providers/theme_provider.dart';

import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/section_header.dart';

import 'balance_card.dart';
import 'compact_news_section.dart';
import 'compact_watchlist_section.dart';
import 'filter_chips.dart';
import 'market_tabs.dart';
import 'stock_chart_section.dart';
import 'stock_comparison_section.dart';
import 'trending_section.dart';
import '../widgets/wallet_balance_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _heroAnimationController;
  late final Animation<double> _heroImageFade;

  @override
  void initState() {
    super.initState();
    _heroAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _heroImageFade = CurvedAnimation(parent: _heroAnimationController, curve: Curves.easeIn);
    _heroAnimationController.forward();
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/notifications');
        break;
      case 1:
        context.go('/settings');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  Widget _buildHeroSection(double scale, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.9), primaryColor.withOpacity(0.62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(28 * scale),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trade with Confidence',
                  style: GoogleFonts.barlow(
                    fontSize: 32 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  'Experience real-time market data and paper trading with zero risk.',
                  style: GoogleFonts.barlow(
                    fontSize: 16 * scale,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 24 * scale),
                ElevatedButton(
                  onPressed: () => context.go('/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 14 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'Start Trading Now',
                    style: GoogleFonts.barlow(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20 * scale),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'lib/assets/images/logo_.png',
                fit: BoxFit.cover,
                height: 160 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final scale = MediaQuery.of(context).size.width / 900;
    final primaryColor = Colors.deepPurpleAccent;
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white70,
        elevation: 1,
        centerTitle: true,
        leading: null, // No back button on homepage
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Demo",
                style: GoogleFonts.barlow(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22 * scale,
                  letterSpacing: 1.4,
                ),
              ),
              TextSpan(
                text: "Trader",
                style: GoogleFonts.barlow(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22 * scale,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/search'),
            icon: Icon(Icons.search, color: textColor, size: 26 * scale),
            tooltip: "Search",
          ),
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: Icon(Icons.notifications_none, color: textColor, size: 26 * scale),
            tooltip: "Notifications",
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Add refresh logic here
              },
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                children: [
                  FadeTransition(
                    opacity: _heroImageFade,
                    child: _buildHeroSection(scale, primaryColor),
                  ),
                  SizedBox(height: 28 * scale),
                  AnimatedInView(index: 0, child: WalletBalanceCard(scale: scale)),
                  SizedBox(height: 16 * scale),
                  AnimatedInView(index: 1, child: BalanceCard(scale: scale)),
                  SizedBox(height: 24 * scale),
                  AnimatedInView(index: 2, child: MarketTabs()),
                  SizedBox(height: 16 * scale),
                  AnimatedInView(index: 3, child: FilterChips()),
                  SizedBox(height: 20 * scale),

                  _buildSection(
                    title: 'Trending Stocks',
                    scale: scale,
                    child: TrendingSection(scale: scale),
                    onViewAllTap: () => context.go('/market-movers'),
                    animationIndex: 4,
                  ),
                  SizedBox(height: 20 * scale),

                  _buildSection(
                    title: 'Latest News',
                    scale: scale,
                    child: CompactNewsSection(scale: scale),
                    onViewAllTap: () => context.go('/news'),
                    animationIndex: 8,
                  ),
                  SizedBox(height: 20 * scale),

                  _buildSection(
                    title: 'Live Stock Chart',
                    scale: scale,
                    child: StockChartSection(scale: scale),
                    onViewAllTap: () => context.go('/stock-chart'),
                    animationIndex: 5,
                  ),
                  SizedBox(height: 20 * scale),

                  _buildSection(
                    title: 'Compare Stocks',
                    scale: scale,
                    child: StockComparisonSection(scale: scale),
                    animationIndex: 6,
                  ),
                  SizedBox(height: 16 * scale),

                  _buildSection(
                    title: 'Watchlist',
                    scale: scale,
                    child: CompactWatchlistSection(scale: scale),
                    onViewAllTap: () => context.go('/watchlist'),
                    animationIndex: 7,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        indicatorColor: Colors.transparent,
        backgroundColor: isDark ? Colors.black : Colors.white,
        onDestinationSelected: _onNavTap,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.notifications_none, color: _selectedIndex == 0 ? primaryColor : Colors.grey),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings, color: _selectedIndex == 1 ? primaryColor : Colors.grey),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: _selectedIndex == 2 ? primaryColor : Colors.grey),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required double scale,
    required Widget child,
    VoidCallback? onViewAllTap,
    required int animationIndex,
  }) {
    return AnimatedInView(
      index: animationIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            scale: scale,
            onViewAll: onViewAllTap,
          ),
          SizedBox(height: 6 * scale),
          child,
        ],
      ),
    );
  }
}
