import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/global_counts_model.dart';
import '../services/api_client.dart';
import '../services/reverb_websocket_service.dart';
import 'user_provider.dart';

/// Prayer type IDs used by the backend.
class PrayerType {
  static const int rosary      = 1;
  static const int divineMercy = 2;
}

enum GlobalCountsStatus { initial, loading, loaded, error }

/// Fetches and caches global counts for both prayer types.
/// Integrates with WebSocket for real-time updates.
///
/// Call [fetchAll] on initial load, then WebSocket will push updates automatically.
class GlobalCountsProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  
  GlobalCountsStatus _status = GlobalCountsStatus.initial;
  String? _errorMessage;

  // Cached data keyed by prayer_type_id
  GlobalCountsData? _rosaryData;
  GlobalCountsData? _divineMercyData;

  // WebSocket subscription tracking
  final Set<int> _subscribedPrayerTypes = {};

  GlobalCountsProvider({UserProvider? userProvider})
      : _userProvider = userProvider ?? UserProvider();

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

  // ── WebSocket Integration ───────────────────────────────────────────────────

  /// Setup Reverb WebSocket listeners for real-time updates
  /// Call this after initializing ReverbProvider
  void setupReverbListeners(ReverbWebSocketService webSocketService) {
    debugPrint('[GlobalCountsProvider] Setting up Reverb listeners...');
    
    webSocketService.events.listen((event) {
      debugPrint('[GlobalCountsProvider] 📨 Received event: ${event.type}');
      
      switch (event.type) {
        case ReverbEventType.countUpdated:
          debugPrint('[GlobalCountsProvider] 🔔 Handling count update');
          _handleCountUpdated(event.data);
          break;
        case ReverbEventType.leaderboardUpdated:
          debugPrint('[GlobalCountsProvider] 🔔 Handling leaderboard update');
          _handleLeaderboardUpdated(event.data);
          break;
        case ReverbEventType.connected:
          debugPrint('[GlobalCountsProvider] ✅ Reverb connected');
          break;
        case ReverbEventType.disconnected:
          debugPrint('[GlobalCountsProvider] 🔌 Reverb disconnected');
          break;
        case ReverbEventType.error:
          debugPrint('[GlobalCountsProvider] ❌ Reverb error: ${event.error}');
          break;
        default:
          break;
      }
    });
    
    debugPrint('[GlobalCountsProvider] ✅ Reverb listeners setup complete');
  }

  /// Handle real-time count update from WebSocket
  void _handleCountUpdated(dynamic data) {
    try {
      debugPrint('[GlobalCountsProvider] 🔍 ===== COUNT UPDATE RECEIVED =====');
      debugPrint('[GlobalCountsProvider] 🔍 Data type: ${data.runtimeType}');
      debugPrint('[GlobalCountsProvider] 🔍 Data keys: ${(data as Map).keys.toList()}');
      
      final prayerTypeId = data['prayer_type_id'] as int?;
      if (prayerTypeId == null) {
        debugPrint('[GlobalCountsProvider] ❌ Missing prayer_type_id');
        return;
      }

      final triggeringUserId = data['triggering_user_id'] as int?;
      debugPrint('[GlobalCountsProvider] 🔍 Triggering user ID: $triggeringUserId');
      
      // Get current user ID from UserProvider
      final currentUserId = _userProvider.userId;
      debugPrint('[GlobalCountsProvider] 🔍 Current user ID: $currentUserId');
      
      // IMPORTANT: 
      // - Leaderboard and community totals ALWAYS update (for all users)
      // - Personal data (your_total, your_today, your_position) only updates if triggering_user_id matches current user
      // - If triggering_user_id is null, treat it as current user (for backward compatibility)
      final isCurrentUserTriggered = triggeringUserId == null || triggeringUserId == currentUserId;
      debugPrint('[GlobalCountsProvider] 🔍 Is current user triggered: $isCurrentUserTriggered');
      debugPrint('[GlobalCountsProvider] 🔍 Comparison: $triggeringUserId == $currentUserId ? ${triggeringUserId == currentUserId}');
      
      if (!isCurrentUserTriggered) {
        debugPrint('[GlobalCountsProvider] ℹ️ Another user prayed - updating leaderboard & community totals only');
      } else {
        debugPrint('[GlobalCountsProvider] ✅ Current user prayed - updating all data');
      }

      final communityTotal = data['community_total'] as int? ?? 0;
      final yourTotal = data['your_total'] as int? ?? 0;
      final yourToday = data['your_today'] as int? ?? 0;
      final communityTodayTotal = data['community_today_total'] as int? ?? 0;
      final yourPosition = data['your_position'] as int? ?? 0;
      final yourContributionPercent = (data['your_contribution_percent'] as num?)?.toDouble() ?? 0.0;
      final prayerTypeName = data['prayer_type_name'] as String? ?? 'Unknown';

      debugPrint('[GlobalCountsProvider] 🔍 Extracted values:');
      debugPrint('[GlobalCountsProvider]   - prayer_type_id: $prayerTypeId ($prayerTypeName)');
      debugPrint('[GlobalCountsProvider]   - triggering_user_id: $triggeringUserId');
      debugPrint('[GlobalCountsProvider]   - community_total: $communityTotal');
      debugPrint('[GlobalCountsProvider]   - your_total: $yourTotal');
      debugPrint('[GlobalCountsProvider]   - your_today: $yourToday');
      debugPrint('[GlobalCountsProvider]   - community_today_total: $communityTodayTotal');
      debugPrint('[GlobalCountsProvider]   - your_position: $yourPosition');
      debugPrint('[GlobalCountsProvider]   - your_contribution_percent: $yourContributionPercent');

      // Parse leaderboard if present
      List<LeaderboardEntry> leaderboard = [];
      final leaderboardData = data['leaderboard'] as List<dynamic>?;
      debugPrint('[GlobalCountsProvider] 🔍 Leaderboard data present: ${leaderboardData != null}');
      debugPrint('[GlobalCountsProvider] 🔍 Leaderboard length: ${leaderboardData?.length ?? 0}');
      
      if (leaderboardData != null && leaderboardData.isNotEmpty) {
        debugPrint('[GlobalCountsProvider] 🔍 Leaderboard entries:');
        for (int i = 0; i < leaderboardData.length; i++) {
          try {
            final entryMap = leaderboardData[i] as Map<String, dynamic>;
            final entry = LeaderboardEntry(
              position: entryMap['position'] as int? ?? 0,
              userId: entryMap['user_id'] as int? ?? 0,
              name: entryMap['name'] as String? ?? '',
              totalCount: entryMap['total_count'] as int? ?? 0,
              todayCount: entryMap['today_count'] as int? ?? 0,
              isCurrentUser: entryMap['is_current_user'] as bool? ?? false,
            );
            leaderboard.add(entry);
            debugPrint('[GlobalCountsProvider]   [$i] Pos: ${entry.position}, User: ${entry.name}, Total: ${entry.totalCount}, Today: ${entry.todayCount}, Current: ${entry.isCurrentUser}');
          } catch (e) {
            debugPrint('[GlobalCountsProvider] ❌ Error parsing leaderboard entry $i: $e');
          }
        }
      }

      debugPrint('[GlobalCountsProvider] 🔍 Total leaderboard entries parsed: ${leaderboard.length}');
      debugPrint('[GlobalCountsProvider] Prayer Type: $prayerTypeId ($prayerTypeName), Community Total: $communityTotal, Triggered by User: $triggeringUserId');

      if (prayerTypeId == PrayerType.rosary) {
        _rosaryData = _rosaryData?.copyWith(
          // ALWAYS update these (community-wide metrics)
          communityTotal: communityTotal,
          communityTodayTotal: communityTodayTotal,
          yourContributionPercent: yourContributionPercent,  // ALWAYS update
          leaderboard: leaderboard.isNotEmpty ? leaderboard : _rosaryData?.leaderboard,
          // Only update personal data if current user prayed
          yourTotal: isCurrentUserTriggered ? yourTotal : _rosaryData?.yourTotal,
          yourToday: isCurrentUserTriggered ? yourToday : _rosaryData?.yourToday,
          yourPosition: isCurrentUserTriggered ? yourPosition : _rosaryData?.yourPosition,
        ) ?? GlobalCountsData(
          yourTotal: yourTotal,
          yourToday: yourToday,
          communityTotal: communityTotal,
          communityTodayTotal: communityTodayTotal,
          yourPosition: yourPosition,
          yourContributionPercent: yourContributionPercent,
          leaderboard: leaderboard,
          prayerTypeId: prayerTypeId,
          prayerTypeName: prayerTypeName,
        );
        debugPrint('[GlobalCountsProvider] ✅ Updated Rosary data');
        debugPrint('[GlobalCountsProvider] 🔍 Rosary - Community: $communityTotal, Your: ${isCurrentUserTriggered ? yourTotal : "NOT UPDATED"}, Contribution: $yourContributionPercent%, Position: ${isCurrentUserTriggered ? yourPosition : "NOT UPDATED"}, Leaderboard: ${_rosaryData?.leaderboard.length ?? 0} entries');
      } else if (prayerTypeId == PrayerType.divineMercy) {
        _divineMercyData = _divineMercyData?.copyWith(
          // ALWAYS update these (community-wide metrics)
          communityTotal: communityTotal,
          communityTodayTotal: communityTodayTotal,
          yourContributionPercent: yourContributionPercent,  // ALWAYS update
          leaderboard: leaderboard.isNotEmpty ? leaderboard : _divineMercyData?.leaderboard,
          // Only update personal data if current user prayed
          yourTotal: isCurrentUserTriggered ? yourTotal : _divineMercyData?.yourTotal,
          yourToday: isCurrentUserTriggered ? yourToday : _divineMercyData?.yourToday,
          yourPosition: isCurrentUserTriggered ? yourPosition : _divineMercyData?.yourPosition,
        ) ?? GlobalCountsData(
          yourTotal: yourTotal,
          yourToday: yourToday,
          communityTotal: communityTotal,
          communityTodayTotal: communityTodayTotal,
          yourPosition: yourPosition,
          yourContributionPercent: yourContributionPercent,
          leaderboard: leaderboard,
          prayerTypeId: prayerTypeId,
          prayerTypeName: prayerTypeName,
        );
        debugPrint('[GlobalCountsProvider] ✅ Updated Divine Mercy data');
        debugPrint('[GlobalCountsProvider] 🔍 Divine Mercy - Community: $communityTotal, Your: ${isCurrentUserTriggered ? yourTotal : "NOT UPDATED"}, Contribution: $yourContributionPercent%, Position: ${isCurrentUserTriggered ? yourPosition : "NOT UPDATED"}, Leaderboard: ${_divineMercyData?.leaderboard.length ?? 0} entries');
      }

      _errorMessage = null;
      debugPrint('[GlobalCountsProvider] 🔔 Calling notifyListeners()');
      notifyListeners();
      debugPrint('[GlobalCountsProvider] ✅ UI should update now');
      debugPrint('[GlobalCountsProvider] 🔍 ===== COUNT UPDATE COMPLETE =====');
    } catch (e) {
      debugPrint('[GlobalCountsProvider] ❌ Error handling count update: $e');
      debugPrint('[GlobalCountsProvider] ❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Handle real-time leaderboard update from WebSocket
  void _handleLeaderboardUpdated(dynamic data) {
    try {
      final prayerTypeId = data['prayer_type_id'] as int;
      final leaderboard = (data['leaderboard'] as List<dynamic>?)
          ?.map((e) => e as LeaderboardEntry)
          .toList() ?? [];

      if (prayerTypeId == PrayerType.rosary) {
        _rosaryData = _rosaryData?.copyWith(leaderboard: leaderboard) ?? GlobalCountsData(
          yourTotal: 0,
          yourToday: 0,
          communityTotal: 0,
          communityTodayTotal: 0,
          yourPosition: 0,
          yourContributionPercent: 0,
          leaderboard: leaderboard,
          prayerTypeId: prayerTypeId,
        );
      } else if (prayerTypeId == PrayerType.divineMercy) {
        _divineMercyData = _divineMercyData?.copyWith(leaderboard: leaderboard) ?? GlobalCountsData(
          yourTotal: 0,
          yourToday: 0,
          communityTotal: 0,
          communityTodayTotal: 0,
          yourPosition: 0,
          yourContributionPercent: 0,
          leaderboard: leaderboard,
          prayerTypeId: prayerTypeId,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error handling leaderboard update: $e');
    }
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────────
  /// Fetches both prayer types in parallel.
  /// Only shows loading state on the very first fetch — refresh keeps data visible.
  /// After initial load, WebSocket will push real-time updates.
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
  /// After initial load, WebSocket will push real-time updates.
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
    
    // DEBUG: Log raw API response
    debugPrint('[GlobalCountsProvider] 🔍 RAW API RESPONSE: ${response.data}');
    
    // The API returns nested structure: { rosary: {...}, chaplet: {...} }
    // Extract the appropriate prayer type data
    final prayerTypeKey = prayerTypeId == PrayerType.rosary ? 'rosary' : 'chaplet';
    final prayerData = response.data[prayerTypeKey] as Map<String, dynamic>;
    
    // DEBUG: Log extracted prayer data
    debugPrint('[GlobalCountsProvider] 🔍 PRAYER DATA ($prayerTypeKey): $prayerData');
    debugPrint('[GlobalCountsProvider] 🔍 community_total VALUE: ${prayerData['community_total']}');
    debugPrint('[GlobalCountsProvider] 🔍 community_total TYPE: ${prayerData['community_total'].runtimeType}');
    
    return GlobalCountsData.fromJson(prayerData);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _setError(String message) {
    _status = GlobalCountsStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
