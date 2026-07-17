import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../../theme/theme_notifier.dart';
import '../../models/prayer_documents_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/language_provider.dart';

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
  double _voicePitch = 1.0;
  double _speechRate = 0.45;

  @override
  void initState() {
    super.initState();
    _loadVoicePreference();
    _initTts();
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voicePitch = prefs.getDouble('voicePitch') ?? 1.0;
      _speechRate = prefs.getDouble('speechRate') ?? 0.45;
    });
  }

  Future<void> _saveVoiceSettings(double pitch, double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('voicePitch', pitch);
    await prefs.setDouble('speechRate', rate);
  }

  void _showVoiceSettings() {
    final isMalayalam = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage == 'Malayalam';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE8E2D8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMalayalam ? 'ശബ്ദ ക്രമീകരണങ്ങൾ' : 'Voice Settings',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D1F40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Pitch Slider
                  Text(
                    isMalayalam ? 'പിച്ച് (Tone)' : 'Pitch (Tone)', 
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: const Color(0xFF2D1F40)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.face, color: Color(0xFF2D1F40), size: 20),
                      Expanded(
                        child: Slider(
                          value: _voicePitch,
                          min: 0.8,
                          max: 1.2,
                          activeColor: const Color(0xFF624294),
                          onChanged: (value) {
                            setModalState(() => _voicePitch = value);
                            setState(() => _voicePitch = value);
                          },
                          onChangeEnd: (value) async {
                            await _saveVoiceSettings(_voicePitch, _speechRate);
                            if (_isPlaying) {
                              await _flutterTts.stop();
                              _speak();
                            }
                          },
                        ),
                      ),
                      const Icon(Icons.face_3, color: Color(0xFF2D1F40), size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Speed Slider
                  Text(
                    isMalayalam ? 'വേഗത' : 'Speed', 
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: const Color(0xFF2D1F40)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, color: Color(0xFF2D1F40), size: 20),
                      Expanded(
                        child: Slider(
                          value: _speechRate,
                          min: 0.2,
                          max: 0.7,
                          activeColor: const Color(0xFF624294),
                          onChanged: (value) {
                            setModalState(() => _speechRate = value);
                            setState(() => _speechRate = value);
                          },
                          onChangeEnd: (value) async {
                            await _saveVoiceSettings(_voicePitch, _speechRate);
                            if (_isPlaying) {
                              await _flutterTts.stop();
                              _speak();
                            }
                          },
                        ),
                      ),
                      const Icon(Icons.directions_run, color: Color(0xFF2D1F40), size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      isMalayalam 
                          ? 'വേഗത കുറയുമ്പോൾ ശബ്ദം കൂടുതൽ സ്വാഭാവികമായി കേൾക്കാം.'
                          : 'Slower speeds often sound smoother and less robotic.',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.restore, color: Color(0xFF624294)),
                      label: Text(
                        isMalayalam ? 'ഡീഫോൾട്ടിലേക്ക് മാറ്റുക' : 'Reset to Default',
                        style: GoogleFonts.lato(color: const Color(0xFF624294), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF624294)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        setModalState(() {
                          _voicePitch = 1.0;
                          _speechRate = 0.45;
                        });
                        setState(() {
                          _voicePitch = 1.0;
                          _speechRate = 0.45;
                        });
                        await _saveVoiceSettings(1.0, 0.45);
                        if (_isPlaying) {
                          await _flutterTts.stop();
                          _speak();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setVolume(1.0);
    // Speech rate is set dynamically in _speak based on _speechRate
    // Pitch will be set dynamically in _speak based on _voicePitch
    
    // Ensure iOS plays sound even if the device is on silent mode
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ]
    );

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
    _isPlaying = false;
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
    
    // Set the appropriate TTS language
    final currentLang = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
    int? langResult;
    
    if (currentLang == 'Malayalam') {
      langResult = await _flutterTts.setLanguage("ml-IN");
    } else {
      langResult = await _flutterTts.setLanguage("en-US");
    }

    // Adjust pitch and speed to simulate smoother voices
    await _flutterTts.setPitch(_voicePitch);
    await _flutterTts.setSpeechRate(_speechRate);

    // If setting language failed (returned 0) or is null, it means the voice is not downloaded on the device
    if (langResult == 0) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Voice Missing'),
            content: Text(
              currentLang == 'Malayalam'
                  ? 'The Malayalam voice is not installed on your device. \n\nOn iPhone, please go to Settings > Accessibility > Spoken Content > Voices and download Malayalam (e.g. Lekha).'
                  : 'The required voice is not installed on your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return; // Do not attempt to speak in the wrong language
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

        return WillPopScope(
          onWillPop: () async {
            _isPlaying = false;
            _flutterTts.stop();
            return true;
          },
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: titleColor),
                onPressed: () {
                  _isPlaying = false;
                  _flutterTts.stop();
                  Navigator.of(context).pop();
                },
              ),
            title: Text(
              widget.prayer.title.toUpperCase(),
              style: widget.prayer.languageId == 2
                  ? GoogleFonts.anekMalayalam(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    )
                  : GoogleFonts.playfairDisplay(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: titleColor,
                ),
                tooltip: 'Voice Settings',
                onPressed: _showVoiceSettings,
              ),
            ],
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
        ),
      );
    },
    );
  }
}
