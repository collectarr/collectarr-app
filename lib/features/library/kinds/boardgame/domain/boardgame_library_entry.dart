import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_personal_data.dart';
import 'package:flutter/foundation.dart';

/// Complete Board Game-collection item state. Reading progress is a separate concern.
@immutable
final class BoardGameLibraryEntry implements JsonEncodable {
  const BoardGameLibraryEntry({
    required this.id,
    required this.metadata,
    this.sourceCatalogRef,
    this.createdAt,
    this.personal = const BoardGamePersonalData(),
    required this.updatedAt,
    this.deletedAt,
  });

  final LibraryEntryId id;
  final BoardGameMetadata metadata;
  final CatalogItemRef? sourceCatalogRef;
  final BoardGamePersonalData personal;

  CatalogItemDto get catalogItem => CatalogItemDto.raw(
        id: id.value,
        mediaKind: CatalogMediaKind.boardgame,
        kindData: metadata.toJson(),
        origin: CatalogItemOrigin.privateLocal,
      );
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => id.value;
  bool get isDeleted => deletedAt != null;

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'catalog_data': metadata.toJson(),
        'source_catalog_ref': sourceCatalogRef?.toJson(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        ...personal.toJson(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory BoardGameLibraryEntry.fromJson(Map<String, dynamic> json) {
    const obsoleteIdentityFields = {'catalog_ref', 'target_ref'};
    final obsoleteFields =
        json.keys.where(obsoleteIdentityFields.contains).toList();
    if (obsoleteFields.isNotEmpty) {
      throw FormatException(
        'Local library entry contains unsupported identity fields: '
        '${obsoleteFields.toList()..sort()}.',
      );
    }

    final rawCatalogData = json['catalog_data'];
    if (rawCatalogData is! Map) {
      throw const FormatException(
        'A Board Game library entry requires typed catalog metadata.',
      );
    }

    return BoardGameLibraryEntry(
      id: LibraryEntryId(json['id'] as String),
      metadata: BoardGameMetadata.fromJson(
        Map<String, dynamic>.from(rawCatalogData),
      ),
      personal: BoardGamePersonalData.fromJson(json),
      sourceCatalogRef: json['source_catalog_ref'] is Map
          ? CatalogItemRef.fromJson(
              Map<String, dynamic>.from(json['source_catalog_ref'] as Map))
          : null,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']) ?? DateTime.utc(1970),
      deletedAt: _date(json['deleted_at']),
    );
  }

  BoardGameLibraryEntry copyWith({
    LibraryEntryId? id,
    BoardGameMetadata? metadata,
    BoardGamePersonalData? personal,
    Object? createdAt = _unset,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return BoardGameLibraryEntry(
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

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
