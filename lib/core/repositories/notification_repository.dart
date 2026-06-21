import '../models/api_notification.dart';
import '../network/api_client.dart';

class NotificationRepository {
  final _client = ApiClient().dio;

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _client.get('/notifications', queryParameters: {'page': page});
    final data = response.data['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    return response.data['data']['count'] ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _client.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.put('/notifications/read-all');
  }

  Future<void> delete(int id) async {
    await _client.delete('/notifications/$id');
  }
}
