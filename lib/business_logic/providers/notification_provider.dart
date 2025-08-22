import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';

/// Manages user notifications and notification settings/preferences.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  /// Returns an unmodifiable view of all notifications.
  List<NotificationItem> get allNotifications => List.unmodifiable(_notifications);

  /// Counts how many notifications are unread.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Preference flags default to true.
  bool _notificationsEnabled = true;
  bool _marketAlertsEnabled = true;
  bool _tradeNotificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get marketAlertsEnabled => _marketAlertsEnabled;
  bool get tradeNotificationsEnabled => _tradeNotificationsEnabled;

  NotificationProvider() {
    loadPreferences();
  }

  /// Adds a new notification to the top of the list.
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Removes a notification by its ID.
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Clears all notifications.
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Marks a specific notification as read by ID.
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Marks all notifications as read in bulk.
  void markAllAsRead() {
    bool changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Loads notification preference flags from persistent shared preferences.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _marketAlertsEnabled = prefs.getBool('marketAlertsEnabled') ?? true;
    _tradeNotificationsEnabled = prefs.getBool('tradeNotificationsEnabled') ?? true;
    notifyListeners();
  }

  /// Saves current notification preference flags persistently.
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('marketAlertsEnabled', _marketAlertsEnabled);
    await prefs.setBool('tradeNotificationsEnabled', _tradeNotificationsEnabled);
  }

  /// Enables or disables all notifications; disables subcategories when false.
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    if (!value) {
      _marketAlertsEnabled = false;
      _tradeNotificationsEnabled = false;
    }
    notifyListeners();
    _savePreferences();
  }

  /// Enables or disables market alert notifications.
  void setMarketAlertsEnabled(bool value) {
    _marketAlertsEnabled = value;
    notifyListeners();
    _savePreferences();
  }

  /// Enables or disables trade-related notifications.
  void setTradeNotificationsEnabled(bool value) {
    _tradeNotificationsEnabled = value;
    notifyListeners();
    _savePreferences();
  }
}
