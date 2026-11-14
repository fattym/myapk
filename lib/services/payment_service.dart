import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class PaymentService extends BaseService {
  static final PaymentService instance = PaymentService._internal();
  PaymentService._internal();

  /// STK push is initiated by checkout web flow (Mpesa gateway). Not exposed as /v1/payments/stk-push.
  Future<StkPushResult> stkPush({
    required String phoneNumber,
    required double amount,
    required int orderId,
    String? accountReference,
  }) async {
    throw ApiError(message: 'STK push is handled by checkout/payment flow; no /v1/payments/stk-push API is available.');
  }

  /// Poll M-Pesa Daraja status by CheckoutRequestID (public web route).
  Future<PaymentStatus> paymentStatus(String checkoutRequestId) async {
    try {
      final resp = await dio.get('/daraja/status/$checkoutRequestId');
      return PaymentStatus.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
