import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';
import '../services/language_id_service.dart';

/// Global language provider to sync language selection across all screens
class LanguageProvider extends ChangeNotifier {
  String _selectedLanguage = 'English';
  static const String _langKey = 'selected_language';

  String get selectedLanguage => _selectedLanguage;

  /// Change language and notify all listeners
  Future<void> setLanguage(String languageName) async {
    if (languageName == _selectedLanguage) return;
    
    _selectedLanguage = languageName;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, languageName);
    
    // Sync with language ID service for API requests
    languageIdService.setLanguageByName(languageName);
    
    await loc.load(languageName);
    notifyListeners();
  }

  /// Initialize with default or saved language
  Future<void> initialize() async {
    // Load from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString(_langKey) ?? 'English';
    
    // Sync with language ID service for API requests
    languageIdService.setLanguageByName(_selectedLanguage);
    
    await loc.load(_selectedLanguage);
    notifyListeners();
  }
}
