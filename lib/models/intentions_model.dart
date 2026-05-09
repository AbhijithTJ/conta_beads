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
