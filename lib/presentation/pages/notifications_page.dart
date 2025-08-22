import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../../business_logic/providers/notification_provider.dart';
import '../../business_logic/models/notification_item.dart';

/// Page displaying all user notifications with interactive read/clear functionality.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double scale = MediaQuery.of(context).size.width / 900;
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.allNotifications;

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
          'Notifications (${notificationProvider.unreadCount})',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read, color: Colors.purpleAccent),
            onPressed: notificationProvider.markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.purpleAccent),
            onPressed: notificationProvider.clearNotifications,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text(
          'No notifications yet',
          style: GoogleFonts.barlow(
            color: Colors.white70,
            fontSize: 16 * scale,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(18 * scale),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final NotificationItem notification = notifications[index];
          return AnimatedInView(
            index: index,
            child: AppGlassyCard(
              borderRadius: BorderRadius.circular(20 * scale),
              padding: EdgeInsets.all(20 * scale),
              child: InkWell(
                onTap: () {
                  if (!notification.isRead) {
                    notificationProvider.markAsRead(notification.id);
                  }
                  context.go('/notification-detail', extra: notification);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.barlow(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      notification.body,
                      style: GoogleFonts.barlow(
                        fontSize: 14 * scale,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    Text(
                      notification.timeAgo,
                      style: GoogleFonts.barlow(
                        fontSize: 12 * scale,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
