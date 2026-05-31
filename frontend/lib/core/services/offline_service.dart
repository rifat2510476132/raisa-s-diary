import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class OfflineService {
  static const _boxName = 'offline_diaries';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Future<void> saveDraft({
    required String content,
    String? title,
    String? moodSticker,
  }) async {
    final box = Hive.box<String>(_boxName);
    final id = const Uuid().v4();
    await box.put(id, jsonEncode({
      'id': id,
      'content': content,
      'title': title,
      'moodSticker': moodSticker,
      'createdAt': DateTime.now().toIso8601String(),
      'synced': false,
    }));
  }

  List<Map<String, dynamic>> getPending() {
    final box = Hive.box<String>(_boxName);
    return box.values
        .map((v) => jsonDecode(v) as Map<String, dynamic>)
        .where((e) => e['synced'] != true)
        .toList();
  }

  Future<void> markSynced(String id) async {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(id);
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    data['synced'] = true;
    await box.put(id, jsonEncode(data));
  }
}
