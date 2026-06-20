import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../dialog_box/logout_alert_dialog.dart';
import '../../login_and_register/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/adopt_priest_provider.dart';
import '../../services/localization_service.dart';
import '../../services/language_id_service.dart';
import '../../theme/theme_notifier.dart';
import '../prayer_history/prayer_history_screen.dart';
import 'account_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool get _isDarkMode => themeNotifier.isDark;

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'ML', 'name': 'Malayalam'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch fresh profile data from API on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    HapticFeedback.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LogoutAlertDialog(),
    );
    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final user = context.read<UserProvider>();
      await auth.logout();
      user.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showLanguagePicker() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.5),
                  radius: 1.2,
                  colors: [
                    Color(0xFF321060),
                    Color(0xFF220850),
                    Color(0xFF1c023d),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    const Icon(Icons.language_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text('Select Language', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                  const SizedBox(height: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _languages.map((lang) {
                      final isSelected = lang['name'] == languageProvider.selectedLanguage;
                      return GestureDetector(
                        onTap: () async {
                          // Only proceed if language is different
                          if (lang['name'] == languageProvider.selectedLanguage) {
                            Navigator.pop(ctx);
                            return;
                          }

                          await languageProvider.setLanguage(lang['name']!);
                          // Sync language ID with the service
                          languageIdService.setLanguageByName(lang['name']!);
                          
                          // Refresh home screen content with new language
                          if (!context.mounted) return;
                          final homeProvider = context.read<HomeProvider>();
                          await homeProvider.refreshTextOnly();
                          
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.18)
                                : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.55)
                                  : Colors.white.withOpacity(0.12),
                              width: 1.5,
                            ),
                          ),
                          child: Row(children: [
                            Container(
                              width: 38, height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  lang['code']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Formats "created_at" ISO string → "January 2026"
  String _formatSince(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso);
      const months = ['January','February','March','April','May','June',
                      'July','August','September','October','November','December'];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: themeNotifier,
          builder: (_, isDark, __) {
            final headerColor = isDark ? Colors.white : AppColors.authBgBottom;
            final subColor = isDark ? Colors.white.withOpacity(0.50) : AppColors.authBgMid.withOpacity(0.6);
            final sectionLabelColor = isDark ? AppColors.goldLight.withOpacity(0.9) : AppColors.goldDark;

            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: isDark
                    ? const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -0.2),
                          radius: 1.2,
                          colors: [
                            Color(0xFF4A4080),
                            Color(0xFF2A1F5E),
                            Color(0xFF100828),
                          ],
                          stops: [0.0, 0.50, 1.0],
                        ),
                      )
                    : const BoxDecoration(color: Color(0xFFF5EEF5)),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.tr('my_profile'), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3.5, color: subColor)),
                            GestureDetector(
                              onTap: _showLanguagePicker,
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFF624294).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withOpacity(0.30) : const Color(0xFF624294).withOpacity(0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.language_rounded, color: isDark ? Colors.white : const Color(0xFF624294), size: 16),
                                  const SizedBox(width: 6),
                                  Text(languageProvider.selectedLanguage, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF624294))),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: (isDark ? Colors.white : const Color(0xFF624294)).withOpacity(0.7), size: 16),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _buildAvatar(),
                        const SizedBox(height: 16),
                        Consumer<UserProvider>(
                          builder: (_, userProvider, __) {
                            if (userProvider.isLoading && userProvider.user == null) {
                              return Column(children: [
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? Colors.white54 : const Color(0xFF624294),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ]);
                            }
                            final name = userProvider.displayName;
                            final createdAt = userProvider.user?.createdAt;
                            final since = _formatSince(createdAt);
                            return Column(children: [
                              Text(name, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: 0.5)),
                              const SizedBox(height: 6),
                              Text('${loc.tr('member_since')} $since', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2.0, color: subColor)),
                            ]);
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildStatsRow(),
                        const SizedBox(height: 36),
                        _buildSectionLabel(loc.tr('account_details'), sectionLabelColor),
                        const SizedBox(height: 12),
                        _buildDetailsCard(),
                        const SizedBox(height: 28),
                        _buildAdoptedPriestsSection(sectionLabelColor),
                        const SizedBox(height: 28),
                        const SizedBox(height: 28),
                        _buildSectionLabel(loc.tr('settings'), sectionLabelColor),
                        const SizedBox(height: 12),
                        _buildSettingsList(),
                        const SizedBox(height: 40),
                        _buildLogoutButton(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar() {
    final isDark = themeNotifier.isDark;
    final name = context.watch<UserProvider>().displayName;
    // Build initials from name (up to 2 chars)
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.cardLavender : Colors.white,
            border: isDark ? null : Border.all(color: const Color(0xFF624294).withOpacity(0.30), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.15)
                    : const Color(0xFF624294).withOpacity(0.12),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardLavender : Colors.white,
                ),
                child: Center(
                  child: Text(initials, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isDark ? const Color(0xFF3D0227) : const Color(0xFF624294), letterSpacing: -1)),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.cardLavender : Colors.white,
              border: Border.all(color: const Color(0xFF624294).withOpacity(isDark ? 1.0 : 0.30), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.15)
                      : const Color(0xFF624294).withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.camera_alt_rounded, size: 14, color: isDark ? const Color(0xFF3D0227) : const Color(0xFF624294)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final user = context.watch<UserProvider>();
    return Row(
      children: [
        _StatBox(value: '${user.totalCount}', label: 'Total'),
        const SizedBox(width: 12),
        _StatBox(value: '${user.rosaryPrayedTotal}', label: 'Rosary'),
        const SizedBox(width: 12),
        _StatBox(value: '${user.chapelPrayedTotal}', label: 'Chaplet'),
      ],
    );
  }

  Widget _buildAdoptedPriestsSection(Color sectionLabelColor) {
    return Consumer<AdoptPriestProvider>(
      builder: (context, adoptProvider, _) {
        final priests = adoptProvider.savedPriests;

        // Don't show section if no priests
        if (priests.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildSectionLabel(loc.tr('adopted_priests'), sectionLabelColor),
            const SizedBox(height: 12),
            ...priests.asMap().entries.map((entry) {
              final index = entry.key;
              final priest = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WhiteCard(
                  child: Row(
                    children: [
                      // Avatar with number
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7B55A8).withOpacity(0.8),
                              const Color(0xFF624294).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF624294).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Priest name
                      Expanded(
                        child: Text(
                          priest.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF624294),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Saved badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          loc.tr('saved'),
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: color),
      ),
    );
  }

  Widget _buildDetailsCard() {
    final user = context.watch<UserProvider>();
    final phone = [user.countryCode, user.phone]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return _WhiteCard(
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined,    label: loc.tr('email_address'), value: user.email.isNotEmpty ? user.email : '—'),
          _divider(),
          _InfoRow(icon: Icons.phone_outlined,    label: loc.tr('phone_number'),  value: phone.isNotEmpty ? phone : '—'),
          _divider(),
          _InfoRow(icon: Icons.schedule_outlined, label: loc.tr('region'),      value: user.timezone.isNotEmpty ? user.timezone : '—'),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 4), color: const Color(0xFF624294).withOpacity(0.08));

  Widget _buildSettingsList() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountSecurityScreen()),
            );
          },
          child: _SettingRow(icon: Icons.security_rounded, title: loc.tr('account_security')),
        ),
        const SizedBox(height: 12),
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF624294).withOpacity(0.08),
                    border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1),
                  ),
                  child: Icon(Icons.dark_mode_rounded, color: const Color(0xFF624294), size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(loc.tr('appearance'), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.authBgBottom))),
                Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: _isDarkMode,
                    activeColor: AppColors.goldPrimary,
                    activeTrackColor: AppColors.goldPrimary.withOpacity(0.3),
                    inactiveThumbColor: const Color(0xFF624294).withOpacity(0.5),
                    inactiveTrackColor: const Color(0xFF624294).withOpacity(0.1),
                    onChanged: (val) {
                      themeNotifier.setDark(val);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrayerHistoryScreen()),
            );
          },
          child: _SettingRow(icon: Icons.history_rounded, title: loc.tr('counting_history')),
        ),
        const SizedBox(height: 12),
        _SettingRow(icon: Icons.help_outline_rounded, title: loc.tr('help_support')),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [Colors.redAccent.shade400, Colors.red.shade800], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Center(child: Text(loc.tr('sign_out'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white))),
      ),
    );
  }
}

// ── White Card (matches login card style) ─────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;

    if (isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 40, spreadRadius: 2, offset: const Offset(0, 12))],
            ),
            child: child,
          ),
        ),
      );
    }

    // Light mode — matches home screen card style
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF624294).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF624294).withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.80),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF624294).withOpacity(0.08),
              border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF624294), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.authBgMid.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.authBgBottom), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Setting Row ───────────────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF624294).withOpacity(0.08),
                border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1),
              ),
              child: Icon(icon, color: const Color(0xFF624294), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.authBgBottom))),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF624294).withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;

    if (isDark) {
      return Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.authBgMid, height: 1)),
                  const SizedBox(height: 6),
                  Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF624294).withOpacity(0.5))),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Light mode — matches home screen card style
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF624294).withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF624294).withOpacity(0.10),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.80),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.authBgMid, height: 1)),
            const SizedBox(height: 6),
            Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF624294).withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

