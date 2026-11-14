import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class CheckoutService extends BaseService {
  static final CheckoutService instance = CheckoutService._internal();
  CheckoutService._internal();

  Future<TaxResult> calculateTaxes({
    String? address,
    String? country,
    String? state,
    String? city,
    String? zipCode,
    double? amount,
    String? currency,
  }) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/checkout/taxes/calculate',
        data: {
          if (address != null) 'address': address,
          if (country != null) 'country': country,
          if (state != null) 'state': state,
          if (city != null) 'city': city,
          if (zipCode != null) 'zip_code': zipCode,
          if (amount != null) 'amount': amount,
          if (currency != null) 'currency': currency,
        },
      );
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return TaxResult.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
