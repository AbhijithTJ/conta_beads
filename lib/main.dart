import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/global_counts_provider.dart';
import 'providers/home_provider.dart';
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
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

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
