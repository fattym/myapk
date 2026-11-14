import 'package:flutter/foundation.dart';
import '../data/schools.dart';
import '../models/api_models.dart';
import '../models/partner_school.dart';
import '../services/api_error.dart';
import '../services/school_service.dart';

enum SchoolsStatus { idle, loading, success, error }

final class SchoolsProvider extends ChangeNotifier {
  SchoolsProvider();

  SchoolsStatus _status = SchoolsStatus.idle;
  SchoolsStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PartnerSchool> _schools = [];
  List<PartnerSchool> get schools => List.unmodifiable(_schools);

  final Map<int, SchoolBooklist> _booklists = {};

  PartnerSchool _toPartnerSchool(ApiSchool school) => PartnerSchool(
        name: school.name,
        code: school.slug,
        location: school.location,
        studentCount: 0,
        contact: school.contact,
        logoUrl: school.logoUrl,
        apiId: school.id,
      );

  bool _initialized = false;

  /// Loads the school directory. Uses the API when `[authenticated]` is true,
  /// otherwise falls back to the local sample data so the UI remains usable
  /// (and testable) without a logged-in session.
  /// Loads the school directory from the (public) API. Falls back to the
  /// local sample data if the API is unreachable or returns nothing, so the
  /// UI is always usable. `[authenticated]` is kept for compatibility.
  Future<void> loadSchools({bool authenticated = false}) async {
    if (_initialized) return;
    _initialized = true;
    _status = SchoolsStatus.loading;
    notifyListeners();
    try {
      final page = await SchoolService.instance.fetchSchools(perPage: 100);
      _schools = page.data.map(_toPartnerSchool).toList();
      _errorMessage = null;
    } on ApiError catch (e) {
      _schools = [];
      _errorMessage = e.message;
    } catch (_) {
      _schools = [];
      _errorMessage = 'Failed to load schools.';
    }
    if (_schools.isEmpty) {
      _schools = List<PartnerSchool>.from(sampleSchools);
    }
    _status = SchoolsStatus.success;
    notifyListeners();
  }

  final Set<int> _loadingBooklists = {};
  final Set<int> _failedBooklists = {};

  bool isBooklistLoading(int apiId) => _loadingBooklists.contains(apiId);
  bool booklistFailed(int apiId) => _failedBooklists.contains(apiId);

  Future<bool> loadBooklist({bool authenticated = false, required int apiId}) async {
    if (_booklists.containsKey(apiId)) return true;
    if (!_loadingBooklists.add(apiId)) return false;
    _failedBooklists.remove(apiId);
    notifyListeners();
    try {
      final booklist = await SchoolService.instance.fetchBooklist(apiId);
      _booklists[apiId] = booklist;
      _loadingBooklists.remove(apiId);
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load booklist.';
    }
    _loadingBooklists.remove(apiId);
    _failedBooklists.add(apiId);
    notifyListeners();
    return false;
  }

  SchoolBooklist? booklistFor(int apiId) => _booklists[apiId];

  void reset() {
    _initialized = false;
    _status = SchoolsStatus.idle;
    _schools = [];
    _booklists.clear();
    _loadingBooklists.clear();
    _failedBooklists.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
