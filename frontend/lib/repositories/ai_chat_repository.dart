import '../core/services/api_client.dart';
import '../models/chat_message_model.dart';

class AiChatRepository {
  AiChatRepository(this._api);
  final ApiClient _api;

  Future<List<ChatMessageModel>> getMessages({int limit = 50}) async {
    final res = await _api.get('/ai/chat?limit=$limit');
    final list = res['data'] as List;
    return list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessageModel> sendMessage(String message) async {
    final res = await _api.post('/ai/chat', {'message': message});
    final data = res['data'] as Map<String, dynamic>;
    final assistant = data['assistantMessage'] as Map<String, dynamic>;
    return ChatMessageModel.fromJson(assistant);
  }

  Future<void> clearHistory() async {
    await _api.delete('/ai/chat');
  }
}
