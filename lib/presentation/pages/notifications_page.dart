import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // ✅ Added for context.pop()
import '../../business_logic/providers/notification_provider.dart';
import '../../business_logic/models/notification_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.allNotifications;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.purpleAccent, // styled back icon
          onPressed: () => context.pop(), // ✅ GoRouter back
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.purpleAccent),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.purpleAccent),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        separatorBuilder: (_, __) =>
        const Divider(color: Colors.white24, height: 1),
        itemBuilder: (context, index) {
          final NotificationItem n = notifications[index];
          return ListTile(
            tileColor: n.isRead
                ? Colors.black54
                : Colors.purpleAccent.withOpacity(0.15),
            leading: Icon(
              Icons.notifications,
              color: n.isRead ? Colors.white54 : Colors.purpleAccent,
            ),
            title: Text(
              n.title,
              style: TextStyle(
                color: n.isRead
                    ? Colors.white70
                    : Colors.purpleAccent,
                fontWeight: n.isRead
                    ? FontWeight.normal
                    : FontWeight.bold,
              ),
            ),
            subtitle: Text(
              n.body,
              style: TextStyle(
                color: n.isRead ? Colors.white60 : Colors.white,
              ),
            ),
            trailing: Text(
              _formatTimestamp(n.timestamp),
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            onTap: () => notificationProvider.markAsRead(n.id),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
