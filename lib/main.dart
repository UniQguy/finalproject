import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Required for Firebase initialization

import 'app.dart';
import 'business_logic/providers/market_provider.dart';
import 'business_logic/providers/portfolio_provider.dart';
import 'business_logic/providers/notification_provider.dart';
import 'business_logic/providers/auth_provider.dart'; // ✅ Include AuthProvider for login/signup
import 'business_logic/providers/theme_provider.dart'; // ✅ New: Theme Provider for dynamic theming

import 'firebase_options.dart'; // Firebase config

import 'package:finalproject/routes/app_router.dart'; // Your app router with GoRouter setup

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options (required for Google Sign-In)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),       // For login/signup
        ChangeNotifierProvider(create: (_) => MarketProvider()),     // Market data
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),  // Portfolio holdings and trades
        ChangeNotifierProvider(create: (_) => NotificationProvider()), // Notifications
        ChangeNotifierProvider(create: (_) => ThemeProvider()),      // Dynamic theming
      ],
      child: const RootApp(),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Premium Trading App',
      theme: themeProvider.themeData, // Pulls theme from ThemeProvider
      routerConfig: AppRouter.router, // Connects your GoRouter config
    );
  }
}
