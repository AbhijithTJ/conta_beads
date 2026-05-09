/// Models for GET /api/daily-prayers?prayer_type_id={id}

class DailyPrayerLanguage {
  final int id;
  final String name;
  final String? code;

  const DailyPrayerLanguage({
    required this.id,
    required this.name,
    this.code,
  });

  factory DailyPrayerLanguage.fromJson(Map<String, dynamic> json) {
    return DailyPrayerLanguage(
      id:   json['id']   as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }
}

class DailyPrayerType {
  final int id;
  final String name;
  final String description;
  final String image;
  final String icon;
  final int globalGoal;
  final DailyPrayerLanguage? language;

  const DailyPrayerType({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.icon,
    required this.globalGoal,
    this.language,
  });

  factory DailyPrayerType.fromJson(Map<String, dynamic> json) {
    return DailyPrayerType(
      id:          json['id']          as int,
      name:        json['name']        as String,
      description: json['description'] as String? ?? '',
      image:       json['image']       as String? ?? '',
      icon:        json['icon']        as String? ?? '',
      globalGoal:  json['global_goal'] as int? ?? 0,
      language:    json['language'] != null
          ? DailyPrayerLanguage.fromJson(json['language'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DailyPrayer {
  final int id;
  final String title;
  final String prayerText; // may contain HTML
  final String createdAt;
  final String updatedAt;

  const DailyPrayer({
    required this.id,
    required this.title,
    required this.prayerText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyPrayer.fromJson(Map<String, dynamic> json) {
    return DailyPrayer(
      id:        json['id']         as int,
      title:     json['title']      as String,
      prayerText: json['prayer_text'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class DailyPrayerData {
  final bool success;
  final DailyPrayerType prayerType;
  final int currentDay;
  final String dayName;
  final String timezone;
  final DailyPrayer prayer;

  const DailyPrayerData({
    required this.success,
    required this.prayerType,
    required this.currentDay,
    required this.dayName,
    required this.timezone,
    required this.prayer,
  });

  factory DailyPrayerData.fromJson(Map<String, dynamic> json) {
    return DailyPrayerData(
      success:    json['success']    as bool? ?? false,
      prayerType: DailyPrayerType.fromJson(json['prayer_type'] as Map<String, dynamic>),
      currentDay: json['current_day'] as int? ?? 0,
      dayName:    json['day_name']   as String? ?? '',
      timezone:   json['timezone']   as String? ?? '',
      prayer:     DailyPrayer.fromJson(json['prayer'] as Map<String, dynamic>),
    );
  }
}
