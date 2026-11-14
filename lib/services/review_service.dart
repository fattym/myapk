import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class ReviewService extends BaseService {
  static final ReviewService instance = ReviewService._internal();
  ReviewService._internal();

  Future<PaginatedList<Review>> fetchReviews({int page = 1, int perPage = 10}) async {
    try {
      final resp = await dio.get(
        '/v1/ecommerce/reviews',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedList<Review>.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
        Review.fromJson,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Review> createReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final resp = await dio.post(
        '/v1/ecommerce/reviews',
        data: {
          'product_id': productId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );
      return Review.fromJson(
        Map<String, dynamic>.from(
          (resp.data as Map)['data'] ?? const {},
        ),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> deleteReview(int id) async {
    try {
      await dio.delete('/v1/ecommerce/reviews/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
