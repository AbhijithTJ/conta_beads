import 'package:flutter/material.dart';
import 'login_and_register/login_screen.dart';
import 'screens/home_page/counting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conta Beads',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3182CE)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

