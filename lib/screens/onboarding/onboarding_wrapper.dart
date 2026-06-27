import 'package:flutter/material.dart';
import '../bottom_nav_wrapper.dart';
import 'onboarding_modified_new.dart';
import '../../services/session_service.dart';

/// Checks if the user has seen onboarding (sync from SessionService — no FutureBuilder needed).
class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  void _navigateToHome(BuildContext context) {
    SessionService.instance.setOnboardingComplete();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BottomNavWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSeenOnboarding = SessionService.instance.onboardingComplete;

    if (hasSeenOnboarding) {
      return const BottomNavWrapper();
    }
    return OnboardingModifiedNew(onComplete: () => _navigateToHome(context));
  }
}
