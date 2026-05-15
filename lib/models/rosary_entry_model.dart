/// Models for POST /api/rosaries response

class RosaryEntry {
  final int id;
  final int userId;
  final int prayerTypeId;
  final String userName;
  final String? parish;
  final String intentionText;
  final int countAdded;
  final String dateKey;
  final String createdAt;

  const RosaryEntry({
    required this.id,
    required this.userId,
    required this.prayerTypeId,
    required this.userName,
    this.parish,
    required this.intentionText,
    required this.countAdded,
    required this.dateKey,
    required this.createdAt,
  });

  factory RosaryEntry.fromJson(Map<String, dynamic> json) {
    return RosaryEntry(
      id:            json['id']             as int,
      userId:        json['user_id']        as int,
      prayerTypeId:  json['prayer_type_id'] as int,
      userName:      json['user_name']      as String? ?? '',
      parish:        json['parish']         as String?,
      intentionText: json['intention_text'] as String? ?? '',
      countAdded:    json['count_added']    as int? ?? 0,
      dateKey:       json['date_key']       as String? ?? '',
      createdAt:     json['created_at']     as String? ?? '',
    );
  }
}

class UserStats {
  final int totalCount;
  final int todayCount;

  const UserStats({
    required this.totalCount,
    required this.todayCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalCount: json['total_count']  as int? ?? 0,
      todayCount: json['today_count']  as int? ?? 0,
    );
  }
}

class PrayerStats {
  final int totalCount;
  final int todayCount;
  final int totalPrayed;
  final int totalBorrowed;
  final int availableBalance;
  final int todayPrayed;
  final int todayBorrowed;
  final int todayAvailable;
  final int prayerTypeId;
  final String prayerTypeName;

  const PrayerStats({
    required this.totalCount,
    required this.todayCount,
    required this.totalPrayed,
    required this.totalBorrowed,
    required this.availableBalance,
    required this.todayPrayed,
    required this.todayBorrowed,
    required this.todayAvailable,
    required this.prayerTypeId,
    required this.prayerTypeName,
  });

  factory PrayerStats.fromJson(Map<String, dynamic> json) {
    return PrayerStats(
      totalCount:      json['total_count']       as int? ?? 0,
      todayCount:      json['today_count']       as int? ?? 0,
      totalPrayed:     json['total_prayed']      as int? ?? 0,
      totalBorrowed:   json['total_borrowed']    as int? ?? 0,
      availableBalance: json['available_balance'] as int? ?? 0,
      todayPrayed:     json['today_prayed']      as int? ?? 0,
      todayBorrowed:   json['today_borrowed']    as int? ?? 0,
      todayAvailable:  json['today_available']   as int? ?? 0,
      prayerTypeId:    json['prayer_type_id']    as int? ?? 0,
      prayerTypeName:  json['prayer_type_name']  as String? ?? '',
    );
  }
}

class RosaryEntryResponse {
  final RosaryEntry entry;
  final UserStats userStats;
  final PrayerStats? prayerStats;

  const RosaryEntryResponse({
    required this.entry,
    required this.userStats,
    this.prayerStats,
  });

  factory RosaryEntryResponse.fromJson(Map<String, dynamic> json) {
    return RosaryEntryResponse(
      entry:       RosaryEntry.fromJson(json['entry'] as Map<String, dynamic>),
      userStats:   UserStats.fromJson(json['user_stats'] as Map<String, dynamic>),
      prayerStats: json['prayer_stats'] != null 
          ? PrayerStats.fromJson(json['prayer_stats'] as Map<String, dynamic>)
          : null,
    );
  }
}
