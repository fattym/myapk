import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class CategoryService extends BaseService {
  static final CategoryService instance = CategoryService._internal();
  CategoryService._internal();

  Future<List<ProductCategory>> fetchCategories() async {
    try {
      final resp = await dio.get('/v1/ecommerce/product-categories');
      final data = listFrom(resp.data);
      return data
          .map((e) =>
              ProductCategory.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<ProductCategory> fetchCategoryBySlug(String slug) async {
    try {
      final resp = await dio.get('/v1/ecommerce/product-categories/$slug');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return ProductCategory.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<PaginatedList<ApiProduct>> fetchCategoryApiProducts(
    int categoryId, {
    int page = 1,
    int perPage = 12,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage.clamp(1, 50),
    };
    try {
      final resp = await dio.get(
        '/v1/ecommerce/product-categories/$categoryId/products',
        queryParameters: query,
      );
      return PaginatedList<ApiProduct>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        ApiProduct.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<Brand>> fetchBrands() async {
    try {
      final resp = await dio.get('/v1/ecommerce/brands');
      final data = listFrom(resp.data);
      return data
          .map((e) => Brand.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Brand> fetchBrandBySlug(String slug) async {
    try {
      final resp = await dio.get('/v1/ecommerce/brands/$slug');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return Brand.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<PaginatedList<ApiProduct>> fetchBrandApiProducts(
    int brandId, {
    int page = 1,
    int perPage = 12,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage.clamp(1, 50),
    };
    try {
      final resp = await dio.get(
        '/v1/ecommerce/brands/$brandId/products',
        queryParameters: query,
      );
      return PaginatedList<ApiProduct>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        ApiProduct.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
