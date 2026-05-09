import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/intentions_model.dart';
import '../services/api_client.dart';

enum IntentionsStatus { initial, loading, loaded, error }

/// Fetches and manages intentions data including quotes, admin intention, and community prayers.
///
/// This provider follows the same pattern as GlobalCountsProvider and AdoptPriestProvider.
/// Call [fetch] whenever the screen becomes visible.
class IntentionsProvider extends ChangeNotifier {
  IntentionsStatus _status = IntentionsStatus.initial;
  String? _errorMessage;
  IntentionsData? _data;
  
  // For borrow operation
  BorrowResponse? _borrowResponse;
  IntentionsStatus _borrowStatus = IntentionsStatus.initial;

  IntentionsStatus get status       => _status;
  String?            get errorMessage => _errorMessage;
  IntentionsData?  get data      => _data;
  
  // Borrow getters
  BorrowResponse? get borrowResponse => _borrowResponse;
  IntentionsStatus get borrowStatus => _borrowStatus;

  bool get isLoading => _status == IntentionsStatus.loading;
  bool get isLoaded => _status == IntentionsStatus.loaded;
  bool get isError => _status == IntentionsStatus.error;
  
  bool get isBorrowLoading => _borrowStatus == IntentionsStatus.loading;
  bool get isBorrowSuccess => _borrowStatus == IntentionsStatus.loaded;
  bool get isBorrowError => _borrowStatus == IntentionsStatus.error;

  // ── Fetch ─────────────────────────────────────────────────────────────────────
  /// Fetches intentions data from the API.
  /// Only shows loading state on the very first fetch — refresh keeps data visible.
  Future<void> fetch() async {
    final isFirstLoad = _data == null;
    if (isFirstLoad) {
      _status = IntentionsStatus.loading;
      notifyListeners();
    }
    try {
      final response = await ApiClient.instance.get(AppConfig.intentionsPath);
      _data = IntentionsData.fromJson(response.data);
      _status = IntentionsStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load intentions.');
    }
  }

  // ── Borrow Rosaries/Chaplets ──────────────────────────────────────────────────
  /// Borrows rosaries or chaplets with an intention.
  /// Returns the BorrowResponse on success, null on failure.
  Future<BorrowResponse?> borrowPrayers({
    required int count,
    required String intentionText,
    required int prayerTypeId,
  }) async {
    _borrowStatus = IntentionsStatus.loading;
    _errorMessage = '';
    _borrowResponse = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        AppConfig.rosariesBorrowPath,
        body: {
          'count': count,
          'intention_text': intentionText,
          'prayer_type_id': prayerTypeId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _borrowResponse = BorrowResponse.fromJson(response.data);
        _borrowStatus = IntentionsStatus.loaded;
        _errorMessage = null;
        notifyListeners();
        return _borrowResponse;
      }
      
      _borrowStatus = IntentionsStatus.error;
      _errorMessage = 'Failed to borrow prayers';
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _borrowStatus = IntentionsStatus.error;
      _errorMessage = e.message;
      _borrowResponse = null;
      notifyListeners();
      return null;
    } catch (e) {
      _borrowStatus = IntentionsStatus.error;
      _errorMessage = 'Failed to borrow prayers.';
      _borrowResponse = null;
      notifyListeners();
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _setError(String message) {
    _status = IntentionsStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Reset the provider to initial state
  void reset() {
    _status = IntentionsStatus.initial;
    _data = null;
    _errorMessage = null;
    _borrowResponse = null;
    _borrowStatus = IntentionsStatus.initial;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Reset borrow status
  void resetBorrowStatus() {
    _borrowStatus = IntentionsStatus.initial;
    _borrowResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
