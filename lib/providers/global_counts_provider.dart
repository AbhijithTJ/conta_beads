import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/global_counts_model.dart';
import '../services/api_client.dart';

/// Prayer type IDs used by the backend.
class PrayerType {
  static const int rosary      = 1;
  static const int divineMercy = 2;
}

enum GlobalCountsStatus { initial, loading, loaded, error }

/// Fetches and caches global counts for both prayer types.
///
/// Call [fetch] whenever the screen becomes visible or the toggle changes.
class GlobalCountsProvider extends ChangeNotifier {
  GlobalCountsStatus _status = GlobalCountsStatus.initial;
  String? _errorMessage;

  // Cached data keyed by prayer_type_id
  GlobalCountsData? _rosaryData;
  GlobalCountsData? _divineMercyData;

  GlobalCountsStatus get status       => _status;
  String?            get errorMessage => _errorMessage;
  GlobalCountsData?  get rosaryData      => _rosaryData;
  GlobalCountsData?  get divineMercyData => _divineMercyData;

  bool get isLoading => _status == GlobalCountsStatus.loading;

  /// Returns cached data for [prayerTypeId], or an empty placeholder.
  GlobalCountsData dataFor(int prayerTypeId) {
    if (prayerTypeId == PrayerType.rosary) {
      return _rosaryData ?? GlobalCountsData.empty(PrayerType.rosary);
    }
    return _divineMercyData ?? GlobalCountsData.empty(PrayerType.divineMercy);
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────────
  /// Fetches both prayer types in parallel.
  /// Only shows loading state on the very first fetch — refresh keeps data visible.
  Future<void> fetchAll() async {
    final isFirstLoad = _rosaryData == null && _divineMercyData == null;
    if (isFirstLoad) {
      _status = GlobalCountsStatus.loading;
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        _fetchOne(PrayerType.rosary),
        _fetchOne(PrayerType.divineMercy),
      ]);
      _rosaryData      = results[0];
      _divineMercyData = results[1];
      _status       = GlobalCountsStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load global counts.');
    }
  }

  /// Fetches a single prayer type and updates only that cache slot.
  /// Only shows loading if that type has no cached data yet.
  Future<void> fetchOne(int prayerTypeId) async {
    final isFirstLoad = prayerTypeId == PrayerType.rosary
        ? _rosaryData == null
        : _divineMercyData == null;
    if (isFirstLoad) {
      _status = GlobalCountsStatus.loading;
      notifyListeners();
    }
    try {
      final data = await _fetchOne(prayerTypeId);
      if (prayerTypeId == PrayerType.rosary) {
        _rosaryData = data;
      } else {
        _divineMercyData = data;
      }
      _status       = GlobalCountsStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load global counts.');
    }
  }

  Future<GlobalCountsData> _fetchOne(int prayerTypeId) async {
    final response = await ApiClient.instance.get(
      AppConfig.globalCountsPath,
      query: {'prayer_type_id': prayerTypeId.toString()},
    );
    return GlobalCountsData.fromJson(response.data);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _setError(String message) {
    _status = GlobalCountsStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
