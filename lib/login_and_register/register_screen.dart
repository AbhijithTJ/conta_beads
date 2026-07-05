import 'dart:ui';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../colors/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/session_service.dart';
import '../services/localization_service.dart';
import '../providers/language_provider.dart';
import '../theme/theme_notifier.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String _phoneNumber = '';        // digits only, e.g. "8946257878"
  String _countryCode = '+91';     // with '+', e.g. "+91" — sent as-is to backend
  bool _isPhoneValid = false;      // tracks if phone number is valid for selected country
  String _selectedCountryName = 'India'; // for user-friendly error messages
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneNumber.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (!_isPhoneValid) {
      final digits = _phoneNumber.length;
      _showError(
        'Phone number for $_selectedCountryName ($_countryCode) is invalid'
        '${digits > 0 ? ' — you entered $digits digit${digits == 1 ? '' : 's'}' : ''}.',
      );
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

    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Get the real IANA timezone name from the device OS.
    // e.g. "America/Los_Angeles", "Asia/Kolkata", "Europe/London"
    String timezone;
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timezone = tzInfo.identifier;
    } catch (_) {
      // Fallback to UTC offset string if the plugin fails.
      final offset = DateTime.now().timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final hh = offset.inHours.abs().toString().padLeft(2, '0');
      final mm = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      timezone = 'UTC$sign$hh:$mm';
    }

    // Stable device identifier.
    final now = DateTime.now();
    final deviceId =
        '${Platform.operatingSystem}_${now.millisecondsSinceEpoch}';

    // Get FCM Token
    String fcmToken = '';
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    final success = await auth.register(
      name: name,
      email: email,
      countryCode: _countryCode,
      phone: phone,
      password: password,
      timezone: timezone,
      deviceId: deviceId,
      fcmToken: fcmToken,
    );

    if (!mounted) return;

    if (success) {
      // Registration succeeded — send to login so the user signs in properly.
      // This ensures biometric setup is offered on first login.
      await auth.logout(); // clear the auto-session created by register API
      // Save only the phone number (no country code) so login screen pre-fills it cleanly.
      await SessionService.instance.saveContact(_phoneNumber);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Account created! Please log in.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      _showError(auth.errorMessage ?? 'Registration failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
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
    // Read provider state at the top of build() — never inside nested builders.
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);
    context.watch<LanguageProvider>();

    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final logoAsset = isDark ? 'assets/demo/logo_image.png' : 'assets/demo/logo_image_light.png';
        final subColor = isDark ? Colors.white.withOpacity(0.65) : AppColors.authBgMid.withOpacity(0.6);
        final backIconColor = isDark ? Colors.white : const Color(0xFF624294);
        final backBg = isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF624294).withOpacity(0.08);
        final backBorder = isDark ? Colors.white.withOpacity(0.30) : const Color(0xFF624294).withOpacity(0.25);
        final linkTextColor = isDark ? Colors.white.withOpacity(0.75) : AppColors.authBgMid.withOpacity(0.7);
        final linkColor = isDark ? Colors.white : AppColors.authPurple;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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
                        _buildGlassCard(isDark, isLoading),
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
      ),
    );
      }, // ValueListenableBuilder builder
    );   // ValueListenableBuilder
  }

  Widget _buildHeader(String logoAsset, Color subColor) {
    return Column(
      children: [
        Image.asset(logoAsset, width: 160, height: 160),
        const SizedBox(height: 6),
        Text.rich(
            TextSpan(
              style: GoogleFonts.poppins(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w500, color: subColor),
              children: [
                const TextSpan(text: 'Where '),
                TextSpan(text: 'U', style: GoogleFonts.poppins(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: subColor)),
                const TextSpan(text: ' Find '),
                TextSpan(text: 'R', style: GoogleFonts.poppins(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: subColor)),
                const TextSpan(text: 'est'),
              ],
            ),
          ),
      ],
    );
  }

  // ── Frosted glass card ───────────────────────────────────────────────────────
  Widget _buildGlassCard(bool isDark, bool isLoading) {
    final titleColor = const Color(0xFF624294);
    final subColor = const Color(0xFF624294).withOpacity(0.60);

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.tr('create_account'),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 3, color: titleColor)),
        const SizedBox(height: 4),
        Text(loc.tr('become_disciple'),
            style: GoogleFonts.poppins(fontSize: 12, color: subColor, letterSpacing: 0.3)),
        const SizedBox(height: 28),
        _buildGlassField(controller: _nameController, label: loc.tr('full_name'), hint: loc.tr('enter_name'), icon: Icons.person_outline_rounded, isDark: isDark),
        const SizedBox(height: 18),
        _buildGlassField(controller: _emailController, label: loc.tr('email_address_label'), hint: loc.tr('enter_email'), icon: Icons.email_outlined, isDark: isDark),
        const SizedBox(height: 18),
        _buildPhoneField(isDark),
        const SizedBox(height: 18),
        _buildGlassField(controller: _passwordController, label: loc.tr('password'), hint: loc.tr('create_password'), icon: Icons.lock_outline_rounded, isPassword: true, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), isDark: isDark),
        const SizedBox(height: 18),
        _buildGlassField(controller: _confirmPasswordController, label: loc.tr('confirm_password'), hint: loc.tr('repeat_password'), icon: Icons.lock_reset_rounded, isPassword: true, obscure: _obscureConfirmPassword, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), isDark: isDark),
        const SizedBox(height: 28),
        _buildRegisterButton(isLoading),
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
          loc.tr('phone_number_reg'),
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
              // Disable ALL built-in inline validation — we validate on submit only.
              autovalidateMode: AutovalidateMode.disabled,
              disableLengthCheck: true,
              invalidNumberMessage: null,
              // onChanged fires on every keystroke — update state and validity.
              onChanged: (phone) {
                _countryCode = '+${phone.countryCode.replaceAll('+', '')}'; // always "+XX"
                _phoneNumber = phone.number;
                // isValidNumber() throws NumberTooShortException / NumberTooLongException
                // while the user is still typing — catch and treat as invalid.
                bool valid = false;
                try {
                  valid = phone.isValidNumber();
                } catch (_) {
                  valid = false;
                }
                setState(() => _isPhoneValid = valid);
              },
              // onCountryChanged fires when the user picks a different country —
              // reset validity so the old number isn't silently accepted.
              onCountryChanged: (country) {
                setState(() {
                  _isPhoneValid = false;
                  _selectedCountryName = country.name;
                  _countryCode = '+${country.dialCode}'; // always "+XX"
                });
              },
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
                hintText: loc.tr('enter_phone'),
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
  Widget _buildRegisterButton(bool isLoading) {
    final isDark = themeNotifier.isDark;
    return GestureDetector(
      onTap: isLoading ? null : _handleRegister,
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
          boxShadow: isLoading ? [] : [
            BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: isLoading
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
            : Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    left: 16,
                    child: Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                  ),
                  Text(loc.tr('create_account_btn'),
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
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(loc.tr('already_have_account'), style: GoogleFonts.poppins(color: textColor, fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Text(loc.tr('log_in_link'), style: GoogleFonts.poppins(color: linkColor, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
      ],
    );
  }
}
