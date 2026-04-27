import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../colors/colors.dart';

class OnboardingPage {
  final String icon;
  final String title;
  final String description;
  final Color accentColor;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

const _pages = [
  OnboardingPage(
    icon: '📿',
    title: 'Welcome to Upper Room',
    description: 'A sacred space to count your rosaries and join a global community united in prayer.',
    accentColor: Color(0xFFD4A843),
  ),
  OnboardingPage(
    icon: '⛪',
    title: 'Count Your Rosary',
    description: 'Use the Home screen to count each rosary bead with the Rosary or Divine Mercy Chaplet. Tap to count, save when done.',
    accentColor: Color(0xFF9B6B8A),
  ),
  OnboardingPage(
    icon: '🌍',
    title: 'Global Community',
    description: 'See how many rosaries our community has offered together worldwide. Your prayers contribute to our collective goal.',
    accentColor: Color(0xFF7B3F6E),
  ),
  OnboardingPage(
    icon: '🙏',
    title: 'Share Your Intentions',
    description: 'Submit your personal prayer requests and share your spiritual intentions with the community.',
    accentColor: Color(0xFFD4A0A0),
  ),
  OnboardingPage(
    icon: '✝️',
    title: 'Adopt a Priest',
    description: 'Spiritually support a priest through prayer. Select up to three priests for a personal spiritual partnership.',
    accentColor: Color(0xFFB89AC8),
  ),
  OnboardingPage(
    icon: '📖',
    title: 'Everyday Prayers',
    description: 'Access the Divine Mercy Chaplet, Way of the Cross, Novenas, and daily guides — all in one place.',
    accentColor: Color(0xFFD4A843),
  ),
  OnboardingPage(
    icon: '👤',
    title: 'Your Profile',
    description: 'Track your personal prayer statistics, manage your account, and customise your experience.',
    accentColor: Color(0xFF9B6B8A),
  ),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;

  // Orb float
  late AnimationController _orb1Ctrl, _orb2Ctrl, _orb3Ctrl, _orb4Ctrl;
  late Animation<double> _orb1, _orb2, _orb3, _orb4;

  // Per-page content animation
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<double> _contentScale;

  // Icon bounce
  late AnimationController _iconCtrl;
  late Animation<double> _iconBounce;

  // Shimmer particles
  late AnimationController _shimmerCtrl;
  final List<_Particle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _orb1Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat(reverse: true);
    _orb2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5800))..repeat(reverse: true);
    _orb3Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);
    _orb4Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 6400))..repeat(reverse: true);

    _orb1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb1Ctrl, curve: Curves.easeInOut));
    _orb2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb2Ctrl, curve: Curves.easeInOut));
    _orb3 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb3Ctrl, curve: Curves.easeInOut));
    _orb4 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb4Ctrl, curve: Curves.easeInOut));

    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentScale = Tween<double>(begin: 0.88, end: 1.0).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutBack));
    _contentCtrl.forward();

    _iconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _iconBounce = Tween<double>(begin: -6, end: 6).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _shimmerCtrl.addListener(() {
      setState(() {
        for (final p in _particles) p.update();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = MediaQuery.of(context).size;
      for (int i = 0; i < 30; i++) {
        _particles.add(_Particle(s.width, s.height, _rng));
      }
    });
  }

  void _animateToPage(int page) {
    _contentCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentPage = page);
      _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _orb1Ctrl.dispose(); _orb2Ctrl.dispose(); _orb3Ctrl.dispose(); _orb4Ctrl.dispose();
    _contentCtrl.dispose();
    _iconCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final page = _pages[_currentPage];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF22014D),
              Color(0xFF3A0A6E),
              Color(0xFF22014D),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating orbs
            _buildOrbs(size),

            // Shimmer particles
            CustomPaint(painter: _ParticlePainter(_particles, page.accentColor), size: Size.infinite),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTopBar(),
                  Expanded(child: _buildPageContent(page, size)),
                  _buildBottomSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbs(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orb1, _orb2, _orb3, _orb4]),
      builder: (_, __) => Stack(children: [
        _OrbWidget(left: size.width * 0.2,  top: -size.height * 0.08 + _orb1.value * 28, size: size.width * 0.72,
          colors: [const Color(0xFF5A0A8A).withOpacity(0.50), const Color(0xFF22014D).withOpacity(0.30)]),
        _OrbWidget(left: -size.width * 0.22, top: size.height * 0.28 + _orb2.value * -22, size: size.width * 0.65,
          colors: [const Color(0xFF3A0A6E).withOpacity(0.55), const Color(0xFF22014D).withOpacity(0.25)]),
        _OrbWidget(left: size.width * 0.55,  top: size.height * 0.38 + _orb3.value * 18, size: size.width * 0.60,
          colors: [const Color(0xFF6B1A8A).withOpacity(0.45), const Color(0xFF22014D).withOpacity(0.20)]),
        _OrbWidget(left: size.width * 0.1,   top: size.height * 0.72 + _orb4.value * -16, size: size.width * 0.55,
          colors: [const Color(0xFFD4A843).withOpacity(0.15), const Color(0xFF3A0A6E).withOpacity(0.25)]),
      ]),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + name
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
                boxShadow: [BoxShadow(color: AppColors.goldPrimary.withOpacity(0.2), blurRadius: 8)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/splash/upper_room.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.plumMid],
              ).createShader(b),
              child: const Text('Upper Room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
            ),
          ]),
          // Skip
          if (_currentPage < _pages.length - 1)
            GestureDetector(
              onTap: _complete,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Text('Skip', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.70),
                    )),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page, Size size) {
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder: (_, child) => FadeTransition(
        opacity: _contentFade,
        child: Transform.scale(scale: _contentScale.value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon inside glass card
            AnimatedBuilder(
              animation: _iconBounce,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _iconBounce.value),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 130, height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: page.accentColor.withOpacity(0.45), blurRadius: 32, spreadRadius: 4),
                        ],
                      ),
                      child: Center(child: Text(page.icon, style: const TextStyle(fontSize: 64))),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Glass content card
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF22014D).withOpacity(0.40), blurRadius: 40, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Column(children: [
                    // Accent line
                    Container(
                      width: 40, height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(colors: [page.accentColor, page.accentColor.withOpacity(0.3)]),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800,
                        color: Colors.white, height: 1.3, letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.72), height: 1.65,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(children: [
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            final active = i == _currentPage;
            return GestureDetector(
              onTap: () => _animateToPage(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 28 : 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active ? AppColors.goldPrimary : AppColors.goldPrimary.withOpacity(0.28),
                  boxShadow: active ? [BoxShadow(color: AppColors.goldPrimary.withOpacity(0.5), blurRadius: 6)] : [],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Buttons row
        Row(children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: GestureDetector(
                    onTap: () => _animateToPage(_currentPage - 1),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.45), width: 1.5),
                      ),
                      child: const Center(child: Text('Back',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.goldDark))),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentPage == _pages.length - 1) {
                  _complete();
                } else {
                  _animateToPage(_currentPage + 1);
                }
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldAccent, AppColors.goldAccentDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.goldAccent.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 6))],
                  border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                ),
                child: Center(child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                )),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Floating orb widget ───────────────────────────────────────────────────────
class _OrbWidget extends StatelessWidget {
  final double left, top, size;
  final List<Color> colors;
  const _OrbWidget({required this.left, required this.top, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left, top: top,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3), radius: 0.85,
            colors: colors, stops: const [0.0, 1.0],
          ),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.25), blurRadius: size * 0.35, spreadRadius: size * 0.05)],
        ),
      ),
    );
  }
}

// ── Shimmer particle ──────────────────────────────────────────────────────────
class _Particle {
  double x, y, size, speed, opacity, angle;
  final double maxW, maxH;
  final Random rng;

  _Particle(this.maxW, this.maxH, this.rng)
      : x = rng.nextDouble() * maxW,
        y = rng.nextDouble() * maxH,
        size = rng.nextDouble() * 3 + 1,
        speed = rng.nextDouble() * 0.6 + 0.2,
        opacity = rng.nextDouble() * 0.35 + 0.1,
        angle = rng.nextDouble() * 2 * pi;

  void update() {
    y -= speed;
    x += sin(angle) * 0.5;
    angle += 0.01;
    if (y < -10) { y = maxH + 10; x = rng.nextDouble() * maxW; }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color accent;
  _ParticlePainter(this.particles, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = accent.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
