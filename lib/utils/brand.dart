import '../services/api_config.dart';

/// Brand assets served by the MyBidhaa website.
final class Brand {
  const Brand._();

  static String get origin {
    final u = Uri.parse(ApiConfig.baseUrl);
    return '${u.scheme}://${u.authority}';
  }

  static String get logoUrl => '$origin/storage/my-bidhaa-final-logoo.png';
}
