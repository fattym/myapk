import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_error.dart';

abstract class BaseService {
  Dio get dio => ApiClient.instance.dio;

  /// The API returns lists either bare (`[...]`) or wrapped (`{"data": [...]}`).
  List<dynamic> listFrom(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  Future<T> request<T>(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is T) return data;
      return data as T;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
