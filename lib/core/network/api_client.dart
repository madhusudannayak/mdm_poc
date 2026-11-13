import 'package:dio/dio.dart';

/// HTTP client for the future MDM backend (Phase 15).
///
/// The base URL is supplied at build time with
/// `--dart-define=MDM_API_BASE_URL=https://...`; nothing is hardcoded and no
/// credentials live in source. Until a backend exists [isConfigured] is false
/// and no feature issues network requests.
class ApiClient {
  ApiClient({Dio? dio, String baseUrl = _baseUrlFromEnvironment})
    : _baseUrl = baseUrl,
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              contentType: Headers.jsonContentType,
            ),
          );

  static const String _baseUrlFromEnvironment = String.fromEnvironment(
    'MDM_API_BASE_URL',
  );

  final String _baseUrl;
  final Dio dio;

  bool get isConfigured => _baseUrl.isNotEmpty;
}
