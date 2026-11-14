import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class LanguageService extends BaseService {
  static final LanguageService instance = LanguageService._internal();
  LanguageService._internal();

  Future<List<LanguageItem>> fetchLanguages() async {
    try {
      final resp = await dio.get('/v1/languages');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      final data = body['data'] ?? body;
      if (data is List) {
        return data.map((e) => LanguageItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<LanguageItem> fetchCurrentLanguage() async {
    try {
      final resp = await dio.get('/v1/languages/current');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      final data = body['data'] ?? body;
      return LanguageItem.fromJson(Map<String, dynamic>.from(data as Map? ?? const {}));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
