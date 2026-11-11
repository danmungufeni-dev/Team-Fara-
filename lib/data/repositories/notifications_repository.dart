import '../models/notification_item.dart';
import '../services/mock_backend_store.dart';

abstract class INotificationsRepository {
  Future<List<NotificationItem>> getNotifications({NotificationCategory? category});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}

class NotificationsRepository implements INotificationsRepository {
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<List<NotificationItem>> getNotifications({
    NotificationCategory? category,
  }) async {
    if (category == null || category == NotificationCategory.all) {
      return _store.notifications;
    }
    return _store.notifications.where((n) => n.category == category).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _store.notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _store.notifications[idx] = _store.notifications[idx].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    _store.notifications = _store.notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    return _store.notifications.where((n) => !n.isRead).length;
  }
}
