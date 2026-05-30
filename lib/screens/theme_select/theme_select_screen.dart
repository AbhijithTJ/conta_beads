import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../colors/colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/home_provider.dart';
import '../../services/language_id_service.dart';
import '../../theme/theme_notifier.dart';
import '../../services/localization_service.dart';
import '../../services/notification_service.dart';
import '../../services/session_service.dart';
import '../../login_and_register/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

// Muted gold palette — softer intensity for this screen only
const Color _goldPrimary = Color(0xFFC4A060);   // was 0xFFD4A843
const Color _goldLight   = Color(0xFFD4B87A);   // was 0xFFE8C97A
const Color _goldDark    = Color(0xFFA07828);   // was 0xFFB8902E

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

  static const List<Map<String, String>> _languages = [
    {'name': 'English',   'native': 'English',  'flag': '🇬🇧'},
    {'name': 'Malayalam', 'native': 'മലയാളം',   'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    // Show notification permission dialog after a short delay
    Future.delayed(const Duration(milliseconds: 500), _showNotificationPermissionDialog);
  }

  /// Show notification permission dialog if not already requested
  Future<void> _showNotificationPermissionDialog() async {
    if (!mounted) return;

    // Check if we've already asked for notification permission
    if (SessionService.instance.hasRequestedNotificationPermission) {
      return;
    }

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bell icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7B55A8).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    size: 32,
                    color: Color(0xFF7B55A8),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  loc.tr('enable_notifications'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  loc.tr('notification_permission_description'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.6,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 28),

                // Allow button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      // User allowed
                      await NotificationService.instance.requestNotificationPermission();
                      await SessionService.instance.setNotificationPermissionRequested();
                      if (mounted) Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB3D9FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      loc.tr('allow'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Don't allow button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      // User declined
                      await SessionService.instance.setNotificationPermissionRequested();
                      if (mounted) Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F0FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      loc.tr('not_now'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF666666),
                      ),
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
    
    // Get language from provider and ensure it's loaded
    final languageProvider = context.read<LanguageProvider>();
    await languageProvider.setLanguage(languageProvider.selectedLanguage);
    
    // Sync language ID with the service (this is the key!)
    languageIdService.setLanguageByName(languageProvider.selectedLanguage);
    
    await prefs.setString('selectedLanguage', languageProvider.selectedLanguage);
    
    // Refresh home provider with new language (after language is loaded)
    final homeProvider = context.read<HomeProvider>();
    await homeProvider.refreshTextOnly();
    
    if (!mounted) return;
    
    // Store context before navigation
    final currentContext = context;
    
    Navigator.of(currentContext).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, __, ___) => OnboardingScreen(
          onComplete: () {
            // Use the new context from the page builder
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LoginScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _selected != false;
    final titleColor = isDark ? Colors.white : const Color(0xFF624294);
    final noteTextColor = isDark ? Colors.white.withOpacity(0.45) : const Color(0xFF624294).withOpacity(0.55);
    final noteBg = isDark ? Colors.white.withOpacity(0.06) : Colors.white;
    final noteBorder = isDark ? Colors.white.withOpacity(0.10) : const Color(0xFF624294).withOpacity(0.15);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF4A4080),
                    Color(0xFF2A1F5E),
                    Color(0xFF100828),
                  ],
                  stops: [0.0, 0.50, 1.0],
                )
              : const LinearGradient(
                  colors: [Color(0xFFF0EBF0), Color(0xFFE8E0F0), Color(0xFFF0EBF0)],
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
                  const SizedBox(height: 36),

                  // ── Hero intro block ───────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.09)
                            : const Color(0xFF624294).withOpacity(0.12),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon row
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : const Color(0xFF624294).withOpacity(0.08),
                              ),
                              child: Icon(
                                Icons.palette_outlined,
                                size: 20,
                                color: isDark
                                    ? Colors.white.withOpacity(0.75)
                                    : const Color(0xFF624294).withOpacity(0.75),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.tr('make_it_yours'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.tr('choose_appearance_language'),
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            height: 1.6,
                            color: isDark
                                ? Colors.white.withOpacity(0.55)
                                : const Color(0xFF624294).withOpacity(0.60),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Two feature chips
                        Row(
                          children: [
                            _IntroChip(
                              icon: Icons.dark_mode_outlined,
                              label: loc.tr('appearance'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _IntroChip(
                              icon: Icons.language_rounded,
                              label: loc.tr('language'),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Theme Cards (smaller) ──────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _ThemeCard(
                        isDarkOption: false,
                        selected: _selected == false,
                        screenIsDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = false);
                        },
                      )),
                      const SizedBox(width: 14),
                      Expanded(child: _ThemeCard(
                        isDarkOption: true,
                        selected: _selected == true,
                        screenIsDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = true);
                        },
                      )),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Language Section ───────────────────────────────────
                  Consumer<LanguageProvider>(
                    builder: (_, languageProvider, __) {
                      return _LanguageSection(
                        isDark: isDark,
                        selectedLanguage: languageProvider.selectedLanguage,
                        languages: _languages,
                        onSelect: (lang) async {
                          HapticFeedback.selectionClick();
                          await languageProvider.setLanguage(lang);
                          // Rebuild entire page with new language
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Profile Preview Tutorial ───────────────────────────
                  _ProfilePreviewTutorial(isDark: isDark),

                  const SizedBox(height: 20),

                  // Info note
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: noteBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: noteBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: noteTextColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            loc.tr('change_anytime_profile'),
                            style: GoogleFonts.poppins(fontSize: 11, height: 1.5, color: noteTextColor),
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B55A8), Color(0xFF624294)],
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
                          child: Text(loc.tr('continue'),
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

// ── Intro Chip ────────────────────────────────────────────────────────────────
class _IntroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _IntroChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFF624294).withOpacity(0.08);
    final color = isDark
        ? Colors.white.withOpacity(0.70)
        : const Color(0xFF624294).withOpacity(0.70);
    final border = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFF624294).withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme Preview Card (compact) ──────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final bool isDarkOption;
  final bool selected;
  final bool screenIsDark;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.isDarkOption,
    required this.selected,
    required this.screenIsDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDarkOption ? const Color(0xFF22014D) : const Color(0xFFF5EEF5);
    final cardBg = isDarkOption ? const Color(0xFFEDE0ED) : Colors.white;
    final textColor = isDarkOption ? Colors.white : const Color(0xFF22014D);
    final label = isDarkOption ? loc.tr('dark') : loc.tr('light');
    final icon = isDarkOption ? Icons.dark_mode_rounded : Icons.light_mode_rounded;

    final unselectedLabelBg = screenIsDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFF624294).withOpacity(0.08);
    final unselectedLabelColor = screenIsDark
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF624294).withOpacity(0.7);
    final unselectedBorder = screenIsDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFF624294).withOpacity(0.20);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _goldPrimary : unselectedBorder,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _goldPrimary.withOpacity(0.20), blurRadius: 14, offset: const Offset(0, 5))]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              // Preview area — reduced height
              Container(
                height: 130,
                color: bg,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Mini header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 24, height: 8, decoration: BoxDecoration(color: textColor.withOpacity(0.8), borderRadius: BorderRadius.circular(4))),
                        Container(width: 32, height: 8, decoration: BoxDecoration(color: textColor.withOpacity(0.3), borderRadius: BorderRadius.circular(8))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mini quote card
                    Container(
                      height: 28,
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      child: Row(children: [
                        Container(width: 2, height: double.infinity, color: const Color(0xFF22014D).withOpacity(0.5)),
                        const SizedBox(width: 5),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 3, width: double.infinity, decoration: BoxDecoration(color: textColor.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(height: 3),
                            Container(height: 3, width: 40, decoration: BoxDecoration(color: const Color(0xFF22014D).withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                          ],
                        )),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    // Mini grid
                    Row(children: [
                      Expanded(child: Container(height: 40, decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(6)))),
                      const SizedBox(width: 5),
                      Expanded(child: Container(height: 40, decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(6)))),
                    ]),
                  ],
                ),
              ),
              // Label area
              Container(
                color: selected ? _goldPrimary : unselectedLabelBg,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                        size: 14,
                        color: selected ? const Color(0xFF2E0A3A) : unselectedLabelColor),
                    const SizedBox(width: 6),
                    Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: selected ? const Color(0xFF2E0A3A) : unselectedLabelColor,
                            letterSpacing: 0.5)),
                    if (selected) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E0A3A)),
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

