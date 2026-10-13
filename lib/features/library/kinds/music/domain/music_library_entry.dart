import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:flutter/foundation.dart';

/// Complete Music-collection item state.
///
/// Each row is a complete, independently editable local album entry.
/// Core provenance is retained separately from the local entry identity.
@immutable
final class MusicLibraryEntry implements JsonEncodable {
  const MusicLibraryEntry({
    required this.id,
    required this.metadata,
    this.sourceCatalogRef,
    this.createdAt,
    this.personal = const MusicPersonalData(),
    required this.updatedAt,
    this.deletedAt,
  });

  final LibraryEntryId id;
  final MusicAlbum metadata;
  final CatalogItemRef? sourceCatalogRef;
  final MusicPersonalData personal;

  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => id.value;
  bool get isDeleted => deletedAt != null;

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'catalog_data': _catalogData(metadata),
        'source_catalog_ref': sourceCatalogRef?.toJson(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        ...personal.toJson(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory MusicLibraryEntry.fromJson(Map<String, dynamic> json) {
    const obsoleteIdentityFields = {'catalog_ref', 'target_ref'};
    final obsoleteFields =
        json.keys.where(obsoleteIdentityFields.contains).toList();
    if (obsoleteFields.isNotEmpty) {
      throw FormatException(
        'Local library entry contains unsupported identity fields: '
        '${obsoleteFields.toList()..sort()}.',
      );
    }

    final id = LibraryEntryId(json['id'] as String);
    final rawCatalogData = json['catalog_data'];
    if (rawCatalogData is! Map) {
      throw const FormatException(
        'A Music library entry requires typed catalog metadata.',
      );
    }
    final item = MusicLibraryEntry(
      id: id,
      metadata: MusicAlbum.fromJson(
        Map<String, dynamic>.from(rawCatalogData),
      ),
      personal: MusicPersonalData.fromJson(json),
      sourceCatalogRef: json['source_catalog_ref'] is Map
          ? CatalogItemRef.fromJson(
              Map<String, dynamic>.from(json['source_catalog_ref'] as Map))
          : null,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']) ?? DateTime.utc(1970),
      deletedAt: _date(json['deleted_at']),
    );
    return item;
  }

  MusicLibraryEntry copyWith({
    LibraryEntryId? id,
    MusicAlbum? metadata,
    MusicPersonalData? personal,
    Object? createdAt = _unset,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return MusicLibraryEntry(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      personal: personal ?? this.personal,
      sourceCatalogRef: sourceCatalogRef,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

const Object _unset = Object();

Map<String, dynamic> _catalogData(MusicAlbum metadata) =>
    Map<String, dynamic>.from(metadata.toJson())
      ..remove('id')
      ..remove('kind');

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
