import 'package:flutter/material.dart';
import '../../services/localization_service.dart';

class OnboardingPage {
  final String titleKey;
  final String descriptionKey;

  const OnboardingPage({
    required this.titleKey,
    required this.descriptionKey,
  });
  
  String getTitle() => loc.tr(titleKey);
  String getDescription() => loc.tr(descriptionKey);
}

final _pages = [
  OnboardingPage(
    titleKey: 'onboarding_welcome_title',
    descriptionKey: 'onboarding_welcome_desc',
  ),
  OnboardingPage(
    titleKey: 'onboarding_count_title',
    descriptionKey: 'onboarding_count_desc',
  ),
  OnboardingPage(
    titleKey: 'onboarding_community_title',
    descriptionKey: 'onboarding_community_desc',
  ),
  OnboardingPage(
    titleKey: 'onboarding_intentions_title',
    descriptionKey: 'onboarding_intentions_desc',
  ),
  OnboardingPage(
    titleKey: 'onboarding_priest_title',
    descriptionKey: 'onboarding_priest_desc',
  ),
  OnboardingPage(
    titleKey: 'onboarding_prayers_title',
    descriptionKey: 'onboarding_prayers_desc',
  ),
  OnboardingPage(
    titleKey: 'onboarding_profile_title',
    descriptionKey: 'onboarding_profile_desc',
  ),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  void _complete() {
    widget.onComplete?.call();
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _complete();
    } else {
      setState(() {
        _currentPage++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF352458), 
              Color(0xFF1E0A3C), 
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/demo/logo_image.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                           // Fallback if logo name is different
                           return Image.asset(
                             'assets/demo/logo_image_light.png',
                             height: 100,
                             errorBuilder: (context, error, stackTrace) => const SizedBox(height: 100),
                           );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upper Room',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Card
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey<int>(_currentPage),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                          decoration: BoxDecoration(
                            color: const Color(0xFF190638), // Dark purple card background
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                page.getTitle(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                page.getDescription(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _pages.length - 1 ? loc.tr('onboarding_get_started') : loc.tr('onboarding_next'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E0A3C),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Bottom Watermark
              Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/splash/splash_bottom.png',
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 60),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
