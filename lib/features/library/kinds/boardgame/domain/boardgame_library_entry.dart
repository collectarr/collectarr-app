import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:flutter/foundation.dart';

/// Complete BoardGame-collection item state.
///
/// Component completeness and storage are entry by BoardGame. Play sessions
/// are tracking data and deliberately remain outside this aggregate.
@immutable
final class BoardGameLibraryEntry implements JsonEncodable {
  const BoardGameLibraryEntry({
    required this.id,
    required this.metadata,
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
    this.details = const BoardgameEntryDetails(),
  });

  final LibraryEntryId id;
  final BoardGameMetadata metadata;
  final CatalogItemRef? sourceCatalogRef;

  CatalogItemDto get catalogItem => CatalogItemDto.raw(
        id: id.value,
        mediaKind: CatalogMediaKind.boardgame,
        kindData: metadata.toJson(),
        origin: CatalogItemOrigin.privateLocal,
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
  final BoardgameEntryDetails details;

  String get itemId => id.value;
  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'catalog_data': metadata.toJson(),
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
        ...details.toJson(),
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
      sourceCatalogRef: json['source_catalog_ref'] is Map
          ? CatalogItemRef.fromJson(
              Map<String, dynamic>.from(json['source_catalog_ref'] as Map))
          : null,
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
      details: BoardgameEntryDetails.fromJson(json),
    );
  }

  BoardGameLibraryEntry copyWith({
    LibraryEntryId? id,
    BoardGameMetadata? metadata,
    Object? createdAt = _unset,
    Object? isDigital = _unset,
    Object? condition = _unset,
    Object? grade = _unset,
    Object? purchaseDate = _unset,
    Object? pricePaidCents = _unset,
    Object? currency = _unset,
    Object? personalNotes = _unset,
    Object? indexNumber = _unset,
    Object? tags = _unset,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
    Object? soldAt = _unset,
    Object? sellPriceCents = _unset,
    Object? soldTo = _unset,
    Object? ownerUserId = _unset,
    Object? ownerLabel = _unset,
    Object? locationId = _unset,
    Object? purchaseStore = _unset,
    Object? collectionStatus = _unset,
    Object? marketValueCents = _unset,
    BoardgameEntryDetails? details,
  }) {
    return BoardGameLibraryEntry(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      sourceCatalogRef: sourceCatalogRef,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      isDigital:
          identical(isDigital, _unset) ? this.isDigital : isDigital as bool?,
      condition:
          identical(condition, _unset) ? this.condition : condition as String?,
      grade: identical(grade, _unset) ? this.grade : grade as String?,
      purchaseDate: identical(purchaseDate, _unset)
          ? this.purchaseDate
          : purchaseDate as DateTime?,
      pricePaidCents: identical(pricePaidCents, _unset)
          ? this.pricePaidCents
          : pricePaidCents as int?,
      currency:
          identical(currency, _unset) ? this.currency : currency as String?,
      personalNotes: identical(personalNotes, _unset)
          ? this.personalNotes
          : personalNotes as String?,
      indexNumber: identical(indexNumber, _unset)
          ? this.indexNumber
          : indexNumber as int?,
      tags: identical(tags, _unset) ? this.tags : tags as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      soldAt: identical(soldAt, _unset) ? this.soldAt : soldAt as DateTime?,
      sellPriceCents: identical(sellPriceCents, _unset)
          ? this.sellPriceCents
          : sellPriceCents as int?,
      soldTo: identical(soldTo, _unset) ? this.soldTo : soldTo as String?,
      ownerUserId: identical(ownerUserId, _unset)
          ? this.ownerUserId
          : ownerUserId as String?,
      ownerLabel: identical(ownerLabel, _unset)
          ? this.ownerLabel
          : ownerLabel as String?,
      locationId: identical(locationId, _unset)
          ? this.locationId
          : locationId as String?,
      purchaseStore: identical(purchaseStore, _unset)
          ? this.purchaseStore
          : purchaseStore as String?,
      collectionStatus: identical(collectionStatus, _unset)
          ? this.collectionStatus
          : collectionStatus as String?,
      marketValueCents: identical(marketValueCents, _unset)
          ? this.marketValueCents
          : marketValueCents as int?,
      details: details ?? this.details,
    );
  }
}

const Object _unset = Object();

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
