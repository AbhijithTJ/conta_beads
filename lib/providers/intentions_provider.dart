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

  IntentionsStatus get status       => _status;
  String?            get errorMessage => _errorMessage;
  IntentionsData?  get data      => _data;

  bool get isLoading => _status == IntentionsStatus.loading;
  bool get isLoaded => _status == IntentionsStatus.loaded;
  bool get isError => _status == IntentionsStatus.error;

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
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
