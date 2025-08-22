import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_in_view.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.tealAccent;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/home'), // Back to homepage
                  ),
                  title: const Text(
                    'Account Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GradientText(
                        text: '👤 Account Settings',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                        gradient: const LinearGradient(
                          colors: [themeColor, Colors.purpleAccent],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _settingTile(
                        context,
                        index: 0,
                        title: 'Change Email',
                        icon: Icons.email_outlined,
                        borderColor: themeColor,
                        onTap: () {
                          // TODO: Implement email change navigation or dialog
                        },
                      ),
                      const SizedBox(height: 16),
                      _settingTile(
                        context,
                        index: 1,
                        title: 'Change Password',
                        icon: Icons.lock_outline,
                        borderColor: themeColor,
                        onTap: () {
                          // TODO: Implement password change navigation or dialog
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(
      BuildContext context, {
        required int index,
        required String title,
        required IconData icon,
        required Color borderColor,
        required VoidCallback onTap,
      }) {
    return AnimatedInView(
      index: index,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale as double,
              child: AppGlassyCard(
                borderColor: borderColor,
                borderRadius: BorderRadius.circular(20),
                padding: EdgeInsets.zero,
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
