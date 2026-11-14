import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class ApiProductService extends BaseService {
  static final ApiProductService instance = ApiProductService._internal();
  ApiProductService._internal();

  Future<PaginatedList<ApiProduct>> fetchApiProducts({
    String? keyword,
    int? categoryId,
    List<int>? categoryIds,
    int? brandId,
    bool discountedOnly = false,
    int page = 1,
    int perPage = 12,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage.clamp(1, 50),
    };
    if (keyword != null && keyword.isNotEmpty) query['q'] = keyword;
    // Botble filter params: categories[]=ID / brands[]=ID
    final cats = categoryIds ?? (categoryId != null ? [categoryId] : null);
    if (cats != null && cats.isNotEmpty) query['categories[]'] = cats;
    if (brandId != null) query['brands[]'] = brandId;
    if (discountedOnly) query['discounted_only'] = 1;
    try {
      final resp = await dio.get(
        '/v1/ecommerce/products',
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

  Future<ApiProduct> fetchApiProductBySlug(String slug) async {
    try {
      final resp = await dio.get('/v1/ecommerce/products/$slug');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return ApiProduct.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<ApiProduct>> fetchRelatedApiProducts(String slug) async {
    try {
      final resp = await dio.get('/v1/ecommerce/products/$slug/related');
      final data = listFrom(resp.data);
      return data
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<ApiProduct>> fetchCrossSaleApiProducts(String slug) async {
    try {
      final resp = await dio.get('/v1/ecommerce/products/$slug/cross-sale');
      final data = listFrom(resp.data);
      return data
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<Review>> fetchApiProductReviews(String slug) async {
    try {
      final resp = await dio.get('/v1/ecommerce/products/$slug/reviews');
      final data = listFrom(resp.data);
      return data
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<ApiProduct> fetchApiProductVariation(int id) async {
    try {
      final resp = await dio.get('/v1/ecommerce/product-variation/$id');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return ApiProduct.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> fetchFilters() async {
    try {
      final resp = await dio.get('/v1/ecommerce/filters');
      return Map<String, dynamic>.from(resp.data as Map? ?? {});
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<FlashSale>> fetchFlashSales() async {
    try {
      final resp = await dio.get('/v1/ecommerce/flash-sales');
      final data = listFrom(resp.data);
      return data
          .map((e) => FlashSale.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}

final class FlashSale {
  const FlashSale({
    required this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.products,
  });

  final int id;
  final String? name;
  final String? startDate;
  final String? endDate;
  final List<ApiProduct>? products;

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    final rawApiProducts = json['products'] as List? ?? [];
    return FlashSale(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      products: rawApiProducts
          .map((e) => ApiProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
