import 'dart:async';
import 'dart:math';
import 'package:finalproject/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _topHandController;
  late final Animation<Offset> _topHandAnimation;

  late final AnimationController _bottomHandController;
  late final Animation<Offset> _bottomHandAnimation;

  late final AnimationController _titleFadeController;
  late final Animation<double> _titleFadeAnimation;
  late final AnimationController _titleScaleController;
  late final Animation<double> _titleScaleAnimation;

  late final AnimationController _sloganFadeController;
  late final Animation<double> _sloganFadeAnimation;
  late final AnimationController _sloganShimmerController;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // After animations complete, navigate based on onboarding status
    Future.delayed(const Duration(milliseconds: 3500), _navigateNext);
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) return;

    if (!seenOnboarding) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _initAnimations() {
    _topHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _topHandAnimation = Tween<Offset>(
      begin: const Offset(0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _topHandController, curve: Curves.easeInOut));

    _bottomHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _bottomHandAnimation = Tween<Offset>(
      begin: const Offset(0, 2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bottomHandController, curve: Curves.easeInOut));

    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _titleFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleFadeController, curve: Curves.easeInOutCubic),
    );

    _titleScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _titleScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _titleScaleController, curve: Curves.elasticOut),
    );

    _sloganFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sloganFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sloganFadeController, curve: Curves.easeIn),
    );

    _sloganShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Start animations with delays
    _topHandController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _bottomHandController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      _titleFadeController.forward();
      _titleScaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      _sloganFadeController.forward();
    });
  }

  @override
  void dispose() {
    _topHandController.dispose();
    _bottomHandController.dispose();
    _titleFadeController.dispose();
    _titleScaleController.dispose();
    _sloganFadeController.dispose();
    _sloganShimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final handHeight = screenH * 0.45;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              const Color(0xFF1a0e37).withOpacity(0.9),
              const Color(0xFF331f60).withOpacity(0.7),
              Colors.black.withOpacity(0.85),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top animated hand image
            Positioned(
              left: screenW * 0.15,
              top: screenH * -0.05,
              child: SlideTransition(
                position: _topHandAnimation,
                child: Transform.rotate(
                  angle: 3.15,
                  child: Image.asset(
                    'lib/assets/images/cyborg_hand_right.png',
                    height: handHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom animated hand image
            Positioned(
              right: screenW * 0.11,
              bottom: screenH * -0.03,
              child: SlideTransition(
                position: _bottomHandAnimation,
                child: Image.asset(
                  'lib/assets/images/cyborg_hand_left.png',
                  height: handHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Title with fade & scale animation
            Positioned(
              left: 0,
              right: 0,
              top: screenH * 0.43,
              child: FadeTransition(
                opacity: _titleFadeAnimation,
                child: ScaleTransition(
                  scale: _titleScaleAnimation,
                  child: Text(
                    'DemoTrader',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.purpleAccent.shade400,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.purple.shade900,
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        Shadow(
                          color: Colors.purpleAccent.shade100,
                          blurRadius: 40,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Slogan with shimmer and fade animation
            Positioned(
              left: 0,
              right: 0,
              top: screenH * 0.53,
              child: FadeTransition(
                opacity: _sloganFadeAnimation,
                child: AnimatedBuilder(
                  animation: _sloganShimmerController,
                  builder: (context, child) {
                    final shimmerValue = (_sloganShimmerController.value * 2) - 1; // -1 to 1
                    final double blurRadius = 5 + (3 * shimmerValue.abs());
                    final double offsetY = -2 * shimmerValue;
                    return Text(
                      'Trade Your Passion With Virtual Money',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.92),
                        letterSpacing: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.purpleAccent.withOpacity(0.5),
                            blurRadius: blurRadius,
                            offset: Offset(0, offsetY),
                          ),
                          Shadow(
                            color: Colors.purpleAccent.withOpacity(0.4),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
