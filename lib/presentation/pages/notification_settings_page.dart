import 'package:flutter/material.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_in_view.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<NotificationSettingsPage> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool smsEnabled = false;

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
                  text: '🔔 Notification Settings',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.pinkAccent],
                  ),
                ),
                const SizedBox(height: 20),

                // Push Notifications
                AnimatedInView(
                  index: 0,
                  child: AppGlassyCard(
                    borderColor: Colors.tealAccent, // ✅ Added required param
                    child: SwitchListTile(
                      activeColor: Colors.tealAccent,
                      title: const Text(
                        'Push Notifications',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: pushEnabled,
                      onChanged: (val) {
                        setState(() => pushEnabled = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Email Alerts
                AnimatedInView(
                  index: 1,
                  child: AppGlassyCard(
                    borderColor: Colors.tealAccent, // ✅ Added required param
                    child: SwitchListTile(
                      activeColor: Colors.tealAccent,
                      title: const Text(
                        'Email Alerts',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: emailEnabled,
                      onChanged: (val) {
                        setState(() => emailEnabled = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // SMS Alerts
                AnimatedInView(
                  index: 2,
                  child: AppGlassyCard(
                    borderColor: Colors.tealAccent, // ✅ Added required param
                    child: SwitchListTile(
                      activeColor: Colors.tealAccent,
                      title: const Text(
                        'SMS Alerts',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: smsEnabled,
                      onChanged: (val) {
                        setState(() => smsEnabled = val);
                      },
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
