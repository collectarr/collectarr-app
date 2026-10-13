import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

const libraryEntrySyncImagesKey = '__sync_item_images';
const libraryEntrySyncCustomFieldsKey = '__sync_custom_fields';
const libraryEntrySyncLoansKey = '__sync_loans';
const libraryEntrySyncFolderMembershipsKey = '__sync_folder_memberships';
const libraryEntrySyncReadingQueuePositionKey = '__sync_reading_queue_position';
const libraryEntrySyncExternalLinksKey = '__sync_external_links';
const libraryEntryCsvFolderDefinitionsKey = '__csv_folder_definitions';

/// The complete local record. Duplicate records never share editable values.
final class LibraryEntryRecord {
  LibraryEntryRecord({
    required this.id,
    required this.kind,
    required JsonMap catalogData,
    required JsonMap personalData,
    required this.updatedAt,
    this.sourceCatalogRef,
    this.deletedAt,
  })  : catalogData = _snapshot(catalogData),
        personalData = _snapshot(personalData) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Library entry IDs cannot be empty.');
    }
    if (kind.isUnknown) {
      throw ArgumentError.value(
          kind, 'kind', 'Library entry kind must be known.');
    }
    if (this.catalogData.isEmpty) {
      throw ArgumentError.value(
        catalogData,
        'catalogData',
        'A library entry must contain its catalog metadata.',
      );
    }
    final sourceRef = sourceCatalogRef;
    if (sourceRef != null && sourceRef.kind != kind) {
      throw ArgumentError.value(
        sourceRef,
        'sourceCatalogRef',
        'Source catalog kind must match the local library entry kind.',
      );
    }
  }

  final String id;
  final CatalogMediaKind kind;
  final JsonMap catalogData;
  final JsonMap personalData;
  final CatalogItemRef? sourceCatalogRef;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  JsonMap toJson() => {
        'id': id,
        'kind': kind.apiValue,
        'catalog_data': catalogData,
        'personal_data': personalData,
        if (sourceCatalogRef != null)
          'source_catalog_ref': sourceCatalogRef!.toJson(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  factory LibraryEntryRecord.fromJson(JsonMap json) {
    const allowedKeys = {
      'id',
      'kind',
      'catalog_data',
      'personal_data',
      'source_catalog_ref',
      'updated_at',
      'deleted_at',
    };
    final unsupportedKeys = json.keys.toSet().difference(allowedKeys);
    if (unsupportedKeys.isNotEmpty) {
      throw FormatException(
        'Library entry contains unsupported fields: '
        '${unsupportedKeys.toList()..sort()}.',
      );
    }
    final id = json['id'];
    final catalog = json['catalog_data'];
    final personal = json['personal_data'];
    final rawKind = json['kind'];
    if (id is! String ||
        id.trim().isEmpty ||
        rawKind is! String ||
        catalog is! Map ||
        personal is! Map ||
        catalog.isEmpty ||
        json['updated_at'] is! String ||
        (json['deleted_at'] != null && json['deleted_at'] is! String)) {
      throw const FormatException(
        'A library entry requires a non-empty ID, kind, catalog data, and personal data.',
      );
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('Unknown library entry kind: $rawKind');
    }
    final source = json['source_catalog_ref'];
    if (source != null && source is! Map) {
      throw const FormatException('source_catalog_ref must be an object.');
    }
    return LibraryEntryRecord(
      id: id,
      kind: kind,
      catalogData: JsonMap.from(catalog),
      personalData: JsonMap.from(personal),
      sourceCatalogRef: source == null
          ? null
          : CatalogItemRef.fromJson(JsonMap.from(source as Map)),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  /// Kind-specific form projections use the local record identity, never the
  /// source Core identity. This is not a second persisted entity.
  JsonMap toKindJson() => {
        ...personalData,
        'id': id,
        'catalog_data': catalogData,
        'source_catalog_ref': sourceCatalogRef?.toJson(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };
}

JsonMap _snapshot(JsonMap values) => JsonMap.unmodifiable(
      JsonMap.from(jsonDecode(jsonEncode(values)) as Map),
    );
