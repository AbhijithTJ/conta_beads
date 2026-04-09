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

    // Auto-trigger biometric if already set up
    if (_biometricAvailable && _biometricEnabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Use biometrics to sign in to Rosary Bank',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString(_prefKeyEmail) ?? 'admin@gmail.com';
        _navigateToHome(email);
      }
    } catch (_) {
      // biometric failed or cancelled — user can still use password
    }
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email != 'admin@gmail.com' || password != '1234') {
      _showError('Invalid email or password');
      return;
    }

    setState(() => _isLoading = true);

    // Offer to enable biometric after first successful password login
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
        content: const Text(
          'Enable biometric login so you don\'t have to type your password next time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.skyTop.withOpacity(0.05),
              AppColors.skyMid.withOpacity(0.05),
              AppColors.skyBottom.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const SizedBox(height: 56),
                _buildHeader(),
                const SizedBox(height: 10),
                Text(
                  'Every bead of the rosary counts.',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 52),
                _buildLoginCard(),
                const SizedBox(height: 24),
                _buildRegisterLink(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.goldPrimary.withOpacity(0.35), blurRadius: 24, spreadRadius: 3),
              BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 12, spreadRadius: -2),
            ],
            border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 2),
          ),
          child: ClipOval(child: Image.asset('assets/splash/splash_org.png', fit: BoxFit.cover)),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Rosary Bank',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 32, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 12, spreadRadius: -2, offset: const Offset(-3, -3)),
        ],
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('Sign in to continue', style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.8))),
          const SizedBox(height: 28),
          _buildInputField(controller: _emailController, label: 'Email', hint: 'Enter your email', icon: Icons.email_outlined),
          const SizedBox(height: 20),
          _buildInputField(controller: _passwordController, label: 'Password', hint: 'Enter your password', icon: Icons.lock_outline_rounded, isPassword: true),
          const SizedBox(height: 32),
          _buildLoginButton(),

          // Biometric button — shown only when available & enabled
          if (_biometricAvailable && _biometricEnabled) ...[
            const SizedBox(height: 16),
            _buildBiometricButton(),
          ],

          // "Set up biometric" hint — shown when available but not yet enabled
          if (_biometricAvailable && !_biometricEnabled) ...[
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _authenticateWithBiometric,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.goldPrimary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: AppColors.goldPrimary, size: 26),
            SizedBox(width: 10),
            Text(
              'Use Biometric',
              style: TextStyle(color: AppColors.goldDark, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.4)),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(colors: [AppColors.goldPrimary.withOpacity(0.5), AppColors.goldDark.withOpacity(0.5)])
              : const LinearGradient(colors: [AppColors.goldAccent, AppColors.goldAccentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isLoading ? [] : [BoxShadow(color: AppColors.goldAccent.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8))),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: const Text('Register', style: TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
