import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class CartService extends BaseService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  String _cartId = '0';

  Future<CartResponse> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/cart/$_cartId',
        data: {'product_id': productId, 'qty': quantity},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _cartId = (body['id'] ?? _cartId).toString();
      return CartResponse.fromJson(body);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CartResponse> updateCartItem({
    required String rowId,
    required int productId,
    required int quantity,
  }) async {
    try {
      final resp = await dio.put(
        '/v1/ecommerce/cart/$_cartId',
        data: {'product_id': productId, 'qty': quantity},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _cartId = (body['id'] ?? _cartId).toString();
      return CartResponse.fromJson(body);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CartResponse> removeFromCart({required int productId}) async {
    try {
      final resp = await dio.delete(
        '/v1/ecommerce/cart/$_cartId',
        data: {'product_id': productId},
      );
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _cartId = (body['id'] ?? _cartId).toString();
      if (body.containsKey('data') || body.containsKey('id')) {
        return CartResponse.fromJson(body);
      }
      return CartResponse(error: false, message: body['message']?.toString() ?? 'Removed');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CartResponse> getCart({String instance = 'cart'}) async {
    try {
      final resp = await dio.get('/v1/ecommerce/cart/$_cartId');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      _cartId = (body['id'] ?? _cartId).toString();
      return CartResponse.fromJson(body);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CartResponse> refreshCart() async {
    try {
      final resp = await dio.post('/v1/ecommerce/cart/refresh', data: {'products': []});
      return CartResponse.fromJson(
        Map<String, dynamic>.from(resp.data as Map? ?? const {}),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CouponResult> applyCoupon(String code) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/coupon/apply',
        data: {'coupon_code': code},
      );
      return CouponResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CouponResult> removeCoupon() async {
    try {
      final resp = await dio.post('/v1/ecommerce/coupon/remove');
      return CouponResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
