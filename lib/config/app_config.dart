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

  // ── WebSocket / Reverb Configuration ────────────────────────────────────────
  /// Pusher Channels app key (from Laravel Reverb config)
  static const String reverbAppKey = 'rp4pjh1p8xc0aj1f81t3';
  
  /// Cluster name - for custom Reverb
  static const String reverbCluster = 'upperroom';
  
  /// Reverb host (your domain or IP)
  static const String reverbHost = 'upperroom.co.in';
  
  /// Reverb port (usually 6001 for WebSocket, 443 for HTTPS)
  static const int reverbPort = 443;
  
  /// Use TLS for WebSocket (false for ws://, true for wss://)
  static const bool reverbUseTLS = true;
  
  /// WebSocket channel name
  static const String reverbChannel = 'dashboard';
  
  /// WebSocket event name
  static const String reverbEvent = 'count.updated';
  
  /// Reverb auth endpoint for private/presence channels
  static String get reverbAuthEndpoint {
    return '$baseUrl/broadcasting/auth';
  }
  
  /// Redis API endpoint for initial load (global counts)
  static const String globalCountsRedisPath = '/api/community/global-counts/redis';
  
  /// Redis API endpoint for rosaries
  static const String rosariesRedisPath = '/api/rosaries/redis';

  // ── API paths ───────────────────────────────────────────────────────────────
  static const String loginPath          = '/api/login';
  static const String registerPath       = '/api/register';
  static const String userPath           = '/api/user';
  static const String logoutPath         = '/api/logout';
  static const String globalCountsPath   = '/api/community/global-counts/redis';
  static const String homePath           = '/api/home';
  static const String dailyPrayersPath   = '/api/daily-prayers';
  static const String rosariesPath       = '/api/rosaries/redis';
  static const String rosariesBorrowPath = '/api/rosaries/borrow';
  static const String rosariesHistoryPath = '/api/rosaries/history';
  static const String priestsPath        = '/api/priests';
  static const String priestsAdoptPath   = '/api/priests/adopt';
  static const String myPriestsPath      = '/api/priests/my-priests';
  static const String intentionsPath     = '/api/intentions';

  // ── Timeouts ────────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProduction => environment == AppEnvironment.production;
}
