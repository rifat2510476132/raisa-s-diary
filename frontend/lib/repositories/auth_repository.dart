import '../core/services/api_client.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final StorageService _storage;

  Future<UserModel> login(String email, String password) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    }, auth: false);
    final data = res['data'] as Map<String, dynamic>;
    await _storage.saveTokens(data['accessToken'], data['refreshToken']);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register(String email, String password, String displayName) async {
    final res = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'displayName': displayName,
    }, auth: false);
    final data = res['data'] as Map<String, dynamic>;
    await _storage.saveTokens(data['accessToken'], data['refreshToken']);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> getProfile() async {
    final res = await _api.get('/auth/profile');
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> logout() => _storage.clearTokens();

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', {'email': email}, auth: false);
  }
}
