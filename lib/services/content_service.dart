import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/content_item.dart';

class ContentService {
  Future<List<ContentItem>> fetchContent() async {
    if (AppConfig.contentUrl.contains('YOUR-ACCOUNT')) {
      throw Exception(
        'Set AppConfig.contentUrl to your public raw content.json URL.',
      );
    }

    final response = await http.get(Uri.parse(AppConfig.contentUrl));

    if (response.statusCode != 200) {
      throw Exception('Could not load class content.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('content.json must contain a JSON list.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ContentItem.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
