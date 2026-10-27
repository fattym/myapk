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
  Future<void> loadSchools({bool authenticated = false}) async {
    if (_initialized) return;
    _initialized = true;
    if (!authenticated) {
      _schools = List<PartnerSchool>.from(sampleSchools);
      _status = SchoolsStatus.success;
      notifyListeners();
      return;
    }
    _status = SchoolsStatus.loading;
    notifyListeners();
    try {
      final page = await SchoolService.instance.fetchSchools();
      _schools = page.data.map(_toPartnerSchool).toList();
      _status = SchoolsStatus.success;
      if (_schools.isEmpty) {
        _errorMessage = 'No schools found.';
      } else {
        _errorMessage = null;
      }
    } on ApiError catch (e) {
      _schools = [];
      _errorMessage = e.message;
      _status = SchoolsStatus.error;
    } catch (e) {
      _schools = [];
      _errorMessage = 'Failed to load schools.';
      _status = SchoolsStatus.error;
    }
    notifyListeners();
  }

  Future<bool> loadBooklist({required bool authenticated, required int apiId}) async {
    if (!authenticated) return false;
    if (_booklists.containsKey(apiId)) return true;
    try {
      final booklist = await SchoolService.instance.fetchBooklist(apiId);
      _booklists[apiId] = booklist;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to load booklist.';
      notifyListeners();
      return false;
    }
  }

  SchoolBooklist? booklistFor(int apiId) => _booklists[apiId];

  void reset() {
    _initialized = false;
    _status = SchoolsStatus.idle;
    _schools = [];
    _booklists.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
