import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class SchoolService extends BaseService {
  static final SchoolService instance = SchoolService._internal();
  SchoolService._internal();

  Future<PaginatedList<ApiSchool>> fetchSchools({
    String? search,
    String? location,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage.clamp(1, 100),
      if (search != null && search.isNotEmpty) 'search': search,
      if (location != null && location.isNotEmpty) 'location': location,
    };
    try {
      final resp = await dio.get(
        '/v1/schools',
        queryParameters: query,
      );
      return PaginatedList<ApiSchool>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        ApiSchool.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<SchoolBooklist> fetchBooklist(int schoolId) async {
    try {
      final resp = await dio.get('/v1/schools/$schoolId/booklist');
      return SchoolBooklist.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
