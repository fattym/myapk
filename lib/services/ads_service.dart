import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class AdsService extends BaseService {
  static final AdsService instance = AdsService._internal();
  AdsService._internal();

  Future<List<AdItem>> fetchAds() async {
    try {
      final resp = await dio.get('/v1/ads');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      final data = body['data'] ?? body;
      if (data is List) {
        return data.map((e) => AdItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      if (data is Map) {
        return data.values.map((e) => AdItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
