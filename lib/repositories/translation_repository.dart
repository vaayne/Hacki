import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hacki/models/models.dart';

/// [TranslationRepository] translates text via any OpenAI-compatible
/// `chat/completions` endpoint.
///
/// The interface is intentionally narrow: callers provide a batch of texts, the
/// target language and the credentials, and get back the translations in the
/// same order. Everything about the HTTP request (endpoint shape, prompt,
/// JSON contract, response parsing) is hidden here so the rest of the app never
/// has to know it is talking to an LLM.
class TranslationRepository {
  TranslationRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Translates each entry of [texts] into [targetLanguage] (a human readable
  /// language name, e.g. `Simplified Chinese`) with a single request, returning
  /// the translations in the same order.
  ///
  /// Throws [AppException] when the request fails or the response cannot be
  /// mapped back one-to-one, so callers can surface a single failure path.
  Future<List<String>> translateBatch({
    required List<String> texts,
    required String targetLanguage,
    required String apiKey,
    required String baseUrl,
    required String model,
  }) async {
    if (texts.isEmpty) return <String>[];

    final String endpoint =
        '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chat/completions';

    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            endpoint,
            options: Options(
              headers: <String, dynamic>{'Authorization': 'Bearer $apiKey'},
              contentType: 'application/json',
            ),
            data: <String, dynamic>{
              'model': model,
              'temperature': 0.3,
              'messages': <Map<String, String>>[
                <String, String>{
                  'role': 'system',
                  'content':
                      'You are a translation engine. The user message is a '
                      'JSON array of strings. Translate every element into '
                      '$targetLanguage, preserving formatting, code, links and '
                      'usernames. Respond with ONLY a JSON array of the same '
                      'length where each element is the translation of the '
                      'element at the same index. Output no other text.',
                },
                <String, String>{'role': 'user', 'content': jsonEncode(texts)},
              ],
            },
          );

      final List<dynamic>? choices =
          response.data?['choices'] as List<dynamic>?;
      final Object? first = (choices != null && choices.isNotEmpty)
          ? choices.first
          : null;
      final Object? message = (first as Map<String, dynamic>?)?['message'];
      final Object? content =
          (message as Map<String, dynamic>?)?['content'];

      if (content is String) {
        final List<String> translations = _parse(content);
        if (translations.length == texts.length) {
          return translations;
        }
      }

      throw AppException(message: 'Malformed translation response.');
    } on DioException catch (e) {
      throw AppException(message: e.message ?? 'Translation request failed.');
    }
  }

  /// Extracts the JSON array from [content], tolerating ```json code fences and
  /// an optional `{"translations": [...]}` wrapper some models emit.
  List<String> _parse(String content) {
    String body = content.trim();
    if (body.startsWith('```')) {
      body = body
          .replaceFirst(RegExp('^```(?:json)?'), '')
          .replaceFirst(RegExp(r'```$'), '')
          .trim();
    }

    final Object? decoded = jsonDecode(body);
    final Object? list = decoded is Map<String, dynamic>
        ? decoded['translations']
        : decoded;
    if (list is List) {
      return list.map((Object? e) => e.toString()).toList();
    }
    return <String>[];
  }
}
