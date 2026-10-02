import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';

/// A user-level correction for one field on one Catalog Item.
///
/// The Catalog Item and field identifier are opaque to generic persistence and
/// synchronization. The owning kind validates and interprets them.
class UserMetadataOverride {
  UserMetadataOverride({
    required this.id,
    required this.catalogRef,
    required this.fieldId,
    required this.overrideValue,
    required this.updatedAt,
    this.originalValue,
    this.deletedAt,
  });

  /// Unique override id (UUID v4).
  final String id;

  /// Structural catalog target. Its semantic meaning belongs to the kind.
  final CatalogItemRef catalogRef;

  /// Kind-owned field identifier. The generic layer does not inspect its
  /// value; it only carries the typed identity to a serialization boundary.
  final MetadataFieldId fieldId;

  /// Original value captured when the override was created.
  final String? originalValue;

  /// JSON-encoded corrected value.
  final String overrideValue;

  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      'field_key': fieldId.serializedValue,
      'original_value': originalValue,
      'override_value': overrideValue,
    };
  }

  factory UserMetadataOverride.fromJson(Map<String, Object?> json) {
    final rawCatalogRef = json['catalog_ref'];
    if (rawCatalogRef is! Map) {
      throw const FormatException('Metadata override catalog_ref is required');
    }
    final catalogRef = CatalogItemRef.fromJson(
      Map<String, Object?>.from(rawCatalogRef),
    );
    return UserMetadataOverride(
      id: json['id'] as String,
      catalogRef: catalogRef,
      fieldId: MetadataFieldId(
        kind: catalogRef.kind,
        value: json['field_key'] as String,
      ),
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
    CatalogItemRef? catalogRef,
    MetadataFieldId? fieldId,
    String? originalValue,
    String? overrideValue,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserMetadataOverride(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      fieldId: fieldId ?? this.fieldId,
      originalValue: originalValue ?? this.originalValue,
      overrideValue: overrideValue ?? this.overrideValue,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
