import 'package:flutter/material.dart';
import '../models/department.dart';

class AppProvider extends ChangeNotifier {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedPublisher;
  int _selectedTabIndex = 0;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedPublisher => _selectedPublisher;
  int get selectedTabIndex => _selectedTabIndex;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _selectedPublisher = null;
    notifyListeners();
  }

  void setSelectedPublisher(String? publisher) {
    _selectedPublisher = publisher;
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
    _selectedPublisher = null;
    notifyListeners();
  }
}
