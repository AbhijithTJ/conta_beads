import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../providers/user_provider.dart';
import '../../theme/theme_notifier.dart';
import '../../services/localization_service.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    HapticFeedback.lightImpact();

    // Validate inputs
    if (_currentPasswordController.text.isEmpty) {
      _showError(loc.tr('current_password_required'));
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      _showError(loc.tr('new_password_required'));
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showError(loc.tr('password_min_length'));
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError(loc.tr('passwords_do_not_match'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateProfile(
      password: _newPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showSuccess(loc.tr('password_changed_successfully'));
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _showError(userProvider.errorMessage ?? loc.tr('failed_to_change_password'));
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    HapticFeedback.heavyImpact();
  }

  void _showSuccess(String message) {
    setState(() => _successMessage = message);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final headerColor = isDark ? Colors.white : AppColors.authBgBottom;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFF624294).withOpacity(0.08),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.30) : const Color(0xFF624294).withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF624294), size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        loc.tr('account_security'),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: headerColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Info Card
                _buildInfoCard(isDark),
                const SizedBox(height: 28),

                // Success Message
                if (_successMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Change Password Section
                Text(
                  loc.tr('change_password').toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: isDark ? AppColors.goldLight.withOpacity(0.9) : AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Current Password
                _buildPasswordField(
                  label: loc.tr('current_password'),
                  controller: _currentPasswordController,
                  isVisible: _showCurrentPassword,
                  onToggle: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // New Password
                _buildPasswordField(
                  label: loc.tr('new_password'),
                  controller: _newPasswordController,
                  isVisible: _showNewPassword,
                  onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildPasswordField(
                  label: loc.tr('confirm_password'),
                  controller: _confirmPasswordController,
                  isVisible: _showConfirmPassword,
                  onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  isDark: isDark,
                ),
                const SizedBox(height: 32),

                // Change Password Button
                GestureDetector(
                  onTap: _isLoading ? null : _changePassword,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: _isLoading
                            ? [Colors.grey.shade400, Colors.grey.shade600]
                            : [AppColors.goldPrimary, AppColors.goldDark],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isLoading ? Colors.grey : AppColors.goldPrimary).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              loc.tr('change_password'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    if (isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 40, spreadRadius: 2, offset: const Offset(0, 12))],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.15),
                  ),
                  child: Icon(Icons.lock_outline_rounded, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('keep_account_secure'),
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.authBgBottom),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.tr('change_password_regularly'),
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.6)),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.15),
            ),
            child: Icon(Icons.lock_outline_rounded, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tr('keep_account_secure'),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.authBgBottom),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.tr('change_password_regularly'),
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark ? Colors.white.withOpacity(0.50) : AppColors.authBgMid.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF624294).withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.authBgBottom,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF624294).withOpacity(0.5),
                  size: 18,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF624294).withOpacity(0.5),
                    size: 18,
                  ),
                ),
              ),
              hintText: label,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withOpacity(0.3) : const Color(0xFF624294).withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