// ── Language Section ──────────────────────────────────────────────────────────
class _LanguageSection extends StatelessWidget {
  final bool isDark;
  final String selectedLanguage;
  final List<Map<String, String>> languages;
  final ValueChanged<String> onSelect;

  const _LanguageSection({
    required this.isDark,
    required this.selectedLanguage,
    required this.languages,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final sectionSubColor = isDark
        ? Colors.white.withOpacity(0.45)
        : const Color(0xFF624294).withOpacity(0.55);
    final headerColor = isDark
        ? Colors.white.withOpacity(0.80)
        : const Color(0xFF624294);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFF624294).withOpacity(0.08),
              ),
              child: Icon(Icons.language_rounded,
                  size: 15,
                  color: isDark
                      ? Colors.white.withOpacity(0.75)
                      : const Color(0xFF624294).withOpacity(0.75)),
            ),
            const SizedBox(width: 10),
            Text(
              loc.tr('select_language'),
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: headerColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          loc.tr('choose_prayer_language'),
          style: GoogleFonts.poppins(
              fontSize: 12, color: sectionSubColor, height: 1.4),
        ),
        const SizedBox(height: 14),

        // Language tiles — 2 columns
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: languages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (_, i) {
            final lang = languages[i];
            final name = lang['name']!;
            final native = lang['native']!;
            final flag = lang['flag']!;
            final isSelected = selectedLanguage == name;

            // Selected: purple accent
            final selectedBg = isDark
                ? const Color(0xFF7B55A8).withOpacity(0.22)
                : Colors.white;
            final selectedBorder = isDark
                ? const Color(0xFF9B75C8)
                : const Color(0xFF624294);
            final selectedText = isDark
                ? Colors.white
                : const Color(0xFF3D1A6E);

            // Unselected: subtle
            final unselectedBg = isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white;
            final unselectedBorder = isDark
                ? Colors.white.withOpacity(0.12)
                : const Color(0xFF624294).withOpacity(0.16);
            final unselectedText = isDark
                ? Colors.white.withOpacity(0.65)
                : const Color(0xFF624294).withOpacity(0.65);

            return GestureDetector(
              onTap: () => onSelect(name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected ? selectedBg : unselectedBg,
                  border: Border.all(
                    color: isSelected ? selectedBorder : unselectedBorder,
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: isDark
                                  ? const Color(0xFF7B55A8).withOpacity(0.25)
                                  : const Color(0xFF624294).withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? selectedText : unselectedText),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            native,
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: isSelected
                                    ? selectedText.withOpacity(0.65)
                                    : unselectedText.withOpacity(0.65)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          size: 15,
                          color: isDark
                              ? const Color(0xFF9B75C8)
                              : const Color(0xFF624294)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
    final cardBg = isDark ? const Color(0xFFEDE0ED) : Colors.white;
    final profileBg = isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
    final textColor = isDark ? const Color(0xFF22014D) : AppColors.authBgBottom;
    final subColor = isDark
        ? const Color(0xFF22014D).withOpacity(0.5)
        : AppColors.authBgMid.withOpacity(0.5);
    final highlightColor = _goldPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tutorial label
        Row(
          children: [
            Icon(Icons.touch_app_rounded,
                size: 14,
                color: isDark ? _goldLight : _goldDark),
            const SizedBox(width: 6),
            Text(
              loc.tr('change_anytime_in_profile'),
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: isDark ? _goldLight : _goldDark),
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
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : const Color(0xFF22014D).withOpacity(0.12),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Mini avatar + name row
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
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
                      Container(
                          width: 70,
                          height: 7,
                          decoration: BoxDecoration(
                              color: textColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 4),
                      Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                              color: subColor,
                              borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Settings section label
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: isDark
                            ? _goldLight.withOpacity(0.45)
                            : _goldDark.withOpacity(0.40),
                        borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 8),
              // Highlighted dark mode row (pulsing)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: Icon(Icons.dark_mode_rounded,
                              color: const Color(0xFF22014D), size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Dark Mode',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor)),
                        ),
                        // Animated demo toggle switch
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          width: 36,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _demoToggle
                                ? _goldPrimary
                                : const Color(0xFF22014D).withOpacity(0.25),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            alignment: _demoToggle
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 16,
                              height: 16,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
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
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF22014D).withOpacity(0.08))),
          const SizedBox(width: 8),
          Container(
              width: 80,
              height: 6,
              decoration: BoxDecoration(
                  color: textColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4))),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 14, color: subColor),
        ],
      ),
    );
  }
}
