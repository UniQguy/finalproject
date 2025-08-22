import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../business_logic/models/notification_item.dart';

/// Displays detailed information about a single notification.
class NotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Navigate to homepage
        ),
        title: Text(
          'Notification Detail',
          style: GoogleFonts.barlow(
            fontWeight: FontWeight.bold,
            fontSize: 20 * scale,
            color: Colors.purpleAccent,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(24.0 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: GoogleFonts.barlow(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              notification.timeAgo,
              style: GoogleFonts.barlow(
                fontSize: 14 * scale,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              notification.body,
              style: GoogleFonts.barlow(
                fontSize: 16 * scale,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
