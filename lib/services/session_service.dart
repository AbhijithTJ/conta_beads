import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';

/// Single source of truth for all persisted session data.
///
/// Loaded once at app startup into memory — no more scattered
/// `SharedPreferences.getInstance()` calls across the codebase.
/// All reads are synchronous after [init] completes.
///
/// Sensitive credentials (contact + password) are stored in
/// [FlutterSecureStorage] (Android Keystore / iOS Keychain) so
/// biometric login can replay the API login without exposing the
/// password in plain SharedPreferences.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  // ── Keys ────────────────────────────────────────────────────────────────────
  static const _kToken      = 'auth_token';
  static const _kContact    = 'saved_contact';
  static const _kName       = 'user_name';
  static const _kEmail      = 'user_email';
  static const _kUserId     = 'user_id';
  static const _kTimezone   = 'user_timezone';
  static const _kCreatedAt  = 'user_created_at';
  static const _kBiometric  = 'biometric_enabled';
  static const _kDarkTheme  = 'isDarkTheme';
  static const _kOnboarded  = 'onboarding_complete';

  // Secure storage keys (Keystore / Keychain)
  static const _ksContact  = 'secure_contact';
  static const _ksPassword = 'secure_password';

  late SharedPreferences _prefs;
  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── In-memory cache ─────────────────────────────────────────────────────────
  String? _token;
  String? _contact;
  String? _name;
  String? _email;
  int?    _userId;
  String? _timezone;
  String? _createdAt;
  bool    _biometricEnabled   = false;
  bool    _isDarkTheme        = true;
  bool    _onboardingComplete = false;

  // ── Getters (synchronous — no await needed) ─────────────────────────────────
  String? get token              => _token;
  String? get contact            => _contact;
  String? get name               => _name;
  String? get email              => _email;
  int?    get userId             => _userId;
  String? get timezone           => _timezone;
  String? get createdAt          => _createdAt;
  bool    get biometricEnabled   => _biometricEnabled;
  bool    get isDarkTheme        => _isDarkTheme;
  bool    get onboardingComplete => _onboardingComplete;
  bool    get isLoggedIn         => _token != null && _token!.isNotEmpty;

  // ── Initialise once at app startup ──────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token              = _prefs.getString(_kToken);
    _contact            = _prefs.getString(_kContact);
    _name               = _prefs.getString(_kName);
    _email              = _prefs.getString(_kEmail);
    _userId             = _prefs.getInt(_kUserId);
    _timezone           = _prefs.getString(_kTimezone);
    _createdAt          = _prefs.getString(_kCreatedAt);
    _biometricEnabled   = _prefs.getBool(_kBiometric) ?? false;
    _isDarkTheme        = _prefs.getBool(_kDarkTheme) ?? true;
    _onboardingComplete = _prefs.getBool(_kOnboarded) ?? false;
  }

  // ── Write helpers ────────────────────────────────────────────────────────────
  Future<void> saveSession(LoginResponse response) async {
    _token   = response.token;
    _contact = response.user.phone;
    _name    = response.user.name;
    _email   = response.user.email;
    _userId  = response.user.id;

    await Future.wait([
      _prefs.setString(_kToken, response.token),
      if (response.user.phone != null)
        _prefs.setString(_kContact, response.user.phone!),
      if (response.user.name != null)
        _prefs.setString(_kName, response.user.name!),
      if (response.user.email != null)
        _prefs.setString(_kEmail, response.user.email!),
      if (response.user.id != null)
        _prefs.setInt(_kUserId, response.user.id!),
    ]);
  }

  /// Persists extra profile fields that aren't in the login response.
  /// Call this after a successful [fetchProfile] so the data survives restarts.
  Future<void> saveProfileExtras({
    String? timezone,
    String? createdAt,
  }) async {
    if (timezone != null && timezone.isNotEmpty) {
      _timezone = timezone;
      await _prefs.setString(_kTimezone, timezone);
    }
    if (createdAt != null && createdAt.isNotEmpty) {
      _createdAt = createdAt;
      await _prefs.setString(_kCreatedAt, createdAt);
    }
  }

  /// Saves contact + password into the device Keystore/Keychain so
  /// biometric login can replay the API call without asking for a password.
  Future<void> saveBiometricCredentials({
    required String contact,
    required String password,
  }) async {
    await Future.wait([
      _secure.write(key: _ksContact,  value: contact),
      _secure.write(key: _ksPassword, value: password),
    ]);
  }

  /// Returns the saved credentials for biometric re-login.
  /// Returns null if credentials were never saved.
  Future<({String contact, String password})?> getBiometricCredentials() async {
    final contact  = await _secure.read(key: _ksContact);
    final password = await _secure.read(key: _ksPassword);
    if (contact == null || password == null) return null;
    return (contact: contact, password: password);
  }

  /// Wipes the secure credentials (call when user disables biometric).
  Future<void> clearBiometricCredentials() async {
    await Future.wait([
      _secure.delete(key: _ksContact),
      _secure.delete(key: _ksPassword),
    ]);
  }

  /// Clears the auth token + user info but keeps biometric credentials
  /// so the user can log back in with fingerprint after logout.
  Future<void> clearSession() async {
    _token     = null;
    _contact   = null;
    _name      = null;
    _email     = null;
    _userId    = null;
    _timezone  = null;
    _createdAt = null;

    await Future.wait([
      _prefs.remove(_kToken),
      _prefs.remove(_kContact),
      _prefs.remove(_kName),
      _prefs.remove(_kEmail),
      _prefs.remove(_kUserId),
      _prefs.remove(_kTimezone),
      _prefs.remove(_kCreatedAt),
      // NOTE: _kBiometric is intentionally NOT removed here.
    ]);
  }

  Future<void> setBiometricEnabled(bool value) async {
    _biometricEnabled = value;
    await _prefs.setBool(_kBiometric, value);
    // If disabling, wipe the stored credentials too.
    if (!value) await clearBiometricCredentials();
  }

  Future<void> setDarkTheme(bool value) async {
    _isDarkTheme = value;
    await _prefs.setBool(_kDarkTheme, value);
  }

  Future<void> setOnboardingComplete() async {
    _onboardingComplete = true;
    await _prefs.setBool(_kOnboarded, true);
  }

  Future<void> saveContact(String contact) async {
    _contact = contact;
    await _prefs.setString(_kContact, contact);
  }
}
