import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../colors/colors.dart';
import '../../services/localization_service.dart';

class CountingScreen extends StatefulWidget {
  final String userEmail;
  final bool startWithChaplet;

  const CountingScreen({
    super.key,
    required this.userEmail,
    this.startWithChaplet = false,
  });

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  int _chapletCount = 0;
  bool _isRosary = true;

  int get _activeCount => _isRosary ? _count : _chapletCount;

  // Rosary palette
  static const _rosaryBgTop    = AppColors.authBgTop;
  static const _rosaryBgMid    = AppColors.authBgMid;
  static const _rosaryBgBottom = AppColors.authBgBottom;
  static const _rosaryAccent   = AppColors.authPurpleLight;
  static const _rosaryDark     = AppColors.authPurple;

  // Chaplet palette — deep teal/indigo
  static const _chapletBgTop    = AppColors.chapletBgTop;
  static const _chapletBgMid    = AppColors.chapletBgMid;
  static const _chapletBgBottom = AppColors.chapletBgBottom;
  static const _chapletAccent   = AppColors.chapletAccent;
  static const _chapletDark     = AppColors.chapletDark;

  Color get _bgTop    => _isRosary ? _rosaryBgTop    : _chapletBgTop;
  Color get _bgMid    => _isRosary ? _rosaryBgMid    : _chapletBgMid;
  Color get _bgBottom => _isRosary ? _rosaryBgBottom : _chapletBgBottom;
  Color get _accent   => _isRosary ? _rosaryAccent   : _chapletAccent;
  Color get _dark     => _isRosary ? _rosaryDark     : _chapletDark;
  final TextEditingController _noteController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _incrementController;
  late AnimationController _decrementController;
  late AnimationController _quoteController;
  late AnimationController _ripple1Controller;
  late AnimationController _ripple2Controller;
  late AnimationController _ripple3Controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _incrementScaleAnim;
  late Animation<double> _decrementScaleAnim;
  late Animation<double> _quoteFadeAnim;
  late Animation<double> _ripple1Anim;
  late Animation<double> _ripple2Anim;
  late Animation<double> _ripple3Anim;

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
    _isRosary = !widget.startWithChaplet;

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

