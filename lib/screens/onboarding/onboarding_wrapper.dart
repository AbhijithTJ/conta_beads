import 'package:flutter/material.dart';
import '../bottom_nav_wrapper.dart';
import 'onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingWrapper extends StatefulWidget {
  final String userEmail;

  const OnboardingWrapper({
    super.key,
    required this.userEmail,
  });

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  late Future<bool> _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _hasSeenOnboarding = _checkOnboardingStatus();
  }

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BottomNavWrapper(userEmail: widget.userEmail),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSeenOnboarding,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return BottomNavWrapper(userEmail: widget.userEmail);
        } else {
          return OnboardingScreen(onComplete: _navigateToHome);
        }
      },
    );
  }
}
