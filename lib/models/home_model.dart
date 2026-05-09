// Models for the GET /api/home endpoint.

class HomeQuote {
  final int id;
  final String quotation;
  final String reference;

  const HomeQuote({
    required this.id,
    required this.quotation,
    required this.reference,
  });

  factory HomeQuote.fromJson(Map<String, dynamic> json) {
    return HomeQuote(
      id:         json['id']         as int,
      quotation:  json['quotation']  as String,
      reference:  json['reference']  as String? ?? '',
    );
  }
}

class HomeSection {
  final int id;
  final String title;
  final String description;
  final String image;
  final String route;
  final String icon;
  final String type;
  final int order;

  const HomeSection({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.route,
    required this.icon,
    required this.type,
    required this.order,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      id:          json['id']          as int,
      title:       json['title']       as String,
      description: json['description'] as String? ?? '',
      image:       json['image']       as String? ?? '',
      route:       json['route']       as String? ?? '',
      icon:        json['icon']        as String? ?? '',
      type:        json['type']        as String? ?? '',
      order:       json['order']       as int? ?? 0,
    );
  }
}

class HomeUser {
  final int id;
  final String name;
  final int rosaryAvailable;
  final int rosaryTodayAvailable;
  final int chapelAvailable;
  final int chapelTodayAvailable;

  const HomeUser({
    required this.id,
    required this.name,
    required this.rosaryAvailable,
    required this.rosaryTodayAvailable,
    required this.chapelAvailable,
    required this.chapelTodayAvailable,
  });

  factory HomeUser.fromJson(Map<String, dynamic> json) {
    return HomeUser(
      id:                   json['id']                     as int,
      name:                 json['name']                   as String? ?? '',
      rosaryAvailable:      json['rosary_available']       as int? ?? 0,
      rosaryTodayAvailable: json['rosary_today_available'] as int? ?? 0,
      chapelAvailable:      json['chapel_available']       as int? ?? 0,
      chapelTodayAvailable: json['chapel_today_available'] as int? ?? 0,
    );
  }
}

class HomeData {
  final List<HomeQuote> quotes;
  final List<HomeSection> sections;
  final HomeUser? user;

  const HomeData({
    required this.quotes,
    required this.sections,
    this.user,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final rawQuotes   = data['quotes']   as List<dynamic>? ?? [];
    final rawSections = data['sections'] as List<dynamic>? ?? [];
    final rawUser     = data['user']     as Map<String, dynamic>?;

    return HomeData(
      quotes:   rawQuotes.map((e)   => HomeQuote.fromJson(e   as Map<String, dynamic>)).toList(),
      sections: rawSections.map((e) => HomeSection.fromJson(e as Map<String, dynamic>)).toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
      user:     rawUser != null ? HomeUser.fromJson(rawUser) : null,
    );
  }
}
