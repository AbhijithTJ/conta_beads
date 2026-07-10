import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../colors/colors.dart';
import '../providers/auth_provider.dart';
import '../services/localization_service.dart';
import '../theme/theme_notifier.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || phone.isEmpty) {
      _showError('Please enter your email and phone number');
      return;
    }

    final auth = context.read<AuthProvider>();
    
    // Call forgot password API
    final newPassword = await auth.forgotPassword(email: email, phone: phone);
    
    if (!mounted) return;

    if (newPassword != null) {
      _showSuccessDialog(newPassword);
    } else {
      _showError(auth.errorMessage ?? 'Forgot password failed');
    }
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

  void _showSuccessDialog(String newPassword) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.tr('success'),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF624294),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.tr('password_reset_success_msg'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF624294).withOpacity(0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF624294).withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        newPassword,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF624294),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: newPassword));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.tr('password_copied'), style: const TextStyle(fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.copy_rounded,
                            color: const Color(0xFF624294).withOpacity(0.8),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.tr('change_password_note'),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.blue.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.tr('important_warning'),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red.shade800,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Go back to login
                  },
                  child: Text(
                    loc.tr('back_to_login'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
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
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);

    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final logoAsset = isDark
            ? 'assets/demo/logo_image.png'
            : 'assets/demo/logo_image_light.png';
        final subColor = isDark
            ? Colors.white.withOpacity(0.65)
            : AppColors.authBgMid.withOpacity(0.6);
            
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.authBgMid),
            ),
            extendBodyBehindAppBar: true,
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
                      _buildHeader(logoAsset, subColor),
                      const SizedBox(height: 48),
                      _buildGlassCard(isDark, isLoading),
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

  Widget _buildGlassCard(bool isDark, bool isLoading) {
    final signInColor = const Color(0xFF624294);
    final subTextColor = const Color(0xFF624294).withOpacity(0.60);

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.tr('reset_password'),
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: signInColor)),
        const SizedBox(height: 4),
        Text(loc.tr('enter_email_and_phone'),
            style: GoogleFonts.poppins(
                fontSize: 12, color: subTextColor, letterSpacing: 0.3)),
        const SizedBox(height: 28),
        _buildGlassField(
          controller: _emailController,
          label: loc.tr('email'),
          hint: loc.tr('enter_your_email'),
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildGlassField(
          controller: _phoneController,
          label: loc.tr('phone_number_label'),
          hint: loc.tr('enter_phone_number'),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isDark: isDark,
        ),
        const SizedBox(height: 28),
        _buildSubmitButton(isLoading),
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
    bool isDark = true,
    TextInputType? keyboardType,
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
                          color: const Color(0xFF624294).withOpacity(0.10),
                          width: 1.5,
                        ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: isDark
                      ? BorderSide(
                          color: Colors.white.withOpacity(0.5), width: 1.5)
                      : BorderSide(
                          color: const Color(0xFF624294).withOpacity(0.10),
                          width: 1.5,
                        ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppColors.goldPrimary.withOpacity(0.8),
                      width: 2.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: isLoading ? null : _handleForgotPassword,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                loc.tr('submit'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}
