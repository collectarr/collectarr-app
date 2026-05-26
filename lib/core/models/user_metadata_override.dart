/// A user-level correction/override for a single field on a catalog item.
///
/// Overrides are stored locally and synced. When displaying catalog data the
/// app merges active overrides on top of the original provider metadata,
/// letting users fix mistakes without losing the original values.
class UserMetadataOverride {
  UserMetadataOverride({
    required this.id,
    required this.itemId,
    required this.fieldPath,
    required this.overrideValue,
    required this.updatedAt,
    this.originalValue,
    this.editionId,
    this.variantId,
    this.deletedAt,
  });

  /// Unique override id (UUID v4).
  final String id;

  /// The catalog item this override applies to.
  final String itemId;

  /// Optional edition scope — when set, the override applies to a specific
  /// edition rather than the top-level item.
  final String? editionId;

  /// Optional variant scope — when set, the override applies to a specific
  /// variant within an edition.
  final String? variantId;

  /// Dot-separated path of the field being overridden.
  ///
  /// Top-level item fields: `title`, `synopsis`, `publisher`, `release_year`,
  /// `cover_image_url`, etc.
  ///
  /// Edition fields (requires [editionId]): `edition.title`,
  /// `edition.publisher`, `edition.isbn`, etc.
  ///
  /// Variant fields (requires [variantId]): `variant.name`,
  /// `variant.barcode`, `variant.cover_price_cents`, etc.
  final String fieldPath;

  /// The original value from the catalog provider (snapshot at override time).
  /// Stored for diff view. May be null if the original was empty.
  final String? originalValue;

  /// The user's corrected value. Stored as a JSON-encoded string for
  /// uniformity across field types.
  final String overrideValue;

  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// Scope key used to group overrides: item-level, edition-level, or
  /// variant-level.
  String get scopeKey {
    if (variantId != null) return 'variant:$variantId';
    if (editionId != null) return 'edition:$editionId';
    return 'item:$itemId';
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'item_id': itemId,
      if (editionId != null) 'edition_id': editionId,
      if (variantId != null) 'variant_id': variantId,
      'field_path': fieldPath,
      'original_value': originalValue,
      'override_value': overrideValue,
    };
  }

  factory UserMetadataOverride.fromJson(Map<String, dynamic> json) {
    return UserMetadataOverride(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      editionId: json['edition_id'] as String?,
      variantId: json['variant_id'] as String?,
      fieldPath: json['field_path'] as String,
      originalValue: json['original_value'] as String?,
      overrideValue: json['override_value'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  UserMetadataOverride copyWith({
    String? id,
    String? itemId,
    String? editionId,
    String? variantId,
    String? fieldPath,
    String? originalValue,
    String? overrideValue,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserMetadataOverride(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      fieldPath: fieldPath ?? this.fieldPath,
      originalValue: originalValue ?? this.originalValue,
      overrideValue: overrideValue ?? this.overrideValue,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
