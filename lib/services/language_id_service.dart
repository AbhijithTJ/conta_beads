import 'package:flutter/foundation.dart';

/// Service to manage the current language ID for API requests.
/// Language ID: 1 = English, 2 = Malayalam
class LanguageIdService extends ChangeNotifier {
  static final LanguageIdService _instance = LanguageIdService._internal();
  factory LanguageIdService() => _instance;
  LanguageIdService._internal();

  int _languageId = 1; // Default to English

  int get languageId => _languageId;

  /// Map language names to their IDs
  static const Map<String, int> languageNameToId = {
    'English': 1,
    'Malayalam': 2,
  };

  /// Map language codes to their IDs
  static const Map<String, int> languageCodeToId = {
    'en': 1,
    'ml': 2,
  };

  /// Set language by name (e.g., 'English', 'Malayalam')
  void setLanguageByName(String languageName) {
    final id = languageNameToId[languageName];
    if (id != null && id != _languageId) {
      _languageId = id;
      notifyListeners();
    }
  }

  /// Set language by code (e.g., 'en', 'ml')
  void setLanguageByCode(String languageCode) {
    final id = languageCodeToId[languageCode];
    if (id != null && id != _languageId) {
      _languageId = id;
      notifyListeners();
    }
  }

  /// Set language by ID directly
  void setLanguageById(int id) {
    if (id != _languageId && (id == 1 || id == 2)) {
      _languageId = id;
      notifyListeners();
    }
  }
}

/// Global instance
final languageIdService = LanguageIdService();
