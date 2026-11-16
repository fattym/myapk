import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/departments.dart';
import '../data/products.dart';
import '../data/publishers.dart';
import '../models/api_models.dart';
import '../models/department.dart';
import '../models/product.dart';
import '../models/publisher.dart';
import '../services/api_error.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../services/slider_service.dart';

enum CatalogStatus { idle, loading, success, error }

/// A brand/publisher shown on the home screen (live brand, or sample fallback).
class PublisherItem {
  const PublisherItem({
    required this.name,
    required this.iconName,
    this.id,
    this.logoUrl,
    this.isFeatured = false,
  });
  final String? logoUrl;
  final bool isFeatured;
  final String name;
  final String iconName;
  final int? id;
}

/// Loads categories, brands and products from the live API, with sample data
/// as an offline fallback so the UI never looks empty.
final class CatalogProvider extends ChangeNotifier {
  CatalogProvider();

  // ---- categories ----
  List<ProductCategory> _allCategories = [];
  List<Department> _departments = [];
  List<Department> get departments =>
      _departments.isEmpty ? sampleDepartments : _departments;

  /// Top-level departments only (home chips).
  List<Department> get topDepartments {
    if (_departments.isEmpty) return sampleDepartments;
    final top = {
      for (final c in _allCategories)
        if ((c.parentId ?? 0) == 0 || c.parentId == c.id) c.id.toString()
    };
    return _departments.where((d) => top.contains(d.id)).toList();
  }

  /// Direct sub-categories of a department (e.g. the grades under "Shop By Grade").
  List<Department> childrenOf(Department d) {
    final id = int.tryParse(d.id);
    if (id == null) return const [];
    final ids = {
      for (final c in _allCategories)
        if (c.parentId == id && c.id != id) c.id.toString()
    };
    final list = _departments.where((x) => ids.contains(x.id)).toList();
    list.sort((a, b) => _gradeOrder(a.name).compareTo(_gradeOrder(b.name)));
    return list;
  }

  static int _gradeOrder(String n) {
    final u = n.toUpperCase();
    if (u.startsWith('PP')) return int.tryParse(u.substring(2)) ?? 0;
    final m = RegExp(r'(\d+)').firstMatch(u);
    return m == null ? 1000 : 10 + int.parse(m.group(1)!);
  }

  /// Maps a department id (string) back to the numeric category id.
  int? categoryIdFor(Department d) => int.tryParse(d.id);

  bool _categoriesLoaded = false;
  Future<void> loadCategories() async {
    if (_categoriesLoaded) return;
    _categoriesLoaded = true;
    try {
      _allCategories = await CategoryService.instance.fetchCategories();
      // Show every category (top-level and sub-categories), de-duplicated by
      // name; entries that are their own parent count as top-level.
      final byId = {for (final c in _allCategories) c.id: c};
      final seen = <String>{};
      final all = _allCategories.where((c) {
        final key = c.name.trim().toLowerCase();
        return key.isNotEmpty && seen.add(key);
      }).toList();
      _departments = all.map((c) {
        final pid = c.parentId ?? 0;
        final parent = (pid == 0 || pid == c.id) ? null : byId[pid];
        final subs = _subCount(c.id);
        return Department(
          id: c.id.toString(),
          name: c.name,
          subtitle: parent != null
              ? 'in ${parent.name}'
              : subs > 0
                  ? '$subs categories'
                  : 'Browse all',
          itemCount: 0,
          iconName: _iconFor(c.name),
        );
      }).toList();
    } catch (_) {
      _categoriesLoaded = false; // allow retry
    }
    notifyListeners();
  }

  /// A category plus all of its sub-categories (the API only matches products
  /// attached directly to each id it is given).
  List<int> _descendantIds(int id) {
    final ids = <int>[id];
    for (final c in _allCategories) {
      if (c.parentId == id) ids.addAll(_descendantIds(c.id));
    }
    return ids;
  }

  int _subCount(int id) =>
      _allCategories.where((x) => x.parentId == id && x.id != id).length;

