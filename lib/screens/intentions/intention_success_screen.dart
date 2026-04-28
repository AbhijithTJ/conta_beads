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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 0.85,
            colors: [
              Color(0xFF321060),
              Color(0xFF220850),
              Color(0xFF1c023d),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
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
                        const SizedBox(height: 40),
                        _buildIntentionCard(),
                        const SizedBox(height: 40),
                        const Text(
                          '🙏',
                          style: TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                color: AppColors.chapletAccent.withOpacity(0.2 * (1 - _animationController.value)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Text(
        widget.intention,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          height: 1.4,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
