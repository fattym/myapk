import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_error.dart';
import 'base_service.dart';

final class SliderService extends BaseService {
  static final SliderService instance = SliderService._internal();
  SliderService._internal();

  Future<List<SliderItem>> fetchSliders() async {
    try {
      final resp = await dio.get('/v1/simple-sliders');
      final body = Map<String, dynamic>.from(resp.data as Map? ?? const {});
      final data = body['data'] ?? body;
      if (data is List) {
        // flat list of slider items
        if (data.isNotEmpty && data.first is Map && (data.first as Map).containsKey('image')) {
          return data.map((e) => SliderItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }
        // list of sliders with items
        final items = <SliderItem>[];
        for (final s in data) {
          final sm = Map<String, dynamic>.from(s as Map);
          final sItems = sm['items'] as List? ?? const [];
          for (final it in sItems) {
            items.add(SliderItem.fromJson(Map<String, dynamic>.from(it as Map)));
          }
        }
        return items;
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
