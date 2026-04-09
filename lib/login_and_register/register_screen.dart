import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../colors/colors.dart';
import '../screens/bottom_nav_wrapper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String _completePhoneNumber = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Orb animations — same as login
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
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
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
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _orb4Controller.dispose();
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
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
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
                      const SizedBox(height: 48),
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildGlassCard(),
                      const SizedBox(height: 24),
                      _buildLoginLink(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // ── Back button ──
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
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.55),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.plumDeep.withOpacity(0.75),
                            size: 20,
                          ),
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

  // ── Animated floating orbs ──────────────────────────────────────────────────
  Widget _buildOrbs(Size size) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_orb1Anim, _orb2Anim, _orb3Anim, _orb4Anim]),
      builder: (context, _) {
        return Stack(
          children: [
            _Orb(
              left: size.width * 0.2,
              top: -size.height * 0.08 + _orb1Anim.value * 28,
              size: size.width * 0.72,
              colors: [
                AppColors.plumMid.withOpacity(0.55),
                AppColors.plumDeep.withOpacity(0.30),
              ],
            ),
            _Orb(
              left: -size.width * 0.22,
              top: size.height * 0.28 + _orb2Anim.value * -22,
              size: size.width * 0.65,
              colors: [
                AppColors.dustyRose.withOpacity(0.60),
                AppColors.dustyRose.withOpacity(0.25),
              ],
            ),
            _Orb(
              left: size.width * 0.55,
              top: size.height * 0.38 + _orb3Anim.value * 18,
              size: size.width * 0.60,
              colors: [
                AppColors.lavenderSoft.withOpacity(0.70),
                AppColors.plumMid.withOpacity(0.20),
              ],
            ),
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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/splash/upper_room.png', fit: BoxFit.cover),
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
            'Upper Room',
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
          'Join the community of prayer.',
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

  // ── Frosted glass card ───────────────────────────────────────────────────────
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
              Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: AppColors.plumDeep.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start your rosary journey today',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.plumMid.withOpacity(0.70),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),

              // Email
              _buildGlassField(
                controller: _emailController,
                label: 'Email address',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 18),

              // Phone
              _buildPhoneField(),
              const SizedBox(height: 18),

              // Password
              _buildGlassField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 18),

              // Confirm password
              _buildGlassField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Repeat your password',
                icon: Icons.lock_reset_rounded,
                isPassword: true,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
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
              obscureText: isPassword ? obscure : false,
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
                prefixIcon: Icon(icon,
                    color: AppColors.plumMid.withOpacity(0.70), size: 20),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.plumMid.withOpacity(0.60),
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.55),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.6)),
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
            color: AppColors.plumDeep.withOpacity(0.70),
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
                color: AppColors.plumDeep,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              dropdownIconPosition: IconPosition.trailing,
              dropdownIcon: Icon(Icons.arrow_drop_down,
                  color: AppColors.plumMid.withOpacity(0.70), size: 20),
              dropdownTextStyle: TextStyle(
                color: AppColors.plumDeep,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              languageCode: 'en',
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  color: AppColors.plumMid.withOpacity(0.40),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.55),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.6)),
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
          border: Border.all(
              color: Colors.white.withOpacity(0.35), width: 1.5),
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
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Login link ───────────────────────────────────────────────────────────────
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.plumDeep.withOpacity(0.60),
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: const Text(
            'Sign In',
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

// ── Orb widget (shared style) ──────────────────────────────────────────────────
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
