import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/colors.dart';
import '../screens/onboarding/onboarding_wrapper.dart';
import '../theme/theme_notifier.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = LocalAuthentication();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  static const _prefKeyBiometric = 'biometric_enabled';
  static const _prefKeyEmail = 'saved_email';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _initBiometric();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefKeyBiometric) ?? false;
    final savedEmail = prefs.getString(_prefKeyEmail) ?? '';
    setState(() {
      _biometricAvailable = canCheck && isSupported;
      _biometricEnabled = enabled;
      if (savedEmail.isNotEmpty) _emailController.text = savedEmail;
    });
    if (_biometricAvailable && _biometricEnabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Use biometrics to sign in to Rosary Bank',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (authenticated && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString(_prefKeyEmail) ?? 'admin@gmail.com';
        _navigateToHome(email);
      }
    } catch (_) {}
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email != 'admin@gmail.com' || password != '1234') {
      _showError('Invalid email or password');
      return;
    }
    setState(() => _isLoading = true);
    if (_biometricAvailable && !_biometricEnabled) {
      await _offerBiometricSetup(email);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyEmail, email);
    }
    if (mounted) _navigateToHome(email);
  }

  Future<void> _offerBiometricSetup(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyEmail, email);
    if (!mounted) return;
    final enable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.goldPrimary),
            SizedBox(width: 10),
            Text('Quick Login', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text('Enable biometric login so you don\'t have to type your password next time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (enable == true) {
      await prefs.setBool(_prefKeyBiometric, true);
      setState(() => _biometricEnabled = true);
    }
  }

  void _navigateToHome(String email) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OnboardingWrapper(userEmail: email)),
      (route) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
    final titleColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.65) : AppColors.authBgMid.withOpacity(0.6);
    final registerTextColor = isDark ? Colors.white.withOpacity(0.75) : AppColors.authBgMid.withOpacity(0.7);
    final registerLinkColor = isDark ? Colors.white : AppColors.authPurple;

    return Scaffold(
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
                    const SizedBox(height: 60),
                    _buildHeader(logoAsset, titleColor, subColor),
                    const SizedBox(height: 48),
                    _buildGlassCard(isDark),
                    const SizedBox(height: 28),
                    _buildRegisterLink(registerTextColor, registerLinkColor),
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

  // ── Header: logo + app name ─────────────────────────────────────────────────
  Widget _buildHeader(String logoAsset, Color titleColor, Color subColor) {
    return Column(
      children: [
        Image.asset('assets/demo/logo_image.png', width: 160, height: 160),
        const SizedBox(height: 6),
        Text('Hearts United in Prayer.',
            style: GoogleFonts.poppins(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
                color: subColor)),
      ],
    );
  }

  // ── Frosted glass login card ────────────────────────────────────────────────
  Widget _buildGlassCard(bool isDark) {
    final signInColor = const Color(0xFF624294);
    final subTextColor = const Color(0xFF624294).withOpacity(0.60);

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SIGN IN',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: signInColor)),
        const SizedBox(height: 4),
        Text('Welcome back, continue your prayer journey',
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: subTextColor,
                letterSpacing: 0.3)),
        const SizedBox(height: 28),
        _buildGlassField(
          controller: _emailController,
          label: 'Email address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildGlassField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text('Forgot password?',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldDark.withOpacity(0.85),
                  letterSpacing: 0.2)),
        ),
        const SizedBox(height: 28),
        _buildLoginButton(),
        if (_biometricAvailable && _biometricEnabled) ...[
          const SizedBox(height: 14),
          _buildBiometricButton(),
        ],
        if (_biometricAvailable && !_biometricEnabled) ...[
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                if (email != 'admin@gmail.com' || password != '1234') {
                  _showError('Sign in with your password first to enable biometrics');
                  return;
                }
                await _offerBiometricSetup(email);
              },
              child: Text('Set up biometric login',
                  style: TextStyle(
                      color: AppColors.authPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.authPurple)),
            ),
          ),
        ],
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
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
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: cardContent,
    );
  }

  // ── Glass-style input field ─────────────────────────────────────────────────
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

  // ── Login button ────────────────────────────────────────────────────────────
  bool _isPressed = false;

  Widget _buildLoginButton() {
    final isDark = themeNotifier.isDark;
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 56,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
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
          boxShadow: _isPressed || _isLoading ? [] : [
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
                    child: Icon(Icons.language_rounded, color: Colors.white, size: 26),
                  ),
                  Text('Sign in',
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

  // ── Biometric button ────────────────────────────────────────────────────────
  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _authenticateWithBiometric,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF624294).withOpacity(0.45), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: const Color(0xFF624294), size: 22),
            const SizedBox(width: 8),
            Text(
              'Use biometric login',
              style: GoogleFonts.poppins(
                color: const Color(0xFF624294),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Register link ───────────────────────────────────────────────────────────
  Widget _buildRegisterLink(Color textColor, Color linkColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ",
            style: GoogleFonts.poppins(color: textColor, fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: Text('Register',
              style: GoogleFonts.poppins(
                  color: linkColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ],
    );
  }
}
