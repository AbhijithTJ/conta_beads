import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../dialog_box/logout_alert_dialog.dart';
import '../../login_and_register/login_screen.dart';
import '../../theme/theme_notifier.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  bool get _isDarkMode => themeNotifier.isDark;

  @override
  void initState() {
    super.initState();
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            color: isDark ? const Color(0xFF22014D) : const Color(0xFFF5EEF5),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text('MY PROFILE', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3.5, color: subColor)),
                    const SizedBox(height: 28),
                    _buildAvatar(),
                    const SizedBox(height: 16),
                    Text('John David', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text('MEMBER SINCE 2023', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2.0, color: subColor)),
                    const SizedBox(height: 32),
                    _buildStatsRow(),
                    const SizedBox(height: 36),
                    _buildSectionLabel('Account Details', sectionLabelColor),
                    const SizedBox(height: 12),
                    _buildDetailsCard(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Settings', sectionLabelColor),
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
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardLavender,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25, spreadRadius: 2)],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardLavender,
                ),
                child: const Center(
                  child: Text('JD', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF3D0227), letterSpacing: -1)),
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
              gradient: LinearGradient(colors: [AppColors.cardLavender, AppColors.cardLavender], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: const Color(0xFF22014D), width: 2.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Color(0xFF3D0227)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatBox(value: '342', label: 'Prayers'),
        const SizedBox(width: 12),
        _StatBox(value: '28', label: 'Novenas'),
        const SizedBox(width: 12),
        _StatBox(value: '14', label: 'Day Streak'),
      ],
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
    return _WhiteCard(
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined, label: 'Email Address', value: widget.userEmail),
          _divider(),
          _InfoRow(icon: Icons.phone_outlined, label: 'Phone Number', value: '+91 98765 43210'),
          _divider(),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Region', value: 'Kerala, India'),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 4), color: const Color(0xFF22014D).withOpacity(0.08));

  Widget _buildSettingsList() {
    return Column(
      children: [
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF22014D).withOpacity(0.08),
                    border: Border.all(color: const Color(0xFF22014D).withOpacity(0.15), width: 1),
                  ),
                  child: Icon(Icons.dark_mode_rounded, color: const Color(0xFF22014D), size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text('Dark Mode', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.authBgBottom))),
                Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: _isDarkMode,
                    activeColor: AppColors.goldPrimary,
                    activeTrackColor: AppColors.goldPrimary.withOpacity(0.3),
                    inactiveThumbColor: const Color(0xFF22014D).withOpacity(0.5),
                    inactiveTrackColor: const Color(0xFF22014D).withOpacity(0.1),
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
        _SettingRow(icon: Icons.history_rounded, title: 'Counting History'),
        const SizedBox(height: 12),
        _SettingRow(icon: Icons.security_rounded, title: 'Account Security'),
        const SizedBox(height: 12),
        _SettingRow(icon: Icons.help_outline_rounded, title: 'Help & Support'),
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
        child: const Center(child: Text('SIGN OUT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white))),
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
              color: const Color(0xFF22014D).withOpacity(0.08),
              border: Border.all(color: const Color(0xFF22014D).withOpacity(0.15), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF22014D), size: 20),
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
                color: const Color(0xFF22014D).withOpacity(0.08),
                border: Border.all(color: const Color(0xFF22014D).withOpacity(0.15), width: 1),
              ),
              child: Icon(icon, color: const Color(0xFF22014D), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.authBgBottom))),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF22014D).withOpacity(0.3), size: 24),
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
                Text(label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF22014D).withOpacity(0.5))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

