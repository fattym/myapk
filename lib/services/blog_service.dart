import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class BlogService extends BaseService {
  static final BlogService instance = BlogService._internal();
  BlogService._internal();

  Future<PaginatedList<BlogPost>> fetchPosts({
    int page = 1,
    int perPage = 10,
    String? category,
    String? tag,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': perPage};
    if (category != null) query['category'] = category;
    if (tag != null) query['tag'] = tag;
    try {
      final resp = await dio.get(
        '/v1/posts',
        queryParameters: query,
      );
      return PaginatedList<BlogPost>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        BlogPost.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<BlogPost> fetchPostBySlug(String slug) async {
    try {
      final resp = await dio.get('/v1/posts/$slug');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return BlogPost.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<BlogCategoryItem>> fetchCategories() async {
    try {
      final resp = await dio.get('/v1/categories');
      final data = listFrom(resp.data);
      return data
          .map((e) => BlogCategoryItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<BlogTagItem>> fetchTags() async {
    try {
      final resp = await dio.get('/v1/tags');
      final data = listFrom(resp.data);
      return data
          .map((e) =>
              BlogTagItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<BlogCategoryItem> fetchCategoryBySlug(String slug) async {
    try {
      final resp = await dio.get('/v1/categories/$slug');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return BlogCategoryItem.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<SearchResultData> search(String query) async {
    try {
      final resp = await dio.get(
        '/search',
        queryParameters: {'q': query},
      );
      return SearchResultData.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> fetchPostFilters() async {
    try {
      final resp = await dio.get('/v1/posts/filters');
      return Map<String, dynamic>.from(resp.data as Map? ?? {});
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> fetchCategoryFilters() async {
    try {
      final resp = await dio.get('/v1/categories/filters');
      return Map<String, dynamic>.from(resp.data as Map? ?? {});
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
