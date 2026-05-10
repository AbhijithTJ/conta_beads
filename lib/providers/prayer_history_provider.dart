import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/prayer_history_model.dart';
import '../services/api_client.dart';

enum PrayerHistoryStatus { initial, loading, loaded, error }

/// Prayer type IDs used by the backend.
class PrayerTypeId {
  static const int rosary = 1;
  static const int chaplet = 2;
}

/// Fetches and manages prayer history data with pagination.
///
/// Call [fetch] whenever the screen becomes visible.
/// Use [nextPage], [previousPage], or [changePrayerType] for navigation.
class PrayerHistoryProvider extends ChangeNotifier {
  PrayerHistoryStatus _status = PrayerHistoryStatus.initial;
  String _errorMessage = '';
  PrayerHistoryResponse? _data;
  
  int _currentPage = 1;
  int _prayerTypeId = PrayerTypeId.rosary;
  static const int _perPage = 20;

  PrayerHistoryStatus get status       => _status;
  String              get errorMessage => _errorMessage;
  PrayerHistoryResponse? get data      => _data;
  
  int get currentPage => _currentPage;
  int get prayerTypeId => _prayerTypeId;
  int get totalPages => _data?.meta.lastPage ?? 1;
  int get totalEntries => _data?.meta.total ?? 0;

  bool get isLoading => _status == PrayerHistoryStatus.loading;
  bool get isLoaded => _status == PrayerHistoryStatus.loaded;
  bool get isError => _status == PrayerHistoryStatus.error;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // ── Fetch ─────────────────────────────────────────────────────────────────────
  /// Fetches prayer history for the current page and prayer type.
  /// Only shows loading state on the very first fetch — refresh keeps data visible.
  Future<void> fetch() async {
    final isFirstLoad = _data == null;
    if (isFirstLoad) {
      _status = PrayerHistoryStatus.loading;
      notifyListeners();
    }
    
    try {
      final query = {
        'page': _currentPage.toString(),
        'per_page': _perPage.toString(),
        'prayer_type_id': _prayerTypeId.toString(),
      };
      
      final response = await ApiClient.instance.get(
        '${AppConfig.rosariesPath}/history',
        query: query,
      );
      
      _data = PrayerHistoryResponse.fromJson(response.data);
      _status = PrayerHistoryStatus.loaded;
      _errorMessage = '';
    } on ApiException catch (e) {
      _status = PrayerHistoryStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = PrayerHistoryStatus.error;
      _errorMessage = 'Failed to load prayer history.';
    }

    notifyListeners();
  }

  // ── Navigation ────────────────────────────────────────────────────────────────
  /// Go to next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await fetch();
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await fetch();
    }
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      await fetch();
    }
  }

  /// Change prayer type and reset to page 1
  Future<void> changePrayerType(int prayerTypeId) async {
    if (prayerTypeId != _prayerTypeId) {
      _prayerTypeId = prayerTypeId;
      _currentPage = 1;
      await fetch();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  /// Reset the provider to initial state
  void reset() {
    _status = PrayerHistoryStatus.initial;
    _data = null;
    _errorMessage = '';
    _currentPage = 1;
    _prayerTypeId = PrayerTypeId.rosary;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
