import 'package:finalproject/presentation/pages/account_settings_page.dart';
import 'package:finalproject/presentation/pages/appearance_settings_page.dart';
import 'package:finalproject/presentation/pages/notification_settings_page.dart';
import 'package:flutter/material.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                GradientText(
                  text: '⚙ Settings',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.tealAccent],
                  ),
                ),
                const SizedBox(height: 20),
                _settingsItem(
                  context,
                  0,
                  icon: Icons.person,
                  title: 'Account',
                  subtitle: 'Manage your account details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
                    );
                  },
                ),
                _settingsItem(
                  context,
                  1,
                  icon: Icons.palette,
                  title: 'Appearance',
                  subtitle: 'Theme & display settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppearanceSettingsPage()),
                    );
                  },
                ),
                _settingsItem(
                  context,
                  2,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Alerts & push notifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsItem(BuildContext context, int index,
      {required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap}) {
    return AnimatedInView(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AppGlassyCard(
          borderColor: Colors.tealAccent, // ✅ required parameter added
          child: ListTile(
            leading: Icon(icon, color: Colors.tealAccent),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 14),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
