import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'connectivity_service.dart';

final class ApiClient {
  ApiClient._internal();

  static final ApiClient instance = ApiClient._internal();

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  late final Dio dio = _build();

  Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout:
            const Duration(milliseconds: connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: receiveTimeoutMs),
        headers: ApiConfig.defaultHeaders,
        validateStatus: (status) =>
            status != null && status < 500,
      ),
    );
    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_ErrorInterceptor());
    return dio;
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  static Future<void> writeToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(ApiConfig.tokenKey);
    } else {
      await prefs.setString(ApiConfig.tokenKey, token);
    }
  }

  static Future<void> clearToken() => writeToken(null);
}

final class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await ApiClient.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

final class _ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ConnectivityService.instance.reportSuccess();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      ConnectivityService.instance.reportFailure();
    }
    handler.reject(err);
  }
}
