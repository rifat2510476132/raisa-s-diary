import '../core/services/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  Future<UserModel> getProfile() async {
    final res = await _api.get('/users/me');
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({String? displayName, String? avatarUrl}) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    final res = await _api.patch('/users/me', body);
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> registerDeviceToken(String token, {String platform = 'android'}) async {
    await _api.post('/users/device-token', {'token': token, 'platform': platform});
  }
}
