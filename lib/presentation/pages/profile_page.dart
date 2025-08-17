import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/neon_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String userName = "John Doe";
    const String userEmail = "john.doe@example.com";
    final Color accent = Colors.tealAccent;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          const AnimatedGradientWidget(),

          // Floating sparkle particles
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ParticlePainter(accent: accent)),
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                AnimatedInView(
                  index: 0,
                  child: GradientText(
                    text: '👤 Profile',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.tealAccent],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar
                AnimatedInView(
                  index: 1,
                  child: Hero(
                    tag: "profile-avatar",
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Colors.purpleAccent,
                            Colors.tealAccent,
                            Colors.purpleAccent,
                          ],
                          startAngle: 0.0,
                          endAngle: pi * 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 55,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Name & Email
                AnimatedInView(
                  index: 2,
                  child: Column(
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Security Settings → navigates to Account Settings
                _buildOptionCard(
                  context: context,
                  index: 3,
                  title: "Security",
                  subtitle: "Manage passwords, 2FA, and device logins",
                  icon: Icons.security,
                  accent: accent,
                  route: AppRoutes.accountSettings,
                ),
                const SizedBox(height: 12),

                // Notifications Settings
                _buildOptionCard(
                  context: context,
                  index: 4,
                  title: "Notifications",
                  subtitle: "Customize alerts and push notifications",
                  icon: Icons.notifications,
                  accent: accent,
                  route: AppRoutes.notificationSettings,
                ),
                const SizedBox(height: 12),

                // General Settings
                _buildOptionCard(
                  context: context,
                  index: 5,
                  title: "General Settings",
                  subtitle: "Theme, language, and app preferences",
                  icon: Icons.settings,
                  accent: accent,
                  route: AppRoutes.appearanceSettings,
                ),

                const SizedBox(height: 40),

                // Logout
                AnimatedInView(
                  index: 6,
                  child: NeonButton(
                    label: 'Logout',
                    onPressed: () {
                      // TODO: implement logout
                    },
                    color: Colors.redAccent,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String route,
  }) {
    return AnimatedInView(
      index: index,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: AppGlassyCard(
                borderColor: accent,
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  leading: Icon(icon, color: accent, size: 26),
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white54, size: 14),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Particle background painter
class _ParticlePainter extends CustomPainter {
  final Color accent;
  _ParticlePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final rnd = Random();
    for (int i = 0; i < 25; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
