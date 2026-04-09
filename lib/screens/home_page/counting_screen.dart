import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../colors/colors.dart';

class CountingScreen extends StatefulWidget {
  final String userEmail;

  const CountingScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  final TextEditingController _noteController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _incrementController;
  late AnimationController _decrementController;
  late AnimationController _quoteController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _incrementScaleAnim;
  late Animation<double> _decrementScaleAnim;
  late Animation<double> _quoteFadeAnim;

  final List<Map<String, String>> _quotes = [
    {
      'text': 'Christ became obedient to the point of death, even death on a cross.',
      'reference': 'Philippians 2:8',
    },
    {
      'text': 'For God so loved the world that he gave his one and only Son.',
      'reference': 'John 3:16',
    },
    {
      'text': 'I have told you all this, so that you may have peace by being united with me.',
      'reference': 'John 16:33',
    },
    {
      'text': 'Ask and it will be given to you; seek and you will find.',
      'reference': 'Matthew 7:7',
    },
    {
      'text': 'The Lord is my shepherd; I shall not want.',
      'reference': 'Psalm 23:1',
    },
  ];

  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

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

    _quoteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _quoteFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeInOut),
    );
    _quoteController.forward();

    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _nextQuote();
    });
  }

  void _nextQuote() {
    _quoteController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
      _quoteController.forward();
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _pulseController.dispose();
    _incrementController.dispose();
    _decrementController.dispose();
    _quoteController.dispose();
    _noteController.dispose();
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
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        content: const Text(
          'Are you sure you want to go back (decrease) the count?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greyButton,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _decrementController.forward().then((_) => _decrementController.reverse());
              setState(() => _count--);
            },
            child: const Text('Go Back', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _save() {
    HapticFeedback.selectionClick();
    final noteText = _noteController.text.trim();
    final msg = noteText.isEmpty
        ? 'Count $_count saved successfully!'
        : 'Count $_count for "$noteText" saved!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _count = 0;
          _noteController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildQuoteCard(),
                const SizedBox(height: 32),
                _buildCountCard(),
                const SizedBox(height: 36),
                _buildCountButtons(),
                const SizedBox(height: 32),
                _buildNoteInput(),
                const SizedBox(height: 20),
                _buildSaveButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ROSARY BANK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: AppColors.goldDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.plumMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'Count',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        // Bead icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardWhite,
            border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.plumMid.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.circle_outlined, color: AppColors.goldPrimary, size: 24),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    final quote = _quotes[_currentQuoteIndex];
    return FadeTransition(
      opacity: _quoteFadeAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(color: AppColors.plumMid.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6)),
            BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 10, spreadRadius: -2, offset: const Offset(-2, -2)),
          ],
        ),
        child: Column(
          children: [
            // ornament
            Text(
              '\u275D',
              style: TextStyle(fontSize: 26, color: AppColors.goldPrimary.withOpacity(0.55), height: 1.0),
            ),
            const SizedBox(height: 10),
            Text(
              quote['text']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary.withOpacity(0.85),
                fontStyle: FontStyle.italic,
                height: 1.65,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quote['reference']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.goldDark,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            // dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_quotes.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == _currentQuoteIndex ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _currentQuoteIndex
                        ? AppColors.goldPrimary
                        : AppColors.goldPrimary.withOpacity(0.25),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cardWhite,
          boxShadow: [
            BoxShadow(color: AppColors.plumMid.withOpacity(0.18), blurRadius: 36, spreadRadius: 4, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 16, spreadRadius: -4, offset: const Offset(-4, -4)),
          ],
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 2.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_count',
              style: const TextStyle(
                fontSize: 68,
                fontWeight: FontWeight.w900,
                color: AppColors.plumDeep,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.goldPrimary, AppColors.goldLight]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'rosary counted',
              style: TextStyle(
                fontSize: 11,
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
        AnimatedBuilder(
          animation: _decrementScaleAnim,
          builder: (context, child) => Transform.scale(scale: _decrementScaleAnim.value, child: child),
          child: _CircleActionButton(
            onTap: _decrement,
            color: AppColors.greyButton,
            darkColor: AppColors.greyDark,
            icon: Icons.remove_rounded,
            size: 76,
            iconSize: 36,
          ),
        ),
        const SizedBox(width: 44),
        AnimatedBuilder(
          animation: _incrementScaleAnim,
          builder: (context, child) => Transform.scale(scale: _incrementScaleAnim.value, child: child),
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

  Widget _buildNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.plumMid.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _noteController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Add your intentions...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.45), fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.goldPrimary, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
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
            BoxShadow(color: AppColors.saveGold.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
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
            BoxShadow(color: darkColor.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 7)),
            BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 6, offset: const Offset(-2, -2)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
