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
        // Book-like color palette
        final titleColor = const Color(0xFF2D1F40);
        final bgColor = const Color(0xFFE8E2D8); // Warm desk/table color
        final paperColor = const Color(0xFFFDFBF7); // Clean paper color
        final textColor = const Color(0xFF333333);
        final secondaryTextColor = const Color(0xFF7D7365);

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              // ── Minimalist Book Header ──────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          child: Icon(Icons.close_rounded, color: titleColor, size: 20),
                        ),
                      ),
                      Text(
                        'PRAYER BOOK',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                          color: titleColor.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 36), // Balance
                    ],
                  ),
                ),
              ),
              
              // ── The Book Content ────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: PageFlipWidget(
                    key: _controller,
                    backgroundColor: bgColor,
                    children: [
                      // Page 1: Cover/Image
                      _buildImagePage(paperColor, 1, _prayerPages.length + 1),
                      // Pages 2+: Content
                      ..._prayerPages.asMap().entries.map((entry) =>
                          _buildContentPage(
                            paperColor, 
                            textColor, 
                            secondaryTextColor, 
                            entry.value, 
                            entry.key + 2, 
                            _prayerPages.length + 1
                          )
                      ),
                    ],
                    onPageFlipped: (pageNumber) {
                      setState(() {
                        _currentPageIndex = pageNumber;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build Image Page (The "Cover") ─────────────────────────────────────────
  Widget _buildImagePage(Color paperColor, int pageNum, int totalPages) {
    return Container(
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine Shadow
          Container(
            width: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      widget.prayer.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: Column(
                  children: [
                    Text(
                      widget.prayer.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D1F40),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE8E2D8), thickness: 1),
                    const SizedBox(height: 20),
                    Text(
                      'PAGE $pageNum OF $totalPages',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: const Color(0xFF7D7365).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Build Content Page ───────────────────────────────────────────────────────
  Widget _buildContentPage(Color paperColor, Color textColor, Color secondaryTextColor, String pageContent, int pageNum, int totalPages) {
    final cleanedContent = _cleanHtmlContent(pageContent);
    
    return Container(
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine Shadow
          Container(
            width: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(45, 40, 40, 12),
                  child: cleanedContent.isNotEmpty
                      ? Html(
                          data: cleanedContent,
                          style: {
                            'body': Style(
                              fontSize: FontSize(16),
                              color: textColor,
                              lineHeight: LineHeight(1.7),
                              fontFamily: 'Georgia', // Using a serif font for book feel
                              margin: Margins.zero,
                            ),
                            'p': Style(margin: Margins.only(bottom: 16)),
                            'strong': Style(color: const Color(0xFF2D1F40)),
                          },
                        )
                      : const Center(child: Text('...')),
                ),
              ),
              // Footer with Page Number
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: const Color(0xFFE8E2D8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pageNum.toString(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
