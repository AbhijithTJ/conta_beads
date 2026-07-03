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
  
  String? _highlightedHtml;
  List<int> _plainToHtmlMap = [];
  String _plainTextForMapping = '';
  String _baseHtml = '';
  int _currentChunkStartOffset = 0;

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
        setState(() {
          _isPlaying = false;
          _highlightedHtml = null;
        });
      }
    });

    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      if (mounted) {
        int globalStart = _currentChunkStartOffset + startOffset;
        int globalEnd = _currentChunkStartOffset + endOffset;
        
        if (globalStart < _plainToHtmlMap.length && globalEnd <= _plainToHtmlMap.length && globalStart < globalEnd) {
          int htmlStart = _plainToHtmlMap[globalStart];
          int htmlEnd = _plainToHtmlMap[globalEnd - 1] + 1;
          
          String newHtml = _baseHtml.substring(0, htmlStart) + 
                           '<span style="background-color: #FFF9C4; color: black; border-radius: 4px;">' + 
                           _baseHtml.substring(htmlStart, htmlEnd) + 
                           '</span>' + 
                           _baseHtml.substring(htmlEnd);
          setState(() {
            _highlightedHtml = newHtml;
          });
        }
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

  void _prepareTextMapping(String html) {
    _baseHtml = html.replaceAll('&nbsp;', ' ');
    _plainToHtmlMap = [];
    StringBuffer plainBuffer = StringBuffer();
    bool inTag = false;
    
    for (int i = 0; i < _baseHtml.length; i++) {
      if (_baseHtml[i] == '<') {
        inTag = true;
      } else if (_baseHtml[i] == '>') {
        inTag = false;
      } else if (!inTag) {
        plainBuffer.write(_baseHtml[i]);
        _plainToHtmlMap.add(i);
      }
    }
    _plainTextForMapping = plainBuffer.toString();
  }

  Future<void> _speak() async {
    if (widget.prayer.data == null) return;
    
    final cleanedHtml = _cleanHtmlContent(widget.prayer.data!);
    _prepareTextMapping(cleanedHtml);
    
    final text = _plainTextForMapping;
    if (text.trim().isEmpty) {
       developer.log('TTS Error: Stripped text is empty.');
       return;
    }

    developer.log('TTS attempting to speak text...');
    setState(() {
      _isPlaying = true;
      _highlightedHtml = null;
    });

    const int maxLen = 3500;
    List<String> chunks = [];
    List<int> chunkStartIndices = [];
    
    if (text.length <= maxLen) {
      chunks.add(text);
      chunkStartIndices.add(0);
    } else {
      int start = 0;
      while (start < text.length) {
        int end = start + maxLen;
        if (end >= text.length) {
          chunks.add(text.substring(start));
          chunkStartIndices.add(start);
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
        chunkStartIndices.add(start);
        start = end;
      }
    }

    try {
      for (int i = 0; i < chunks.length; i++) {
        if (!_isPlaying) break; // User pressed stop
        
        _currentChunkStartOffset = chunkStartIndices[i];
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
        setState(() {
          _isPlaying = false;
          _highlightedHtml = null;
        });
      }
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _highlightedHtml = null;
    });
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
                    data: _highlightedHtml ?? cleanedContent,
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
