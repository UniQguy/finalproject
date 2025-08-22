import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_glassy_card.dart';
import '../widgets/animated_in_view.dart';

/// Settings page with grouped account and app preference sections, plus logout action.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Back to homepage
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
            letterSpacing: 1.3,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(18 * scale),
        children: [
          AnimatedInView(
            index: 0,
            child: AppGlassyCard(
              borderRadius: BorderRadius.circular(20 * scale),
              padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 28 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * scale,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingRow(context, 'Profile', '/profile', scale),
                  _buildSettingRow(context, 'Security', '/settings/security', scale),
                  _buildSettingRow(context, 'Notifications', '/settings/notifications', scale),
                ],
              ),
            ),
          ),
          SizedBox(height: 28 * scale),
          AnimatedInView(
            index: 1,
            child: AppGlassyCard(
              borderRadius: BorderRadius.circular(20 * scale),
              padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 28 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Preferences',
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * scale,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingRow(context, 'Appearance', '/settings/appearance', scale),
                  _buildSettingRow(context, 'Language', '/settings/language', scale),
                  _buildSettingRow(context, 'Data & Privacy', '/settings/privacy', scale),
                ],
              ),
            ),
          ),
          SizedBox(height: 28 * scale),
          AnimatedInView(
            index: 2,
            child: AppGlassyCard(
              borderRadius: BorderRadius.circular(20 * scale),
              padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 28 * scale),
              child: GestureDetector(
                onTap: () {
                  // TODO: Trigger logout functionality
                },
                child: Center(
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * scale,
                      color: Colors.redAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40 * scale),
        ],
      ),
    );
  }

  Widget _buildSettingRow(BuildContext context, String title, String route, double scale) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14 * scale),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.barlow(
                fontSize: 18 * scale,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.purpleAccent),
          ],
        ),
      ),
    );
  }
}
