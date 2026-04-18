import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF3B1F7A),
      body: Stack(
        children: [
          // Main centered content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // UR Logo
                  Image.asset(
                    'assets/splash/ur_logo.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 28),
                  // App name
                  const Text(
                    'Upper Room',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tagline
                  Text(
                    'One Prayer One Mission',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.80),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom crowd silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Opacity(
                opacity: _fadeAnimation.value * 0.35,
                child: child,
              ),
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120),
                painter: _CrowdPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrowdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.fill;

    // Draw a row of simple person silhouettes
    final double personWidth = size.width / 14;
    for (int i = 0; i < 14; i++) {
      final double cx = personWidth * i + personWidth / 2;
      final double baseY = size.height;
      final double heightVariation = (i % 3 == 0) ? 0.0 : (i % 3 == 1 ? 8.0 : -5.0);
      final double bodyH = 55 + heightVariation;
      final double headR = 7.0;

      // Head
      canvas.drawCircle(Offset(cx, baseY - bodyH - headR), headR, paint);

      // Body
      final path = Path();
      path.moveTo(cx - 8, baseY - bodyH);
      path.lineTo(cx + 8, baseY - bodyH);
      path.lineTo(cx + 12, baseY);
      path.lineTo(cx - 12, baseY);
      path.close();
      canvas.drawPath(path, paint);

      // Arms
      canvas.drawLine(
        Offset(cx - 8, baseY - bodyH + 10),
        Offset(cx - 18, baseY - bodyH + 28),
        paint..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(cx + 8, baseY - bodyH + 10),
        Offset(cx + 18, baseY - bodyH + 28),
        paint..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(_CrowdPainter oldDelegate) => false;
}
