import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/splash_page.dart';
import '../presentation/pages/onboarding_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/signup_page.dart';
import '../presentation/pages/password_reset_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/trading_page.dart';
import '../presentation/pages/order_confirmation_page.dart';
import '../presentation/pages/portfolio_page.dart';
import '../presentation/pages/notifications_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/pages/market_movers_page.dart';
import '../presentation/pages/news_page.dart';
import '../presentation/pages/news_detail_page.dart';
import '../presentation/pages/watchlist_page.dart';
import '../presentation/pages/stock_chart_page.dart';
import '../presentation/pages/account_settings_page.dart';
import '../presentation/pages/appearance_settings_page.dart';
import '../presentation/pages/notification_settings_page.dart';
import '../presentation/pages/notification_detail_page.dart';
import '../presentation/pages/trading_history_page.dart';
import '../presentation/pages/search_page.dart';
import '../presentation/pages/orders_page.dart';
import '../presentation/pages/stock_comparison_page.dart';

import '../business_logic/models/stock.dart';
import '../business_logic/models/notification_item.dart';

import 'app_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.passwordReset,
        builder: (_, __) => const PasswordResetPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),

      // Trading Page: with optional symbol param
      GoRoute(
        path: '${AppRoutes.trading}/:symbol',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? '';
          return TradingPage(symbol: symbol);
        },
      ),
      GoRoute(
        path: AppRoutes.trading,
        builder: (_, __) => const TradingPage(),
      ),

      GoRoute(
        path: AppRoutes.orders,
        builder: (_, __) => const OrdersPage(),
      ),

      GoRoute(
        path: '${AppRoutes.orderConfirmation}/:symbol/:quantity/:isCall',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? '';
          final quantity = int.tryParse(state.pathParameters['quantity'] ?? '1') ?? 1;
          final isCall = (state.pathParameters['isCall'] ?? 'true') == 'true';

          final stock = Stock(
            symbol: symbol,
            company: '',
            price: 0,
            previousClose: 0,
            recentPrices: [],
          );

          return OrderConfirmationPage(
            stock: stock,
            quantity: quantity,
            isCall: isCall,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.portfolio,
        builder: (_, __) => const PortfolioPage(),
      ),

      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsPage(),
      ),

      // Profile Page (with all required params)
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          return ProfilePage(
            userEmail: 'user@example.com',
            userName: 'John Doe',
            avatarUrl: '', // add if available
            walletBalance: 100000.0,
            premium: true,
            details: {
              'Joined': 'January 2025',
              'Membership': 'Premium',
              'Referral Code': 'ABCD1234',
              'Phone': '+91 9876543210',
              'Email Verified': 'Yes',
              '2FA Enabled': 'Yes',
              'Notifications': 'Enabled',
              'Dark Mode': 'On',
              'Language': 'English',
              'Currency': 'INR',
              'Time Zone': 'GMT+5:30',
            },
            onLogout: () {
              context.go(AppRoutes.login);
            },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.marketMovers,
        builder: (_, __) => const MarketMoversPage(),
      ),

      // News Page with nested detail route
      GoRoute(
        path: AppRoutes.news,
        builder: (context, state) => NewsPage(
          apiKey: 'd2jhgg9r01qj8a5jdo1gd2jhgg9r01qj8a5jdo20', // your actual API key
        ),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final article = state.extra as Map? ?? {};
              return NewsDetailPage(
                title: article['title'] ?? '',
                summary: article['summary'] ?? '',
                time: article['time'] ?? '',
                imageUrl: article['imageUrl'] ?? '',
                fullArticle: article['fullArticle'] ?? '',
              );
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.watchlist,
        builder: (_, __) => const WatchlistPage(scale: 1.0),
      ),

      GoRoute(
        path: AppRoutes.stockChart,
        builder: (context, state) {
          final symbol = state.uri.queryParameters['symbol'] ?? 'AAPL';
          final prices = state.extra as List<double>? ?? [150, 152, 148, 154, 156, 158];
          return StockChartPage(stockSymbol: symbol, prices: prices);
        },
      ),

      GoRoute(
        path: AppRoutes.stockComparison,
        builder: (_, __) => const StockComparisonPage(),
      ),

      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (_, __) => const AccountSettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.appearanceSettings,
        builder: (_, __) => const AppearanceSettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (_, __) => const NotificationSettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.notificationDetail,
        builder: (context, state) {
          final notification = state.extra as NotificationItem?;
          if (notification == null) {
            return const Scaffold(
              body: Center(child: Text('Notification data missing')),
            );
          }
          return NotificationDetailPage(notification: notification);
        },
      ),

      GoRoute(
        path: AppRoutes.search,
        builder: (_, __) => const SearchPage(),
      ),

      GoRoute(
        path: AppRoutes.tradingHistory,
        builder: (_, __) => const TradingHistoryPage(),
      ),
    ],
  );
}
