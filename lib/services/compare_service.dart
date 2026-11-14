import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class CompareService extends BaseService {
  static final CompareService instance = CompareService._internal();
  CompareService._internal();

  String _compareId = '0';

  Future<List<ApiProduct>> fetchCompareList() async {
    try {
      final resp = await dio.get('/v1/ecommerce/compare/$_compareId');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _compareId = (body['id'] ?? _compareId).toString();
      final data = Map<String, dynamic>.from(body['data'] as Map? ?? const {});
      final items = data['items'] as List? ?? const [];
      return items
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> addToCompare(int productId) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/compare/$_compareId',
        data: {'product_id': productId},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _compareId = (body['id'] ?? _compareId).toString();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> removeFromCompare(int productId) async {
    try {
      final resp = await dio.delete(
        '/v1/ecommerce/compare/$_compareId',
        data: {'product_id': productId},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _compareId = (body['id'] ?? _compareId).toString();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
