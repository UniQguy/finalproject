import 'package:intl/intl.dart';

/// Represents a single notification item with read status and timestamp utilities.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  /// Returns a human-readable relative time string like "2 hours ago",
  /// "Just now", or formatted date for older notifications.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return '$m minute${m > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final h = difference.inHours;
      return '$h hour${h > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final d = difference.inDays;
      return '$d day${d > 1 ? 's' : ''} ago';
    } else {
      // For dates older than a week, return a formatted date string
      final formatter = DateFormat.yMMMd();
      return formatter.format(timestamp);
    }
  }

  /// Returns a formatted date and time string for detailed display
  String get formattedDateTime {
    final formatter = DateFormat('MMM d, yyyy h:mm a');
    return formatter.format(timestamp);
  }

  /// Marks this notification as read.
  void markAsRead() {
    isRead = true;
  }

  /// Marks this notification as unread.
  void markAsUnread() {
    isRead = false;
  }

  /// Clones the current notification item with optional new values.
  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