    // ripple rings — each 900ms, staggered
    _ripple1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ripple2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ripple3Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _ripple1Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ripple1Controller, curve: Curves.easeOut),
    );
    _ripple2Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ripple2Controller, curve: Curves.easeOut),
    );
    _ripple3Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ripple3Controller, curve: Curves.easeOut),
    );

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
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _ripple3Controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _incrementController.forward().then((_) => _incrementController.reverse());
    // fire ripple rings staggered
    _ripple1Controller.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 150), () { if (mounted) _ripple2Controller.forward(from: 0); });
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ripple3Controller.forward(from: 0); });
    setState(() => _isRosary ? _count++ : _chapletCount++);
  }

  void _decrement() {
    if (_activeCount == 0) return;
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardWhite,
        title: Text(
          loc.tr('decrease_count'),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        content: Text(
          loc.tr('decrease_confirm'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
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
              setState(() => _isRosary ? _count-- : _chapletCount--);
            },
            child: Text(loc.tr('go_back'), style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _save() {
    HapticFeedback.selectionClick();
    final noteText = _noteController.text.trim();
    final msg = noteText.isEmpty
        ? loc.tr('count_saved', args: {'count': '$_activeCount'})
        : loc.tr('count_saved_note', args: {'count': '$_activeCount', 'note': noteText});

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
          if (_isRosary) _count = 0; else _chapletCount = 0;
          _noteController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgMid, _bgBottom],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Static orb bubbles ──
            _Orb(left: size.width * 0.2, top: -size.height * 0.08, size: size.width * 0.72,
              colors: [_dark.withOpacity(0.55), _bgTop.withOpacity(0.30)]),
            _Orb(left: -size.width * 0.22, top: size.height * 0.28, size: size.width * 0.65,
              colors: [_accent.withOpacity(0.45), _dark.withOpacity(0.25)]),
            _Orb(left: size.width * 0.55, top: size.height * 0.38, size: size.width * 0.60,
              colors: [_bgMid.withOpacity(0.70), _bgBottom.withOpacity(0.40)]),
            _Orb(left: size.width * 0.1, top: size.height * 0.72, size: size.width * 0.55,
              colors: [_accent.withOpacity(0.20), _dark.withOpacity(0.25)]),
            // ── Content ──
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildQuoteCard(),
                    const SizedBox(height: 24),
                    _buildModeToggle(),
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
          ],
        ),
      ),
    );
  }

  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'ML', 'name': 'Malayalam'},
    {'code': 'HI', 'name': 'Hindi'},
    {'code': 'TA', 'name': 'Tamil'},
    {'code': 'LA', 'name': 'Latin'},
  ];

  void _showLanguagePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.authBgMid,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.3), width: 1.5),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.authPurpleLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.language_rounded, color: AppColors.authPurpleLight, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      loc.tr('select_language'),
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _languages.map((lang) {
                        final isSelected = lang['name'] == _selectedLanguage;
                        return GestureDetector(
                          onTap: () async {
                            await loc.load(lang['name']!);
                            setState(() => _selectedLanguage = lang['name']!);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.authPurpleLight.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.authPurpleLight.withOpacity(0.5) : AppColors.authPurpleLight.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.authPurpleLight.withOpacity(0.20) : AppColors.authBgTop.withOpacity(0.3),
                                    border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      lang['code']!,
                                      style: TextStyle(
                                        fontSize: 10, fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.white : AppColors.authLavender,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    lang['name']!,
                                    style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.70),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_rounded, color: AppColors.authPurpleLight, size: 20),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _toggleTab('Rosary', true),
          _toggleTab('Chaplet', false),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool isRosary) {
    final selected = _isRosary == isRosary;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isRosary = isRosary),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.authBgMid : Colors.white.withOpacity(0.55),
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
        // Logo + name
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.45), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.authPurple.withOpacity(0.25), blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/splash/ur_logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Upper Room',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        // Language selector
        GestureDetector(
          onTap: _showLanguagePicker,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.authBgMid,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppColors.authBgBottom.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, color: AppColors.authPurpleLight, size: 16),
                const SizedBox(width: 6),
                Text(
                  _selectedLanguage,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.authPurpleLight.withOpacity(0.7), size: 16),
              ],
            ),
          ),
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
        height: 160,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _accent.withOpacity(0.30), width: 1.5),
          boxShadow: [
            BoxShadow(color: _bgBottom.withOpacity(0.20), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ornament
            Text(
              '\u275D',
              style: TextStyle(fontSize: 20, color: _accent.withOpacity(0.70), height: 1.0),
            ),
            const SizedBox(height: 6),
            Text(
              quote['text']!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.90),
                fontStyle: FontStyle.italic,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote['reference']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
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
                        ? _accent
                        : _accent.withOpacity(0.30),
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
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ripple ring 1
          _RippleRing(animation: _ripple1Anim, baseSize: 210, color: _accent),
          // ripple ring 2
          _RippleRing(animation: _ripple2Anim, baseSize: 210, color: _accent),
          // ripple ring 3
          _RippleRing(animation: _ripple3Anim, baseSize: 210, color: _accent),
          // main orb
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(color: _bgBottom.withOpacity(0.35), blurRadius: 36, spreadRadius: 4, offset: const Offset(0, 8)),
                  BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 16, spreadRadius: -4, offset: const Offset(-4, -4)),
                ],
                border: Border.all(color: _accent.withOpacity(0.45), width: 2.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_activeCount',
                    style: const TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_accent, _dark]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRosary ? loc.tr('rosary_counted') : 'Chaplet Counted',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.65),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(color: _bgBottom.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _noteController,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: loc.tr('add_intentions'),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.edit_note_rounded, color: _accent, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _accent, width: 1.5),
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
          gradient: LinearGradient(
            colors: [_accent, _dark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: _bgBottom.withOpacity(0.60), blurRadius: 0, offset: const Offset(0, 5)),
            BoxShadow(color: _dark.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              loc.tr('save'),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ripple ring (water-drop effect) ──────────────────────────────────────────
class _RippleRing extends StatelessWidget {
  const _RippleRing({required this.animation, required this.baseSize, required this.color});

  final Animation<double> animation;
  final double baseSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final scale = 1.0 + animation.value * 0.55;
        final opacity = (1.0 - animation.value).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(opacity * 0.7),
                width: 2.5 * (1.0 - animation.value * 0.6),
              ),
            ),
          ),
        );
      },
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

// ── Orb bubble widget ─────────────────────────────────────────────────────────
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
