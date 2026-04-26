import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';
import '../splash/splash_screen.dart';

class ThemeSelectScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const ThemeSelectScreen({super.key, required this.onComplete});

  @override
  State<ThemeSelectScreen> createState() => _ThemeSelectScreenState();
}

class _ThemeSelectScreenState extends State<ThemeSelectScreen>
    with SingleTickerProviderStateMixin {
  bool? _selected = true; // dark selected by default
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    HapticFeedback.mediumImpact();
    themeNotifier.setDark(_selected!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _selected!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SplashScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _selected != false;
    final bgColors = [const Color(0xFF22014D), const Color(0xFF22014D), const Color(0xFF22014D)];
    final titleColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.50) : AppColors.authBgMid.withOpacity(0.6);
    final badgeColor = isDark ? AppColors.goldLight : AppColors.goldDark;
    final badgeBg = isDark ? AppColors.goldPrimary.withOpacity(0.12) : AppColors.goldPrimary.withOpacity(0.15);
    final badgeBorder = isDark ? AppColors.goldLight.withOpacity(0.5) : AppColors.goldDark.withOpacity(0.4);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeBorder, width: 1),
                      color: badgeBg,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome_rounded, color: badgeColor, size: 13),
                      const SizedBox(width: 6),
                      Text('PERSONALISE YOUR EXPERIENCE',
                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.8, color: badgeColor)),
                    ]),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Choose Your\nAppearance',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: Colors.white, height: 1.2, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 28),
                  // Cards row
                  Row(
                    children: [
                      Expanded(child: _ThemeCard(
                        isDarkOption: false,
                        selected: _selected == false,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = false);
                        },
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _ThemeCard(
                        isDarkOption: true,
                        selected: _selected == true,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = true);
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ProfilePreviewTutorial(isDark: isDark),
                  const SizedBox(height: 16),
                  // Future note
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: Colors.white.withOpacity(0.45)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You can change this anytime from your Profile → Settings inside the app.',
                            style: GoogleFonts.poppins(fontSize: 11, height: 1.5, color: Colors.white.withOpacity(0.45)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Continue button
                  AnimatedOpacity(
                    opacity: _selected != null ? 1.0 : 0.35,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: _confirm,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [const Color(0xFF7B55A8), const Color(0xFF624294)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF624294).withOpacity(0.40),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('CONTINUE',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme Preview Card ────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final bool isDarkOption;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.isDarkOption,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDarkOption ? const Color(0xFF22014D) : const Color(0xFFF5EEF5);
    final cardBg = isDarkOption ? const Color(0xFF2E0A5E) : Colors.white;
    final textColor = isDarkOption ? Colors.white : const Color(0xFF3D0227);
    final subColor = isDarkOption
        ? Colors.white.withOpacity(0.45)
        : const Color(0xFF3D0227).withOpacity(0.45);
    final label = isDarkOption ? 'Dark' : 'Light';
    final icon = isDarkOption ? Icons.dark_mode_rounded : Icons.light_mode_rounded;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.goldPrimary : Colors.white.withOpacity(0.12),
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.goldPrimary.withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 8))]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              // Preview area
              Container(
                height: 180,
                color: bg,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Mini header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 28, height: 10, decoration: BoxDecoration(color: textColor.withOpacity(0.8), borderRadius: BorderRadius.circular(4))),
                        Container(width: 40, height: 10, decoration: BoxDecoration(color: textColor.withOpacity(0.3), borderRadius: BorderRadius.circular(8))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Mini quote card
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(children: [
                        Container(width: 2, height: double.infinity, color: const Color(0xFF22014D).withOpacity(0.5)),
                        const SizedBox(width: 6),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: textColor.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(height: 4),
                            Container(height: 4, width: 60, decoration: BoxDecoration(color: const Color(0xFF22014D).withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                          ],
                        )),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    // Mini grid
                    Row(children: [
                      Expanded(child: Container(height: 52, decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)))),
                      const SizedBox(width: 6),
                      Expanded(child: Container(height: 52, decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)))),
                    ]),
                  ],
                ),
              ),
              // Label area
              Container(
                color: selected ? AppColors.goldPrimary : Colors.white.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                        size: 16,
                        color: selected ? const Color(0xFF2E0A3A) : Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text(label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: selected ? const Color(0xFF2E0A3A) : Colors.white.withOpacity(0.7),
                            letterSpacing: 0.5)),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF2E0A3A)),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Preview Tutorial ──────────────────────────────────────────────────
class _ProfilePreviewTutorial extends StatefulWidget {
  final bool isDark;
  const _ProfilePreviewTutorial({required this.isDark});

  @override
  State<_ProfilePreviewTutorial> createState() => _ProfilePreviewTutorialState();
}

class _ProfilePreviewTutorialState extends State<_ProfilePreviewTutorial>
    with SingleTickerProviderStateMixin {
  late AnimationController _switchCtrl;
  late Animation<double> _pulseAnim;
  bool _demoToggle = true;

  @override
  void initState() {
    super.initState();
    _switchCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _switchCtrl, curve: Curves.easeInOut));

    // Auto-animate the demo toggle every 2s
    Future.delayed(const Duration(milliseconds: 1200), _autoToggle);
  }

  void _autoToggle() {
    if (!mounted) return;
    setState(() => _demoToggle = !_demoToggle);
    Future.delayed(const Duration(milliseconds: 2000), _autoToggle);
  }

  @override
  void dispose() {
    _switchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF560737) : Colors.white;
    final profileBg = isDark ? const Color(0xFF3D0227) : const Color(0xFFF0EBF0);
    final textColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.45) : AppColors.authBgMid.withOpacity(0.5);
    final highlightColor = AppColors.goldPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tutorial label
        Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 14,
                color: isDark ? AppColors.goldLight : AppColors.goldDark),
            const SizedBox(width: 6),
            Text(
              'CHANGE ANYTIME IN PROFILE',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: isDark ? AppColors.goldLight : AppColors.goldDark),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Mini profile screen mockup
        Container(
          decoration: BoxDecoration(
            color: profileBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF22014D).withOpacity(0.12),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Mini avatar + name row
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardLavender,
                    ),
                    child: Center(
                      child: Text('JD',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.authBgBottom)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 70, height: 7,
                          decoration: BoxDecoration(color: textColor.withOpacity(0.7), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 4),
                      Container(width: 45, height: 5,
                          decoration: BoxDecoration(color: subColor, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Settings section label
              Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 50, height: 5,
                    decoration: BoxDecoration(
                        color: isDark ? AppColors.goldLight.withOpacity(0.5) : AppColors.goldDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 8),
              // Highlighted dark mode row
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: highlightColor, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                            color: highlightColor.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 1),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF22014D).withOpacity(0.10),
                          ),
                          child: Icon(Icons.dark_mode_rounded, color: const Color(0xFF22014D), size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Dark Mode',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor)),
                        ),
                        // Animated demo switch
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          width: 36,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _demoToggle
                                ? AppColors.goldPrimary
                                : const Color(0xFF22014D).withOpacity(0.25),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            alignment: _demoToggle
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 16, height: 16,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Two dummy setting rows
              _miniSettingRow(textColor, subColor, cardBg),
              const SizedBox(height: 6),
              _miniSettingRow(textColor, subColor, cardBg),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniSettingRow(Color textColor, Color subColor, Color cardBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(width: 20, height: 20,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF22014D).withOpacity(0.08))),
          const SizedBox(width: 8),
          Container(width: 80, height: 6,
              decoration: BoxDecoration(color: textColor.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 14, color: subColor),
        ],
      ),
    );
  }
}
