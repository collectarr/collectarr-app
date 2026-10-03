import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';

/// A user-level correction for one field on one local library entry.
///
/// The Catalog Item and field identifier are opaque to generic persistence and
/// synchronization. The owning kind validates and interprets them.
class UserMetadataOverride {
  UserMetadataOverride({
    required this.id,
    required this.libraryEntryRef,
    required this.fieldId,
    required this.overrideValue,
    required this.updatedAt,
    this.originalValue,
    this.deletedAt,
  });

  /// Unique override id (UUID v4).
  final String id;

  /// Structural catalog target. Its semantic meaning belongs to the kind.
  final LibraryEntryRef libraryEntryRef;

  /// Kind-entry field identifier. The generic layer does not inspect its
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
      'library_entry_ref': libraryEntryRef.toJson(),
      'field_key': fieldId.serializedValue,
      'original_value': originalValue,
      'override_value': overrideValue,
    };
  }

  factory UserMetadataOverride.fromJson(Map<String, Object?> json) {
    final rawEntryRef = json['library_entry_ref'];
    if (rawEntryRef is! Map) {
      throw const FormatException('Metadata override library_entry_ref is required');
    }
    final libraryEntryRef = LibraryEntryRef.fromJson(
      Map<String, Object?>.from(rawEntryRef),
    );
    return UserMetadataOverride(
      id: json['id'] as String,
      libraryEntryRef: libraryEntryRef,
      fieldId: MetadataFieldId(
        kind: libraryEntryRef.kind,
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
    LibraryEntryRef? libraryEntryRef,
    MetadataFieldId? fieldId,
    String? originalValue,
    String? overrideValue,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserMetadataOverride(
      id: id ?? this.id,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      fieldId: fieldId ?? this.fieldId,
      originalValue: originalValue ?? this.originalValue,
      overrideValue: overrideValue ?? this.overrideValue,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
