import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart'; // Your main app widget containing MaterialApp.router or equivalent
import 'firebase_options.dart';

import 'business_logic/providers/auth_provider.dart';
import 'business_logic/providers/market_provider.dart';
import 'business_logic/providers/notification_provider.dart';
import 'business_logic/providers/portfolio_provider.dart';
import 'business_logic/providers/stock_provider.dart';
import 'business_logic/providers/theme_provider.dart';
import 'business_logic/providers/wallet_provider.dart';
import 'business_logic/providers/watchlist_provider.dart';
import 'business_logic/providers/news_provider.dart';

const String finnhubApiKey = 'd2jhgg9r01qj8a5jdo1gd2jhgg9r01qj8a5jdo20';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = MarketProvider(apiKey: finnhubApiKey);
          provider.startFetchingStocks(['AAPL', 'GOOGL', 'TSLA', 'MSFT']);
          return provider;
        }),
        ChangeNotifierProxyProvider2<AuthProvider, MarketProvider, PortfolioProvider>(
          create: (_) => PortfolioProvider(userId: '', marketProvider: null),
          update: (context, authProvider, marketProvider, previous) {
            final uid = authProvider.userId ?? '';
            return PortfolioProvider(userId: uid, marketProvider: marketProvider);
          },
        ),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider(apiKey: finnhubApiKey)),
        ChangeNotifierProxyProvider<AuthProvider, WalletProvider>(
          create: (_) => WalletProvider(userId: ''),
          update: (context, authProvider, previous) {
            final uid = authProvider.userId ?? '';
            return WalletProvider(userId: uid);
          },
        ),
        ChangeNotifierProvider(create: (_) {
          final newsProvider = NewsProvider(apiKey: finnhubApiKey);
          newsProvider.fetchNews();
          return newsProvider;
        }),
      ],
      child: const DemoApp(),
    ),
  );
}
