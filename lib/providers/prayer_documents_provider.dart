import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../config/app_config.dart';
import '../models/prayer_documents_model.dart';
import '../services/api_client.dart';
import '../services/language_id_service.dart';

enum PrayerDocumentsStatus { initial, loading, loaded, error }

class PrayerDocumentsProvider extends ChangeNotifier {
  PrayerDocumentsData? _data;
  PrayerDocumentsStatus _status = PrayerDocumentsStatus.initial;
  String? _error;
  int _lastLanguageId = languageIdService.languageId;

  PrayerDocumentsStatus get status => _status;
  PrayerDocumentsData? get data => _data;
  String? get error => _error;

  bool get isLoading => _status == PrayerDocumentsStatus.loading;
  bool get hasData => _data != null;

  /// Constructor - listen to language changes
  PrayerDocumentsProvider() {
    languageIdService.addListener(_onLanguageChanged);
  }

  /// Called when language changes
  void _onLanguageChanged() {
    final newLanguageId = languageIdService.languageId;
    if (newLanguageId != _lastLanguageId) {
      _lastLanguageId = newLanguageId;
      // Refresh documents when language changes
      refresh();
    }
  }

  Future<void> fetch() async {
    // Skip if already loaded (use refresh() to force)
    if (_status == PrayerDocumentsStatus.loaded) return;

    _status = PrayerDocumentsStatus.loading;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(
        '/api/prayer-documents',
      );
      developer.log('API Response: ${response.data}');
      
      _data = PrayerDocumentsData.fromJson(response.data);
      
      developer.log('Parsed ${_data?.documents.length ?? 0} prayer documents');
      for (var doc in _data?.documents ?? []) {
        developer.log('Document: ${doc.title}, Type: ${doc.type}, Link: ${doc.link}');
      }
      
      _status = PrayerDocumentsStatus.loaded;
      _error = null;
    } on ApiException catch (e) {
      _status = PrayerDocumentsStatus.error;
      _error = e.message;
      developer.log('API Error: ${e.message}');
    } catch (e) {
      _status = PrayerDocumentsStatus.error;
      _error = 'Failed to load prayer documents.';
      developer.log('Fetch Error: $e');
    }

    notifyListeners();
  }

  /// Force re-fetch even if already loaded.
  Future<void> refresh() async {
    _status = PrayerDocumentsStatus.initial;
    await fetch();
  }

  @override
  void dispose() {
    languageIdService.removeListener(_onLanguageChanged);
    super.dispose();
  }
}
