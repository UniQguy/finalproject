import 'package:finalproject/presentation/pages/account_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

// Pages
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/onboarding_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/signup_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/trading_page.dart';
import '../presentation/pages/portfolio_page.dart';
import '../presentation/pages/news_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/pages/notifications_page.dart';
import '../presentation/pages/trading_history_page.dart';
import '../presentation/pages/market_movers_page.dart';
import '../presentation/pages/search_page.dart';
import '../presentation/pages/news_detail_page.dart';
import '../presentation/pages/stock_chart_page.dart';
import '../presentation/pages/appearance_settings_page.dart';
import '../presentation/pages/notification_settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash, // Start at splash screen
    routes: [
      _slideFade(AppRoutes.splash, const SplashPage()),
      _slideFade(AppRoutes.onboarding, const OnboardingPage()),
      _slideFade(AppRoutes.login, const LoginPage()),
      _slideFade(AppRoutes.signup, const SignupPage()),
      _slideFade(AppRoutes.home, const HomePage()),
      _slideFade(AppRoutes.trading, const TradingPage()),
      _slideFade(AppRoutes.portfolio, const PortfolioPage()),

      // News with nested detail route
      _slideFade(AppRoutes.news, const NewsPage(), subRoutes: [
        GoRoute(
          path: 'detail',
          pageBuilder: (context, state) {
            final data = state.extra as Map<String, dynamic>? ?? {};
            return _transitionPage(
              child: NewsDetailPage(
                title: data['title'] ?? 'Unknown Title',
                summary: data['summary'] ?? '',
                time: data['time'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                fullArticle: data['fullArticle'] ?? '',
              ),
            );
          },
        ),
      ]),

      _slideFade(AppRoutes.profile, const ProfilePage()),
      _slideFade(AppRoutes.settings, const SettingsPage()),
      _slideFade(AppRoutes.notifications, const NotificationsPage()),
      _slideFade(AppRoutes.tradingHistory, const TradingHistoryPage()),
      _slideFade(AppRoutes.marketMovers, const MarketMoversPage()),
      _slideFade(AppRoutes.search, const SearchPage()),

      // Stock chart
      _slideFade(AppRoutes.stockChart, StockChartPage(stockSymbol: 'AAPL')),

      // Settings subpages
      _slideFade(AppRoutes.accountSettings, const AccountSettingsPage()),
      _slideFade(AppRoutes.appearanceSettings, const AppearanceSettingsPage()),
      _slideFade(AppRoutes.notificationSettings, const NotificationSettingsPage()),
    ],
  );

  /// Creates a GoRoute with a fade + slide transition
  static GoRoute _slideFade(String path, Widget child, {List<RouteBase> subRoutes = const []}) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => _transitionPage(child: child),
      routes: subRoutes,
    );
  }

  /// Shared page transition style (fade + horizontal slide)
  static CustomTransitionPage _transitionPage({required Widget child}) {
    return CustomTransitionPage(
      transitionDuration: const Duration(milliseconds: 500),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween(begin: const Offset(0.1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          ),
        );
      },
    );
  }
}
