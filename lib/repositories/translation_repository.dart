import 'package:dio/dio.dart';
import 'package:hacki/models/models.dart';

/// [TranslationRepository] translates text via any OpenAI-compatible
/// `chat/completions` endpoint.
///
/// The interface is intentionally narrow: callers provide the text, the target
/// language and the credentials, and get back the translated text. Everything
/// about the HTTP request (endpoint shape, prompt, response parsing) is hidden
/// here so the rest of the app never has to know it is talking to an LLM.
class TranslationRepository {
  TranslationRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Translates [text] into [targetLanguage] (a human readable language name,
  /// e.g. `Simplified Chinese`).
  ///
  /// Throws [AppException] when the request fails or the response is malformed,
  /// so callers can surface a single failure path.
  Future<String> translate({
    required String text,
    required String targetLanguage,
    required String apiKey,
    required String baseUrl,
    required String model,
  }) async {
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
                      'You are a translation engine. Translate the user '
                      'message into $targetLanguage. Preserve the original '
                      'formatting, code, links and usernames. Output only the '
                      'translation without any explanation or quotation.',
                },
                <String, String>{'role': 'user', 'content': text},
              ],
            },
          );

      final List<dynamic>? choices =
          response.data?['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final Object? message =
            (choices.first as Map<String, dynamic>?)?['message'];
        final Object? content =
            (message as Map<String, dynamic>?)?['content'];
        if (content is String && content.trim().isNotEmpty) {
          return content.trim();
        }
      }

      throw AppException(message: 'Empty translation response.');
    } on DioException catch (e) {
      throw AppException(message: e.message ?? 'Translation request failed.');
    }
  }
}
