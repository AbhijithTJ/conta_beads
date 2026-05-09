// Models for the GET /api/intentions endpoint.

class QuoteCategory {
  final int id;
  final String name;
  final String description;

  const QuoteCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory QuoteCategory.fromJson(Map<String, dynamic> json) {
    return QuoteCategory(
      id:          json['id']          as int,
      name:        json['name']        as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class IntentionQuote {
  final int id;
  final String quotation;
  final String reference;
  final QuoteCategory category;

  const IntentionQuote({
    required this.id,
    required this.quotation,
    required this.reference,
    required this.category,
  });

  factory IntentionQuote.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'] as Map<String, dynamic>? ?? {};
    return IntentionQuote(
      id:         json['id']         as int,
      quotation:  json['quotation']  as String? ?? '',
      reference:  (json['reference'] as String? ?? '').trim(),
      category:   QuoteCategory.fromJson(rawCategory),
    );
  }
}

class AdminIntention {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? startDate;
  final String? endDate;

  const AdminIntention({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory AdminIntention.fromJson(Map<String, dynamic> json) {
    return AdminIntention(
      id:          json['id']          as int,
      title:       json['title']       as String? ?? '',
      description: json['description'] as String? ?? '',
      status:      json['status']      as String? ?? '',
      startDate:   json['start_date']  as String?,
      endDate:     json['end_date']    as String?,
    );
  }
}

class CommunityPrayers {
  final int activeRequests;

  const CommunityPrayers({
    required this.activeRequests,
  });

  factory CommunityPrayers.fromJson(Map<String, dynamic> json) {
    return CommunityPrayers(
      activeRequests: json['active_requests'] as int? ?? 0,
    );
  }
}

class PrayerCount {
  final String prayerType;
  final int activeRequests;

  const PrayerCount({
    required this.prayerType,
    required this.activeRequests,
  });

  factory PrayerCount.fromJson(Map<String, dynamic> json) {
    return PrayerCount(
      prayerType: json['prayer_type'] as String? ?? '',
      activeRequests: json['active_requests'] as int? ?? 0,
    );
  }
}

class PersonalPrayer {
  final String prayerType;
  final int personalCount;

  const PersonalPrayer({
    required this.prayerType,
    required this.personalCount,
  });

  factory PersonalPrayer.fromJson(Map<String, dynamic> json) {
    return PersonalPrayer(
      prayerType: json['prayer_type'] as String? ?? '',
      personalCount: json['personal_count'] as int? ?? 0,
    );
  }
}

class IntentionsData {
  final List<IntentionQuote> quotes;
  final List<AdminIntention> adminIntentions;
  final List<PrayerCount> communityPrayers;
  final List<PersonalPrayer> personalPrayers;

  const IntentionsData({
    required this.quotes,
    required this.adminIntentions,
    required this.communityPrayers,
    required this.personalPrayers,
  });

  factory IntentionsData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final rawQuotes = data['quotes'] as List<dynamic>? ?? [];
    final rawAdminIntentions = data['admin_intentions'] as List<dynamic>? ?? [];
    final rawCommunityPrayers = data['community_prayers'] as List<dynamic>? ?? [];
    final rawPersonalPrayers = data['personal_prayers'] as List<dynamic>? ?? [];

    return IntentionsData(
      quotes: rawQuotes
          .map((e) => IntentionQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      adminIntentions: rawAdminIntentions
          .map((e) => AdminIntention.fromJson(e as Map<String, dynamic>))
          .toList(),
      communityPrayers: rawCommunityPrayers
          .map((e) => PrayerCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      personalPrayers: rawPersonalPrayers
          .map((e) => PersonalPrayer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get rosary count from personal prayers
  int getRosaryCount() {
    final rosary = personalPrayers.firstWhere(
      (p) => p.prayerType.toLowerCase() == 'rosary',
      orElse: () => const PersonalPrayer(prayerType: 'Rosary', personalCount: 0),
    );
    return rosary.personalCount;
  }

  /// Get community rosary requests
  int getCommunityRosaryRequests() {
    final rosary = communityPrayers.firstWhere(
      (p) => p.prayerType.toLowerCase() == 'rosary',
      orElse: () => const PrayerCount(prayerType: 'Rosary', activeRequests: 0),
    );
    return rosary.activeRequests;
  }
}

// Models for the POST /api/rosaries/borrow endpoint.

class BorrowEntry {
  final int id;
  final int userId;
  final int prayerTypeId;
  final String userName;
  final String? parish;
  final String intentionText;
  final int countAdded;
  final bool isBorrowed;
  final String dateKey;
  final String createdAt;

  const BorrowEntry({
    required this.id,
    required this.userId,
    required this.prayerTypeId,
    required this.userName,
    this.parish,
    required this.intentionText,
    required this.countAdded,
    required this.isBorrowed,
    required this.dateKey,
    required this.createdAt,
  });

  factory BorrowEntry.fromJson(Map<String, dynamic> json) {
    return BorrowEntry(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      prayerTypeId: json['prayer_type_id'] as int,
      userName: json['user_name'] as String? ?? '',
      parish: json['parish'] as String?,
      intentionText: json['intention_text'] as String? ?? '',
      countAdded: json['count_added'] as int? ?? 0,
      isBorrowed: json['is_borrowed'] as bool? ?? false,
      dateKey: json['date_key'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class UserStats {
  final int totalCount;
  final int todayCount;
  final int availableToBorrow;

  const UserStats({
    required this.totalCount,
    required this.todayCount,
    required this.availableToBorrow,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalCount: json['total_count'] as int? ?? 0,
      todayCount: json['today_count'] as int? ?? 0,
      availableToBorrow: json['available_to_borrow'] as int? ?? 0,
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
      totalCount: json['total_count'] as int? ?? 0,
      todayCount: json['today_count'] as int? ?? 0,
      totalPrayed: json['total_prayed'] as int? ?? 0,
      totalBorrowed: json['total_borrowed'] as int? ?? 0,
      availableBalance: json['available_balance'] as int? ?? 0,
      todayPrayed: json['today_prayed'] as int? ?? 0,
      todayBorrowed: json['today_borrowed'] as int? ?? 0,
      todayAvailable: json['today_available'] as int? ?? 0,
      prayerTypeId: json['prayer_type_id'] as int? ?? 0,
      prayerTypeName: json['prayer_type_name'] as String? ?? '',
    );
  }
}

class BalanceChange {
  final int before;
  final int borrowed;
  final int after;

  const BalanceChange({
    required this.before,
    required this.borrowed,
    required this.after,
  });

  factory BalanceChange.fromJson(Map<String, dynamic> json) {
    return BalanceChange(
      before: json['before'] as int? ?? 0,
      borrowed: json['borrowed'] as int? ?? 0,
      after: json['after'] as int? ?? 0,
    );
  }
}

class BorrowResponse {
  final bool success;
  final String message;
  final BorrowEntry entry;
  final UserStats userStats;
  final PrayerStats prayerStats;
  final BalanceChange balanceChange;

  const BorrowResponse({
    required this.success,
    required this.message,
    required this.entry,
    required this.userStats,
    required this.prayerStats,
    required this.balanceChange,
  });

  factory BorrowResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return BorrowResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      entry: BorrowEntry.fromJson(data['entry'] as Map<String, dynamic>? ?? {}),
      userStats: UserStats.fromJson(data['user_stats'] as Map<String, dynamic>? ?? {}),
      prayerStats: PrayerStats.fromJson(data['prayer_stats'] as Map<String, dynamic>? ?? {}),
      balanceChange: BalanceChange.fromJson(data['balance_change'] as Map<String, dynamic>? ?? {}),
    );
  }
}
