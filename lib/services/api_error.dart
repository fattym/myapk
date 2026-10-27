import 'dart:convert';
import 'package:dio/dio.dart';

final class ApiError implements Exception {
  ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  factory ApiError.fromDioException(DioException error) {
    final status = error.response?.statusCode;
    final body = _decodeBody(error.response?.data);

    if (status == 429) {
      return ApiError(
        message: body['message'] ?? 'Too many requests.',
        statusCode: status,
      );
    }
    if (status == 422 && body['errors'] is Map) {
      return ApiError(
        message: body['message'] ?? 'Validation failed.',
        statusCode: status,
        errors: Map<String, dynamic>.from(body['errors'] as Map),
      );
    }
    final message = body['message'] ??
        error.message ??
        'Something went wrong.';

    return ApiError(
      message: message,
      statusCode: status,
    );
  }

  static Map<String, dynamic> _decodeBody(dynamic data) {
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

  @override
  String toString() => 'ApiError($statusCode): $message';
}
