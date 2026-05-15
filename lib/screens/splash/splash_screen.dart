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

    // Duration matches the GIF's total animation length (182 frames @ ~6.07 s).
    _gifCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6070),
    );

    _gifCtrl.forward();

    _gifCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Route to home if already logged in, otherwise show theme selection.
        final destination = SessionService.instance.isLoggedIn
            ? const OnboardingWrapper()
            : ThemeSelectScreen(onComplete: () {});

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => destination,
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
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
