import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/theme_provider.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_in_view.dart';
import 'color_picker_page.dart'; // Ensure this exists as we built earlier

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  void _openColorPicker(BuildContext context, Color currentColor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ColorPickerPage(
          currentColor: currentColor,
          onColorSelected: (color) {
            context.read<ThemeProvider>().setPrimaryColor(color);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Header Title
                GradientText(
                  text: '🎨 Appearance Settings',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  gradient: LinearGradient(
                    colors: [themeProvider.primaryColor, Colors.purpleAccent],
                  ),
                ),
                const SizedBox(height: 20),

                // Dark Mode toggle
                AnimatedInView(
                  index: 0,
                  child: AppGlassyCard(
                    borderColor: themeProvider.primaryColor, // Added required parameter
                    child: SwitchListTile(
                      activeColor: themeProvider.primaryColor,
                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (val) {
                        // *TODO: Hook into a Light/Dark theme provider*
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dark mode toggle not yet implemented'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Primary Color Picker
                AnimatedInView(
                  index: 1,
                  child: AppGlassyCard(
                    borderColor: themeProvider.primaryColor, // Added required parameter
                    child: ListTile(
                      leading: Icon(Icons.palette, color: themeProvider.primaryColor),
                      title: const Text(
                        'Primary Color',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Choose app accent color',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 14,
                      ),
                      onTap: () => _openColorPicker(context, themeProvider.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
