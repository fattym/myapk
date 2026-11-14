import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class SocialLoginService extends BaseService {
  static final SocialLoginService instance = SocialLoginService._internal();
  SocialLoginService._internal();

  /// Login with Apple access token
  Future<SocialLoginResult> loginWithApple(String token) async {
    try {
      final resp = await dio.post(
        '/v1/auth/apple',
        data: {'token': token},
      );
      return SocialLoginResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Login with Google access token
  Future<SocialLoginResult> loginWithGoogle(String token) async {
    try {
      final resp = await dio.post(
        '/v1/auth/google',
        data: {'token': token},
      );
      return SocialLoginResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Login with Facebook access token
  Future<SocialLoginResult> loginWithFacebook(String token) async {
    try {
      final resp = await dio.post(
        '/v1/auth/facebook',
        data: {'token': token},
      );
      return SocialLoginResult.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
