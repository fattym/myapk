import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class LocationService extends BaseService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  Future<List<Country>> fetchCountries() async {
    try {
      final resp = await dio.get('/v1/ecommerce/countries');
      final data = listFrom(resp.data);
      return data
          .map((e) => Country.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<Currency>> fetchCurrencies() async {
    try {
      final resp = await dio.get('/v1/ecommerce/currencies');
      final data = listFrom(resp.data);
      return data
          .map((e) => Currency.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Currency> fetchCurrentCurrency() async {
    try {
      final resp = await dio.get('/v1/ecommerce/currencies/current');
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return Currency.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
