import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/global_counts_provider.dart';
import 'providers/home_provider.dart';
import 'providers/daily_prayer_provider.dart';
import 'providers/prayer_documents_provider.dart';
import 'providers/adopt_priest_provider.dart';
import 'providers/intentions_provider.dart';
import 'providers/prayer_history_provider.dart';
import 'providers/language_provider.dart';
import 'providers/reverb_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/theme_select/theme_select_screen.dart';
import 'services/localization_service.dart';
import 'services/session_service.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences once into memory — all subsequent reads are sync.
  await SessionService.instance.init();

  // Restore theme from session (sync, no await).
  themeNotifier.setDark(SessionService.instance.isDarkTheme);

  // Load default language.
  await loc.load('English');

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => UserProvider()..restoreFromSession()),
        ChangeNotifierProvider(create: (_) => GlobalCountsProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DailyPrayerProvider()),
        ChangeNotifierProvider(create: (_) => PrayerDocumentsProvider()),
        ChangeNotifierProvider(create: (_) => AdoptPriestProvider()),
        ChangeNotifierProvider(create: (_) => IntentionsProvider()),
        ChangeNotifierProvider(create: (_) => PrayerHistoryProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ReverbProvider()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  @override
  void initState() {
    super.initState();
    // Initialize WebSocket after providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
    });
  }

  /// Initialize Reverb WebSocket connection
  Future<void> _initializeWebSocket() async {
    try {
      final reverbProvider = context.read<ReverbProvider>();
      
      // Initialize Reverb and wait for connection
      await reverbProvider.initialize();
      debugPrint('[App] Reverb connected');

      // Subscribe to dashboard channel (will wait for connection if needed)
      await reverbProvider.subscribe('dashboard');
      debugPrint('[App] Subscribed to dashboard');

      // Setup WebSocket listeners in GlobalCountsProvider
      final globalCountsProvider = context.read<GlobalCountsProvider>();
      globalCountsProvider.setupReverbListeners(reverbProvider.service);

      debugPrint('[App] Reverb initialized and subscribed to dashboard');
    } catch (e) {
      debugPrint('[App] Reverb initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        return MaterialApp(
          title: 'UPPER ROOM',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            fontFamily: 'Georgia',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5EEF5),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3D0227),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: 'Georgia',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF3D0227),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9B6B8A),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: ThemeSelectScreen(
            onComplete: () {}, // handled inside the screen via Navigator
          ),
        );
      },
    );
  }
}
