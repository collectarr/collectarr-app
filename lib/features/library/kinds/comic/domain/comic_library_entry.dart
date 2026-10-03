import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:flutter/foundation.dart';

/// The complete Comic-entry domain model.
///
/// Fields that happen to occur on other kinds are deliberately declared here
/// instead of being promoted to a common entry aggregate. Reading progress is
/// a separate Comic domain value and is not persisted as part of copy state.
@immutable
final class ComicLibraryEntry implements JsonEncodable {
  const ComicLibraryEntry({
    required this.id,
    this.catalogData = const {},
    this.sourceCatalogRef,
    this.createdAt,
    this.isDigital,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.indexNumber,
    this.tags,
    required this.updatedAt,
    this.deletedAt,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.ownerUserId,
    this.ownerLabel,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.marketValueCents,
    this.details = const ComicEntryDetails(),
    this.reading = const ComicReadingState(),
  });

  final LibraryEntryId id;
  final Map<String, dynamic> catalogData;
  final CatalogItemRef? sourceCatalogRef;

  CatalogItemDto get catalogItem => CatalogItemDto.raw(
    id: id.value, mediaKind: CatalogMediaKind.comic,
    kindData: catalogData, origin: CatalogItemOrigin.privateLocal,
  );
  final DateTime? createdAt;
  final bool? isDigital;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int? indexNumber;
  final String? tags;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? ownerUserId;
  final String? ownerLabel;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final int? marketValueCents;
  final ComicEntryDetails details;
  final ComicReadingState reading;

  String get itemId => id.value;
  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'catalog_data': catalogData,
        'source_catalog_ref': sourceCatalogRef?.toJson(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        'is_digital': isDigital,
        'condition': condition,
        'grade': grade,
        'purchase_date': purchaseDate?.toUtc().toIso8601String(),
        'price_paid_cents': pricePaidCents,
        'currency': currency,
        'personal_notes': personalNotes,
        'index_number': indexNumber,
        'tags': tags,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
        'sold_at': soldAt?.toUtc().toIso8601String(),
        'sell_price_cents': sellPriceCents,
        'sold_to': soldTo,
        'owner_user_id': ownerUserId,
        'owner_label': ownerLabel,
        'location_id': locationId,
        'purchase_store': purchaseStore,
        'collection_status': collectionStatus,
        'market_value_cents': marketValueCents,
        'reading': reading.toJson(),
        ...details.toJson(),
      };

  factory ComicLibraryEntry.fromJson(Map<String, dynamic> json) {
    const obsoleteIdentityFields = {'catalog_ref', 'target_ref'};
    final obsoleteFields = json.keys.where(obsoleteIdentityFields.contains).toList();
    if (obsoleteFields.isNotEmpty) {
      throw FormatException(
        'Local library entry contains unsupported identity fields: '
        '${obsoleteFields.toList()..sort()}.',
      );
    }

    final rawReading = json['reading'];
    return ComicLibraryEntry(
      id: LibraryEntryId(json['id'] as String),
      catalogData: json['catalog_data'] is Map ? Map<String, dynamic>.from(json['catalog_data'] as Map) : const {},
      sourceCatalogRef: json['source_catalog_ref'] is Map ? CatalogItemRef.fromJson(Map<String, dynamic>.from(json['source_catalog_ref'] as Map)) : null,
      createdAt: _date(json['created_at']),
      isDigital: json['is_digital'] as bool?,
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      purchaseDate: _date(json['purchase_date']),
      pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      personalNotes: json['personal_notes'] as String?,
      indexNumber: (json['index_number'] as num?)?.toInt(),
      tags: json['tags'] as String?,
      updatedAt: _date(json['updated_at']) ?? DateTime.utc(1970),
      deletedAt: _date(json['deleted_at']),
      soldAt: _date(json['sold_at']),
      sellPriceCents: (json['sell_price_cents'] as num?)?.toInt(),
      soldTo: json['sold_to'] as String?,
      ownerUserId: json['owner_user_id'] as String?,
      ownerLabel: json['owner_label'] as String?,
      locationId: json['location_id'] as String?,
      purchaseStore: json['purchase_store'] as String?,
      collectionStatus: json['collection_status'] as String?,
      marketValueCents: (json['market_value_cents'] as num?)?.toInt(),
      details: ComicEntryDetails.fromJson(json),
      reading: rawReading is Map
          ? ComicReadingState.fromJson(Map<String, dynamic>.from(rawReading))
          : const ComicReadingState(),
    );
  }