  static String _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('grade') || n.contains('school')) return 'school';
    if (n.contains('book') || n.contains('stationery')) return 'menu-book';
    if (n.contains('electronic')) return 'precision';
    if (n.contains('art') || n.contains('craft')) return 'palette';
    if (n.contains('special')) return 'science';
    if (n.contains('uniform') || n.contains('wear')) return 'checkroom';
    return 'book';
  }

  // ---- brands / publishers ----
  List<PublisherItem> _publishers = [];
  List<PublisherItem> get publishers => _publishers.isEmpty
      ? samplePublishers
          .map((Publisher p) =>
              PublisherItem(name: p.name, iconName: p.iconName))
          .toList()
      : _publishers;

  List<PublisherItem> get featuredBrands =>
      _publishers.where((b) => b.isFeatured).toList();

  bool _brandsLoaded = false;
  Future<void> loadBrands() async {
    if (_brandsLoaded) return;
    _brandsLoaded = true;
    try {
      final brands = await CategoryService.instance.fetchBrands();
      _publishers = brands
          .where((b) => (b.name ?? '').isNotEmpty)
          .map((b) => PublisherItem(
              name: b.name!,
              iconName: 'book-open',
              id: b.id,
              logoUrl: b.logo,
              isFeatured: b.isFeatured))
          .toList();
    } catch (_) {
      _brandsLoaded = false;
    }
    notifyListeners();
  }

  // ---- products (catalog) ----
  CatalogStatus _status = CatalogStatus.idle;
  CatalogStatus get status => _status;

  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  bool _usingSample = false;
  bool get usingSample => _usingSample;

  String? _error;
  String? get error => _error;

  int _page = 1;
  int _lastPage = 1;
  int _total = 0;
  int get total => _total;
  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;
  bool get hasMore => !_usingSample && _page < _lastPage;

  String _query = '';
  int? _categoryId;
  int? _brandId;
  String? _categoryName;
  String? _brandName;
  bool _discountedOnly = false;
  Timer? _debounce;
  int _requestToken = 0;

  /// Applies filters (debounced) and reloads page 1 when they changed.
  void setFilters({
    String query = '',
    int? categoryId,
    int? brandId,
    String? categoryName,
    String? brandName,
    bool discountedOnly = false,
    bool force = false,
  }) {
    final same = query == _query &&
        categoryId == _categoryId &&
        brandId == _brandId &&
        categoryName == _categoryName &&
        brandName == _brandName &&
        discountedOnly == _discountedOnly;
    if (same && !force && _status != CatalogStatus.idle) return;
    _query = query;
    _categoryId = categoryId;
    _brandId = brandId;
    _categoryName = categoryName;
    _brandName = brandName;
    _discountedOnly = discountedOnly;
    _debounce?.cancel();
    _status = CatalogStatus.loading;
    notifyListeners();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetch(reset: true),
    );
  }

  Future<void> retry() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;
    _loadingMore = true;
    notifyListeners();
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final token = ++_requestToken;
    final page = reset ? 1 : _page + 1;
    try {
      final result = await ApiProductService.instance.fetchApiProducts(
        keyword: _query,
        categoryIds: _categoryId == null ? null : _descendantIds(_categoryId!),
        brandId: _brandId,
        discountedOnly: _discountedOnly,
        page: page,
      );
      if (token != _requestToken) return;
      final items = result.data.map(Product.fromApi).toList();
      _products = reset ? items : [..._products, ...items];
      _page = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _usingSample = false;
      _error = null;
      _status = CatalogStatus.success;
    } on ApiError catch (e) {
      if (token != _requestToken) return;
      _fallback(e.message);
    } catch (_) {
      if (token != _requestToken) return;
      _fallback('Could not reach the server.');
    }
    _loadingMore = false;
    notifyListeners();
  }

  void _fallback(String message) {
    _error = message;
    final q = _query.toLowerCase();
    _products = sampleProducts.where((p) {
      if (_categoryName != null && p.category != _categoryName) return false;
      if (_brandName != null && p.publisher != _brandName) return false;
      if (q.isNotEmpty && !p.title.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
    _usingSample = true;
    _total = _products.length;
    _page = 1;
    _lastPage = 1;
    _status = CatalogStatus.error;
  }

  // ---- home banners ----
  List<SliderItem> _sliders = [];
  List<SliderItem> get sliders => _sliders;
  bool _slidersLoaded = false;
  Future<void> loadSliders() async {
    if (_slidersLoaded) return;
    _slidersLoaded = true;
    try {
      _sliders = (await SliderService.instance.fetchSliders())
          .where((s) => (s.image ?? '').isNotEmpty)
          .toList();
    } catch (_) {
      _slidersLoaded = false;
    }
    notifyListeners();
  }

  // ---- automatic discount detector (home "Deals") ----
  List<Product> _deals = [];
  List<Product> get deals => _deals;
  bool _dealsLoaded = false;

  /// Fetches products the server flags as discounted, keeps the ones whose live
  /// price is really below the list price, and ranks them by percentage off.
  Future<void> loadDeals() async {
    if (_dealsLoaded) return;
    _dealsLoaded = true;
    try {
      final page = await ApiProductService.instance
          .fetchApiProducts(discountedOnly: true);
      final all = page.data.map(Product.fromApi).where((p) => p.isDiscounted);
      final sorted = all.toList()
        ..sort((a, b) =>
            (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0));
      _deals = sorted.take(10).toList();
    } catch (_) {
      _dealsLoaded = false;
    }
    notifyListeners();
  }

  // ---- home "recommended" products ----
  List<Product> _featured = [];
  List<Product> get featured =>
      _featured.isEmpty ? sampleProducts.take(6).toList() : _featured;

  bool _featuredLoaded = false;
  Future<void> loadFeatured() async {
    if (_featuredLoaded) return;
    _featuredLoaded = true;
    try {
      final page = await ApiProductService.instance.fetchApiProducts();
      _featured = page.data.take(8).map(Product.fromApi).toList();
    } catch (_) {
      _featuredLoaded = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
