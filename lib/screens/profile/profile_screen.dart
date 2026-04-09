import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';
import '../../dialog_box/logout_alert_dialog.dart';
import '../../login_and_register/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.userEmail,
  });

  Future<void> _logout(BuildContext context) async {
    HapticFeedback.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LogoutAlertDialog(),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgTop,
              AppColors.bgMid,
              AppColors.bgBottom,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                _buildPageLabel(),
                const SizedBox(height: 28),
                _buildAvatar(),
                const SizedBox(height: 16),
                _buildUserName(),
                const SizedBox(height: 6),
                _buildUserSubtitle(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 28),
                _buildGoldDivider(),
                const SizedBox(height: 28),
                _buildSectionLabel('Account Details'),
                const SizedBox(height: 10),
                _buildDetailsCard(),
                const SizedBox(height: 24),
                _buildSectionLabel('Settings'),
                const SizedBox(height: 10),
                _buildSettingsList(),
                const SizedBox(height: 28),
                _buildLogoutButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageLabel() {
    return Text(
      'MY PROFILE',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.5,
        color: AppColors.goldDark.withOpacity(0.7),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardWhite,
              ),
              child: const Center(
                child: Text(
                  'JD',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.goldPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'John David',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildUserSubtitle() {
    return Text(
      'MEMBER SINCE 2023',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
        color: AppColors.textSecondary.withOpacity(0.6),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatBox(value: '342', label: 'Prayers'),
        const SizedBox(width: 8),
        _StatBox(value: '28', label: 'Novenas'),
        const SizedBox(width: 8),
        _StatBox(value: '14', label: 'Day Streak'),
      ],
    );
  }

  Widget _buildGoldDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.goldPrimary.withOpacity(0.3)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '✦',
            style: TextStyle(fontSize: 11, color: AppColors.goldPrimary.withOpacity(0.5)),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldPrimary.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
          color: AppColors.goldDark.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _LightCard(
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined, label: 'Email Address', value: userEmail),
          _buildCardDivider(),
          _InfoRow(icon: Icons.phone_outlined, label: 'Phone Number', value: '+91 98765 43210'),
          _buildCardDivider(),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Region', value: 'Kerala, India'),
        ],
      ),
    );
  }

  Widget _buildCardDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.goldPrimary.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return const Column(
      children: [
        _SettingRow(icon: Icons.layers_rounded, title: 'Counting History'),
        SizedBox(height: 8),
        _SettingRow(icon: Icons.shield_outlined, title: 'Account Security'),
        SizedBox(height: 8),
        _SettingRow(icon: Icons.help_outline_rounded, title: 'Help & Support'),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFB43232).withOpacity(0.85),
              const Color(0xFF8C1919).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFFC85050).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFFFC8C8), size: 18),
            SizedBox(width: 10),
            Text(
              'SIGN OUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: Color(0xFFFFC8C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable: Light Card (matches intentions screen) ────────────────────────
class _LightCard extends StatelessWidget {
  final Widget child;
  const _LightCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Reusable: Info Row ───────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: AppColors.goldDark.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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

// ─── Reusable: Setting Row ────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _IconBox(icon: icon, size: 38, iconSize: 17, radius: 11),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary.withOpacity(0.4),
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable: Icon Box ───────────────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final double radius;

  const _IconBox({
    required this.icon,
    this.size = 42,
    this.iconSize = 18,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: AppColors.goldPrimary.withOpacity(0.1),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Icon(icon, color: AppColors.goldDark, size: iconSize),
    );
  }
}

// ─── Reusable: Stat Box ───────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldPrimary.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.goldDark,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
