import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
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
import 'services/notification_service.dart';
import 'services/session_service.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with explicit options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Notifications
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] Firebase/Notification initialization error: $e');
  }

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
        ChangeNotifierProvider(create: (context) => GlobalCountsProvider(
          userProvider: context.read<UserProvider>(),
        )),
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
    // Defer WebSocket initialization to after first frame on iOS
    // This prevents context access issues on iOS
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeWebSocket();
      }
    });
  }

  /// Initialize Reverb WebSocket connection
  Future<void> _initializeWebSocket() async {
    if (!mounted) return;
    
    try {
      // Check if context is still valid
      if (!context.mounted) return;
      
      final reverbProvider = context.read<ReverbProvider>();
      
      // Initialize Reverb and wait for connection
      await reverbProvider.initialize();
      
      if (!mounted) return;
      debugPrint('[App] Reverb connected');

      // Subscribe to dashboard channel (will wait for connection if needed)
      await reverbProvider.subscribe('dashboard');
      
      if (!mounted) return;
      debugPrint('[App] Subscribed to dashboard');

      // Setup WebSocket listeners in GlobalCountsProvider
      final globalCountsProvider = context.read<GlobalCountsProvider>();
      globalCountsProvider.setupReverbListeners(reverbProvider.service);

      debugPrint('[App] Reverb initialized and subscribed to dashboard');
    } catch (e) {
      debugPrint('[App] Reverb initialization error: $e');
      // Don't crash the app if WebSocket initialization fails
      // Users can still use the app without real-time updates
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
          home: const SplashScreen(),
        );
      },
    );
  }
}
