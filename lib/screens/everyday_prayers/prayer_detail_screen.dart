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
  final _controller = GlobalKey<PageFlipWidgetState>();

  @override
  void initState() {
    super.initState();
    _paginatePrayerContent();
  }

  /// Split prayer content into pages based on HTML structure and character count
  void _paginatePrayerContent() {
    if (widget.prayer.data == null || widget.prayer.data!.isEmpty) {
      _prayerPages = ['No content available'];
      return;
    }

    final String content = widget.prayer.data!;
    const int targetCharsPerPage = 750; // Balanced for most screen sizes
    _prayerPages = [];

    int startIndex = 0;
    while (startIndex < content.length) {
      int endIndex = startIndex + targetCharsPerPage;
      
      if (endIndex >= content.length) {
        _prayerPages.add(content.substring(startIndex));
        break;
      }
      
      // ── Step 1: Look for natural HTML block boundaries ──────────────────
      // We look for closing tags of blocks like paragraphs, headings, or list items.
      int lastBlockEnd = -1;
      final blockTags = ['</p>', '</h1>', '</h2>', '</h3>', '</h4>', '</ul>', '</li>', '<br>', '</div>'];
      
      for (final tag in blockTags) {
        int pos = content.lastIndexOf(tag, endIndex);
        if (pos > startIndex && pos > lastBlockEnd) {
          lastBlockEnd = pos + tag.length;
        }
      }
      
      // ── Step 2: Use the best boundary found ──────────────────────────────
      if (lastBlockEnd != -1 && lastBlockEnd > startIndex + (targetCharsPerPage * 0.5)) {
        // We found a good HTML block boundary in the last half of the page
        endIndex = lastBlockEnd;
      } else {
        // No block boundary found nearby, look for a sentence boundary
        int lastSentenceEnd = content.lastIndexOf(RegExp(r'\.\s'), endIndex);
        if (lastSentenceEnd > startIndex && lastSentenceEnd > startIndex + (targetCharsPerPage * 0.3)) {
          endIndex = lastSentenceEnd + 1;
        }
        // If still no good boundary, we use the character limit but must be careful...
      }
      
      // ── Step 3: Safety Guard — Never split inside a tag ──────────────────
      // This handles cases like <strong style="color: red">...
      int lastOpenBracket = content.lastIndexOf('<', endIndex);
      int lastCloseBracket = content.lastIndexOf('>', endIndex);
      
      if (lastOpenBracket > lastCloseBracket) {
        // We are currently inside a tag, move the split point to the start of the tag
        endIndex = lastOpenBracket;
      }

      // ── Step 4: Inline Tag Protection ────────────────────────────────────
      // If we are splitting after a tag like <strong> or <em>, but before the 
      // closing </strong>, the styling will be lost on the next page.
      // We try to avoid splitting mid-sentence if there's an active inline tag.
      final inlineTags = ['<strong>', '<b>', '<em>', '<i>', '<u>'];
      for (final tag in inlineTags) {
        int tagStart = content.lastIndexOf(tag, endIndex);
        if (tagStart > startIndex) {
          String closingTag = tag.replaceFirst('<', '</');
          int tagEnd = content.lastIndexOf(closingTag, endIndex);
          
          // If the tag started on this page but hasn't closed yet
          if (tagStart > tagEnd) {
            // Move the split to before the opening tag to keep the styled block together
            endIndex = tagStart;
          }
        }
      }
      
      // ── Step 5: Extract and Clean ─────────────────────────────────────────
      String pageContent = content.substring(startIndex, endIndex).trim();
      if (pageContent.isNotEmpty) {
        _prayerPages.add(pageContent);
      }
      
      startIndex = endIndex;
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
          body: Container(
            color: bgColor,
            child: Column(
              children: [
                // ── Header with back button (Fixed at top) ──────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Page Flip Content (Takes remaining space) ────────────────
                Expanded(
                  child: PageFlipWidget(
                    key: _controller,
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
                // ── Page Indicator ──────────────────────────────────────────
                if (_prayerPages.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: Text(
                      'Page ${_currentPageIndex + 1} of ${_prayerPages.length + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build Image Page ─────────────────────────────────────────────────────────
  Widget _buildImagePage(bool isDark, Color contentBgColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    '← Swipe to read the prayer →',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                      fontSize: FontSize(16),
                      color: textColor,
                      lineHeight: LineHeight(1.6),
                      fontFamily: 'Poppins',
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
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
                      fontSize: FontSize(22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF624294),
                      margin: Margins.only(top: 8, bottom: 12),
                    ),
                    'h2': Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF624294),
                      margin: Margins.only(top: 6, bottom: 10),
                    ),
                    'h3': Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF624294),
                      margin: Margins.only(top: 4, bottom: 8),
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
              : Center(
                  child: Text(
                    'No content available',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Clean and normalize HTML content from API
  String _cleanHtmlContent(String html) {
    if (html.isEmpty) return '';
    
    String cleaned = html;
    
    // Step 1: Remove all style attributes (handles both style="..." and style='...')
    cleaned = cleaned.replaceAll(RegExp(r'\s*style\s*=\s*"[^"]*"', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r"\s*style\s*=\s*'[^']*'", caseSensitive: false), '');
    
    // Step 2: Remove extra spaces left after removing attributes (before closing >)
    cleaned = cleaned.replaceAll(RegExp(r'\s+>'), '>');
    
    // Step 3: Remove extra spaces between tags
    cleaned = cleaned.replaceAll(RegExp(r'>\s+<'), '><');
    cleaned = cleaned.replaceAll(RegExp(r'\s+<'), '<');
    
    // Step 4: Normalize self-closing br tags to consistent format
    cleaned = cleaned.replaceAll(RegExp(r'<br\s*/?\s*>', caseSensitive: false), '<br>');
    
    // Step 5: Remove multiple consecutive <br> tags (keep only one)
    cleaned = cleaned.replaceAll(RegExp(r'<br>\s*<br>(\s*<br>)*', caseSensitive: false), '<br>');
    
    // Step 6: Remove empty paragraphs with only whitespace or <br>
    cleaned = cleaned.replaceAll(RegExp(r'<p>\s*<br>\s*</p>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<p>\s*</p>', caseSensitive: false), '');
    
    // Step 7: Trim leading/trailing whitespace
    cleaned = cleaned.trim();
    
    return cleaned;
  }
}
