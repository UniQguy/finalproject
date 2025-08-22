import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To save onboarding seen flag
import '../../routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _current = 0;

  late final AnimationController _morphController;
  late Animation<double> _morphAnimation;

  final List<Map<String, String>> _slides = [
    {
      "title": "Trade Smarter",
      "desc": "Simulate stock trading with real-time dummy prices.",
      "svg": "assets/svgs/trade.svg"
    },
    {
      "title": "Put & Call",
      "desc": "Execute options trades with a simple tap.",
      "svg": "assets/svgs/options.svg"
    },
    {
      "title": "Track Portfolio",
      "desc": "View live P&L and manage positions easily.",
      "svg": "assets/svgs/portfolio.svg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    );
    _morphController.forward();
  }

  @override
  void dispose() {
    _morphController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _current = index;
    });
    _morphController.forward(from: 0);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    const double topPadding = 140;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
      body: SafeArea(
        child: Stack(
          children: [
            // Morphing line animation near the top center
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              height: 100,
              child: AnimatedBuilder(
                animation: _morphAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: MorphingLinePainter(
                      progress: _morphAnimation.value,
                      slideIndex: _current,
                      color: Colors.purpleAccent.withOpacity(0.7),
                    ),
                  );
                },
              ),
            ),

            // Main onboarding content
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _slides.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, index) {
                      final slide = _slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (child, animation) {
                                  switch (_current) {
                                    case 0:
                                      return ScaleTransition(
                                        scale: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.elasticOut,
                                        ),
                                        child: child,
                                      );
                                    case 1:
                                      return RotationTransition(
                                        turns: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      );
                                    case 2:
                                    default:
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.2),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                  }
                                },
                                child: SvgPicture.asset(
                                  slide["svg"]!,
                                  fit: BoxFit.contain,
                                  key: ValueKey(slide["svg"]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            slide["title"]!,
                            style: GoogleFonts.orbitron(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                              shadows: [
                                Shadow(
                                  color: Colors.deepPurpleAccent.withOpacity(0.7),
                                  blurRadius: 20,
                                  offset: Offset.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 38),
                            child: Text(
                              slide["desc"]!,
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 38),
                        ],
                      );
                    },
                  ),
                ),

                // Pagination dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                      height: 9,
                      width: _current == index ? 30 : 9,
                      decoration: BoxDecoration(
                        color: _current == index ? Colors.purpleAccent : Colors.white24,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: _current == index
                            ? [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.6),
                            blurRadius: 12,
                          )
                        ]
                            : [],
                      ),
                    ),
                  ),
                ),

                // Next / Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 14,
                    ),
                    onPressed: () async {
                      if (_current == _slides.length - 1) {
                        await _completeOnboarding();
                        context.go(AppRoutes.login);
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _current == _slides.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MorphingLinePainter extends CustomPainter {
  final double progress;
  final int slideIndex;
  final Color color;

  MorphingLinePainter({
    required this.progress,
    required this.slideIndex,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    const baseLength = 140.0;

    switch (slideIndex) {
      case 0:
        double lineProgress = progress;

        path.moveTo(centerX - baseLength / 2, centerY);

        double peakHeight = 40 * sin(pi * lineProgress);
        double controlX = centerX;
        double controlY = centerY - peakHeight;

        path.quadraticBezierTo(controlX, controlY, centerX + baseLength / 2, centerY);

        canvas.drawPath(path, paint);

        double spacing = baseLength / 7;
        double barWidth = 8;
        for (int i = 0; i < 8; i++) {
          double barX = centerX - baseLength / 2 + i * spacing;
          double barHeight = 0;
          if (lineProgress > 0.3) {
            double barProgress = ((lineProgress - 0.3) * 1.5 - i * 0.1).clamp(0.0, 1.0);
            double sinFactor = 0.5 + 0.5 * sin(i * pi / 3);
            barHeight = 30 * barProgress * sinFactor;
          }
          if (barHeight > 0) {
            paint.strokeWidth = barWidth;
            canvas.drawLine(Offset(barX, centerY), Offset(barX, centerY - barHeight), paint);
          }
        }
        break;

      case 1:
        double morph = progress;

        final leftStartX = centerX - baseLength / 3;
        final leftStartY = centerY;
        final leftControlX = centerX - baseLength / 2 * (0.7 + 0.3 * morph);
        final leftControlY = centerY - 40 * morph;
        final leftEndX = centerX - baseLength / 8;
        final leftEndY = centerY - 10 * morph;

        path.moveTo(leftStartX, leftStartY);
        path.quadraticBezierTo(leftControlX, leftControlY, leftEndX, leftEndY);

        final rightStartX = centerX + baseLength / 3;
        final rightStartY = centerY;
        final rightControlX = centerX + baseLength / 2 * (0.7 + 0.3 * morph);
        final rightControlY = centerY + 40 * morph;
        final rightEndX = centerX + baseLength / 8;
        final rightEndY = centerY + 10 * morph;

        path.moveTo(rightStartX, rightStartY);
        path.quadraticBezierTo(rightControlX, rightControlY, rightEndX, rightEndY);

        canvas.drawPath(path, paint);

        double arrowSize = 12 * morph;

        path.reset();
        path.moveTo(leftEndX - arrowSize / 2, leftEndY - arrowSize / 2);
        path.lineTo(leftEndX, leftEndY);
        path.lineTo(leftEndX + arrowSize / 2, leftEndY - arrowSize / 2);

        path.moveTo(rightEndX - arrowSize / 2, rightEndY + arrowSize / 2);
        path.lineTo(rightEndX, rightEndY);
        path.lineTo(rightEndX + arrowSize / 2, rightEndY + arrowSize / 2);

        canvas.drawPath(path, paint);
        break;

      case 2:
      default:
        int dotCount = 8;
        double spacing = baseLength / (dotCount - 1);

        for (int i = 0; i < dotCount; i++) {
          double progressOffset = (progress * 2 - i / dotCount) % 1.0;
          if (progressOffset < 0) progressOffset += 1.0;

          double x = centerX - baseLength / 2 + i * spacing;
          double y = centerY + 20 * sin(progress * 2 * pi + i);
          double radius = 6 + 4 * progressOffset;

          paint.color = color.withOpacity(0.2 + 0.8 * progressOffset.abs());
          canvas.drawCircle(Offset(x, y - radius / 2), radius, paint);
        }

        paint
          ..color = color.withOpacity(0.4)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(centerX - baseLength / 2, centerY),
          Offset(centerX + baseLength / 2, centerY),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant MorphingLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.slideIndex != slideIndex;
  }
}
