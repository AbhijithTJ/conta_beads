import 'dart:ui';
import 'package:flutter/material.dart';
import '../../colors/colors.dart';

class IntentionSuccessScreen extends StatefulWidget {
  final String intention;

  const IntentionSuccessScreen({
    super.key,
    required this.intention,
  });

  @override
  State<IntentionSuccessScreen> createState() => _IntentionSuccessScreenState();
}

class _IntentionSuccessScreenState extends State<IntentionSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Orb float animations
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _orb4Controller;
  late Animation<double> _orb1Anim;
  late Animation<double> _orb2Anim;
  late Animation<double> _orb3Anim;
  late Animation<double> _orb4Anim;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _initOrbAnimations();
    
    // Animate badge in then start pulsing
    _animationController.forward().then((_) {
      if (mounted) {
        _animationController.repeat(reverse: true);
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _initOrbAnimations() {
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat(reverse: true);
    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    )..repeat(reverse: true);
    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _orb4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7200),
    )..repeat(reverse: true);

    _orb1Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb1Controller, curve: Curves.easeInOut),
    );
    _orb2Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb2Controller, curve: Curves.easeInOut),
    );
    _orb3Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb3Controller, curve: Curves.easeInOut),
    );
    _orb4Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb4Controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _orb4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.authBgTop,
              AppColors.authBgMid,
              AppColors.authBgBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Animated floating orbs ──
            _buildOrbs(size),

            // ── Content ──
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildSuccessBadge(),
                      ),
                      const SizedBox(height: 48),
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Column(
                          children: [
                            const Text(
                              'Intention Received',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your prayer intention has been shared\nwith our community in faith.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildIntentionCard(),
                            const SizedBox(height: 32),
                            _buildBlessingBadge(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbs(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orb1Anim, _orb2Anim, _orb3Anim, _orb4Anim]),
      builder: (context, _) {
        return Stack(
          children: [
            _Orb(
              left: size.width * 0.2,
              top: -size.height * 0.08 + _orb1Anim.value * 28,
              size: size.width * 0.72,
              colors: [
                AppColors.authPurple.withOpacity(0.55),
                AppColors.authBgTop.withOpacity(0.30),
              ],
            ),
            _Orb(
              left: -size.width * 0.22,
              top: size.height * 0.28 + _orb2Anim.value * -22,
              size: size.width * 0.65,
              colors: [
                AppColors.authPurpleLight.withOpacity(0.45),
                AppColors.authPurple.withOpacity(0.25),
              ],
            ),
            _Orb(
              left: size.width * 0.55,
              top: size.height * 0.38 + _orb3Anim.value * 18,
              size: size.width * 0.60,
              colors: [
                AppColors.authBgMid.withOpacity(0.70),
                AppColors.authBgBottom.withOpacity(0.40),
              ],
            ),
            _Orb(
              left: size.width * 0.1,
              top: size.height * 0.72 + _orb4Anim.value * -16,
              size: size.width * 0.55,
              colors: [
                AppColors.goldPrimary.withOpacity(0.18),
                AppColors.authPurple.withOpacity(0.25),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuccessBadge() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Divine Halo (Pulse)
            Container(
              width: 140 * (1.0 + (_animationController.value * 0.2)),
              height: 140 * (1.0 + (_animationController.value * 0.2)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldPrimary.withOpacity(0.15 * (1 - _animationController.value)),
              ),
            ),
            
            // Main Premium Badge
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.volunteer_activism_rounded, // Praying Hands with Heart
                      size: 85,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntentionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'YOUR INTENTION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.authBgMid.withOpacity(0.5),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.intention,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.authBgBottom,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlessingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.authPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🙏', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            'May God bless your intention',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.authLavender,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Orb Widget ───────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final List<Color> colors;

  const _Orb({
    required this.left,
    required this.top,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 0.85,
            colors: colors,
            stops: const [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.25),
              blurRadius: size * 0.35,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
