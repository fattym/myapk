import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

final class AuthProvider extends ChangeNotifier {
  AuthProvider();

  bool _initialized = false;
  bool get initialized => _initialized;

  String? _token;
  String? get token => _token;

  UserProfile? _user;
  UserProfile? get user => _user;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  Future<void> init() async {
    if (_initialized) return;
    _token = await ApiClient.readToken();
    _status = _token == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    _initialized = true;
    notifyListeners();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    String? device,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final result = await AuthService.instance.login(
        email: email,
        password: password,
        device: device,
      );
      _token = result.token;
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return result;
    } catch (e) {
      _status = AuthStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? device,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final result = await AuthService.instance.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        device: device,
      );
      _token = result.token;
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return result;
    } catch (e) {
      _status = AuthStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

enum AuthStatus { unknown, loading, authenticated, unauthenticated, error }
