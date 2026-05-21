// Models for the /api/community/global-counts endpoint.

class LeaderboardEntry {
  final int position;
  final int userId;
  final String name;
  final int totalCount;
  final int todayCount;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.position,
    required this.userId,
    required this.name,
    required this.totalCount,
    required this.todayCount,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      position:      json['position']        as int,
      userId:        json['user_id']         as int,
      name:          json['name']            as String,
      totalCount:    json['total_count']     as int,
      todayCount:    json['today_count']     as int,
      isCurrentUser: json['is_current_user'] as bool,
    );
  }

  LeaderboardEntry copyWith({
    int? position,
    int? userId,
    String? name,
    int? totalCount,
    int? todayCount,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      position: position ?? this.position,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalCount: totalCount ?? this.totalCount,
      todayCount: todayCount ?? this.todayCount,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class GlobalCountsData {
  final int yourTotal;
  final int yourToday;
  final int communityTotal;
  final int communityTodayTotal;
  final int yourPosition;
  final double yourContributionPercent;
  final List<LeaderboardEntry> leaderboard;
  final int prayerTypeId;
  final String? prayerTypeName;

  const GlobalCountsData({
    required this.yourTotal,
    required this.yourToday,
    required this.communityTotal,
    required this.communityTodayTotal,
    required this.yourPosition,
    required this.yourContributionPercent,
    required this.leaderboard,
    required this.prayerTypeId,
    this.prayerTypeName,
  });

  factory GlobalCountsData.fromJson(Map<String, dynamic> json) {
    final rawList = json['leaderboard'] as List<dynamic>? ?? [];
    return GlobalCountsData(
      yourTotal:               json['your_total']               as int,
      yourToday:               json['your_today']               as int,
      communityTotal:          json['community_total']          as int,
      communityTodayTotal:     json['community_today_total']    as int,
      yourPosition:            json['your_position']            as int,
      yourContributionPercent: (json['your_contribution_percent'] as num).toDouble(),
      leaderboard:             rawList.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList(),
      prayerTypeId:            int.parse(json['prayer_type_id'].toString()),
      prayerTypeName:          json['prayer_type_name'] as String?,
    );
  }

  /// Empty placeholder used while loading.
  factory GlobalCountsData.empty(int prayerTypeId) => GlobalCountsData(
    yourTotal: 0,
    yourToday: 0,
    communityTotal: 0,
    communityTodayTotal: 0,
    yourPosition: 0,
    yourContributionPercent: 0,
    leaderboard: [],
    prayerTypeId: prayerTypeId,
    prayerTypeName: null,
  );

  /// Create a copy with updated fields
  GlobalCountsData copyWith({
    int? yourTotal,
    int? yourToday,
    int? communityTotal,
    int? communityTodayTotal,
    int? yourPosition,
    double? yourContributionPercent,
    List<LeaderboardEntry>? leaderboard,
    int? prayerTypeId,
    String? prayerTypeName,
  }) {
    return GlobalCountsData(
      yourTotal: yourTotal ?? this.yourTotal,
      yourToday: yourToday ?? this.yourToday,
      communityTotal: communityTotal ?? this.communityTotal,
      communityTodayTotal: communityTodayTotal ?? this.communityTodayTotal,
      yourPosition: yourPosition ?? this.yourPosition,
      yourContributionPercent: yourContributionPercent ?? this.yourContributionPercent,
      leaderboard: leaderboard ?? this.leaderboard,
      prayerTypeId: prayerTypeId ?? this.prayerTypeId,
      prayerTypeName: prayerTypeName ?? this.prayerTypeName,
    );
  }
}
