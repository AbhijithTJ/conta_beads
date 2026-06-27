import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/localization_service.dart';

class OnboardingPageData {
  final String titleKey;
  final String descriptionKey;
  final String imagePath;

  const OnboardingPageData({
    required this.titleKey,
    required this.descriptionKey,
    required this.imagePath,
  });
  
  String getTitle() => loc.tr(titleKey);
  String getDescription() => loc.tr(descriptionKey);
}

final _pages = [
  const OnboardingPageData(
    titleKey: 'onboarding_welcome_title',
    descriptionKey: 'onboarding_welcome_desc',
    imagePath: 'assets/onboarding/welcome.png',
  ),
  const OnboardingPageData(
    titleKey: 'onboarding_prayers_title',
    descriptionKey: 'onboarding_prayers_desc',
    imagePath: 'assets/onboarding/every_day.png',
  ),
  const OnboardingPageData(
    titleKey: 'onboarding_community_title',
    descriptionKey: 'onboarding_community_desc',
    imagePath: 'assets/onboarding/globel_count.png',
  ),
  const OnboardingPageData(
    titleKey: 'onboarding_count_title',
    descriptionKey: 'onboarding_count_desc',
    imagePath: 'assets/onboarding/count_screen.png',
  ),
  const OnboardingPageData(
    titleKey: 'onboarding_intentions_title',
    descriptionKey: 'onboarding_intentions_desc',
    imagePath: 'assets/onboarding/intention page.png',
  ),
  const OnboardingPageData(
    titleKey: 'onboarding_priest_title',
    descriptionKey: 'onboarding_priest_desc',
    imagePath: 'assets/onboarding/adopt_priest.png',
  ),
];

class OnboardingModifiedNew extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingModifiedNew({super.key, this.onComplete});

  @override
  State<OnboardingModifiedNew> createState() => _OnboardingModifiedNewState();
}

class _OnboardingModifiedNewState extends State<OnboardingModifiedNew> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _complete() {
    widget.onComplete?.call();
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _complete();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF352458);
    final descColor = isDark ? Colors.grey.shade300 : const Color(0xFF4A4A4A);
    final primaryPurple = const Color(0xFF352458);

    return Scaffold(
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF4A4080),
                    Color(0xFF2A1F5E),
                    Color(0xFF100828),
                  ],
                  stops: [0.0, 0.50, 1.0],
                ),
              )
            : const BoxDecoration(color: Color(0xFFF0EBF0)),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Column(
                  children: [
                    // Top Curved Image Section
                    Expanded(
                      flex: 65,
                      child: ClipPath(
                        clipper: _BottomCurveClipper(),
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            page.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom Text Section
                    Expanded(
                      flex: 35,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                        child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            page.getTitle(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.getDescription(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              color: descColor,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: GestureDetector(
              onTap: _complete,
              child: Text(
                loc.tr('onboarding_skip'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Controls
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots Indicator
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? primaryPurple 
                            : primaryPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Next / Get Started Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == _pages.length - 1 ? 140 : 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _nextPage,
                      child: Center(
                        child: _currentPage == _pages.length - 1
                            ? Text(
                                loc.tr('onboarding_get_started'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Start at top-left
    path.lineTo(0, size.height - 70); 
    // Quadratic bezier curve to bottom-center and up to top-right
    path.quadraticBezierTo(
      size.width / 2, 
      size.height + 40, 
      size.width, 
      size.height - 70,
    );
    // Line to top-right
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
