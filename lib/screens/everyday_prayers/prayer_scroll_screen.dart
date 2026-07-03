import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../../theme/theme_notifier.dart';
import '../../models/prayer_documents_model.dart';

class PrayerScrollScreen extends StatefulWidget {
  final PrayerDocument prayer;

  const PrayerScrollScreen({
    super.key,
    required this.prayer,
  });

  @override
  State<PrayerScrollScreen> createState() => _PrayerScrollScreenState();
}

class _PrayerScrollScreenState extends State<PrayerScrollScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setErrorHandler((msg) {
      developer.log("TTS Error: $msg");
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  String _cleanHtmlContent(String html) {
    if (html.isEmpty) return '';
    String cleaned = html;
    cleaned = cleaned.replaceAll(RegExp(r'\s+>'), '>');
    cleaned = cleaned.replaceAll(RegExp(r'>\s+<'), '><');
    cleaned = cleaned.replaceAll(RegExp(r'\s+<'), '<');
    cleaned = cleaned.replaceAll(RegExp(r'<br\s*/?\s*>', caseSensitive: false), '<br>');
    cleaned = cleaned.replaceAll(RegExp(r'<br>\s*<br>(\s*<br>)*', caseSensitive: false), '<br>');
    cleaned = cleaned.replaceAll(RegExp(r'<p>\s*<br>\s*</p>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<p>\s*</p>', caseSensitive: false), '');
    return cleaned.trim();
  }

  String _stripHtmlTags(String html) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return html.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  Future<void> _speak() async {
    if (widget.prayer.data == null) return;
    
    final text = _stripHtmlTags(widget.prayer.data!);
    if (text.isEmpty) {
       developer.log('TTS Error: Stripped text is empty.');
       return;
    }

    developer.log('TTS attempting to speak text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    setState(() => _isPlaying = true);

    const int maxLen = 3500;
    List<String> chunks = [];
    
    if (text.length <= maxLen) {
      chunks.add(text);
    } else {
      int start = 0;
      while (start < text.length) {
        int end = start + maxLen;
        if (end >= text.length) {
          chunks.add(text.substring(start));
          break;
        }
        
        int lastPunctuation = text.lastIndexOf(RegExp(r'[\.\n]'), end);
        if (lastPunctuation > start) {
          end = lastPunctuation + 1; 
        } else {
          int lastSpace = text.lastIndexOf(' ', end);
          if (lastSpace > start) {
            end = lastSpace;
          }
        }
        chunks.add(text.substring(start, end));
        start = end;
      }
    }

    try {
      for (int i = 0; i < chunks.length; i++) {
        if (!_isPlaying) break; // User pressed stop
        
        var result = await _flutterTts.speak(chunks[i]);
        if (result != 1) {
          developer.log('TTS speak returned $result (failed) for chunk $i');
          break;
        }
      }
    } catch (e) {
      developer.log('TTS error during speak: $e');
    } finally {
      if (mounted && _isPlaying) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF624294),
            onPressed: () {
              if (_isPlaying) {
                _stop();
              } else {
                _speak();
              }
            },
            child: Icon(
              _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              color: Colors.white,
            ),
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
