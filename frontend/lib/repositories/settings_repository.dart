import '../core/services/api_client.dart';
import '../models/achievement_model.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  SettingsRepository(this._api);
  final ApiClient _api;

  Future<SettingsModel> getSettings() async {
    final res = await _api.get('/settings');
    return SettingsModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<SettingsModel> updateSettings(Map<String, dynamic> body) async {
    final res = await _api.patch('/settings', body);
    return SettingsModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> setPin(String pin) async {
    await _api.post('/settings/pin', {'pin': pin});
  }

  Future<bool> verifyPin(String pin) async {
    final res = await _api.post('/settings/pin/verify', {'pin': pin});
    return res['data']['valid'] as bool? ?? false;
  }

  Future<void> removePin() async {
    await _api.delete('/settings/pin');
  }

  Future<Map<String, dynamic>> getStreak() async {
    final res = await _api.get('/settings/streak');
    return res['data'] as Map<String, dynamic>;
  }

  Future<List<AchievementModel>> getAchievements() async {
    final res = await _api.get('/settings/achievements');
    final list = res['data'] as List;
    return list
        .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
