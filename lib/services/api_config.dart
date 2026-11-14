import 'dart:convert';

final class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mybidhaa.com/api',
  );

  static const String tokenKey = 'auth_token';

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Uri parseUrl(String path) => Uri.parse('$baseUrl$path');

  static Map<String, dynamic> decodeBody(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return decoded is Map<String, dynamic> ? decoded : {};
      } catch (_) {
        return {};
      }
    }
    return {};
  }
}
