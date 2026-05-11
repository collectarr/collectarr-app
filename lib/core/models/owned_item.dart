class OwnedItem {
  const OwnedItem({
    required this.id,
    required this.itemId,
    this.editionId,
    this.variantId,
    this.condition,
    this.grade,
    this.personalNotes,
  });

  final String id;
  final String itemId;
  final String? editionId;
  final String? variantId;
  final String? condition;
  final String? grade;
  final String? personalNotes;

  factory OwnedItem.fromJson(Map<String, dynamic> json) {
    return OwnedItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      editionId: json['edition_id'] as String?,
      variantId: json['variant_id'] as String?,
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      personalNotes: json['personal_notes'] as String?,
    );
  }
}

