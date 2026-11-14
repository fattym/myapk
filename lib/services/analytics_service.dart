import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class AnalyticsService extends BaseService {
  static final AnalyticsService instance = AnalyticsService._internal();
  AnalyticsService._internal();

  Future<AnalyticsOverview> fetchOverview() async {
    try {
      final resp = await dio.get('/analytics/overview');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return AnalyticsOverview.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<ApiProduct>> fetchPopularApiProducts({int limit = 10}) async {
    try {
      final resp = await dio.get(
        '/analytics/products/popular',
        queryParameters: {'limit': limit},
      );
      final data = resp.data as List? ?? [];
      return data
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchSearchAnalytics({int days = 7}) async {
    try {
      final resp = await dio.get(
        '/analytics/search',
        queryParameters: {'days': days},
      );
      final data = resp.data as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchSessionAnalytics({int days = 7}) async {
    try {
      final resp = await dio.get(
        '/analytics/sessions',
        queryParameters: {'days': days},
      );
      final data = resp.data as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> fetchConversionFunnel() async {
    try {
      final resp = await dio.get('/analytics/funnel');
      return Map<String, dynamic>.from(resp.data as Map? ?? {});
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> fetchVendorAnalytics(int vendorId) async {
    try {
      final resp = await dio.get('/analytics/vendor/$vendorId');
      return Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventTimeline({int limit = 50}) async {
    try {
      final resp = await dio.get(
        '/analytics/events/timeline',
        queryParameters: {'limit': limit},
      );
      final data = resp.data as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}

final class RecommendationService extends BaseService {
  static final RecommendationService instance = RecommendationService._internal();
  RecommendationService._internal();

  Future<List<ApiProduct>> fetchTrending({int limit = 10}) async {
    try {
      final resp = await dio.get(
        '/analytics/trending',
        queryParameters: {'limit': limit},
      );
      final data = resp.data as List? ?? [];
      return data
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<ApiProduct>> fetchSimilarApiProducts(int productId) async {
    try {
      final resp = await dio.get('/analytics/similar/$productId');
      final data = resp.data as List? ?? [];
      return data
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<ApiProduct>> fetchRecentlyViewed({int limit = 10}) async {
    try {
      final resp = await dio.get(
        '/analytics/recently-viewed',
        queryParameters: {'limit': limit},
      );
      final data = resp.data as List? ?? [];
      return data
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
