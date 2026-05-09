import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../config/app_config.dart';
import '../../services/api_client.dart';
import '../../models/priest_model.dart';
import '../../theme/theme_notifier.dart';
import 'suggest_priest_success_screen.dart';

class SuggestPriestScreen extends StatefulWidget {
  const SuggestPriestScreen({super.key});

  @override
  State<SuggestPriestScreen> createState() => _SuggestPriestScreenState();
}

class _SuggestPriestScreenState extends State<SuggestPriestScreen> {
  final TextEditingController _originalNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  final FocusNode _originalNameFocus = FocusNode();
  final FocusNode _displayNameFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _originalNameController.dispose();
    _displayNameController.dispose();
    _noteController.dispose();
    _originalNameFocus.dispose();
    _displayNameFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<void> _submitSuggestion() async {
    if (_originalNameController.text.isEmpty) {
      _showError('Please enter the priest\'s original name');
      return;
    }
    if (_displayNameController.text.isEmpty) {
      _showError('Please enter the display name');
      return;
    }
    if (_noteController.text.isEmpty) {
      _showError('Please enter a note about the priest');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.post(
        AppConfig.priestsPath,
        body: {
          'original_name': _originalNameController.text,
          'display_name': _displayNameController.text,
          'note': _noteController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final suggestResponse = SuggestPriestResponse.fromJson(response.data);
        
        if (mounted) {
          _originalNameController.clear();
          _displayNameController.clear();
          _noteController.clear();
          
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SuggestPriestSuccessScreen(
              priest: suggestResponse.priest,
            ),
          ));
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to suggest priest. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final titleColor = const Color(0xFF624294);
        final subColor = const Color(0xFF624294).withOpacity(0.6);
        final inputBg = isDark ? Colors.white.withOpacity(0.80) : const Color(0xFFF5F0FF);
        final inputBorder = const Color(0xFF624294).withOpacity(0.15);
        final hintColor = const Color(0xFF624294).withOpacity(0.5);

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
                      const SizedBox(height: 40),
                      _buildHeader(titleColor, subColor),
                      const SizedBox(height: 40),
                      _buildFormCard(isDark, titleColor, subColor, inputBg, inputBorder, hintColor),
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

  Widget _buildHeader(Color titleColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Suggest a Priest',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            )),
        const SizedBox(height: 8),
        Text('Help us grow our community',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )),
      ],
    );
  }

  Widget _buildFormCard(bool isDark, Color titleColor, Color subColor, Color inputBg, Color inputBorder, Color hintColor) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original Name Field
        Text('Priest\'s Original Name',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            )),
        const SizedBox(height: 10),
        _buildInputField(
          controller: _originalNameController,
          focusNode: _originalNameFocus,
          hint: 'e.g., Father John Smith',
          inputBg: inputBg,
          inputBorder: inputBorder,
          hintColor: hintColor,
          titleColor: titleColor,
        ),
        const SizedBox(height: 20),
        // Display Name Field
        Text('Display Name',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            )),
        const SizedBox(height: 10),
        _buildInputField(
          controller: _displayNameController,
          focusNode: _displayNameFocus,
          hint: 'e.g., Fr. John',
          inputBg: inputBg,
          inputBorder: inputBorder,
          hintColor: hintColor,
          titleColor: titleColor,
        ),
        const SizedBox(height: 20),
        // Note Field
        Text('Note (Why suggest this priest?)',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            )),
        const SizedBox(height: 10),
        _buildInputField(
          controller: _noteController,
          focusNode: _noteFocus,
          hint: 'Tell us about this priest...',
          inputBg: inputBg,
          inputBorder: inputBorder,
          hintColor: hintColor,
          titleColor: titleColor,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        // Info Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF624294).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF624294).withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: subColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your suggestion will be reviewed by our admin team before being added.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF624294).withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Submit Button
        _buildSubmitButton(),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required Color inputBg,
    required Color inputBorder,
    required Color hintColor,
    required Color titleColor,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: titleColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: hintColor,
          fontSize: 13,
        ),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: inputBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF624294), width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitSuggestion,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B55A8), Color(0xFF624294)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF624294).withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                )
              : Text('Submit Suggestion',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  )),
        ),
      ),
    );
  }
}
