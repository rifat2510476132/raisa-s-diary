import '../core/services/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._api);
  final ApiClient _api;

  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    final res = await _api.get('/notifications${unreadOnly ? '?unread=true' : ''}');
    final list = res['data'] as List;
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await _api.patch('/notifications/$id/read', {});
  }

  Future<void> markAllRead() async {
    await _api.patch('/notifications/read-all', {});
  }

  Future<void> registerDevice(String token, {String platform = 'android'}) async {
    await _api.post('/notifications/device', {
      'token': token,
      'platform': platform,
    });
  }
}
