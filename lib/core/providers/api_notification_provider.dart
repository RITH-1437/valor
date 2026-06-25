import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repositories.dart';
import '../models/api_notification.dart';
import '../network/api_client.dart' show ApiClient, ApiMode;
import '../repositories/notification_repository.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return ApiClient.apiMode == ApiMode.live ? ApiNotificationRepository() : MockNotificationRepository();
});

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  @override
  Future<List<NotificationModel>> build() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return [];
    _unreadCount = await ref.read(notificationRepositoryProvider).getUnreadCount();
    return ref.read(notificationRepositoryProvider).getNotifications();
  }

  Future<void> refresh() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    _unreadCount = await ref.read(notificationRepositoryProvider).getUnreadCount();
    ref.invalidateSelf();
  }

  Future<void> markAsRead(int id) async {
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      _unreadCount = 0;
      ref.invalidateSelf();
    } catch (_) {}
  }

  Future<void> delete(int id) async {
    try {
      await ref.read(notificationRepositoryProvider).delete(id);
      ref.invalidateSelf();
    } catch (_) {}
  }
}

final notificationProvider = AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(NotificationNotifier.new);
