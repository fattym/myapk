import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_config.dart';
import 'base_service.dart';

final class WebGrade {
  const WebGrade({required this.slug, required this.name});
  final String slug;
  final String name;
}

final class WebSchool {
  const WebSchool({
    required this.slug,
    required this.name,
    required this.grades,
  });
  final String slug;
  final String name;
  final List<WebGrade> grades;
}

/// Reads schools and booklists from the public website pages
/// (`/shop-by-school`, `/school/{slug}/{grade}`). Used as a fallback while the
/// JSON endpoints (`/api/v1/schools`) require authentication.
final class WebBooklistService extends BaseService {
  static final WebBooklistService instance = WebBooklistService._internal();
  WebBooklistService._internal();

  String get _origin {
    final u = Uri.parse(ApiConfig.baseUrl);
    return '${u.scheme}://${u.authority}';
  }

  Future<String> _html(String path) async {
    final resp = await dio.get<String>(
      '$_origin$path',
      options: Options(
        responseType: ResponseType.plain,
        headers: {'Accept': 'text/html'},
      ),
    );
    final code = resp.statusCode ?? 0;
    if (code != 200 || (resp.data ?? '').isEmpty) {
      throw Exception('Page $path returned $code');
    }
    return resp.data!;
  }

  static String _unescape(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&#39;', "'")
      .replaceAllMapped(
        RegExp(r'&#(\d+);'),
        (m) => String.fromCharCode(int.parse(m.group(1)!)),
      );

  Future<List<WebSchool>> fetchSchools() async {
    final html = await _html('/shop-by-school');
    final re = RegExp(
      r'''<option\s+value="([^"]+)"\s+data-grades='([^']*)'\s*>([^<]*)</option>''',
      dotAll: true,
    );
    final schools = <WebSchool>[];
    for (final m in re.allMatches(html)) {
      List<WebGrade> grades = [];
      try {
        final list = jsonDecode(_unescape(m.group(2)!)) as List;
        grades = list
            .map((e) => WebGrade(
                  slug: (e['slug'] ?? '') as String,
                  name: (e['name'] ?? '') as String,
                ))
            .toList();
      } catch (_) {}
      schools.add(WebSchool(
        slug: m.group(1)!,
        name: _unescape(m.group(3)!).trim(),
        grades: grades,
      ));
    }
    return schools;
  }

  Future<GradeBooklist> fetchGrade(
      String schoolSlug, WebGrade grade, int gradeId) async {
    final html = await _html('/school/$schoolSlug/${grade.slug}');
    final itemRe = RegExp(
      r'<li class="list-group-item[^"]*">(.*?)</li>',
      dotAll: true,
    );
    final products = <BooklistProduct>[];
    for (final li in itemRe.allMatches(html)) {
      final body = li.group(1)!;
      final id = RegExp(r'value="(\d+)"').firstMatch(body)?.group(1);
      final name =
          RegExp(r'<label[^>]*>(.*?)</label>', dotAll: true)
              .firstMatch(body)
              ?.group(1);
      final qty = RegExp(r'Qty\s+(\d+)').firstMatch(body)?.group(1);
      final price = RegExp(r'class="fw-semibold">([^<]+)<')
          .firstMatch(body)
          ?.group(1);
      if (id == null || name == null || price == null) continue;
      final amount =
          double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      products.add(BooklistProduct(
        id: int.parse(id),
        name: _unescape(name).trim(),
        price: amount,
        quantity: int.tryParse(qty ?? '1') ?? 1,
      ));
    }
    return GradeBooklist(id: gradeId, name: grade.name, products: products);
  }

  Future<SchoolBooklist> fetchBooklist(WebSchool school, int schoolId) async {
    final grades = await Future.wait([
      for (var i = 0; i < school.grades.length; i++)
        fetchGrade(school.slug, school.grades[i], i + 1),
    ]);
    return SchoolBooklist(
      school: ApiSchool(
        id: schoolId,
        name: school.name,
        slug: school.slug,
        location: '',
      ),
      grades: grades,
    );
  }
}
