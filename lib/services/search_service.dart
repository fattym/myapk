import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class SearchService extends BaseService {
  static final SearchService instance = SearchService._internal();
  SearchService._internal();

  Future<List<SearchSuggestion>> fetchSuggestions(String query, {String type = 'product'}) async {
    try {
      final resp = await dio.get(
        '/search/suggestions',
        queryParameters: {'q': query, 'type': type},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      final data = body['data'] as List? ?? [];
      return data.map((e) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          m['type'] = (m['type'] ?? type).toString();
          return SearchSuggestion.fromJson(m);
        }
        return SearchSuggestion(type: type, name: e.toString());
      }).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<SearchResultData> search(String query, {String type = 'product'}) async {
    try {
      final resp = await dio.get(
        '/search',
        queryParameters: {'q': query, 'type': type},
      );
      return SearchResultData.fromJson(
        Map<String, dynamic>.from(resp.data as Map? ?? const {}),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> trackSearch({
    required String query,
    required String type,
    int? resultsCount,
    String event = 'search_submitted',
    int? productId,
  }) async {
    try {
      await dio.post(
        '/search/track',
        data: {
          'query': query,
          'event': event,
          'type': type,
          if (resultsCount != null) 'results_count': resultsCount,
          if (productId != null) 'product_id': productId,
        },
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
