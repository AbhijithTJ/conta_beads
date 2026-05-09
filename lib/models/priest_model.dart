// Models for the GET /api/priests endpoint.

class Priest {
  final int id;
  final String displayName;

  const Priest({
    required this.id,
    required this.displayName,
  });

  factory Priest.fromJson(Map<String, dynamic> json) {
    return Priest(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
    );
  }

  @override
  String toString() => 'Priest(id: $id, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Priest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName;

  @override
  int get hashCode => id.hashCode ^ displayName.hashCode;
}

class PriestsData {
  final List<Priest> priests;
  final int count;
  final String type;
  final String search;

  const PriestsData({
    required this.priests,
    required this.count,
    required this.type,
    required this.search,
  });

  factory PriestsData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final rawPriests = data['priests'] as List<dynamic>? ?? [];

    return PriestsData(
      priests: rawPriests
          .map((p) => Priest.fromJson(p as Map<String, dynamic>))
          .toList(),
      count: data['count'] as int? ?? 0,
      type: data['type'] as String? ?? '',
      search: data['search'] as String? ?? '',
    );
  }

  /// Empty placeholder used while loading.
  factory PriestsData.empty() => const PriestsData(
    priests: [],
    count: 0,
    type: '',
    search: '',
  );
}

class AdoptedPriest {
  final int id;
  final String displayName;
  final String originalName;
  final String note;

  const AdoptedPriest({
    required this.id,
    required this.displayName,
    required this.originalName,
    required this.note,
  });

  factory AdoptedPriest.fromJson(Map<String, dynamic> json) {
    return AdoptedPriest(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
      originalName: json['original_name'] as String,
      note: json['note'] as String? ?? '',
    );
  }
}

class AdoptPriestsResponse {
  final bool success;
  final String message;
  final List<AdoptedPriest> adoptedPriests;
  final int adoptedCount;
  final int totalAdopted;
  final int remainingSlots;
  final List<String> errors;

  const AdoptPriestsResponse({
    required this.success,
    required this.message,
    required this.adoptedPriests,
    required this.adoptedCount,
    required this.totalAdopted,
    required this.remainingSlots,
    required this.errors,
  });

  factory AdoptPriestsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawPriests = data['adopted_priests'] as List<dynamic>? ?? [];

    return AdoptPriestsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      adoptedPriests: rawPriests
          .map((p) => AdoptedPriest.fromJson(p as Map<String, dynamic>))
          .toList(),
      adoptedCount: data['adopted_count'] as int? ?? 0,
      totalAdopted: data['total_adopted'] as int? ?? 0,
      remainingSlots: data['remaining_slots'] as int? ?? 0,
      errors: List<String>.from(data['errors'] as List<dynamic>? ?? []),
    );
  }
}
