import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/daily_prayer_model.dart';
import '../services/api_client.dart';

enum DailyPrayerStatus { initial, loading, loaded, error }

class DailyPrayerProvider extends ChangeNotifier {
  // Cache keyed by prayer_type_id so Rosary and Chaplet don't clobber each other
  final Map<int, DailyPrayerData> _cache = {};
  final Map<int, DailyPrayerStatus> _statuses = {};
  final Map<int, String> _errors = {};

  DailyPrayerStatus statusFor(int typeId) =>
      _statuses[typeId] ?? DailyPrayerStatus.initial;

  DailyPrayerData? dataFor(int typeId) => _cache[typeId];

  String? errorFor(int typeId) => _errors[typeId];

  bool isLoadingFor(int typeId) => statusFor(typeId) == DailyPrayerStatus.loading;

  bool hasDataFor(int typeId) => _cache.containsKey(typeId);

  Future<void> fetch(int typeId) async {
    // Skip if already loaded (use refresh() to force)
    if (statusFor(typeId) == DailyPrayerStatus.loaded) return;

    _statuses[typeId] = DailyPrayerStatus.loading;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(
        AppConfig.dailyPrayersPath,
        query: {'prayer_type_id': '$typeId'},
      );
      _cache[typeId]   = DailyPrayerData.fromJson(response.data);
      _statuses[typeId] = DailyPrayerStatus.loaded;
      _errors.remove(typeId);
    } on ApiException catch (e) {
      _statuses[typeId] = DailyPrayerStatus.error;
      _errors[typeId]   = e.message;
    } catch (_) {
      _statuses[typeId] = DailyPrayerStatus.error;
      _errors[typeId]   = 'Failed to load daily prayer.';
    }

    notifyListeners();
  }

  /// Force re-fetch even if already loaded.
  Future<void> refresh(int typeId) async {
    _statuses.remove(typeId);
    await fetch(typeId);
  }
}
