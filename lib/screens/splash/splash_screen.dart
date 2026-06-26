import 'package:flutter/material.dart';
import '../../login_and_register/login_screen.dart';
import '../../screens/onboarding/onboarding_wrapper.dart';
import '../../screens/theme_select/theme_select_screen.dart';
import '../../services/session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gifCtrl;

  @override
  void initState() {
    super.initState();

    // Reduced duration so user doesn't have to wait for the entire 6s GIF.
    _gifCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _gifCtrl.forward();

    _gifCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        try {
          // Route logic:
          // 1. If logged in → go to OnboardingWrapper (which checks onboarding flag)
          // 2. If not logged in but has seen onboarding → go directly to LoginScreen
          // 3. If first install → show ThemeSelectScreen -> Onboarding -> Login
          final destination = SessionService.instance.isLoggedIn
              ? const OnboardingWrapper()
              : (SessionService.instance.onboardingComplete
                  ? const LoginScreen()
                  : ThemeSelectScreen(onComplete: () {}));

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => destination,
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        } catch (e) {
          debugPrint('[SplashScreen] Navigation error: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _gifCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/splash/spalsh_final.gif',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
