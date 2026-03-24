import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';
import '../../dialog_box/logout_alert_dialog.dart';
import '../../login_and_register/login_screen.dart';
import '../profile/profile_screen.dart';


void main() {
  runApp(const ContaBeadsApp());
}

class ContaBeadsApp extends StatelessWidget {
  const ContaBeadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conta Beads',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const CountingScreen(userEmail: 'guest@example.com'),
    );
  }
}

class CountingScreen extends StatefulWidget {
  final String userEmail;
  const CountingScreen({super.key, required this.userEmail});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  late AnimationController _pulseController;
  late AnimationController _incrementController;
  late AnimationController _decrementController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _incrementScaleAnim;
  late Animation<double> _decrementScaleAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _incrementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _decrementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _incrementScaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _incrementController, curve: Curves.easeOut),
    );
    _decrementScaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _decrementController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _incrementController.dispose();
    _decrementController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _incrementController.forward().then((_) => _incrementController.reverse());
    setState(() => _count++);
  }

  void _decrement() {
    if (_count == 0) return;

    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardWhite,
        title: const Text(
          'Decrease Count',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to go back (decrease) the count?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greyButton,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _decrementController
                  .forward()
                  .then((_) => _decrementController.reverse());
              setState(() => _count--);
            },
            child: const Text('Go Back', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardWhite,
        title: const Text(
          'Reset Count',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to reset the count to zero?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _count = 0);
            },
            child: const Text('Reset', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    HapticFeedback.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LogoutAlertDialog(),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _save() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Count $_count saved successfully!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.goldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
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
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main content ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    
                    // User Profile Section
                    _buildProfileEntry(),
                    
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 10),
                    Text(
                      'Prayer Counter',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 44),
                    _buildCountCard(),
                    const SizedBox(height: 48),
                    _buildCountButtons(),
                    const Spacer(),
                    _buildBottomActions(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ── Logout button pinned top-right ──
              Positioned(
                top: 12,
                right: 16,
                child: GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileEntry() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProfileScreen(userEmail: widget.userEmail)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.goldPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.userEmail,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Golden cross icon with halo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [AppColors.haloLight, AppColors.haloDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.add, // Using '+' as cross proxy; replace with custom SVG if available
            color: AppColors.goldPrimary,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Conta Beads',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.2,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.goldPrimary.withOpacity(0.20),
              blurRadius: 36,
              spreadRadius: 4,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 16,
              spreadRadius: -4,
              offset: const Offset(-4, -4),
            ),
          ],
          border: Border.all(
            color: AppColors.goldPrimary.withOpacity(0.25),
            width: 2.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_count',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldLight]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'beads counted',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decrement (−)
        AnimatedBuilder(
          animation: _decrementScaleAnim,
          builder: (context, child) =>
              Transform.scale(scale: _decrementScaleAnim.value, child: child),
          child: _CircleActionButton(
            onTap: _decrement,
            color: AppColors.greyButton,
            darkColor: AppColors.greyDark,
            icon: Icons.remove_rounded,
            size: 80,
            iconSize: 38,
          ),
        ),

        const SizedBox(width: 40),

        // Increment (+)
        AnimatedBuilder(
          animation: _incrementScaleAnim,
          builder: (context, child) =>
              Transform.scale(scale: _incrementScaleAnim.value, child: child),
          child: _CircleActionButton(
            onTap: _increment,
            color: AppColors.greenButton,
            darkColor: AppColors.greenDark,
            icon: Icons.add_rounded,
            size: 88,
            iconSize: 44,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        // Reset
        Expanded(
          child: GestureDetector(
            onTap: _reset,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.resetGrey,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.resetGreyDark.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Save
        Expanded(
          child: GestureDetector(
            onTap: _save,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.saveGold, AppColors.goldAccentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saveGold.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable circular action button ──────────────────────────────────────────
class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.onTap,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  final VoidCallback onTap;
  final Color color;
  final Color darkColor;
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, darkColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: darkColor.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}