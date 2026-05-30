import 'package:flutter/foundation.dart';
import '../models/auth_model.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import '../config/app_config.dart';

/// Holds the logged-in user's data and exposes it app-wide.
///
/// Populated after login/register via [setUser].
/// Screens read from this instead of passing userEmail through every constructor.
class UserProvider extends ChangeNotifier {
  UserData? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserData? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Convenience getters used across screens
  String get displayName => _user?.name ?? 'Guest';
  String get email => _user?.email ?? '';
  String get phone => _user?.phone ?? '';
  int get userId => _user?.id ?? 0;
  String get countryCode => _user?.countryCode ?? '';
  String get timezone => _user?.timezone ?? '';
  String get parish => _user?.parish ?? '';
  String get role => _user?.role ?? '';

  // Prayer counts
  int get rosaryPrayedTotal => _user?.rosaryPrayedTotal ?? 0;
  int get rosaryBorrowedTotal => _user?.rosaryBorrowedTotal ?? 0;
  int get rosaryAvailable => _user?.rosaryAvailable ?? 0;
  int get rosaryTodayPrayed => _user?.rosaryTodayPrayed ?? 0;
  int get rosaryTodayBorrowed => _user?.rosaryTodayBorrowed ?? 0;
  int get rosaryTodayAvailable => _user?.rosaryTodayAvailable ?? 0;

  int get chapelPrayedTotal => _user?.chapelPrayedTotal ?? 0;
  int get chapelBorrowedTotal => _user?.chapelBorrowedTotal ?? 0;
  int get chapelAvailable => _user?.chapelAvailable ?? 0;
  int get chapelTodayPrayed => _user?.chapelTodayPrayed ?? 0;
  int get chapelTodayBorrowed => _user?.chapelTodayBorrowed ?? 0;
  int get chapelTodayAvailable => _user?.chapelTodayAvailable ?? 0;

  int get totalCount => _user?.totalCount ?? 0;
  int get todayCount => _user?.todayCount ?? 0;

  // ── Setters ───────────────────────────────────────────────────────────────────
  void setUser(UserData user) {
    _user = user;
    notifyListeners();
  }

  /// Restore lightweight user from session cache (no API call needed).
  void restoreFromSession() {
    final s = SessionService.instance;
    if (s.isLoggedIn) {
      _user = UserData(
        id:        s.userId,
        name:      s.name,
        email:     s.email,
        phone:     s.contact,
        timezone:  s.timezone,
        createdAt: s.createdAt,
      );
      notifyListeners();
    }
  }

  /// Fetch full user profile from GET /api/user.
  /// Uses the Bearer token stored in [SessionService].
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.instance.get(AppConfig.userPath);
      final data = res.data['user'] as Map<String, dynamic>? ?? res.data;
      _user = UserData.fromJson(data);
      // Persist timezone + createdAt so they survive app restarts
      await SessionService.instance.saveProfileExtras(
        timezone:  _user?.timezone,
        createdAt: _user?.createdAt,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile via PUT /api/user/update-profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? countryCode,
    String? phone,
    String? password,
    String? timezone,
    String? deviceId,
    String? fcmToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateProfileRequest(
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
        password: password,
        timezone: timezone,
        deviceId: deviceId,
        fcmToken: fcmToken,
      );

      final res = await ApiClient.instance.put(
        AppConfig.updateProfilePath,
        body: request.toJson(),
      );

      final data = res.data['user'] as Map<String, dynamic>? ?? res.data;
      _user = UserData.fromJson(data);

      // Update session with new data
      await SessionService.instance.saveProfileExtras(
        timezone: _user?.timezone,
        createdAt: _user?.createdAt,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
