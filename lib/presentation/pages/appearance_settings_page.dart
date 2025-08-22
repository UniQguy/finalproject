import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/providers/theme_provider.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance Settings',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.purpleAccent,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Dark Mode',
                style: GoogleFonts.barlow(color: Colors.white),
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleDarkMode,
                activeColor: Colors.purpleAccent,
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              title: Text(
                'Use System Theme',
                style: GoogleFonts.barlow(color: Colors.white),
              ),
              trailing: Switch(
                value: themeProvider.useSystemTheme,
                onChanged: themeProvider.toggleUseSystemTheme,
                activeColor: Colors.purpleAccent,
              ),
            ),
            const Divider(color: Colors.white24),
            // Additional appearance settings can be added here
          ],
        ),
      ),
    );
  }
}
