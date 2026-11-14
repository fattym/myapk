import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class AddressService extends BaseService {
  static final AddressService instance = AddressService._internal();
  AddressService._internal();

  Future<List<Address>> fetchAddresses() async {
    try {
      final resp = await dio.get('/v1/ecommerce/addresses');
      final data = listFrom(resp.data);
      return data
          .map((e) => Address.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Address> createAddress(Address address) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/addresses',
        data: address.toJson(),
      );
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return Address.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Address> updateAddress(int id, Address address) async {
    try {
      final resp = await dio.put(
        '/v1/ecommerce/addresses/$id',
        data: address.toJson(),
      );
      final data = Map<String, dynamic>.from(
        (resp.data as Map)['data'] ?? const {},
      );
      return Address.fromJson(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await dio.delete('/v1/ecommerce/addresses/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
