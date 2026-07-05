import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _strings = {};
  String _currentLangCode = 'en';

  String get currentLangCode => _currentLangCode;

  static const Map<String, String> langCodeMap = {
    'English':   'en',
    'Malayalam': 'ml',
  };

  Future<void> load(String languageName) async {
    final code = langCodeMap[languageName] ?? 'en';
    _currentLangCode = code;
    final jsonStr = await rootBundle.loadString('assets/lang/$code.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    _strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Get a translated string by key.
  /// Supports {placeholder} substitution via [args].
  String tr(String key, {Map<String, String>? args}) {
    String value = _strings[key] ?? key;
    if (args != null) {
      args.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
  }
}

/// Global shorthand
final loc = LocalizationService();
