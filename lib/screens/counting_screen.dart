import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

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
      home: const CountingScreen(),
    );
  }
}

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen>
    with TickerProviderStateMixin {
  int _count = 150;
  late AnimationController _pulseController;
  late AnimationController _incrementController;
  late AnimationController _decrementController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _incrementScaleAnim;
  late Animation<double> _decrementScaleAnim;

  // Color constants
  static const Color _goldPrimary = Color(0xFFD4A843);
  static const Color _goldLight = Color(0xFFF0C96A);
  static const Color _goldDark = Color(0xFFB8902E);
  static const Color _skyTop = Color(0xFFDCEEFB);
  static const Color _skyBottom = Color(0xFFB8D9F5);
  static const Color _skyMid = Color(0xFFC8E3F8);
  static const Color _greenButton = Color(0xFF4CAF82);
  static const Color _greenDark = Color(0xFF3A9669);
  static const Color _greyButton = Color(0xFF8FA3B1);
  static const Color _greyDark = Color(0xFF6B8291);
  static const Color _textPrimary = Color(0xFF1A3A5C);
  static const Color _textSecondary = Color(0xFF4A6FA5);
  static const Color _cardWhite = Color(0xFFF5FAFF);
  static const Color _saveGold = Color(0xFFE8A020);
  static const Color _saveDark = Color(0xFFC8880A);
  static const Color _resetGrey = Color(0xFFDDE8F0);
  static const Color _resetGreyDark = Color(0xFFC0D0DC);

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
    HapticFeedback.lightImpact();
    _decrementController.forward().then((_) => _decrementController.reverse());
    if (_count > 0) setState(() => _count--);
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _cardWhite,
        title: const Text(
          'Reset Count',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to reset the count to zero?',
          style: TextStyle(color: _textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: _textSecondary, fontSize: 15)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldPrimary,
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
        backgroundColor: _goldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_skyTop, _skyMid, _skyBottom],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const SizedBox(height: 36),

                // ── Header ──
                _buildHeader(),

                const SizedBox(height: 10),

                // ── Subtitle ──
                Text(
                  'Prayer Counter',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 44),

                // ── Count Card ──
                _buildCountCard(),

                const SizedBox(height: 48),

                // ── +/- Buttons ──
                _buildCountButtons(),

                const Spacer(),

                // ── Bottom Actions ──
                _buildBottomActions(),

                const SizedBox(height: 32),
              ],
            ),
          ),
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
              colors: [Color(0xFFFFF8E7), Color(0xFFF5E8C0)],
            ),
            boxShadow: [
              BoxShadow(
                color: _goldPrimary.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.add, // Using '+' as cross proxy; replace with custom SVG if available
            color: _goldPrimary,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_goldDark, _goldPrimary, _goldLight],
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
          color: _cardWhite,
          boxShadow: [
            BoxShadow(
              color: _goldPrimary.withOpacity(0.20),
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
            color: _goldPrimary.withOpacity(0.25),
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
                color: _textPrimary,
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
                    colors: [_goldPrimary, _goldLight]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'beads counted',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _textSecondary.withOpacity(0.7),
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
            color: _greyButton,
            darkColor: _greyDark,
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
            color: _greenButton,
            darkColor: _greenDark,
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
                color: _resetGrey,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _resetGreyDark.withOpacity(0.5),
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
                  Icon(Icons.refresh_rounded, color: _textSecondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Reset',
                    style: TextStyle(
                      color: _textSecondary,
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
                  colors: [_saveGold, Color(0xFFD4780A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _saveGold.withOpacity(0.45),
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