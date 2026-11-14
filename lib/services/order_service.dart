import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class OrderService extends BaseService {
  static final OrderService instance = OrderService._internal();
  OrderService._internal();

  Future<PaginatedList<ApiOrder>> fetchOrders({int page = 1, int perPage = 10}) async {
    try {
      final resp = await dio.get(
        '/v1/ecommerce/orders',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedList<ApiOrder>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        ApiOrder.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<ApiOrder> fetchOrder(int id) async {
    try {
      final resp = await dio.get('/v1/ecommerce/orders/$id');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return ApiOrder.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<ApiOrder> cancelOrder(int id, {String? reason}) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/orders/$id/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return ApiOrder.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<GenericResponse> trackOrder(String orderId) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/orders/tracking',
        data: {'order_id': orderId},
      );
      return GenericResponse.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> uploadPaymentProof(int orderId, String proof, {String? reference}) async {
    try {
      await dio.post(
        '/v1/ecommerce/orders/$orderId/upload-proof',
        data: {
          'proof': proof,
          if (reference != null) 'reference': reference,
        },
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> confirmDelivery(int orderId) async {
    try {
      await dio.post('/v1/ecommerce/orders/$orderId/confirm-delivery');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<PaginatedList<OrderReturn>> fetchReturns({int page = 1, int perPage = 10}) async {
    try {
      final resp = await dio.get(
        '/v1/ecommerce/order-returns',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedList<OrderReturn>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        OrderReturn.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<OrderReturn> fetchReturn(int id) async {
    try {
      final resp = await dio.get('/v1/ecommerce/order-returns/$id');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return OrderReturn.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<OrderReturn> createReturn(int orderId, List<Map<String, dynamic>> products) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/order-returns',
        data: {'order_id': orderId, 'products': products},
      );
      return OrderReturn.fromJson(
        Map<String, dynamic>.from(
          (resp.data as Map)['data'] ?? const {},
        ),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<OrderReturn> fetchOrderReturns(int orderId) async {
    try {
      final resp = await dio.get('/v1/ecommerce/orders/$orderId/returns');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return OrderReturn.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<PaginatedList<DownloadItem>> fetchDownloads({int page = 1, int perPage = 10}) async {
    try {
      final resp = await dio.get(
        '/v1/ecommerce/downloads',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedList<DownloadItem>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        DownloadItem.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
