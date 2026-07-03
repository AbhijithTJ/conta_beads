import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:page_flip/page_flip.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';
import '../../models/prayer_documents_model.dart';

class PrayerDetailScreen extends StatefulWidget {
  final PrayerDocument prayer;

  const PrayerDetailScreen({
    super.key,
    required this.prayer,
    this.isScrollMode = false,
  });

  final bool isScrollMode;

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  late List<String> _prayerPages;
  int _currentPageIndex = 0;
  final _controller = GlobalKey<PageFlipWidgetState>();
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _paginatePrayerContent();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Play page flip sound effect
  Future<void> _playPageFlipSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/page_flip.mp3'));
    } catch (e) {
      debugPrint('Error playing page flip sound: $e');
    }
  }

  /// Split prayer content into pages based on HTML structure and character count
  void _paginatePrayerContent() {
    if (widget.prayer.data == null || widget.prayer.data!.isEmpty) {
      _prayerPages = ['No content available'];
      return;
    }

    String rawContent = widget.prayer.data!;
    
    // ── Clean up: Remove empty paragraphs that cause blank pages ─────────
    rawContent = rawContent.replaceAll(RegExp(r'<p[^>]*>\s*(<br>|&nbsp;|\s)*\s*</p>'), '');
    rawContent = rawContent.replaceAll(RegExp(r'<h[1-6][^>]*>\s*(<br>|&nbsp;|\s)*\s*</h[1-6]>'), '');
    
    // ── Pre-process: Force page breaks around paragraphs containing <strong> ─────────
    // This isolates bold text onto their own separate pages
    rawContent = rawContent.replaceAllMapped(RegExp(r'<p[^>]*>\s*<strong>'), (match) => '<!--PAGE_BREAK-->${match.group(0)}');
    rawContent = rawContent.replaceAllMapped(RegExp(r'</strong>\s*</p>'), (match) => '${match.group(0)}<!--PAGE_BREAK-->');
    
    final List<String> chunks = rawContent.split('<!--PAGE_BREAK-->');
    
    // We use a safe character limit for block packing. 
    // This ensures that 2 medium paragraphs won't accidentally combine and overflow.
    const int targetCharsPerPage = 450; 
    _prayerPages = [];

    for (String chunk in chunks) {
      String content = chunk.trim();
      
      // Skip empty chunks or filler breaks
      if (content.isEmpty || content == '<p><br></p>' || content == '<br>') {
        continue;
      }
      
      // ── Step 1: Split chunk into atomic HTML blocks (e.g. paragraphs) ─────────
      List<String> blocks = [];
      int lastIndex = 0;
      final blockTags = ['</p>', '</h1>', '</h2>', '</h3>', '</h4>', '</ul>', '</li>', '</div>'];
      
      while (lastIndex < content.length) {
        int bestNext = -1;
        int bestLen = -1;
        
        for (final tag in blockTags) {
          int pos = content.indexOf(tag, lastIndex);
          if (pos != -1) {
            if (bestNext == -1 || pos < bestNext) {
              bestNext = pos;
              bestLen = tag.length;
            }
          }
        }
        
        if (bestNext == -1) {
          blocks.add(content.substring(lastIndex).trim());
          break;
        }
        
        bestNext += bestLen;
        blocks.add(content.substring(lastIndex, bestNext).trim());
        lastIndex = bestNext;
      }
      
      // ── Step 2: Pack blocks into pages ────────────────────────────────────────
      // This ensures <p> tags are never cut in half. If adding a paragraph exceeds 
      // the limit, the ENTIRE paragraph moves to the next page.
      String currentPage = '';
      for (String block in blocks) {
        if (block.isEmpty) continue;
        
        if (currentPage.isNotEmpty && (currentPage.length + block.length > targetCharsPerPage)) {
          _prayerPages.add(currentPage.trim());
          currentPage = block;
        } else {
          currentPage = currentPage.isEmpty ? block : '$currentPage\n$block';
        }
      }
      
      if (currentPage.isNotEmpty) {
        // Fallback safety for exceptionally huge single paragraphs that must be split
        if (currentPage.length > 800) {
          int splitIndex = 0;
          while (splitIndex < currentPage.length) {
            int end = splitIndex + 650;
            if (end >= currentPage.length) {
              _prayerPages.add(currentPage.substring(splitIndex).trim());
              break;
            }
            int lastSentence = currentPage.lastIndexOf(RegExp(r'\.\s'), end);
            if (lastSentence > splitIndex) {
              end = lastSentence + 1;
            }
            _prayerPages.add(currentPage.substring(splitIndex, end).trim());
            splitIndex = end;
          }
        } else {
          _prayerPages.add(currentPage.trim());
        }
      }
    }

    if (_prayerPages.isEmpty) {
      _prayerPages = [widget.prayer.data!];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isScrollMode) {
      return _buildScrollView(context);
    }

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
                      _playPageFlipSound();
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
                      ? Align(
                          alignment: Alignment.center,
                          child: Html(
                            data: cleanedContent,
                            style: {
                              'body': Style(
                                fontSize: FontSize(16),
                                color: textColor,
                                lineHeight: LineHeight(1.7),
                                fontFamily: 'Georgia', // Using a serif font for book feel
                                margin: Margins.zero,
                                textAlign: TextAlign.left, // Keep text starting from the left
                              ),
                              'p': Style(margin: Margins.only(bottom: 16)),
                              'strong': Style(color: const Color(0xFF2D1F40)),
                            },
                          ),
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
                      '$pageNum / $totalPages',
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
    
    // Step 1: Remove extra spaces left after removing attributes (before closing >)
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

  Widget _buildScrollView(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = const Color(0xFFE8E2D8);
        final textColor = const Color(0xFF333333);
        final titleColor = const Color(0xFF2D1F40);
        final cleanedContent = _cleanHtmlContent(widget.prayer.data ?? '');

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: titleColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.prayer.title.toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                if (widget.prayer.imagePath.isNotEmpty)
                  Image.network(
                    widget.prayer.imagePath,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Html(
                    data: cleanedContent,
                    style: {
                      'body': Style(
                        fontSize: FontSize(16),
                        color: textColor,
                        lineHeight: LineHeight(1.7),
                        fontFamily: 'Georgia',
                        margin: Margins.zero,
                      ),
                      'p': Style(margin: Margins.only(bottom: 16)),
                      'strong': Style(color: titleColor),
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
