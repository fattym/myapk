import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_error.dart';

abstract class BaseService {
  Dio get dio => ApiClient.instance.dio;

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
