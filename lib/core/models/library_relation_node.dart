class LibraryRelationNode {
  const LibraryRelationNode({
    required this.id,
    required this.relationType,
    required this.targetId,
    required this.targetTitle,
    required this.targetKind,
    this.ordinal,
    this.imageUrl,
    this.startYear,
    this.provider,
    this.providerId,
  });

  factory LibraryRelationNode.fromJson(Map<String, dynamic> json) {
    return LibraryRelationNode(
      id: json['id'] as String,
      relationType: json['relation_type'] as String,
      targetId: (json['target_id'] ?? json['target_series_id']) as String,
      targetTitle:
          (json['target_title'] ?? json['target_series_title']) as String,
      targetKind: (json['target_kind'] ?? json['target_series_kind']) as String,
      ordinal: json['ordinal'] as int?,
      imageUrl: json['image_url'] as String?,
      startYear: json['start_year'] as int?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
    );
  }

  final String id;
  final String relationType;
  final String targetId;
  final String targetTitle;
  final String targetKind;
  final int? ordinal;
  final String? imageUrl;
  final int? startYear;
  final String? provider;
  final String? providerId;

  String get relationLabel {
    return switch (relationType) {
      'sequel' => 'Sequel',
      'prequel' => 'Prequel',
      'side_story' => 'Side Story',
      'spin_off' => 'Spin-off',
      'parent' => 'Parent',
      'adaptation' => 'Adaptation',
      'alternative' => 'Alternative',
      'summary' => 'Summary',
      'compilation' => 'Collection',
      _ => 'Related',
    };
  }
}

class LibraryRelationTarget {
  const LibraryRelationTarget({
    required this.id,
    required this.title,
    required this.label,
  });

  final String id;
  final String title;
  final String label;
}
