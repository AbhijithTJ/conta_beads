import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';
import '../../services/localization_service.dart';
import 'counting_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Quote rotation
  late AnimationController _quoteController;
  late Animation<double> _quoteFadeAnim;
  Timer? _quoteTimer;
  int _currentQuoteIndex = 0;

  // Orb animations
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _orb4Controller;
  late Animation<double> _orb1Anim;
  late Animation<double> _orb2Anim;
  late Animation<double> _orb3Anim;
  late Animation<double> _orb4Anim;

  // Quick count drag handle
  double _dragOffset = 0;
  bool _dragging = false;
  static const double _dragThreshold = 80;

  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'ML', 'name': 'Malayalam'},
    {'code': 'HI', 'name': 'Hindi'},
    {'code': 'TA', 'name': 'Tamil'},
    {'code': 'LA', 'name': 'Latin'},
  ];

  final List<Map<String, String>> _quotes = [
    {'text': '"God\'s love is a sea without a shore."', 'reference': 'St. Catherine of Siena'},
    {'text': '"Prayer is the key of the morning and the bolt of the evening."', 'reference': 'Mahatma Gandhi'},
    {'text': '"To pray is to let Jesus into our lives."', 'reference': 'Ole Hallesby'},
    {'text': '"The rosary is the most excellent form of prayer."', 'reference': 'Pope Paul VI'},
    {'text': '"With God, all things are possible."', 'reference': 'Matthew 19:26'},
  ];

  final List<Map<String, dynamic>> _features = [
    {'title': 'Count Your', 'subtitle': 'Rosary', 'image': 'assets/demo/1.jpg'},
    {'title': 'Divine Mercy', 'subtitle': 'Chaplet', 'image': 'assets/demo/jesus.jpg'},
    {'title': 'Adopt a', 'subtitle': 'Priest', 'image': 'assets/demo/2.jpg'},
    {'title': 'Every Day', 'subtitle': 'Prayers', 'image': 'assets/demo/1.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _quoteController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeInOut),
    );
    _quoteController.forward();

    _orb1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat(reverse: true);
    _orb2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5800))..repeat(reverse: true);
    _orb3Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);
    _orb4Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 6400))..repeat(reverse: true);

    _orb1Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb1Controller, curve: Curves.easeInOut));
    _orb2Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb2Controller, curve: Curves.easeInOut));
    _orb3Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb3Controller, curve: Curves.easeInOut));
    _orb4Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb4Controller, curve: Curves.easeInOut));

    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) => _nextQuote());
  }

  void _nextQuote() {
    _quoteController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length);
      _quoteController.forward();
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _quoteController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _orb4Controller.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
              Row(children: [
                const Icon(Icons.language_rounded, color: AppColors.authPurpleLight, size: 20),
                const SizedBox(width: 10),
                const Text('Select Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              const SizedBox(height: 16),
              Column(
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
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.authPurpleLight.withOpacity(0.20) : AppColors.authBgTop.withOpacity(0.3),
                            border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.3)),
                          ),
                          child: Center(child: Text(lang['code']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.authLavender))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Text(lang['name']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.white.withOpacity(0.70)))),
                        if (isSelected) const Icon(Icons.check_rounded, color: AppColors.authPurpleLight, size: 20),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
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
            colors: [AppColors.authBgTop, AppColors.authBgMid, AppColors.authBgBottom],
          ),
        ),
        child: Stack(
          children: [
            _buildOrbs(size),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildQuoteCard(),
                    const SizedBox(height: 24),
                    _buildGrid(size),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildDragHandle(size),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(Size size) {
    return Positioned(
      right: 0,
      top: size.height * 0.40,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CountingScreen(userEmail: widget.userEmail),
        )),
        onHorizontalDragStart: (_) => setState(() { _dragging = true; _dragOffset = 0; }),
        onHorizontalDragUpdate: (d) {
          // right-side tab: drag left (negative delta) to trigger
          setState(() => _dragOffset = (_dragOffset - d.delta.dx).clamp(0, _dragThreshold + 20));
        },
        onHorizontalDragEnd: (_) {
          if (_dragOffset >= _dragThreshold) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CountingScreen(userEmail: widget.userEmail),
            ));
          }
          setState(() { _dragOffset = 0; _dragging = false; });
        },
        child: AnimatedContainer(
          duration: _dragging ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(-_dragOffset, 0, 0),
          child: Row(
            children: [
              // Progress indicator while dragging (appears to the left of tab)
              if (_dragging && _dragOffset > 8)
                Container(
                  width: _dragOffset.clamp(0, _dragThreshold),
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.chapletAccent.withOpacity(0.0), AppColors.chapletAccent.withOpacity(0.5)],
                    ),
                  ),
                  child: _dragOffset >= _dragThreshold
                      ? const Center(child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20))
                      : null,
                ),
              // The pull tab
              Container(
                width: 36,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.chapletAccent, AppColors.authPurpleLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(color: AppColors.chapletAccent.withOpacity(0.60), blurRadius: 16, spreadRadius: 2, offset: const Offset(3, 0)),
                    BoxShadow(color: AppColors.authPurpleLight.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 22),
                    const SizedBox(height: 4),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'ROSARY',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbs(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orb1Anim, _orb2Anim, _orb3Anim, _orb4Anim]),
      builder: (context, _) => Stack(children: [
        _Orb(left: size.width * 0.2, top: -size.height * 0.08 + _orb1Anim.value * 28, size: size.width * 0.72,
          colors: [AppColors.authPurple.withOpacity(0.55), AppColors.authBgTop.withOpacity(0.30)]),
        _Orb(left: -size.width * 0.22, top: size.height * 0.28 + _orb2Anim.value * -22, size: size.width * 0.65,
          colors: [AppColors.authPurpleLight.withOpacity(0.45), AppColors.authPurple.withOpacity(0.25)]),
        _Orb(left: size.width * 0.55, top: size.height * 0.38 + _orb3Anim.value * 18, size: size.width * 0.60,
          colors: [AppColors.authBgMid.withOpacity(0.70), AppColors.authBgBottom.withOpacity(0.40)]),
        _Orb(left: size.width * 0.1, top: size.height * 0.72 + _orb4Anim.value * -16, size: size.width * 0.55,
          colors: [AppColors.authPurpleLight.withOpacity(0.20), AppColors.authPurple.withOpacity(0.25)]),
      ]),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/splash/ur_logo.png', width: 52, height: 52),
        GestureDetector(
          onTap: _showLanguagePicker,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.authBgMid,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.5), width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.language_rounded, color: AppColors.authPurpleLight, size: 16),
              const SizedBox(width: 6),
              Text(_selectedLanguage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.authPurpleLight.withOpacity(0.7), size: 16),
            ]),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.30), width: 1.5),
          boxShadow: [
            BoxShadow(color: AppColors.authBgBottom.withOpacity(0.20), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\u275D',
              style: TextStyle(fontSize: 20, color: AppColors.authPurple.withOpacity(0.45), height: 1.0),
            ),
            const SizedBox(height: 6),
            Text(
              quote['text']!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                fontStyle: FontStyle.italic,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote['reference']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.authPurple,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
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
                        ? AppColors.authPurple
                        : AppColors.authPurple.withOpacity(0.25),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(Size size) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final item = _features[i];
        return GestureDetector(
          onTap: () {
            if (i == 0) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CountingScreen(userEmail: widget.userEmail),
              ));
            } else if (i == 1) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CountingScreen(userEmail: widget.userEmail, startWithChaplet: true),
              ));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(item['image']!, fit: BoxFit.cover),
                // dark gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                    ),
                  ),
                ),
                // title + heart
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(item['subtitle']!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double left, top, size;
  final List<Color> colors;
  const _Orb({required this.left, required this.top, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left, top: top,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: const Alignment(-0.3, -0.3), radius: 0.85, colors: colors, stops: const [0.0, 1.0]),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.25), blurRadius: size * 0.35, spreadRadius: size * 0.05)],
        ),
      ),
    );
  }
}
