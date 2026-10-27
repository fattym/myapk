import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class PaymentService extends BaseService {
  static final PaymentService instance = PaymentService._internal();
  PaymentService._internal();

  /// Trigger an STK push. `phoneNumber` accepts 07XXXXXXXX, 2547XXXXXXXX.
  Future<StkPushResult> stkPush({
    required String phoneNumber,
    required double amount,
    required int orderId,
    String? accountReference,
  }) async {
    final body = <String, dynamic>{
      'phone_number': phoneNumber,
      'amount': amount,
      'order_id': orderId,
    };
    if (accountReference != null) body['account_reference'] = accountReference;
    try {
      final resp = await dio.post('/v1/payments/stk-push', data: body);
      return StkPushResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Poll the status of an order's payment (after STK push).
  Future<PaymentStatus> paymentStatus(int orderId) async {
    try {
      final resp = await dio.get('/v1/payments/status/$orderId');
      return PaymentStatus.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
