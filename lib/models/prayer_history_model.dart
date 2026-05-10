/// Models for GET /api/rosaries/history response

class PrayerHistoryEntry {
  final int id;
  final int userId;
  final int prayerTypeId;
  final String userName;
  final String? parish;
  final String? intentionText;
  final int countAdded;
  final bool isBorrowed;
  final String dateKey;
  final String createdAt;
  final String updatedAt;

  const PrayerHistoryEntry({
    required this.id,
    required this.userId,
    required this.prayerTypeId,
    required this.userName,
    this.parish,
    this.intentionText,
    required this.countAdded,
    required this.isBorrowed,
    required this.dateKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrayerHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PrayerHistoryEntry(
      id:            json['id']             as int,
      userId:        json['user_id']        as int,
      prayerTypeId:  json['prayer_type_id'] as int,
      userName:      json['user_name']      as String? ?? '',
      parish:        json['parish']         as String?,
      intentionText: json['intention_text'] as String?,
      countAdded:    json['count_added']    as int? ?? 0,
      isBorrowed:    json['is_borrowed']    as bool? ?? false,
      dateKey:       json['date_key']       as String? ?? '',
      createdAt:     json['created_at']     as String? ?? '',
      updatedAt:     json['updated_at']     as String? ?? '',
    );
  }
}

class PrayerHistoryMeta {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  const PrayerHistoryMeta({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory PrayerHistoryMeta.fromJson(Map<String, dynamic> json) {
    return PrayerHistoryMeta(
      currentPage: json['current_page'] as int? ?? 1,
      total:       json['total']        as int? ?? 0,
      perPage:     json['per_page']     as int? ?? 20,
      lastPage:    json['last_page']    as int? ?? 1,
    );
  }
}

class PrayerHistoryResponse {
  final List<PrayerHistoryEntry> data;
  final PrayerHistoryMeta meta;

  const PrayerHistoryResponse({
    required this.data,
    required this.meta,
  });

  factory PrayerHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>?)
        ?.map((item) => PrayerHistoryEntry.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    return PrayerHistoryResponse(
      data: dataList,
      meta: PrayerHistoryMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}
