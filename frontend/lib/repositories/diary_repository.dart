import '../core/services/api_client.dart';
import '../core/services/offline_service.dart';
import '../models/diary_entry_model.dart';

class DiaryRepository {
  DiaryRepository(this._api, this._offline);
  final ApiClient _api;
  final OfflineService _offline;

  Future<DiaryEntryModel> getEntry(String id) async {
    final res = await _api.get('/diary/$id');
    return DiaryEntryModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEntry(String id) async {
    await _api.delete('/diary/$id');
  }

  Future<List<DiaryEntryModel>> getEntries({int page = 1}) async {
    final res = await _api.get('/diary?page=$page&limit=30');
    final entries = (res['data']['entries'] as List)
        .map((e) => DiaryEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return entries;
  }

  Future<Map<String, dynamic>> createEntry({
    required String content,
    String? title,
    String? moodSticker,
  }) async {
    try {
      final res = await _api.post('/diary', {
        'content': content,
        'title': title,
        'moodSticker': moodSticker,
      });
      return res['data'] as Map<String, dynamic>;
    } catch (_) {
      await _offline.saveDraft(content: content, title: title, moodSticker: moodSticker);
      rethrow;
    }
  }

  Future<String> getTahsinMessage() async {
    final res = await _api.get('/diary/tahsin-message');
    return res['data']['message'] as String;
  }

  Future<Map<String, dynamic>> getEmotionStats({int days = 30}) async {
    final res = await _api.get('/diary/emotions/stats?days=$days');
    return res['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMoodCalendar(int year, int month) async {
    final res = await _api.get('/diary/mood-calendar?year=$year&month=$month');
    return res['data'] as List;
  }

  Future<void> syncOffline() async {
    final pending = _offline.getPending();
    for (final draft in pending) {
      try {
        await _api.post('/diary', {
          'content': draft['content'],
          'title': draft['title'],
          'moodSticker': draft['moodSticker'],
        });
        await _offline.markSynced(draft['id'] as String);
      } catch (_) {}
    }
  }
}
