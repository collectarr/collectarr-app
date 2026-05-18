class SeriesRelation {
  final String id;
  final String relationType;
  final String targetSeriesId;
  final String targetSeriesTitle;
  final String targetSeriesKind;
  final int? ordinal;
  final String? imageUrl;
  final int? startYear;
  final String? provider;
  final String? providerId;

  SeriesRelation({
    required this.id,
    required this.relationType,
    required this.targetSeriesId,
    required this.targetSeriesTitle,
    required this.targetSeriesKind,
    this.ordinal,
    this.imageUrl,
    this.startYear,
    this.provider,
    this.providerId,
  });

  factory SeriesRelation.fromJson(Map<String, dynamic> json) {
    return SeriesRelation(
      id: json['id'] as String,
      relationType: json['relation_type'] as String,
      targetSeriesId: json['target_series_id'] as String,
      targetSeriesTitle: json['target_series_title'] as String,
      targetSeriesKind: json['target_series_kind'] as String,
      ordinal: json['ordinal'] as int?,
      imageUrl: json['image_url'] as String?,
      startYear: json['start_year'] as int?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
    );
  }

  String get relationLabel {
    switch (relationType) {
      case 'sequel':
        return 'Sequel';
      case 'prequel':
        return 'Prequel';
      case 'side_story':
        return 'Side Story';
      case 'spin_off':
        return 'Spin-off';
      case 'parent':
        return 'Parent';
      case 'adaptation':
        return 'Adaptation';
      case 'alternative':
        return 'Alternative';
      case 'summary':
        return 'Summary';
      case 'compilation':
        return 'Collection';
      default:
        return 'Related';
    }
  }
}
