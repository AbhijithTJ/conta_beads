import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:page_flip/page_flip.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';
import '../../models/prayer_documents_model.dart';

class PrayerDetailScreen extends StatefulWidget {
  final PrayerDocument prayer;

  const PrayerDetailScreen({
    super.key,
    required this.prayer,
  });

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  late List<String> _prayerPages;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _paginatePrayerContent();
  }

  /// Split prayer content into pages based on character count
  void _paginatePrayerContent() {
    if (widget.prayer.data == null || widget.prayer.data!.isEmpty) {
      _prayerPages = ['No content available'];
      return;
    }

    // Split content into chunks of approximately 1500 characters per page
    const int charsPerPage = 1500;
    final String content = widget.prayer.data!;
    _prayerPages = [];

    int startIndex = 0;
    while (startIndex < content.length) {
      int endIndex = startIndex + charsPerPage;
      if (endIndex >= content.length) {
        _prayerPages.add(content.substring(startIndex));
        break;
      } else {
        // Find the last closing tag or paragraph break before endIndex
        int lastTagIndex = content.lastIndexOf('</p>', endIndex);
        if (lastTagIndex > startIndex) {
          endIndex = lastTagIndex + 4; // Include the closing tag
        }
        _prayerPages.add(content.substring(startIndex, endIndex));
        startIndex = endIndex;
      }
    }

    if (_prayerPages.isEmpty) {
      _prayerPages = [widget.prayer.data!];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        // Use white UI color scheme (like global counts and daily prayer screens)
        final titleColor = AppColors.authBgBottom;
        final bgColor = const Color(0xFFF0EBF0);
        final contentBgColor = Colors.white;
        final textColor = AppColors.authBgBottom;
        final secondaryTextColor = AppColors.authBgMid.withOpacity(0.6);

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // ── Light background ────────────────────────────────────────
              Positioned.fill(
                child: Container(
                  color: bgColor,
                ),
              ),
              // ── Main content with Page Flip ──────────────────────────────
              Column(
                children: [
                  // ── Header with back button ──────────────────────────────
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF624294).withOpacity(0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF624294).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: const Color(0xFF624294),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.prayer.title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Page Flip Content ────────────────────────────────────
                  Expanded(
                    child: PageFlipWidget(
                      children: [
                        // ── Page 1: Image ───────────────────────────────────
                        _buildImagePage(isDark, contentBgColor),
                        // ── Pages 2+: Content pages ─────────────────────────
                        ..._prayerPages.map((pageContent) =>
                            _buildContentPage(isDark, contentBgColor, textColor, secondaryTextColor, pageContent)),
                      ],
                      backgroundColor: contentBgColor,
                      onPageFlipped: (pageNumber) {
                        setState(() {
                          _currentPageIndex = pageNumber;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build Image Page ─────────────────────────────────────────────────────────
  Widget _buildImagePage(bool isDark, Color contentBgColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contentBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF624294).withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.prayer.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.prayer.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF624294),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '← Swipe to read →',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build Content Page ───────────────────────────────────────────────────────
  Widget _buildContentPage(bool isDark, Color contentBgColor, Color textColor, Color secondaryTextColor, String pageContent) {
    // Clean up the HTML content - remove extra whitespace and normalize
    final cleanedContent = _cleanHtmlContent(pageContent);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contentBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF624294).withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: cleanedContent.isNotEmpty
              ? Html(
                  data: cleanedContent,
                  style: {
                    'body': Style(
                      fontSize: FontSize(15),
                      color: textColor,
                      lineHeight: LineHeight(1.8),
                      fontFamily: 'Poppins',
                    ),
                    'p': Style(
                      margin: Margins.only(bottom: 16),
                      color: textColor,
                    ),
                    'strong': Style(
                      color: const Color(0xFF624294),
                      fontWeight: FontWeight.bold,
                    ),
                    'em': Style(
                      color: secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                    'h1': Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF624294),
                      margin: Margins.only(top: 16, bottom: 12),
                    ),
                    'h2': Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF624294),
                      margin: Margins.only(top: 14, bottom: 10),
                    ),
                    'h3': Style(
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF624294),
                      margin: Margins.only(top: 12, bottom: 8),
                    ),
                    'ul': Style(
                      margin: Margins.only(bottom: 16),
                    ),
                    'li': Style(
                      margin: Margins.only(bottom: 8),
                      color: textColor,
                    ),
                  },
                )
              : Text(
                  'No content available',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }

  /// Clean and normalize HTML content from API
  String _cleanHtmlContent(String html) {
    if (html.isEmpty) return '';
    
    // Remove multiple consecutive <br> tags and replace with single <br>
    String cleaned = html.replaceAll(RegExp(r'<br\s*/?>\s*<br\s*/?>', caseSensitive: false), '<br>');
    
    // Remove empty paragraphs with only whitespace or <br>
    cleaned = cleaned.replaceAll(RegExp(r'<p>\s*<br\s*/?>\s*</p>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<p>\s*</p>', caseSensitive: false), '');
    
    // Normalize inline style attributes - convert rgb colors to hex or remove problematic styles
    cleaned = cleaned.replaceAll(RegExp(r'style="[^"]*"', caseSensitive: false), '');
    
    // Remove extra whitespace between tags
    cleaned = cleaned.replaceAll(RegExp(r'>\s+<'), '><');
    
    // Trim leading/trailing whitespace
    cleaned = cleaned.trim();
    
    return cleaned;
  }
}
