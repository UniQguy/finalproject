import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/providers/notification_provider.dart';

/// Page to control various notification settings with toggles.
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(
              'Enable Notifications',
              style: GoogleFonts.barlow(color: Colors.white),
            ),
            value: notificationProvider.notificationsEnabled,
            onChanged: (value) => notificationProvider.setNotificationsEnabled(value),
            activeColor: Colors.purpleAccent,
          ),
          const Divider(color: Colors.white24),
          SwitchListTile(
            title: Text(
              'Market Alerts',
              style: GoogleFonts.barlow(color: Colors.white),
            ),
            value: notificationProvider.marketAlertsEnabled,
            onChanged: notificationProvider.notificationsEnabled
                ? (value) => notificationProvider.setMarketAlertsEnabled(value)
                : null,
            activeColor: Colors.purpleAccent,
          ),
          const Divider(color: Colors.white24),
          SwitchListTile(
            title: Text(
              'Trade Notifications',
              style: GoogleFonts.barlow(color: Colors.white),
            ),
            value: notificationProvider.tradeNotificationsEnabled,
            onChanged: notificationProvider.notificationsEnabled
                ? (value) => notificationProvider.setTradeNotificationsEnabled(value)
                : null,
            activeColor: Colors.purpleAccent,
          ),
          // Additional notification settings could be added here
        ],
      ),
    );
  }
}
