import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_client.dart';
import 'api_error.dart';
import 'base_service.dart';

final class AuthService extends BaseService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  Future<AuthResult> login({
    required String email,
    required String password,
    String? device,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'password': password,
      };
      if (device != null) data['device'] = device;
      final resp = await dio.post('/v1/auth/login', data: data);
      final result = AuthResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
      if (result.token.isEmpty) {
        throw ApiError(message: 'Sign-in failed. Please try again.');
      }
      await ApiClient.writeToken(result.token);
      return result;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? device,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (phone != null) data['phone'] = phone;
      if (device != null) data['device'] = device;
      final resp = await dio.post('/v1/auth/register', data: data);
      final result = AuthResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
      if (result.token.isEmpty) {
        throw ApiError(message: 'Sign-in failed. Please try again.');
      }
      await ApiClient.writeToken(result.token);
      return result;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await dio.post('/v1/auth/logout');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } finally {
      await ApiClient.clearToken();
    }
  }

  Future<UserProfile> me() async {
    try {
      final resp = await dio.get('/v1/auth/me');
      return UserProfile.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? phone,
    String? password,
    String? passwordConfirmation,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (password != null) {
      body['password'] = password;
      if (passwordConfirmation != null) {
        body['password_confirmation'] = passwordConfirmation;
      }
    }
    try {
      final resp = await dio.put('/v1/user/profile', data: body);
      return UserProfile.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
