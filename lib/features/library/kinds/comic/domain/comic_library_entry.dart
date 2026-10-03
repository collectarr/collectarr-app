import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:flutter/foundation.dart';

/// The complete Comic-entry domain model.
///
/// Comic metadata, personal state, and provenance for one local entry.
@immutable
final class ComicLibraryEntry implements JsonEncodable {
  const ComicLibraryEntry({
    required this.id,
    required this.metadata,
    this.sourceCatalogRef,
    this.createdAt,
    this.personal = const ComicPersonalData(),
    required this.updatedAt,
    this.deletedAt,
  });

  final LibraryEntryId id;
  final ComicCatalogItem metadata;
  final CatalogItemRef? sourceCatalogRef;
  final ComicPersonalData personal;

  CatalogItemDto get catalogItem => CatalogItemDto.raw(
        id: id.value,
        mediaKind: CatalogMediaKind.comic,
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

  factory ComicLibraryEntry.fromJson(Map<String, dynamic> json) {
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
        'A Comic library entry requires typed catalog metadata.',
      );
    }
    final id = LibraryEntryId(json['id'] as String);
    return ComicLibraryEntry(
      id: id,
      metadata: ComicCatalogItem.fromJson(
        Map<String, dynamic>.from(rawCatalogData),
      ).copyWith(id: ComicCatalogItemId(id.value)),
      personal: ComicPersonalData.fromJson(json),
      sourceCatalogRef: json['source_catalog_ref'] is Map
          ? CatalogItemRef.fromJson(
              Map<String, dynamic>.from(json['source_catalog_ref'] as Map))
          : null,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']) ?? DateTime.utc(1970),
      deletedAt: _date(json['deleted_at']),
    );
  }

  ComicLibraryEntry copyWith({
    LibraryEntryId? id,
    ComicCatalogItem? metadata,
    ComicPersonalData? personal,
    Object? createdAt = _entryUnset,
    DateTime? updatedAt,
    Object? deletedAt = _entryUnset,
  }) {
    return ComicLibraryEntry(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      personal: personal ?? this.personal,
      sourceCatalogRef: sourceCatalogRef,
      createdAt: identical(createdAt, _entryUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _entryUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicLibraryEntry &&
          id == other.id &&
          _sameInstant(createdAt, other.createdAt) &&
          personal.isDigital == other.personal.isDigital &&
          personal.condition == other.personal.condition &&
          personal.grade == other.personal.grade &&
          _sameInstant(personal.purchaseDate, other.personal.purchaseDate) &&
          personal.pricePaidCents == other.personal.pricePaidCents &&
          personal.currency == other.personal.currency &&
          personal.personalNotes == other.personal.personalNotes &&
          personal.indexNumber == other.personal.indexNumber &&
          personal.tags == other.personal.tags &&
          _sameInstant(updatedAt, other.updatedAt) &&
          _sameInstant(deletedAt, other.deletedAt) &&
          _sameInstant(personal.soldAt, other.personal.soldAt) &&
          personal.sellPriceCents == other.personal.sellPriceCents &&
          personal.soldTo == other.personal.soldTo &&
          personal.ownerUserId == other.personal.ownerUserId &&
          personal.ownerLabel == other.personal.ownerLabel &&
          personal.locationId == other.personal.locationId &&
          personal.purchaseStore == other.personal.purchaseStore &&
          personal.collectionStatus == other.personal.collectionStatus &&
          personal.marketValueCents == other.personal.marketValueCents &&
          personal.details == other.personal.details &&
          personal.reading == other.personal.reading;

  @override
  int get hashCode => Object.hashAll([
        id,
        createdAt?.toUtc(),
        personal.isDigital,
        personal.condition,
        personal.grade,
        personal.purchaseDate?.toUtc(),
        personal.pricePaidCents,
        personal.currency,
        personal.personalNotes,
        personal.indexNumber,
        personal.tags,
        updatedAt.toUtc(),
        deletedAt?.toUtc(),
        personal.soldAt?.toUtc(),
        personal.sellPriceCents,
        personal.soldTo,
        personal.ownerUserId,
        personal.ownerLabel,
        personal.locationId,
        personal.purchaseStore,
        personal.collectionStatus,
        personal.marketValueCents,
        personal.details,
        personal.reading,
      ]);
}

const Object _entryUnset = Object();

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

bool _sameInstant(DateTime? first, DateTime? second) {
  return first?.toUtc() == second?.toUtc();
}
