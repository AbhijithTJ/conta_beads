import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../providers/user_provider.dart';
import '../../theme/theme_notifier.dart';
import '../../services/localization_service.dart';
import '../../login_and_register/login_screen.dart';
import 'update_profile_screen.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
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

                // Security Options
                Text(
                  loc.tr('security_options').toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: isDark ? AppColors.goldLight.withOpacity(0.9) : AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Change Password Option
                _buildSecurityOption(
                  icon: Icons.lock_outline_rounded,
                  title: loc.tr('change_password'),
                  subtitle: loc.tr('update_your_password'),
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _ChangePasswordScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Update Account Details Option
                _buildSecurityOption(
                  icon: Icons.person_outline_rounded,
                  title: loc.tr('update_account_details'),
                  subtitle: 'Change your name, email, phone number and country code',
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Delete Account Option
                _buildSecurityOption(
                  icon: Icons.delete_outline_rounded,
                  title: loc.tr('delete_account'),
                  subtitle: loc.tr('permanently_delete_account'),
                  isDark: isDark,
                  isDestructive: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showDeleteAccountDialog(context, isDark);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final iconColor = isDestructive ? Colors.red : Colors.blue;

    if (isDark) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
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
                      color: iconColor.withOpacity(0.15),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.authBgBottom),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: const Color(0xFF624294).withOpacity(0.3), size: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: iconColor.withOpacity(0.15),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.authBgBottom),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFF624294).withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A1F5E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          loc.tr('delete_account'),
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.authBgBottom),
        ),
        content: Text(
          loc.tr('delete_account_warning'),
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : AppColors.authBgMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.tr('cancel'),
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDeletePasswordDialog(context, isDark);
            },
            child: Text(
              loc.tr('delete'),
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePasswordDialog(BuildContext context, bool isDark) {
    final passwordController = TextEditingController();
    bool showPassword = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A1F5E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            loc.tr('confirm_deletion'),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.authBgBottom),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.tr('enter_password_to_delete'),
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : AppColors.authBgMid),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF624294).withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.authBgBottom,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    hintText: loc.tr('password'),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withOpacity(0.3) : const Color(0xFF624294).withOpacity(0.3),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => showPassword = !showPassword),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF624294).withOpacity(0.5),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 100), () {
                  passwordController.dispose();
                });
              },
              child: Text(
                loc.tr('cancel'),
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294)),
              ),
            ),
            TextButton(
              onPressed: () {
                final password = passwordController.text;
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 100), () {
                  passwordController.dispose();
                });
                _deleteAccount(password);
              },
              child: Text(
                loc.tr('delete'),
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(String password) async {
    if (password.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.tr('password_required')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.deleteAccount(password: password);

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.tr('account_deleted_successfully')),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to login screen after deletion
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Import LoginScreen at the top of the file
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? loc.tr('failed_to_delete_account')),
          backgroundColor: Colors.red,
        ),
      );
    }
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
}

// ── Change Password Screen ────────────────────────────────────────────────────
class _ChangePasswordScreen extends StatefulWidget {
  const _ChangePasswordScreen();

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
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
    final success = await userProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
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
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
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
                        loc.tr('change_password'),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: headerColor),
                      ),
                    ),
                  ],
                ),
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
