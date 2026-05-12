class OwnedItem {
  const OwnedItem({
    required this.id,
    required this.itemId,
    this.editionId,
    this.variantId,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.storageBox,
    this.indexNumber,
    this.coverPriceCents,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.keyComic = false,
    this.keyReason,
    this.rating,
    this.readStatus,
    this.tags,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String itemId;
  final String? editionId;
  final String? variantId;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final String? storageBox;
  final int? indexNumber;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final int? rating;
  final String? readStatus;
  final String? tags;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'item_id': itemId,
      'edition_id': editionId,
      'variant_id': variantId,
      'condition': condition,
      'grade': grade,
      'purchase_date': purchaseDate?.toUtc().toIso8601String(),
      'price_paid_cents': pricePaidCents,
      'currency': currency,
      'personal_notes': personalNotes,
      'quantity': quantity,
      'storage_box': storageBox,
      'index_number': indexNumber,
      'cover_price_cents': coverPriceCents,
      'raw_or_slabbed': rawOrSlabbed,
      'grading_company': gradingCompany,
      'grader_notes': graderNotes,
      'signed_by': signedBy,
      'key_comic': keyComic,
      'key_reason': keyReason,
      'rating': rating,
      'read_status': readStatus,
      'tags': tags,
    };
  }

  factory OwnedItem.fromJson(Map<String, dynamic> json) {
    return OwnedItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      editionId: json['edition_id'] as String?,
      variantId: json['variant_id'] as String?,
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      pricePaidCents: json['price_paid_cents'] as int?,
      currency: json['currency'] as String?,
      personalNotes: json['personal_notes'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      storageBox: json['storage_box'] as String?,
      indexNumber: json['index_number'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      rawOrSlabbed: json['raw_or_slabbed'] as String?,
      gradingCompany: json['grading_company'] as String?,
      graderNotes: json['grader_notes'] as String?,
      signedBy: json['signed_by'] as String?,
      keyComic: json['key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      rating: json['rating'] as int?,
      readStatus: json['read_status'] as String?,
      tags: json['tags'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  OwnedItem copyWith({
    String? id,
    String? itemId,
    String? editionId,
    String? variantId,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    String? storageBox,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    bool? keyComic,
    String? keyReason,
    int? rating,
    String? readStatus,
    String? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return OwnedItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      storageBox: storageBox ?? this.storageBox,
      indexNumber: indexNumber ?? this.indexNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
