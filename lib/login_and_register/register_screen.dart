import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final logoAsset = isDark ? 'assets/splash/ur_logo.png' : 'assets/splash/ur_logo_light.png';
    final subColor = isDark ? Colors.white.withOpacity(0.65) : AppColors.authBgMid.withOpacity(0.6);
    final backIconColor = isDark ? Colors.white : const Color(0xFF624294);
    final backBg = isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF624294).withOpacity(0.08);
    final backBorder = isDark ? Colors.white.withOpacity(0.30) : const Color(0xFF624294).withOpacity(0.25);
    final linkTextColor = isDark ? Colors.white.withOpacity(0.75) : AppColors.authBgMid.withOpacity(0.7);
    final linkColor = isDark ? Colors.white : AppColors.authPurple;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: isDark
              ? const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.4),
                    radius: 0.85,
                    colors: [
                      Color(0xFF321060),
                      Color(0xFF220850),
                      Color(0xFF1c023d),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                )
              : const BoxDecoration(color: Color(0xFFF0EBF0)),
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildHeader(logoAsset, subColor),
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
                        filter: ImageFilter.blur(sigmaX: isDark ? 10 : 0, sigmaY: isDark ? 10 : 0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: backBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: backBorder, width: 1.5),
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

  Widget _buildHeader(String logoAsset, Color subColor) {
    return Column(
      children: [
        Image.asset('assets/demo/logo_image.png', width: 160, height: 160),
        const SizedBox(height: 6),
        Text('Hearts United in Prayer.',
            style: GoogleFonts.poppins(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w500, color: subColor)),
      ],
    );
  }

  // ── Frosted glass card ───────────────────────────────────────────────────────
  Widget _buildGlassCard(bool isDark) {
    final titleColor = const Color(0xFF624294);
    final subColor = const Color(0xFF624294).withOpacity(0.60);

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CREATE ACCOUNT',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 3, color: titleColor)),
        const SizedBox(height: 4),
        Text('Become a disciple of prayer',
            style: GoogleFonts.poppins(fontSize: 12, color: subColor, letterSpacing: 0.3)),
        const SizedBox(height: 28),
        _buildGlassField(controller: _emailController, label: 'Email address', hint: 'Enter your email', icon: Icons.email_outlined, isDark: isDark),
        const SizedBox(height: 18),
        _buildPhoneField(isDark),
        const SizedBox(height: 18),
        _buildGlassField(controller: _passwordController, label: 'Password', hint: 'Create a password', icon: Icons.lock_outline_rounded, isPassword: true, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), isDark: isDark),
        const SizedBox(height: 18),
        _buildGlassField(controller: _confirmPasswordController, label: 'Confirm Password', hint: 'Repeat your password', icon: Icons.lock_reset_rounded, isPassword: true, obscure: _obscureConfirmPassword, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), isDark: isDark),
        const SizedBox(height: 28),
        _buildRegisterButton(),
      ],
    );

    if (isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 40, spreadRadius: 2, offset: const Offset(0, 12)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: cardContent,
          ),
        ),
      );
    }

    // Light mode — home screen card style
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF624294).withOpacity(0.10), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.white.withOpacity(0.80), blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: cardContent,
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
    bool isDark = true,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF624294).withOpacity(0.80),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: isDark ? 8 : 0, sigmaY: isDark ? 8 : 0),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              style: GoogleFonts.poppins(
                color: const Color(0xFF624294),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF624294).withOpacity(0.40),
                  fontSize: 14,
                ),
                prefixIcon: Icon(icon, color: const Color(0xFF624294).withOpacity(0.70), size: 20),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF624294).withOpacity(0.60),
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.80)
                    : const Color(0xFFF5F0FF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? const BorderSide(color: Colors.white, width: 2.0)
                      : BorderSide(color: const Color(0xFF624294).withOpacity(0.20), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? const BorderSide(color: Colors.white, width: 2.0)
                      : BorderSide(color: const Color(0xFF624294).withOpacity(0.20), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.7), width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Phone field with glass style ─────────────────────────────────────────────
  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF624294).withOpacity(0.80),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: isDark ? 8 : 0, sigmaY: isDark ? 8 : 0),
            child: IntlPhoneField(
              controller: _phoneController,
              initialCountryCode: 'IN',
              onChanged: (phone) => _completePhoneNumber = phone.completeNumber,
              style: GoogleFonts.poppins(
                color: const Color(0xFF624294),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              dropdownIconPosition: IconPosition.trailing,
              dropdownIcon: Icon(Icons.arrow_drop_down, color: const Color(0xFF624294).withOpacity(0.70), size: 20),
              dropdownTextStyle: GoogleFonts.poppins(
                color: const Color(0xFF624294),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              languageCode: 'en',
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.40), fontSize: 14),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.80)
                    : const Color(0xFFF5F0FF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? const BorderSide(color: Colors.white, width: 2.0)
                      : BorderSide(color: const Color(0xFF624294).withOpacity(0.20), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? const BorderSide(color: Colors.white, width: 2.0)
                      : BorderSide(color: const Color(0xFF624294).withOpacity(0.20), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.7), width: 1.5),
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
    final isDark = themeNotifier.isDark;
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF321060), const Color(0xFF220850), const Color(0xFF1c023d)]
                : [const Color(0xFF7B55A8), const Color(0xFF624294)],
            stops: isDark ? const [0.0, 0.5, 1.0] : const [0.0, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.75), width: 1.5),
          boxShadow: _isLoading ? [] : [
            BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: _isLoading
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
            : Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    left: 16,
                    child: Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                  ),
                  Text('Create account',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      )),
                ],
              ),
      ),
    );
  }

  // ── Login link ───────────────────────────────────────────────────────────────
  Widget _buildLoginLink(Color textColor, Color linkColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: GoogleFonts.poppins(color: textColor, fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Text('Log In', style: GoogleFonts.poppins(color: linkColor, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
      ],
    );
  }
}
