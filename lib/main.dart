import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loc.load('English'); // default language
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rosary Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B6B8A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
