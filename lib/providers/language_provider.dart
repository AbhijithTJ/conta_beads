import 'package:flutter/foundation.dart';
import '../services/localization_service.dart';

/// Global language provider to sync language selection across all screens
class LanguageProvider extends ChangeNotifier {
  String _selectedLanguage = 'English';

  String get selectedLanguage => _selectedLanguage;

  /// Change language and notify all listeners
  Future<void> setLanguage(String languageName) async {
    if (languageName == _selectedLanguage) return;
    
    _selectedLanguage = languageName;
    await loc.load(languageName);
    notifyListeners();
  }

  /// Initialize with default language
  Future<void> initialize() async {
    await loc.load(_selectedLanguage);
    notifyListeners();
  }
}
