import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/colors.dart';
import '../screens/onboarding/onboarding_wrapper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _auth = LocalAuthentication();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  // Orb float animations
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _orb4Controller;
  late Animation<double> _orb1Anim;
  late Animation<double> _orb2Anim;
  late Animation<double> _orb3Anim;
  late Animation<double> _orb4Anim;

  static const _prefKeyBiometric = 'biometric_enabled';
  static const _prefKeyEmail = 'saved_email';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _initBiometric();
    _initOrbAnimations();
  }

  void _initOrbAnimations() {
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    )..repeat(reverse: true);
    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _orb4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6400),
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
    _emailController.dispose();
    _passwordController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _orb4Controller.dispose();
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Base gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bgTop,
              AppColors.bgMid,
              AppColors.bgBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Floating orbs ──
            _buildOrbs(size),

            // ── Content ──
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildGlassCard(),
                    const SizedBox(height: 28),
                    _buildRegisterLink(),
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

  // ── Animated floating orbs ──────────────────────────────────────────────────
  Widget _buildOrbs(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orb1Anim, _orb2Anim, _orb3Anim, _orb4Anim]),
      builder: (context, _) {
        return Stack(
          children: [
            // Top-center large orb — plum
            _Orb(
              left: size.width * 0.2,
              top: -size.height * 0.08 + _orb1Anim.value * 28,
              size: size.width * 0.72,
              colors: [
                AppColors.plumMid.withOpacity(0.55),
                AppColors.plumDeep.withOpacity(0.30),
              ],
            ),
            // Left-middle orb — dusty rose
            _Orb(
              left: -size.width * 0.22,
              top: size.height * 0.28 + _orb2Anim.value * -22,
              size: size.width * 0.65,
              colors: [
                AppColors.dustyRose.withOpacity(0.60),
                AppColors.dustyRose.withOpacity(0.25),
              ],
            ),
            // Right-middle orb — lavender
            _Orb(
              left: size.width * 0.55,
              top: size.height * 0.38 + _orb3Anim.value * 18,
              size: size.width * 0.60,
              colors: [
                AppColors.lavenderSoft.withOpacity(0.70),
                AppColors.plumMid.withOpacity(0.20),
              ],
            ),
            // Bottom-center orb — gold tint
            _Orb(
              left: size.width * 0.1,
              top: size.height * 0.72 + _orb4Anim.value * -16,
              size: size.width * 0.55,
              colors: [
                AppColors.goldPrimary.withOpacity(0.22),
                AppColors.dustyRose.withOpacity(0.30),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Header: logo + app name ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with gold glow ring
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withOpacity(0.40),
                blurRadius: 28,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: AppColors.plumMid.withOpacity(0.20),
                blurRadius: 14,
                spreadRadius: -2,
              ),
            ],
            border: Border.all(
              color: AppColors.goldPrimary.withOpacity(0.35),
              width: 2.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset('assets/splash/splash_org.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.plumMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Rosary Bank',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Every bead of the rosary counts.',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
            color: AppColors.plumDeep.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  // ── Frosted glass login card ────────────────────────────────────────────────
  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.30),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.plumMid.withOpacity(0.12),
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
              // Card title
              Text(
                'SIGN IN',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: AppColors.plumDeep.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, continue your prayer journey',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.plumMid.withOpacity(0.70),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),

              // Email field
              _buildGlassField(
                controller: _emailController,
                label: 'Email address',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 18),

              // Password field
              _buildGlassField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 10),

              // Forgot password row
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldDark.withOpacity(0.85),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Login button
              _buildLoginButton(),

              // Biometric
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
                    child: Text(
                      'Set up biometric login',
                      style: TextStyle(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.goldDark,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Glass-style input field ─────────────────────────────────────────────────
  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.plumDeep.withOpacity(0.70),
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
              obscureText: isPassword ? _obscurePassword : false,
              style: TextStyle(
                color: AppColors.plumDeep,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.plumMid.withOpacity(0.40),
                  fontSize: 14,
                ),
                prefixIcon: Icon(icon, color: AppColors.plumMid.withOpacity(0.70), size: 20),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.plumMid.withOpacity(0.60),
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.55),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
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
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(colors: [
                  AppColors.goldPrimary.withOpacity(0.5),
                  AppColors.goldDark.withOpacity(0.5),
                ])
              : const LinearGradient(
                  colors: [AppColors.goldAccent, AppColors.goldAccentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.goldAccent.withOpacity(0.50),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Biometric button ────────────────────────────────────────────────────────
  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _authenticateWithBiometric,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.40), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint, color: AppColors.goldPrimary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Use Biometric',
                  style: TextStyle(
                    color: AppColors.plumDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Register link ───────────────────────────────────────────────────────────
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColors.plumDeep.withOpacity(0.60),
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text(
            'Register',
            style: TextStyle(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Orb widget ─────────────────────────────────────────────────────────────────
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
