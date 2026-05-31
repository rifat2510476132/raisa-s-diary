import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../core/services/storage_service.dart';
import '../models/media_file_model.dart';

class MediaRepository {
  MediaRepository(this._storage);
  final StorageService _storage;

  Future<MediaFileModel> uploadFile(File file, {String type = 'image'}) async {
    final token = await _storage.getAccessToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}/media/upload');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields['type'] = type;
    final mime = type == 'video' ? 'video/mp4' : 'image/jpeg';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mime),
      ),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload failed: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return MediaFileModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}
