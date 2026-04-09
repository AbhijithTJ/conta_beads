import 'package:flutter/material.dart';
import 'dart:math';
import '../../colors/colors.dart';
import '../../login_and_register/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class Snowflake {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;
  late double angle;

  Snowflake({required double screenWidth, required double screenHeight}) {
    x = Random().nextDouble() * screenWidth;
    y = Random().nextDouble() * screenHeight - screenHeight;
    size = Random().nextDouble() * 4 + 2;
    speed = Random().nextDouble() * 3 + 2;
    opacity = Random().nextDouble() * 0.8 + 0.4;
    angle = Random().nextDouble() * 2 * pi;
  }

  void update(double screenHeight, double screenWidth) {
    y += speed;
    x += sin(angle) * 1.5;
    angle += 0.02;
    
    if (y > screenHeight) {
      y = -10;
      x = Random().nextDouble() * screenWidth;
    }
    if (x < -10) {
      x = screenWidth + 10;
    }
    if (x > screenWidth + 10) {
      x = -10;
    }
  }
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _snowController;
  late AnimationController _prayController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _prayAnimation;
  late List<Snowflake> snowflakes = [];

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
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _prayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _prayAnimation = Tween<double>(begin: 0.06, end: 0.14).animate(
      CurvedAnimation(parent: _prayController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();

    // Initialize snowflakes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 80; i++) {
        snowflakes.add(Snowflake(screenWidth: size.width, screenHeight: size.height));
      }
      _snowController.addListener(() {
        setState(() {
          for (var snowflake in snowflakes) {
            snowflake.update(size.height, size.width);
          }
        });
      });
    });

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
    _slideController.dispose();
    _snowController.dispose();
    _prayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgTop,    // soft lavender-white
              AppColors.bgMid,    // light mauve
              AppColors.bgBottom, // dusty lavender
            ],
          ),
        ),
        child: Stack(
          children: [
            // Snowflakes background
            CustomPaint(
              painter: SnowPainter(snowflakes),
              size: Size.infinite,
            ),

            // Praying hands background decoration
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _prayAnimation,
                builder: (context, child) => Opacity(
                  opacity: _prayAnimation.value,
                  child: child,
                ),
                child: const Center(
                  child: Text(
                    '🙏',
                    style: TextStyle(fontSize: 280),
                  ),
                ),
              ),
            ),
            
            // Main content - centered
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _scaleAnimation, _slideAnimation]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rounded logo image with shadow
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.goldPrimary.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/splash/upper_room.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Premium app name
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFD4A843), // gold
                            Color(0xFF9B6B8A), // mauve
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Upper Room',
                          style: TextStyle(
                            fontSize: 44,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Tagline
                      Text(
                        'Every bead of the rosary counts.',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Decorative line
                      Container(
                        width: 50,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.goldPrimary,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom loading indicator
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.goldPrimary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.goldPrimary.withOpacity(0.8),
                        ),
                        minHeight: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontFamily: 'Georgia',
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

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var snowflake in snowflakes) {
      // Draw petal particle as a circle
      paint.color = Color.fromARGB(
        (snowflake.opacity * 180).toInt(),
        212, // dusty rose R
        160, // dusty rose G
        160, // dusty rose B
      );
      
      canvas.drawCircle(
        Offset(snowflake.x, snowflake.y),
        snowflake.size,
        paint,
      );
      
      // Add subtle glow
      paint.color = Color.fromARGB(
        ((snowflake.opacity * 0.25) * 255).toInt(),
        155, // mauve R
        107, // mauve G
        138, // mauve B
      );
      canvas.drawCircle(
        Offset(snowflake.x, snowflake.y),
        snowflake.size * 1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}
