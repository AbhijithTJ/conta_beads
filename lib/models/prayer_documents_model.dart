/// Models for GET /api/prayer-documents

class PrayerDocumentLanguage {
  final int id;
  final String name;
  final String? code;

  const PrayerDocumentLanguage({
    required this.id,
    required this.name,
    this.code,
  });

  factory PrayerDocumentLanguage.fromJson(Map<String, dynamic> json) {
    return PrayerDocumentLanguage(
      id:   json['id']   as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }
}

class PrayerDocument {
  final int id;
  final String title;
  final String? description; // Short description/subtitle
  final String type; // 'link' or 'text'
  final String? link; // URL for link type
  final String? data; // HTML content for text type
  final String imageFile;
  final String imagePath;
  final int languageId;
  final PrayerDocumentLanguage language;

  const PrayerDocument({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.link,
    this.data,
    required this.imageFile,
    required this.imagePath,
    required this.languageId,
    required this.language,
  });

  factory PrayerDocument.fromJson(Map<String, dynamic> json) {
    return PrayerDocument(
      id:          json['id']          as int,
      title:       json['title']       as String,
      description: json['description'] as String?,
      type:        json['type']        as String,
      link:        json['link']        as String?,
      data:        json['data']        as String?,
      imageFile:   json['image_file']  as String? ?? '',
      imagePath:   json['image_path']  as String? ?? '',
      languageId:  json['language_id'] as int,
      language:    PrayerDocumentLanguage.fromJson(json['language'] as Map<String, dynamic>),
    );
  }
}

class PrayerDocumentsData {
  final bool success;
  final List<PrayerDocument> documents;
  final int count;

  const PrayerDocumentsData({
    required this.success,
    required this.documents,
    required this.count,
  });

  factory PrayerDocumentsData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final docsList = (data['documents'] as List<dynamic>?)
        ?.map((doc) => PrayerDocument.fromJson(doc as Map<String, dynamic>))
        .toList() ?? [];
    
    return PrayerDocumentsData(
      success:   json['success'] as bool? ?? false,
      documents: docsList,
      count:     data['count'] as int? ?? 0,
    );
  }
}
