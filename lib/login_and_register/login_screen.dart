import 'package:flutter/material.dart';
import '../screens/home_page/counting_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Matching color constants from CountingScreen
  static const Color _goldPrimary = Color(0xFFD4A843);
  static const Color _goldLight = Color(0xFFF0C96A);
  static const Color _goldDark = Color(0xFFB8902E);
  static const Color _skyTop = Color(0xFFDCEEFB);
  static const Color _skyBottom = Color(0xFFB8D9F5);
  static const Color _skyMid = Color(0xFFC8E3F8);
  static const Color _textPrimary = Color(0xFF1A3A5C);
  static const Color _textSecondary = Color(0xFF4A6FA5);
  static const Color _cardWhite = Color(0xFFF5FAFF);

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username != 'admin' || password != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Invalid username or password',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CountingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_skyTop, _skyMid, _skyBottom],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                const SizedBox(height: 56),

                // ── Header (mirrors CountingScreen header) ──
                _buildHeader(),

                const SizedBox(height: 10),
                Text(
                  'Prayer Counter',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 52),

                // ── Login Card ──
                Container(
                  decoration: BoxDecoration(
                    color: _cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _goldPrimary.withOpacity(0.15),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        blurRadius: 12,
                        spreadRadius: -2,
                        offset: const Offset(-3, -3),
                      ),
                    ],
                    border: Border.all(
                      color: _goldPrimary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Username field
                      _buildInputField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Enter your username',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),

                      const SizedBox(height: 32),

                      // Login button
                      _buildLoginButton(),
                    ],
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFF8E7), Color(0xFFF5E8C0)],
            ),
            boxShadow: [
              BoxShadow(
                color: _goldPrimary.withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: _goldPrimary,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_goldDark, _goldPrimary, _goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Conta Beads',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.2,
              height: 1.0,
            ),
          ),
        ),
      ],
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _textSecondary.withOpacity(0.4),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: _textSecondary, size: 20),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: _textSecondary,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _goldPrimary.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _goldPrimary.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _goldPrimary, width: 1.5),
            ),
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
              ? LinearGradient(colors: [_goldPrimary.withOpacity(0.5), _goldDark.withOpacity(0.5)])
              : const LinearGradient(
                  colors: [Color(0xFFE8A020), Color(0xFFD4780A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFE8A020).withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
