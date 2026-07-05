import 'dart:ui';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../colors/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart';
import '../screens/onboarding/onboarding_wrapper.dart';
import '../services/session_service.dart';
import '../services/language_id_service.dart';
import '../services/localization_service.dart';
import '../theme/theme_notifier.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _localAuth = LocalAuthentication();
  late TextEditingController _contactController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  bool _hasCredentialsSaved = false;
  bool _isBiometricLoading = false;

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'ML', 'name': 'Malayalam'},
  ];

  @override
  void initState() {
    super.initState();
    _contactController = TextEditingController();
    _passwordController = TextEditingController();
    _initBiometric();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    developer.log('Biometric: Initializing biometric system');

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final session = SessionService.instance;
      
      developer.log('Biometric: canCheckBiometrics=$canCheck, isSupported=$isSupported');
      
      // Check if credentials are actually saved
      final savedCreds = await session.getBiometricCredentials();
      final hasCredentials = savedCreds != null;

      developer.log('Biometric: hasCredentials=$hasCredentials, biometricEnabled=${session.biometricEnabled}');

      setState(() {
        _biometricAvailable = canCheck && isSupported;
        _hasCredentialsSaved = hasCredentials;
        final saved = session.contact ?? '';
        if (saved.isNotEmpty) _contactController.text = saved;
      });

      // We removed the auto-trigger here so that biometric auth only happens when the user presses the button.
      if (_biometricAvailable && session.biometricEnabled && hasCredentials) {
        developer.log('Biometric: Auto-trigger disabled per user request. User must tap the button.');
      } else {
        developer.log('Biometric: Skipping auto-trigger (available=$_biometricAvailable, enabled=${session.biometricEnabled}, creds=$hasCredentials)');
      }
    } catch (e) {
      developer.log('Biometric: Error during initialization - $e');
      setState(() {
        _biometricAvailable = false;
        _hasCredentialsSaved = false;
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    // Fetch saved credentials from secure storage
    final creds = await SessionService.instance.getBiometricCredentials();
    if (creds == null) {
      developer.log('Biometric: No saved credentials found');
      _showError('No saved credentials. Please log in with your password first.');
      return;
    }

    // Add UI feedback that we're attempting biometric
    setState(() => _isBiometricLoading = true);

    developer.log('Biometric: Starting authentication');

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use biometrics to sign in to Rosary Bank',
        options: const AuthenticationOptions(
          biometricOnly: false, 
          stickyAuth: false,  // ✅ Add timeout instead of indefinite
        ),
      );

      developer.log('Biometric: Authentication result = $authenticated');

      if (!authenticated) {
        developer.log('Biometric: User cancelled or failed');
        if (mounted) {
          setState(() => _isBiometricLoading = false);
          _showError('Biometric authentication cancelled. Please try again.');
        }
        return;
      }

      if (!mounted) {
        developer.log('Biometric: Widget no longer mounted');
        return;
      }

      developer.log('Biometric: Authentication successful, calling API');

      // Replay the login API with saved credentials
      final auth = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      // Get FCM Token
      String fcmToken = '';
      try {
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      } catch (e) {
        developer.log('Biometric: Error getting FCM token: $e');
      }

      final success = await auth.login(
        contact: creds.contact,
        password: creds.password,
        fcmToken: fcmToken,
      );

      if (!mounted) {
        developer.log('Biometric: Widget unmounted before login completed');
        return;
      }

      if (success) {
        developer.log('Biometric: Login successful');
        if (auth.user != null) userProvider.setUser(auth.user!);
        _navigateToHome();
      } else {
        developer.log('Biometric: API login failed - ${auth.errorMessage}');
        setState(() => _isBiometricLoading = false);
        _showError('Biometric login failed. Please log in with your password.');
      }
    } on PlatformException catch (e) {
      developer.log('Biometric: PlatformException - ${e.code}: ${e.message}');
      
      if (mounted) setState(() => _isBiometricLoading = false);
      
      // Handle specific platform errors
      if (e.code == 'NotAvailable') {
        _showError('Biometric authentication not available on this device.');
      } else if (e.code == 'NotEnrolled') {
        _showError('No biometric data enrolled. Please set up biometrics in settings.');
      } else if (e.code == 'LockedOut') {
        _showError('Too many failed attempts. Please try again later.');
      } else if (e.code == 'PermanentlyLockedOut') {
        _showError('Biometric is locked. Please use your password to login.');
      } else {
        _showError('Biometric authentication failed: ${e.message}');
      }
    } catch (e) {
      developer.log('Biometric: Unexpected error - $e');
      if (mounted) setState(() => _isBiometricLoading = false);
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> _handleLogin() async {
    final contact = _contactController.text.trim();
    final password = _passwordController.text;

    if (contact.isEmpty || password.isEmpty) {
      _showError('Please enter your phone number and password');
      return;
    }

    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Get FCM Token
    String fcmToken = '';
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    final success = await auth.login(
      contact: contact,
      password: password,
      fcmToken: fcmToken,
    );

    if (!mounted) return;

    if (success) {
      // Sync user data into UserProvider.
      if (auth.user != null) userProvider.setUser(auth.user!);

      // Offer biometric on first login (not yet enabled).
      if (_biometricAvailable && !SessionService.instance.biometricEnabled) {
        await _offerBiometricSetup(contact, password);
      } else if (_biometricAvailable && SessionService.instance.biometricEnabled) {
        // Already enabled — refresh the stored credentials in case password changed.
        await SessionService.instance.saveBiometricCredentials(
          contact: contact,
          password: password,
        );
      }
      _navigateToHome();
    } else {
      _showError(auth.errorMessage ?? 'Login failed');
    }
  }

  Future<void> _offerBiometricSetup(String contact, String password) async {
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
            'Enable biometric login so you don\'t have to type your password next time.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (enable == true) {
      // Save credentials securely so biometric can replay the login API.
      await SessionService.instance.saveBiometricCredentials(
        contact: contact,
        password: password,
      );
      await SessionService.instance.setBiometricEnabled(true);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
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
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLanguagePicker() {
    HapticFeedback.lightImpact();
    final languageProvider = context.read<LanguageProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.language_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text('Select Language',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ]),
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: _languages.map((lang) {
                  final isSelected = lang['name'] == languageProvider.selectedLanguage;
                  return GestureDetector(
                    onTap: () async {
                      // Only proceed if language is different
                      if (lang['name'] == languageProvider.selectedLanguage) {
                        Navigator.pop(ctx);
                        return;
                      }

                      await languageProvider.setLanguage(lang['name']!);
                      // Sync language ID with the service
                      languageIdService.setLanguageByName(lang['name']!);
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.18)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withOpacity(0.55)
                              : Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(lang['code']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(lang['name']!,
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Read provider state here — inside build() — before any nested builders.
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);
    // Watch language provider to trigger full screen rebuild on language change
    context.watch<LanguageProvider>();

    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final logoAsset = isDark
            ? 'assets/demo/logo_image.png'
            : 'assets/demo/logo_image_light.png';
        final subColor = isDark
            ? Colors.white.withOpacity(0.65)
            : AppColors.authBgMid.withOpacity(0.6);
        final registerTextColor = isDark
            ? Colors.white.withOpacity(0.75)
            : AppColors.authBgMid.withOpacity(0.7);
        final registerLinkColor =
            isDark ? Colors.white : AppColors.authPurple;

        return GestureDetector(
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
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildLanguageButton(isDark),
                      const SizedBox(height: 40),
                      _buildHeader(logoAsset, subColor),
                      const SizedBox(height: 48),
                      _buildGlassCard(isDark, isLoading),
                      const SizedBox(height: 28),
                      _buildRegisterLink(registerTextColor, registerLinkColor),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String logoAsset, Color subColor) {
    return Column(
      children: [
        Image.asset(logoAsset, width: 160, height: 160),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: GoogleFonts.poppins(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
                color: subColor),
            children: [
              const TextSpan(text: 'Where '),
              TextSpan(
                  text: 'U',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: subColor)),
              const TextSpan(text: ' Find '),
              TextSpan(
                  text: 'R',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: subColor)),
              const TextSpan(text: 'est'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(bool isDark) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: _showLanguagePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFF624294).withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.25)
                      : const Color(0xFF624294).withOpacity(0.20),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_rounded,
                    color: isDark ? Colors.white : const Color(0xFF624294),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    languageProvider.selectedLanguage,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF624294),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.expand_more_rounded,
                    color: isDark ? Colors.white : const Color(0xFF624294),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassCard(bool isDark, bool isLoading) {
    final signInColor = const Color(0xFF624294);
    final subTextColor = const Color(0xFF624294).withOpacity(0.60);

    final biometricEnabled = SessionService.instance.biometricEnabled;
    final hasCredentials = _hasCredentialsSaved;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.tr('log_in'),
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: signInColor)),
        const SizedBox(height: 4),
        Text(loc.tr('return_to_prayer'),
            style: GoogleFonts.poppins(
                fontSize: 12, color: subTextColor, letterSpacing: 0.3)),
        const SizedBox(height: 28),
        _buildGlassField(
          controller: _contactController,
          label: loc.tr('phone_number_label'),
          hint: loc.tr('enter_phone_number'),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildGlassField(
          controller: _passwordController,
          label: loc.tr('password_label'),
          hint: loc.tr('enter_password'),
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscurePassword,
          onToggle: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(loc.tr('forgot_password'),
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldDark.withOpacity(0.85),
                  letterSpacing: 0.2)),
        ),
        const SizedBox(height: 28),
        _buildLoginButton(isLoading),
        // Show biometric button only when credentials are saved AND biometric is enabled
        if (_biometricAvailable && biometricEnabled && hasCredentials) ...[
          const SizedBox(height: 14),
          _buildBiometricButton(),
        ],
        // Show setup link only when biometric not yet enabled AND no credentials saved
        if (_biometricAvailable && !biometricEnabled && !hasCredentials) ...[
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () async {
                final contact = _contactController.text.trim();
                final password = _passwordController.text;
                if (contact.isEmpty || password.isEmpty) {
                  _showError(loc.tr('enter_phone_and_password'));
                  return;
                }
                await _offerBiometricSetup(contact, password);
              },
              child: Text(loc.tr('set_up_biometric'),
                  style: const TextStyle(
                      color: Color(0xFF624294),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF624294))),
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

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    bool isDark = true,
    TextInputType? keyboardType,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF624294).withOpacity(0.80),
              letterSpacing: 0.4,
            )),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: isDark ? 8 : 0, sigmaY: isDark ? 8 : 0),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscure : false,
              keyboardType: keyboardType,
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
                prefixIcon: Icon(icon,
                    color: const Color(0xFF624294).withOpacity(0.70),
                    size: 20),
                suffixIcon: isPassword
                    ? GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF624294).withOpacity(0.60),
                          size: 20,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.80)
                    : const Color(0xFFF5F0FF),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? const BorderSide(color: Colors.white, width: 2.0)
                      : BorderSide(
                          color: const Color(0xFF624294).withOpacity(0.20),
                          width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? const BorderSide(color: Colors.white, width: 2.0)
                      : BorderSide(
                          color: const Color(0xFF624294).withOpacity(0.20),
                          width: 1.5),
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

  bool _isPressed = false;

  Widget _buildLoginButton(bool isLoading) {
    final isDark = themeNotifier.isDark;
    return GestureDetector(
      onTap: isLoading ? null : _handleLogin,
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
                ? [
                    const Color(0xFF321060),
                    const Color(0xFF220850),
                    const Color(0xFF1c023d)
                  ]
                : [const Color(0xFF7B55A8), const Color(0xFF624294)],
            stops: isDark ? const [0.0, 0.5, 1.0] : const [0.0, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: AppColors.goldPrimary.withOpacity(0.75), width: 1.5),
          boxShadow: _isPressed || isLoading
              ? []
              : [
                  BoxShadow(
                      color: AppColors.goldPrimary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6)),
                ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5)))
            : Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    left: 16,
                    child: Icon(Icons.language_rounded,
                        color: Colors.white, size: 26),
                  ),
                  Text(loc.tr('continue_btn'),
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

  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _isBiometricLoading ? null : _authenticateWithBiometric,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF624294).withOpacity(_isBiometricLoading ? 0.25 : 0.45),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBiometricLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF624294)),
                ),
              )
            else
              const Icon(Icons.fingerprint, color: Color(0xFF624294), size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _isBiometricLoading 
                  ? 'Verifying...' 
                  : loc.tr('use_biometric'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF624294),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(Color textColor, Color linkColor) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(loc.tr('new_here'),
            style: GoogleFonts.poppins(color: textColor, fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: Text(loc.tr('create_account'),
              style: GoogleFonts.poppins(
                  color: linkColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ],
    );
  }
}
