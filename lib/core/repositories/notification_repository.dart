import '../models/api_notification.dart';
import '../network/api_client.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications({int page = 1});
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<void> delete(int id);
}

class ApiNotificationRepository implements NotificationRepository {
  final _client = ApiClient().dio;

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _client.get('/notifications', queryParameters: {'page': page});
    final data = response.data['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    return response.data['data']['count'] ?? 0;
  }

  @override
  Future<void> markAsRead(int id) async {
    await _client.put('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _client.put('/notifications/read-all');
  }

  @override
  Future<void> delete(int id) async {
    await _client.delete('/notifications/$id');
  }
}
