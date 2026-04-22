import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/theme_select/theme_select_screen.dart';
import 'services/localization_service.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loc.load('English');
  // Restore saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? true;
  themeNotifier.setDark(isDark);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        return MaterialApp(
          title: 'Rosary Bank',
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
