import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';
import '../../dialog_box/logout_alert_dialog.dart';
import '../../login_and_register/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isDarkMode = true;

  // Orb float animations
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _orb4Controller;
  late Animation<double> _orb1Anim;
  late Animation<double> _orb2Anim;
  late Animation<double> _orb3Anim;
  late Animation<double> _orb4Anim;

  @override
  void initState() {
    super.initState();
    _initOrbAnimations();
  }

  void _initOrbAnimations() {
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    )..repeat(reverse: true);
    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
    _orb4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    )..repeat(reverse: true);

    _orb1Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb1Controller, curve: Curves.easeInOut),
    );
    _orb2Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb2Controller, curve: Curves.easeInOut),
    );
    _orb3Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb3Controller, curve: Curves.easeInOut),
    );
    _orb4Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _orb4Controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _orb4Controller.dispose();
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
    final size = MediaQuery.of(context).size;
    final isDark = _isDarkMode;

    // Theme dynamic colors
    final bgColors = isDark
        ? [AppColors.authBgTop, AppColors.authBgMid, AppColors.authBgBottom]
        : [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom];
    final headerTextColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subHeaderTextColor = isDark ? Colors.white.withOpacity(0.65) : AppColors.authBgMid.withOpacity(0.7);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: Stack(
          children: [
            // ── Animated floating orbs ──
            _buildOrbs(size),

            // ── Content ──
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'MY PROFILE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                        color: subHeaderTextColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildAvatar(isDark),
                    const SizedBox(height: 16),
                    Text(
                      'John David',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: headerTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'MEMBER SINCE 2023',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: subHeaderTextColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStatsRow(isDark),
                    const SizedBox(height: 36),
                    _buildSectionLabel('Account Details', isDark),
                    const SizedBox(height: 12),
                    _buildDetailsCard(isDark),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Settings', isDark),
                    const SizedBox(height: 12),
                    _buildSettingsList(isDark),
                    const SizedBox(height: 40),
                    _buildLogoutButton(context),
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

  Widget _buildOrbs(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orb1Anim, _orb2Anim, _orb3Anim, _orb4Anim]),
      builder: (context, _) {
        return Stack(
          children: [
            _Orb(
              left: size.width * 0.2,
              top: -size.height * 0.08 + _orb1Anim.value * 28,
              size: size.width * 0.72,
              colors: [
                AppColors.authPurple.withOpacity(0.55),
                AppColors.authBgTop.withOpacity(0.30),
              ],
            ),
            _Orb(
              left: -size.width * 0.22,
              top: size.height * 0.28 + _orb2Anim.value * -22,
              size: size.width * 0.65,
              colors: [
                AppColors.authPurpleLight.withOpacity(0.45),
                AppColors.authPurple.withOpacity(0.25),
              ],
            ),
            _Orb(
              left: size.width * 0.55,
              top: size.height * 0.38 + _orb3Anim.value * 18,
              size: size.width * 0.60,
              colors: [
                AppColors.authBgMid.withOpacity(0.70),
                AppColors.authBgBottom.withOpacity(0.40),
              ],
            ),
            _Orb(
              left: size.width * 0.1,
              top: size.height * 0.72 + _orb4Anim.value * -16,
              size: size.width * 0.55,
              colors: [
                AppColors.goldPrimary.withOpacity(0.18),
                AppColors.authPurple.withOpacity(0.25),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.3),
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
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.92),
                    border: Border.all(
                      color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'JD',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.authBgBottom,
                        letterSpacing: -1,
                      ),
                    ),
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
                gradient: const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.goldPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: isDark ? AppColors.authBgMid : Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _StatBox(value: '342', label: 'Prayers', isDark: isDark),
        const SizedBox(width: 12),
        _StatBox(value: '28', label: 'Novenas', isDark: isDark),
        const SizedBox(width: 12),
        _StatBox(value: '14', label: 'Day Streak', isDark: isDark),
      ],
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: isDark ? AppColors.goldLight.withOpacity(0.9) : AppColors.goldDark,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined, label: 'Email Address', value: widget.userEmail, isDark: isDark),
          _buildCardDivider(isDark),
          _InfoRow(icon: Icons.phone_outlined, label: 'Phone Number', value: '+91 98765 43210', isDark: isDark),
          _buildCardDivider(isDark),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Region', value: 'Kerala, India', isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildCardDivider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.authPurple.withOpacity(0.1),
      ),
    );
  }

  Widget _buildSettingsList(bool isDark) {
    return Column(
      children: [
        _buildDarkThemeToggle(isDark),
        const SizedBox(height: 12),
        _SettingRow(icon: Icons.history_rounded, title: 'Counting History', isDark: isDark),
        const SizedBox(height: 12),
        _SettingRow(icon: Icons.security_rounded, title: 'Account Security', isDark: isDark),
        const SizedBox(height: 12),
        _SettingRow(icon: Icons.help_outline_rounded, title: 'Help & Support', isDark: isDark),
      ],
    );
  }

  Widget _buildDarkThemeToggle(bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _IconBox(icon: Icons.dark_mode_rounded, size: 40, iconSize: 18, radius: 12, isDark: isDark),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.authBgBottom,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                value: _isDarkMode,
                activeColor: AppColors.goldPrimary,
                activeTrackColor: AppColors.goldPrimary.withOpacity(0.3),
                inactiveThumbColor: AppColors.authPurple.withOpacity(0.5),
                inactiveTrackColor: AppColors.authPurple.withOpacity(0.1),
                onChanged: (val) {
                  setState(() => _isDarkMode = val);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
        ),
      ),
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
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.shade400,
              Colors.red.shade800,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'SIGN OUT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Glassmorphic Card ────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _GlassCard({required this.child, required this.isDark});

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
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.95),
              width: 1.5,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _IconBox(icon: icon, isDark: isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white.withOpacity(0.4) : AppColors.authBgMid.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.authBgBottom,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
  final bool isDark;
  const _SettingRow({required this.icon, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _IconBox(icon: icon, size: 40, iconSize: 18, radius: 12, isDark: isDark),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.authBgBottom,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white.withOpacity(0.2) : AppColors.authPurple.withOpacity(0.3),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon Box ─────────────────────────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final double radius;
  final bool isDark;

  const _IconBox({
    required this.icon,
    this.size = 42,
    this.iconSize = 20,
    this.radius = 14,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.authPurple.withOpacity(0.08),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.authPurple.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Icon(icon, color: isDark ? Colors.white.withOpacity(0.8) : AppColors.authPurple, size: iconSize),
    );
  }
}

// ── Stat Box ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;
  const _StatBox({required this.value, required this.label, required this.isDark});

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
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.95), width: 1),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.authBgMid,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white.withOpacity(0.4) : AppColors.authPurple.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Orb Widget ───────────────────────────────────────────────────────────────
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
