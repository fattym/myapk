import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class WishlistService extends BaseService {
  static final WishlistService instance = WishlistService._internal();
  WishlistService._internal();

  String _wishlistId = '0';

  Future<List<WishlistItem>> fetchWishlist() async {
    try {
      final resp = await dio.get('/v1/ecommerce/wishlist/$_wishlistId');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _wishlistId = (body['id'] ?? _wishlistId).toString();
      final data = Map<String, dynamic>.from(body['data'] as Map? ?? const {});
      final items = data['items'] as List? ?? const [];
      return items
          .map((e) =>
              WishlistItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> addToWishlist(int productId) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/wishlist/$_wishlistId',
        data: {'product_id': productId},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _wishlistId = (body['id'] ?? _wishlistId).toString();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      final resp = await dio.delete(
        '/v1/ecommerce/wishlist/$_wishlistId',
        data: {'product_id': productId},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _wishlistId = (body['id'] ?? _wishlistId).toString();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
