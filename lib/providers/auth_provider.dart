import 'package:flutter/foundation.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Manages authentication state for the whole app.
///
/// Screens listen to [status] and [errorMessage] — no direct
/// SharedPreferences or AuthService calls needed in UI code.
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserData? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserData? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Bootstrap ─────────────────────────────────────────────────────────────────
  /// Called once at startup — restores session from [SessionService] (in-memory).
  void restoreSession() {
    if (SessionService.instance.isLoggedIn) {
      // Rebuild a lightweight UserData from cached session fields.
      _user = UserData(
        id: SessionService.instance.userId,
        name: SessionService.instance.name,
        email: SessionService.instance.email,
        phone: SessionService.instance.contact,
      );
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────────
  Future<bool> login({required String contact, required String password}) async {
    _setLoading();
    try {
      final response = await AuthService.instance.login(
        contact: contact,
        password: password,
      );
      _user = response.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String countryCode,
    required String phone,
    required String password,
    required String timezone,
    required String deviceId,
    String fcmToken = '',
  }) async {
    _setLoading();
    try {
      final response = await AuthService.instance.register(
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
        password: password,
        timezone: timezone,
        deviceId: deviceId,
        fcmToken: fcmToken,
      );
      _user = response.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.instance.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
