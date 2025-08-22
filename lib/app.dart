import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'routes/app_router.dart';

import 'business_logic/providers/auth_provider.dart';
import 'business_logic/providers/market_provider.dart';
import 'business_logic/providers/portfolio_provider.dart';
import 'business_logic/providers/notification_provider.dart';
import 'business_logic/providers/theme_provider.dart';
import 'business_logic/providers/watchlist_provider.dart';
import 'business_logic/providers/stock_provider.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = MarketProvider(apiKey: 'YOUR_ACTUAL_API_KEY');
          provider.startFetchingStocks(['AAPL', 'GOOGL', 'TSLA', 'MSFT']);
          return provider;
        }),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'DemoTrader',
            themeMode: themeProvider.useSystemTheme
                ? ThemeMode.system
                : (themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light),
            theme: _buildLightTheme(themeProvider),
            darkTheme: _buildDarkTheme(themeProvider),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(ThemeProvider themeProvider) {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: themeProvider.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.primaryColor.withOpacity(0.9),
        elevation: 4,
        centerTitle: true,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: themeProvider.primaryColor,
        secondary: themeProvider.primaryColor,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Barlow',
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(ThemeProvider themeProvider) {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: themeProvider.primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: themeProvider.primaryColor,
        secondary: themeProvider.primaryColor,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Barlow',
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 10,
        ),
      ),
    );
  }
}
