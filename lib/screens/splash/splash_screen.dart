import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';
import '../../login_and_register/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bgColor = isDark ? AppColors.homeBg : const Color(0xFFF0EBF0);
    final logoAsset = isDark ? 'assets/splash/ur_logo.png' : 'assets/splash/ur_logo_light.png';
    final bottomAsset = isDark ? 'assets/splash/splash_bottom.png' : 'assets/splash/splash_bottom_light.png';
    final titleColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.80) : AppColors.authBgMid.withOpacity(0.6);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgColor),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(scale: _scaleAnimation.value, child: child),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(logoAsset, width: 160, height: 160),
                    Text('Upper Room',
                        style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Text('One Prayer One Mission',
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w400,
                            color: subColor,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value * 0.85,
                  child: child,
                ),
                child: Image.asset(
                  bottomAsset,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

