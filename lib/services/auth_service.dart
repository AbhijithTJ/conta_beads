import '../config/app_config.dart';
import '../models/auth_model.dart';
import 'api_client.dart';
import 'session_service.dart';

/// Handles authentication API calls.
/// Session persistence is delegated to [SessionService].
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── Login ────────────────────────────────────────────────────────────────────
  Future<LoginResponse> login({
    required String contact,
    required String password,
  }) async {
    final res = await ApiClient.instance.post(
      AppConfig.loginPath,
      body: LoginRequest(contact: contact, password: password).toJson(),
      auth: false, // no token needed for login
    );
    final loginResponse = LoginResponse.fromJson(res.data);
    await SessionService.instance.saveSession(loginResponse);
    return loginResponse;
  }

  // ── Register ─────────────────────────────────────────────────────────────────
  Future<LoginResponse> register({
    required String name,
    required String email,
    required String countryCode,
    required String phone,
    required String password,
    required String timezone,
    required String deviceId,
    String fcmToken = '',
  }) async {
    final res = await ApiClient.instance.post(
      AppConfig.registerPath,
      body: RegisterRequest(
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
        password: password,
        timezone: timezone,
        deviceId: deviceId,
        fcmToken: fcmToken,
      ).toJson(),
      auth: false,
    );
    final loginResponse = LoginResponse.fromJson(res.data);
    await SessionService.instance.saveSession(loginResponse);
    return loginResponse;
  }

  // ── Logout ────────────────────────────────────────────────────────────────────
  /// Calls POST /api/logout on the backend to invalidate the server-side token,
  /// then clears the local session regardless of the API result so the user
  /// is always logged out even if the network call fails.
  Future<void> logout() async {
    try {
      await ApiClient.instance.post(AppConfig.logoutPath);
    } catch (_) {
      // Swallow errors — local session must be cleared no matter what.
    } finally {
      await SessionService.instance.clearSession();
    }
  }
}
