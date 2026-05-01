import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../services/localization_service.dart';
import '../../theme/theme_notifier.dart';
import '../../widgets/global_count_panel.dart';

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

  // Rosary palette — resolved at build time via themeNotifier
  Color get _rosaryBgTop    => const Color(0xFF22014D);
  Color get _rosaryBgMid    => const Color(0xFF22014D);
  Color get _rosaryBgBottom => const Color(0xFF22014D);
  static const _rosaryAccent = Color(0xFFC9A8F5);
  static const _rosaryDark   = Color(0xFF6B3FA0);

  // Chaplet palette — same as Rosary
  static const _chapletBgTop    = Color(0xFF22014D);
  static const _chapletBgMid    = Color(0xFF22014D);
  static const _chapletBgBottom = Color(0xFF22014D);
  static const _chapletAccent   = Color(0xFFC9A8F5);
  static const _chapletDark     = Color(0xFF6B3FA0);

  Color get _bgTop    => _isRosary ? _rosaryBgTop    : _chapletBgTop;
  Color get _bgMid    => _isRosary ? _rosaryBgMid    : _chapletBgMid;
  Color get _bgBottom => _isRosary ? _rosaryBgBottom : _chapletBgBottom;
  Color get _accent   => _isRosary ? _rosaryAccent   : _chapletAccent;
  Color get _dark     => _isRosary ? _rosaryDark     : _chapletDark;
  final TextEditingController _noteController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _incrementController;
  late AnimationController _decrementController;
  late AnimationController _ripple1Controller;
  late AnimationController _ripple2Controller;
  late AnimationController _ripple3Controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _incrementScaleAnim;
  late Animation<double> _decrementScaleAnim;
  late Animation<double> _ripple1Anim;
  late Animation<double> _ripple2Anim;
  late Animation<double> _ripple3Anim;

  // ── Floating global-count button state ──
  Offset _fabPosition = const Offset(20, 200);
  bool _showGlobalPanel = false;
  late List<Map<String, dynamic>> _leaderboardData;
  Timer? _leaderboardTimer;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  final _random = Random();

  // Prayer text for the scrollable box
  static const String _rosaryPrayer =
      'The Apostles\' Creed\n\nI believe in God, the Father Almighty, Creator of Heaven and earth; and in Jesus Christ, His only Son, Our Lord, Who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died, and was buried. He descended into Hell; the third day He rose again from the dead; He ascended into Heaven, and sitteth at the right hand of God, the Father Almighty; from thence He shall come to judge the living and the dead.\n\nI believe in the Holy Spirit, the holy Catholic Church, the communion of saints, the forgiveness of sins, the resurrection of the body, and life everlasting. Amen.\n\nOur Father\n\nOur Father, Who art in heaven, hallowed be Thy name; Thy kingdom come; Thy will be done on earth as it is in heaven. Give us this day our daily bread; and forgive us our trespasses as we forgive those who trespass against us; and lead us not into temptation, but deliver us from evil. Amen.\n\nHail Mary\n\nHail Mary, full of grace, the Lord is with thee; blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.\n\nGlory Be\n\nGlory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen.';

  static const String _chapletPrayer =
      'Divine Mercy Chaplet\n\nBegin with:\nOur Father, Hail Mary, and The Apostles\' Creed.\n\nOn the Our Father beads say:\n"Eternal Father, I offer You the Body and Blood, Soul and Divinity of Your dearly beloved Son, Our Lord Jesus Christ, in atonement for our sins and those of the whole world."\n\nOn the Hail Mary beads say:\n"For the sake of His sorrowful Passion, have mercy on us and on the whole world."\n\nRepeat for all five decades.\n\nConclude with (3 times):\n"Holy God, Holy Mighty One, Holy Immortal One, have mercy on us and on the whole world."';

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

    // ── Floating leaderboard ──
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _leaderboardData = [
      {'name': 'Emma',    'count': 56, 'isYou': false},
      {'name': 'Rachel',  'count': 42, 'isYou': false},
      {'name': 'James T.','count': 38, 'isYou': false},
      {'name': 'You',     'count': 245,'isYou': true},
    ];

    _leaderboardTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        final nonYou = _leaderboardData.where((e) => !(e['isYou'] as bool)).toList();
        if (nonYou.isNotEmpty) {
          final pick = nonYou[_random.nextInt(nonYou.length)];
          pick['count'] = (pick['count'] as int) + _random.nextInt(3) + 1;
        }
        _leaderboardData.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      });
    });

  }

  @override
  void dispose() {
    _pulseController.dispose();
    _incrementController.dispose();
    _decrementController.dispose();
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _ripple3Controller.dispose();
    _blinkController.dispose();
    _leaderboardTimer?.cancel();
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
    final isDark = themeNotifier.isDark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark
            ? const BoxDecoration(
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
              )
            : const BoxDecoration(color: Color(0xFFF0EBF0)),
        child: Stack(
          children: [
            // ── Blended top image ──
            Positioned(
              top: -90,
              left: 0,
              right: 0,
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.82, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  _isRosary ? 'assets/demo/mathav.png' : 'assets/demo/i trust you jesus.png',
                  width: double.infinity,
                  height: 395,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            // ── Content ──
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 300),
                    _buildQuoteCard(),
                    const SizedBox(height: 24),
                    _buildModeToggle(),
                    const SizedBox(height: 20),
                    _buildCountCard(),
                    const SizedBox(height: 8),
                    _buildCountButtons(),
                    const SizedBox(height: 32),
                    _buildNoteInput(),
                    const SizedBox(height: 12),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // ── Global-count panel overlay ──
            if (_showGlobalPanel)
              GestureDetector(
                onTap: () => setState(() => _showGlobalPanel = false),
                child: Container(
                  color: themeNotifier.isDark
                      ? Colors.black.withOpacity(0.35)
                      : const Color(0xFF624294).withOpacity(0.08),
                ),
              ),
            if (_showGlobalPanel)
              Positioned(
                left: 16,
                right: 16,
                bottom: 90,
                child: GlobalCountPanel(
                  leaderboardData: _leaderboardData,
                  blinkAnimation: _blinkAnimation,
                  onClose: () => setState(() => _showGlobalPanel = false),
                ),
              ),
            // ── Draggable floating button ──
            _buildDraggableFab(size),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableFab(Size size) {
    final isDark = themeNotifier.isDark;
    return Positioned(
      left: _fabPosition.dx,
      top: _fabPosition.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            final nx = (_fabPosition.dx + d.delta.dx).clamp(0.0, size.width - 56.0);
            final ny = (_fabPosition.dy + d.delta.dy).clamp(0.0, size.height - 56.0);
            _fabPosition = Offset(nx, ny);
          });
        },
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _showGlobalPanel = !_showGlobalPanel);
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark
                ? const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFB57BEA), Color(0xFF624294)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.goldDark.withOpacity(0.5)
                    : const Color(0xFFB57BEA).withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.white.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: const Icon(Icons.public_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'ML', 'name': 'Malayalam'},
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
    final isDark = themeNotifier.isDark;
    final toggleBg = isDark
        ? (_isRosary ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.35))
        : const Color(0xFF624294).withOpacity(0.10);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: toggleBg,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? null : Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
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
    final isDark = themeNotifier.isDark;
    final selected = _isRosary == isRosary;
    final selectedTextColor = isDark ? AppColors.authBgMid : const Color(0xFF624294);
    final unselectedTextColor = isDark
        ? Colors.white.withOpacity(0.55)
        : const Color(0xFF624294).withOpacity(0.50);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isRosary = isRosary),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: selected && !isDark
                ? [BoxShadow(color: const Color(0xFF624294).withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? selectedTextColor : unselectedTextColor)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = themeNotifier.isDark;
    final logoAsset = isDark || !_isRosary ? 'assets/splash/ur_logo.png' : 'assets/splash/ur_logo.png';
    final titleColor = Colors.white;
    final langBg = Colors.white.withOpacity(0.12);
    final langText = Colors.white;
    final langBorder = Colors.white.withOpacity(0.30);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.45), width: 1.5),
                boxShadow: [BoxShadow(color: AppColors.authPurple.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(logoAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Text('Upper Room',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: titleColor, letterSpacing: 0.5)),
          ],
        ),
        GestureDetector(
          onTap: _showLanguagePicker,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: langBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: langBorder, width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.language_rounded, color: langText, size: 16),
              const SizedBox(width: 6),
              Text(_selectedLanguage, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: langText, letterSpacing: 0.3)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: langText.withOpacity(0.7), size: 16),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    final prayer = _isRosary ? _rosaryPrayer : _chapletPrayer;
    final title  = _isRosary ? 'Rosary Prayers' : 'Divine Mercy Chaplet';
    return _PrayerInlineCard(
      prayer: prayer,
      title: title,
      accentColor: _accent,
      darkColor: _dark,
      bgBottom: _bgBottom,
      onExpand: (speed) => _showPrayerExpanded(title, prayer, speed),
    );
  }

  void _showPrayerExpanded(String title, String prayer, double initialSpeed) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'prayer',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return FadeTransition(
          opacity: anim,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: _bgBottom.withOpacity(0.75)),
              ),
              Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: _PrayerExpandedModal(
                    title: title,
                    prayer: prayer,
                    accentColor: _accent,
                    darkColor: _dark,
                    bgBottom: _bgBottom,
                    initialSpeed: initialSpeed,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountCard() {
    final isDark = themeNotifier.isDark;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _RippleRing(animation: _ripple1Anim, baseSize: 155, color: _accent),
          _RippleRing(animation: _ripple2Anim, baseSize: 155, color: _accent),
          _RippleRing(animation: _ripple3Anim, baseSize: 155, color: _accent),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? (_isRosary ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.40))
                    : Colors.white,
                boxShadow: isDark
                    ? [
                        BoxShadow(color: _bgBottom.withOpacity(0.35), blurRadius: 36, spreadRadius: 4, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 16, spreadRadius: -4, offset: const Offset(-4, -4)),
                      ]
                    : [
                        BoxShadow(color: const Color(0xFF624294).withOpacity(0.15), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.white.withOpacity(0.90), blurRadius: 8, offset: const Offset(-4, -4)),
                      ],
                border: Border.all(
                  color: isDark ? _accent.withOpacity(0.45) : const Color(0xFF624294).withOpacity(0.20),
                  width: 2.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_activeCount',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF624294),
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_accent, _dark]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRosary ? loc.tr('rosary_counted') : 'Chaplet Counted',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withOpacity(0.65) : const Color(0xFF624294).withOpacity(0.60),
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
    final isDark = themeNotifier.isDark;
    final iconColor = isDark ? Colors.white : const Color(0xFF624294);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _decrementScaleAnim,
          builder: (context, child) => Transform.scale(scale: _decrementScaleAnim.value, child: child),
          child: GestureDetector(
            onTap: _decrement,
            child: Icon(Icons.remove_rounded, color: iconColor, size: 36),
          ),
        ),
        const SizedBox(width: 60),
        AnimatedBuilder(
          animation: _incrementScaleAnim,
          builder: (context, child) => Transform.scale(scale: _incrementScaleAnim.value, child: child),
          child: GestureDetector(
            onTap: _increment,
            child: Icon(Icons.add_rounded, color: iconColor, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    final isDark = themeNotifier.isDark;
    final inputBg = isDark
        ? (_isRosary ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.35))
        : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF624294);
    final hintColor = isDark
        ? Colors.white.withOpacity(0.40)
        : const Color(0xFF624294).withOpacity(0.40);
    final borderColor = isDark
        ? _accent.withOpacity(0.35)
        : const Color(0xFF624294).withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isDark
            ? [BoxShadow(color: _bgBottom.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
            : [
                BoxShadow(color: const Color(0xFF624294).withOpacity(0.10), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6)),
                BoxShadow(color: Colors.white.withOpacity(0.80), blurRadius: 4, offset: const Offset(0, -2)),
              ],
      ),
      child: TextField(
        controller: _noteController,
        style: GoogleFonts.poppins(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: loc.tr('add_intentions'),
          hintStyle: GoogleFonts.poppins(color: hintColor, fontSize: 12, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.edit_note_rounded,
              color: isDark ? _accent : const Color(0xFF624294).withOpacity(0.60), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark ? _accent : AppColors.goldPrimary.withOpacity(0.7),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    bool _isSavePressed = false;
    return StatefulBuilder(
      builder: (context, setSaveState) => GestureDetector(
        onTap: _save,
        onTapDown: (_) => setSaveState(() => _isSavePressed = true),
        onTapUp: (_) => setSaveState(() => _isSavePressed = false),
        onTapCancel: () => setSaveState(() => _isSavePressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 46,
          transform: Matrix4.translationValues(0, _isSavePressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B55A8), Color(0xFF624294)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _isSavePressed
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF2A0A5E),
                      blurRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: const Color(0xFF624294).withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
            border: Border.all(
              color: _isSavePressed ? Colors.transparent : Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(_isSavePressed ? 0.0 : 0.10),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  loc.tr('save'),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
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

// ── Prayer inline card (unexpanded, with auto-scroll + speed) ─────────────────
class _PrayerInlineCard extends StatefulWidget {
  final String prayer;
  final String title;
  final Color accentColor;
  final Color darkColor;
  final Color bgBottom;
  final void Function(double speed) onExpand;

  const _PrayerInlineCard({
    required this.prayer,
    required this.title,
    required this.accentColor,
    required this.darkColor,
    required this.bgBottom,
    required this.onExpand,
  });

  @override
  State<_PrayerInlineCard> createState() => _PrayerInlineCardState();
}

class _PrayerInlineCardState extends State<_PrayerInlineCard> {
  final ScrollController _scrollController = ScrollController();
  double _speed = 20.0;
  double _fontSize = 13.0;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _scrollTimer?.cancel();
    if (_speed == 0) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.offset;
      final max = _scrollController.position.maxScrollExtent;
      if (pos >= max) return;
      _scrollController.jumpTo((pos + _speed / 60).clamp(0, max));
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: themeNotifier.isDark ? Colors.white : const Color(0xFF624294).withOpacity(0.15),
          width: themeNotifier.isDark ? 2.0 : 1.5,
        ),
        boxShadow: themeNotifier.isDark
            ? [BoxShadow(color: widget.bgBottom.withOpacity(0.20), blurRadius: 20, offset: const Offset(0, 6))]
            : [
                BoxShadow(color: const Color(0xFF624294).withOpacity(0.10), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6)),
                BoxShadow(color: Colors.white.withOpacity(0.80), blurRadius: 4, offset: const Offset(0, -2)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 6),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: widget.darkColor, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: widget.darkColor, letterSpacing: 1.0),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _fontSize = (_fontSize - 1).clamp(10.0, 24.0)),
                  child: const Icon(Icons.zoom_out_rounded, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _fontSize = (_fontSize + 1).clamp(10.0, 24.0)),
                  child: const Icon(Icons.zoom_in_rounded, color: Colors.grey, size: 22),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => widget.onExpand(_speed),
                  child: Icon(Icons.open_in_full_rounded, color: widget.accentColor, size: 18),
                ),
              ],
            ),
          ),
          Divider(color: widget.accentColor.withOpacity(0.15), height: 1, indent: 16, endIndent: 16),
          // scrollable text
          Expanded(
            child: Listener(
              onPointerDown: (_) => _scrollTimer?.cancel(),
              onPointerUp: (_) => _startScroll(),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                physics: const BouncingScrollPhysics(),
              child: Text(
                widget.prayer,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF333333).withOpacity(0.88),
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
              ),
            ),
          ),
          // speed slider
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Icon(Icons.speed_rounded, color: widget.accentColor, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: widget.accentColor,
                      inactiveTrackColor: widget.accentColor.withOpacity(0.20),
                      thumbColor: widget.darkColor,
                      overlayColor: widget.accentColor.withOpacity(0.12),
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _speed,
                      min: 0,
                      max: 120,
                      onChanged: (v) {
                        setState(() => _speed = v);
                        if (v == 0) {
                          _scrollTimer?.cancel();
                        } else {
                          _startScroll();
                        }
                      },
                    ),
                  ),
                ),
                Text(
                  _speed == 0 ? 'Off' : '${_speed.toInt()}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.accentColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prayer expanded modal with auto-scroll ────────────────────────────────────
class _PrayerExpandedModal extends StatefulWidget {
  final String title;
  final String prayer;
  final Color accentColor;
  final Color darkColor;
  final Color bgBottom;
  final double initialSpeed;

  const _PrayerExpandedModal({
    required this.title,
    required this.prayer,
    required this.accentColor,
    required this.darkColor,
    required this.bgBottom,
    required this.initialSpeed,
  });

  @override
  State<_PrayerExpandedModal> createState() => _PrayerExpandedModalState();
}

class _PrayerExpandedModalState extends State<_PrayerExpandedModal> {
  final ScrollController _scrollController = ScrollController();
  late double _speed;
  double _fontSize = 14.5;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _speed = widget.initialSpeed;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _scrollTimer?.cancel();
    if (_speed == 0) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      final pos = _scrollController.offset;
      final max = _scrollController.position.maxScrollExtent;
      if (pos >= max) return;
      _scrollController.jumpTo((pos + _speed / 60).clamp(0, max));
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: widget.bgBottom.withOpacity(0.40), blurRadius: 40, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: widget.darkColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: widget.darkColor, letterSpacing: 0.8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _fontSize = (_fontSize - 1).clamp(10.0, 26.0)),
                    child: Icon(Icons.zoom_out_rounded, color: widget.accentColor, size: 22),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _fontSize = (_fontSize + 1).clamp(10.0, 26.0)),
                    child: Icon(Icons.zoom_in_rounded, color: widget.accentColor, size: 24),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: widget.darkColor.withOpacity(0.6), size: 22),
                  ),
                ],
              ),
            ),
            Divider(color: widget.accentColor.withOpacity(0.20), height: 1, indent: 20, endIndent: 20),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                physics: const BouncingScrollPhysics(),
                child: Text(
                  widget.prayer,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF222222).withOpacity(0.90),
                    height: 1.8,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed_rounded, color: widget.accentColor, size: 16),
                      const SizedBox(width: 8),
                      Text('Scroll Speed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.darkColor)),
                      const Spacer(),
                      Text(
                        _speed == 0 ? 'Stopped' : '${_speed.toInt()}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.accentColor),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: widget.accentColor,
                      inactiveTrackColor: widget.accentColor.withOpacity(0.20),
                      thumbColor: widget.darkColor,
                      overlayColor: widget.accentColor.withOpacity(0.15),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: Slider(
                      value: _speed,
                      min: 0,
                      max: 120,
                      onChanged: (v) {
                        setState(() => _speed = v);
                        if (v == 0) {
                          _scrollTimer?.cancel();
                        } else {
                          _startScroll();
                        }
                      },
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


