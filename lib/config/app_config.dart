/// Defines the available build environments.
enum AppEnvironment { staging, production }

/// Central configuration for the app.
/// Switch [environment] before building to target a different backend.
class AppConfig {
  AppConfig._();

  // ── Change this to [AppEnvironment.production] for release builds ──────────
  static const AppEnvironment environment = AppEnvironment.production;

  // ── Base URLs ───────────────────────────────────────────────────────────────
  static const String _stagingBaseUrl = 'https://upperroom.co.in/staging';
  static const String _productionBaseUrl = 'https://upperroom.co.in';

  /// The active base URL, chosen by [environment].
  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.staging:
        return _stagingBaseUrl;
      case AppEnvironment.production:
        return _productionBaseUrl;
    }
  }

  // ── API paths ───────────────────────────────────────────────────────────────
  static const String loginPath          = '/api/login';
  static const String registerPath       = '/api/register';
  static const String userPath           = '/api/user';
  static const String logoutPath         = '/api/logout';
  static const String globalCountsPath   = '/api/community/global-counts';
  static const String homePath           = '/api/home';
  static const String dailyPrayersPath   = '/api/daily-prayers';
  static const String rosariesPath       = '/api/rosaries';

  // ── Timeouts ────────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProduction => environment == AppEnvironment.production;
}
