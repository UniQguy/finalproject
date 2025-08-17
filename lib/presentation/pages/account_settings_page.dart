import 'package:flutter/material.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_in_view.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.tealAccent;

    return Scaffold(
      body: Stack(
        children: [
          // Subtle moving gradient background
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GradientText(
                  text: '👤 Account Settings',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: LinearGradient(
                    colors: [themeColor, Colors.purpleAccent],
                  ),
                ),
                const SizedBox(height: 20),

                // Change Email
                _settingTile(
                  context,
                  index: 0,
                  title: 'Change Email',
                  icon: Icons.email_outlined,
                  borderColor: themeColor,
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // Change Password
                _settingTile(
                  context,
                  index: 1,
                  title: 'Change Password',
                  icon: Icons.lock_outline,
                  borderColor: themeColor,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(BuildContext context,
      {required int index,
        required String title,
        required IconData icon,
        required Color borderColor,
        required VoidCallback onTap}) {
    return AnimatedInView(
      index: index,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 250),
          tween: Tween(begin: 1.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: AppGlassyCard(
                borderColor: borderColor,
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(0),
                child: ListTile(
                  leading: Icon(icon, color: borderColor, size: 26),
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
