import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';

// Providers
import 'business_logic/providers/auth_provider.dart';
import 'business_logic/providers/market_provider.dart';
import 'business_logic/providers/portfolio_provider.dart';
import 'business_logic/providers/notification_provider.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'DemoTrader',
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF7F3FBF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
