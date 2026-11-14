import 'package:flutter/material.dart';
import '../models/department.dart';

class AppProvider extends ChangeNotifier {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedPublisher;
  int? _selectedCategoryId;
  int? _selectedBrandId;
  bool _discountedOnly = false;
  int _selectedTabIndex = 0;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedPublisher => _selectedPublisher;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  bool get discountedOnly => _discountedOnly;

  void setDiscountedOnly(bool value) {
    _discountedOnly = value;
    notifyListeners();
  }
  int get selectedTabIndex => _selectedTabIndex;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category, {int? id}) {
    _selectedCategory = category;
    _selectedCategoryId = category == null ? null : id;
    _selectedPublisher = null;
    _selectedBrandId = null;
    notifyListeners();
  }

  void setSelectedPublisher(String? publisher, {int? id}) {
    _selectedPublisher = publisher;
    _selectedBrandId = publisher == null ? null : id;
    if (publisher != null) {
      _selectedCategory = null;
      _selectedCategoryId = null;
    }
    notifyListeners();
  }

  void setDepartment(Department? department) {
    _selectedCategory = department?.name;
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedCategoryId = null;
    _selectedPublisher = null;
    _selectedBrandId = null;
    _discountedOnly = false;
    notifyListeners();
  }
}
