import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../../login_and_register/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();

    // Navigate to Login after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyMid, AppColors.skyBottom],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Golden cross icon with glowing halo ──
              _buildLargeLogo(),

              const SizedBox(height: 32),

              // ── App Name ──
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'Conta Beads',
                  style: TextStyle(
                    fontSize: 44,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    height: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Tagline ──
              Text(
                'PRAY · COUNT · REJOICE',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 6.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 120),

              // ── Subtle Progress Indicator ──
              const SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppColors.goldPrimary,
                  minHeight: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFF8E7), Color(0xFFF5E8C0)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.25),
          width: 3.5,
        ),
      ),
      child: const Icon(
        Icons.add_rounded, // Using '+' as cross proxy; replace with custom SVG if available
        color: AppColors.goldPrimary,
        size: 84,
      ),
    );
  }
}
