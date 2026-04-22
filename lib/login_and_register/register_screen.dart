import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../colors/colors.dart';
import '../screens/bottom_nav_wrapper.dart';
import '../theme/theme_notifier.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String _completePhoneNumber = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (!email.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BottomNavWrapper(userEmail: email)),
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bgColor = isDark ? AppColors.homeBg : const Color(0xFFF0EBF0);
    final logoAsset = isDark ? 'assets/splash/ur_logo.png' : 'assets/splash/ur_logo_light.png';
    final titleColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.65) : AppColors.authBgMid.withOpacity(0.6);
    final backIconColor = isDark ? Colors.white : AppColors.authPurple;
    final backBg = isDark ? Colors.white.withOpacity(0.35) : AppColors.authPurple.withOpacity(0.08);
    final backBorder = isDark ? Colors.white.withOpacity(0.55) : AppColors.authPurple.withOpacity(0.25);
    final linkTextColor = isDark ? Colors.white.withOpacity(0.75) : AppColors.authBgMid.withOpacity(0.7);
    final linkColor = isDark ? Colors.white : AppColors.authPurple;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: bgColor),
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildHeader(logoAsset, titleColor, subColor),
                      const SizedBox(height: 36),
                      _buildGlassCard(isDark),
                      const SizedBox(height: 24),
                      _buildLoginLink(linkTextColor, linkColor),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: backBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: backBorder, width: 1),
                          ),
                          child: Icon(Icons.arrow_back_rounded, color: backIconColor, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String logoAsset, Color titleColor, Color subColor) {
    return Column(
      children: [
        Image.asset(logoAsset, width: 140, height: 140),
        const SizedBox(height: 18),
        Text('Upper Room',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: titleColor, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text('Every bead of the rosary counts.',
            style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w500, color: subColor)),
      ],
    );
  }

  // ── Frosted glass card ───────────────────────────────────────────────────────
  Widget _buildGlassCard(bool isDark) {
    final cardBg = isDark ? Colors.white.withOpacity(0.92) : Colors.white;
    final titleColor = isDark ? AppColors.authBgMid : AppColors.authBgBottom;
    final subColor = isDark ? AppColors.authPurple.withOpacity(0.70) : AppColors.authBgMid.withOpacity(0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.20) : AppColors.authPurple.withOpacity(0.10),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CREATE ACCOUNT',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 3, color: titleColor)),
              const SizedBox(height: 4),
              Text('Start your rosary journey today',
                  style: TextStyle(fontSize: 12, color: subColor, letterSpacing: 0.3)),
              const SizedBox(height: 28),
              _buildGlassField(controller: _emailController, label: 'Email address', hint: 'Enter your email', icon: Icons.email_outlined),
              const SizedBox(height: 18),
              _buildPhoneField(),
              const SizedBox(height: 18),
              _buildGlassField(controller: _passwordController, label: 'Password', hint: 'Create a password', icon: Icons.lock_outline_rounded, isPassword: true, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
              const SizedBox(height: 18),
              _buildGlassField(controller: _confirmPasswordController, label: 'Confirm Password', hint: 'Repeat your password', icon: Icons.lock_reset_rounded, isPassword: true, obscure: _obscureConfirmPassword, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
              const SizedBox(height: 28),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Glass input field ────────────────────────────────────────────────────────
  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.authBgMid.withOpacity(0.80),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              style: TextStyle(
                color: AppColors.authBgBottom,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.authPurple.withOpacity(0.40),
                  fontSize: 14,
                ),
                prefixIcon: Icon(icon,
                    color: AppColors.authPurple.withOpacity(0.70), size: 20),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.authPurple.withOpacity(0.60),
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.80),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.authPurple.withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.authPurple.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppColors.goldPrimary.withOpacity(0.7),
                      width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Phone field with glass style ─────────────────────────────────────────────
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.authBgMid.withOpacity(0.80),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: IntlPhoneField(
              controller: _phoneController,
              initialCountryCode: 'IN',
              onChanged: (phone) => _completePhoneNumber = phone.completeNumber,
              style: TextStyle(
                color: AppColors.authBgBottom,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              dropdownIconPosition: IconPosition.trailing,
              dropdownIcon: Icon(Icons.arrow_drop_down,
                  color: AppColors.authPurple.withOpacity(0.70), size: 20),
              dropdownTextStyle: TextStyle(
                color: AppColors.authBgBottom,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              languageCode: 'en',
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  color: AppColors.authPurple.withOpacity(0.40),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.80),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.authPurple.withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.authPurple.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppColors.goldPrimary.withOpacity(0.7),
                      width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Register button ──────────────────────────────────────────────────────────
  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [
                    AppColors.homeBg.withOpacity(0.5),
                    AppColors.homeBg.withOpacity(0.5),
                  ]
                : [
                    AppColors.homeBg,
                    AppColors.homeBg,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.authBgBottom.withOpacity(0.60),
                    blurRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: AppColors.authPurple.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'Create account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Login link ───────────────────────────────────────────────────────────────
  Widget _buildLoginLink(Color textColor, Color linkColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: TextStyle(color: textColor, fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Text('Sign In', style: TextStyle(color: linkColor, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
      ],
    );
  }
}
