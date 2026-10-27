import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class DeliveryService extends BaseService {
  static final DeliveryService instance = DeliveryService._internal();
  DeliveryService._internal();

  /// Track an order. Customers can only track their own orders.
  Future<DeliveryInfo> trackOrder(int orderId) async {
    try {
      final resp = await dio.get('/v1/deliveries/track/$orderId');
      return DeliveryInfo.fromResponse(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Update a delivery status (staff/agent tokens only).
  Future<DeliveryInfo> updateDeliveryStatus({
    required int id,
    required String shippingStatus,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'shipping_status': shippingStatus,
    };
    if (note != null) body['note'] = note;
    try {
      final resp = await dio.put(
        '/v1/agent/deliveries/$id/status',
        data: body,
      );
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] as Map? ?? {},
      );
      return DeliveryInfo.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