  ComicLibraryEntry copyWith({
    LibraryEntryId? id,
    Object? createdAt = _entryUnset,
    Object? isDigital = _entryUnset,
    Object? condition = _entryUnset,
    Object? grade = _entryUnset,
    Object? purchaseDate = _entryUnset,
    Object? pricePaidCents = _entryUnset,
    Object? currency = _entryUnset,
    Object? personalNotes = _entryUnset,
    Object? indexNumber = _entryUnset,
    Object? tags = _entryUnset,
    DateTime? updatedAt,
    Object? deletedAt = _entryUnset,
    Object? soldAt = _entryUnset,
    Object? sellPriceCents = _entryUnset,
    Object? soldTo = _entryUnset,
    Object? ownerUserId = _entryUnset,
    Object? ownerLabel = _entryUnset,
    Object? locationId = _entryUnset,
    Object? purchaseStore = _entryUnset,
    Object? collectionStatus = _entryUnset,
    Object? marketValueCents = _entryUnset,
    ComicEntryDetails? details,
    ComicReadingState? reading,
  }) {
    return ComicLibraryEntry(
      id: id ?? this.id,
      catalogData: this.catalogData,
      sourceCatalogRef: this.sourceCatalogRef,
      createdAt: identical(createdAt, _entryUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      isDigital: identical(isDigital, _entryUnset)
          ? this.isDigital
          : isDigital as bool?,
      condition: identical(condition, _entryUnset)
          ? this.condition
          : condition as String?,
      grade: identical(grade, _entryUnset) ? this.grade : grade as String?,
      purchaseDate: identical(purchaseDate, _entryUnset)
          ? this.purchaseDate
          : purchaseDate as DateTime?,
      pricePaidCents: identical(pricePaidCents, _entryUnset)
          ? this.pricePaidCents
          : pricePaidCents as int?,
      currency: identical(currency, _entryUnset)
          ? this.currency
          : currency as String?,
      personalNotes: identical(personalNotes, _entryUnset)
          ? this.personalNotes
          : personalNotes as String?,
      indexNumber: identical(indexNumber, _entryUnset)
          ? this.indexNumber
          : indexNumber as int?,
      tags: identical(tags, _entryUnset) ? this.tags : tags as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _entryUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      soldAt:
          identical(soldAt, _entryUnset) ? this.soldAt : soldAt as DateTime?,
      sellPriceCents: identical(sellPriceCents, _entryUnset)
          ? this.sellPriceCents
          : sellPriceCents as int?,
      soldTo: identical(soldTo, _entryUnset) ? this.soldTo : soldTo as String?,
      ownerUserId: identical(ownerUserId, _entryUnset)
          ? this.ownerUserId
          : ownerUserId as String?,
      ownerLabel: identical(ownerLabel, _entryUnset)
          ? this.ownerLabel
          : ownerLabel as String?,
      locationId: identical(locationId, _entryUnset)
          ? this.locationId
          : locationId as String?,
      purchaseStore: identical(purchaseStore, _entryUnset)
          ? this.purchaseStore
          : purchaseStore as String?,
      collectionStatus: identical(collectionStatus, _entryUnset)
          ? this.collectionStatus
          : collectionStatus as String?,
      marketValueCents: identical(marketValueCents, _entryUnset)
          ? this.marketValueCents
          : marketValueCents as int?,
      details: details ?? this.details,
      reading: reading ?? this.reading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicLibraryEntry &&
          id == other.id &&
          _sameInstant(createdAt, other.createdAt) &&
          isDigital == other.isDigital &&
          condition == other.condition &&
          grade == other.grade &&
          _sameInstant(purchaseDate, other.purchaseDate) &&
          pricePaidCents == other.pricePaidCents &&
          currency == other.currency &&
          personalNotes == other.personalNotes &&
          indexNumber == other.indexNumber &&
          tags == other.tags &&
          _sameInstant(updatedAt, other.updatedAt) &&
          _sameInstant(deletedAt, other.deletedAt) &&
          _sameInstant(soldAt, other.soldAt) &&
          sellPriceCents == other.sellPriceCents &&
          soldTo == other.soldTo &&
          ownerUserId == other.ownerUserId &&
          ownerLabel == other.ownerLabel &&
          locationId == other.locationId &&
          purchaseStore == other.purchaseStore &&
          collectionStatus == other.collectionStatus &&
          marketValueCents == other.marketValueCents &&
          details == other.details &&
          reading == other.reading;

  @override
  int get hashCode => Object.hashAll([
        id,
        createdAt?.toUtc(),
        isDigital,
        condition,
        grade,
        purchaseDate?.toUtc(),
        pricePaidCents,
        currency,
        personalNotes,
        indexNumber,
        tags,
        updatedAt.toUtc(),
        deletedAt?.toUtc(),
        soldAt?.toUtc(),
        sellPriceCents,
        soldTo,
        ownerUserId,
        ownerLabel,
        locationId,
        purchaseStore,
        collectionStatus,
        marketValueCents,
        details,
        reading,
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

