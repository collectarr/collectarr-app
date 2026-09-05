import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:flutter/foundation.dart';

/// The complete Comic-owned domain model.
///
/// Fields that happen to occur on other kinds are deliberately declared here
/// instead of being promoted to a common owned aggregate. Reading progress is
/// a separate Comic domain value and is not persisted as part of copy state.
@immutable
final class ComicOwnedItem {
  const ComicOwnedItem({
    required this.id,
    required this.catalogRef,
    this.createdAt,
    this.isDigital,
    this.anchor,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
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
    this.details = const ComicOwnedDetails(),
    this.reading = const ComicReadingState(),
  });

  final ComicOwnedItemId id;
  final CatalogEntityRef catalogRef;
  final DateTime? createdAt;
  final bool? isDigital;
  final PersonalItemAnchor? anchor;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
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
  final ComicOwnedDetails details;
  final ComicReadingState reading;

  String get itemId => catalogRef.id;
  String? get anchorType => anchor?.apiValue;
  String? get editionId => anchor?.editionId;
  String? get variantId => anchor?.variantId;
  String? get bundleReleaseId => anchor?.bundleReleaseId;
  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'catalog_ref': catalogRef.toJson(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        'is_digital': isDigital,
        if (anchor != null) ...anchor!.toSyncPayload(),
        'condition': condition,
        'grade': grade,
        'purchase_date': purchaseDate?.toUtc().toIso8601String(),
        'price_paid_cents': pricePaidCents,
        'currency': currency,
        'personal_notes': personalNotes,
        'quantity': quantity,
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

  factory ComicOwnedItem.fromJson(Map<String, dynamic> json) {
    final rawRef = json['catalog_ref'];
    if (rawRef is! Map) {
      throw const FormatException('ComicOwnedItem requires catalog_ref');
    }
    final catalogRef = CatalogEntityRef.fromJson(
      Map<String, dynamic>.from(rawRef),
    );
    if (catalogRef.mediaKind != CatalogMediaKind.comic) {
      throw FormatException(
        'Expected comic catalog_ref, got ${catalogRef.kind}',
      );
    }
    final rawReading = json['reading'];
    return ComicOwnedItem(
      id: ComicOwnedItemId(json['id'] as String),
      catalogRef: catalogRef,
      createdAt: _date(json['created_at']),
      isDigital: json['is_digital'] as bool?,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: json['anchor_type'] as String?,
        editionId: json['edition_id'] as String?,
        variantId: json['variant_id'] as String?,
        bundleReleaseId: json['bundle_release_id'] as String?,
      ),
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      purchaseDate: _date(json['purchase_date']),
      pricePaidCents: (json['price_paid_cents'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      personalNotes: json['personal_notes'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
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
      details: ComicOwnedDetails.fromJson(json),
      reading: rawReading is Map
          ? ComicReadingState.fromJson(Map<String, dynamic>.from(rawReading))
          : const ComicReadingState(),
    );
  }

  ComicOwnedItem copyWith({
    ComicOwnedItemId? id,
    CatalogEntityRef? catalogRef,
    Object? createdAt = _ownedUnset,
    Object? isDigital = _ownedUnset,
    Object? anchor = _ownedUnset,
    Object? condition = _ownedUnset,
    Object? grade = _ownedUnset,
    Object? purchaseDate = _ownedUnset,
    Object? pricePaidCents = _ownedUnset,
    Object? currency = _ownedUnset,
    Object? personalNotes = _ownedUnset,
    int? quantity,
    Object? indexNumber = _ownedUnset,
    Object? tags = _ownedUnset,
    DateTime? updatedAt,
    Object? deletedAt = _ownedUnset,
    Object? soldAt = _ownedUnset,
    Object? sellPriceCents = _ownedUnset,
    Object? soldTo = _ownedUnset,
    Object? ownerUserId = _ownedUnset,
    Object? ownerLabel = _ownedUnset,
    Object? locationId = _ownedUnset,
    Object? purchaseStore = _ownedUnset,
    Object? collectionStatus = _ownedUnset,
    Object? marketValueCents = _ownedUnset,
    ComicOwnedDetails? details,
    ComicReadingState? reading,
  }) {
    return ComicOwnedItem(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      createdAt: identical(createdAt, _ownedUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      isDigital: identical(isDigital, _ownedUnset)
          ? this.isDigital
          : isDigital as bool?,
      anchor: identical(anchor, _ownedUnset)
          ? this.anchor
          : anchor as PersonalItemAnchor?,
      condition: identical(condition, _ownedUnset)
          ? this.condition
          : condition as String?,
      grade: identical(grade, _ownedUnset) ? this.grade : grade as String?,
      purchaseDate: identical(purchaseDate, _ownedUnset)
          ? this.purchaseDate
          : purchaseDate as DateTime?,
      pricePaidCents: identical(pricePaidCents, _ownedUnset)
          ? this.pricePaidCents
          : pricePaidCents as int?,
      currency: identical(currency, _ownedUnset)
          ? this.currency
          : currency as String?,
      personalNotes: identical(personalNotes, _ownedUnset)
          ? this.personalNotes
          : personalNotes as String?,
      quantity: quantity ?? this.quantity,
      indexNumber: identical(indexNumber, _ownedUnset)
          ? this.indexNumber
          : indexNumber as int?,
      tags: identical(tags, _ownedUnset) ? this.tags : tags as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _ownedUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      soldAt:
          identical(soldAt, _ownedUnset) ? this.soldAt : soldAt as DateTime?,
      sellPriceCents: identical(sellPriceCents, _ownedUnset)
          ? this.sellPriceCents
          : sellPriceCents as int?,
      soldTo: identical(soldTo, _ownedUnset) ? this.soldTo : soldTo as String?,
      ownerUserId: identical(ownerUserId, _ownedUnset)
          ? this.ownerUserId
          : ownerUserId as String?,
      ownerLabel: identical(ownerLabel, _ownedUnset)
          ? this.ownerLabel
          : ownerLabel as String?,
      locationId: identical(locationId, _ownedUnset)
          ? this.locationId
          : locationId as String?,
      purchaseStore: identical(purchaseStore, _ownedUnset)
          ? this.purchaseStore
          : purchaseStore as String?,
      collectionStatus: identical(collectionStatus, _ownedUnset)
          ? this.collectionStatus
          : collectionStatus as String?,
      marketValueCents: identical(marketValueCents, _ownedUnset)
          ? this.marketValueCents
          : marketValueCents as int?,
      details: details ?? this.details,
      reading: reading ?? this.reading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicOwnedItem &&
          id == other.id &&
          catalogRef.kind == other.catalogRef.kind &&
          catalogRef.entityType == other.catalogRef.entityType &&
          catalogRef.id == other.catalogRef.id &&
          _sameInstant(createdAt, other.createdAt) &&
          isDigital == other.isDigital &&
          anchor?.apiValue == other.anchor?.apiValue &&
          anchor?.editionId == other.anchor?.editionId &&
          anchor?.variantId == other.anchor?.variantId &&
          anchor?.bundleReleaseId == other.anchor?.bundleReleaseId &&
          condition == other.condition &&
          grade == other.grade &&
          _sameInstant(purchaseDate, other.purchaseDate) &&
          pricePaidCents == other.pricePaidCents &&
          currency == other.currency &&
          personalNotes == other.personalNotes &&
          quantity == other.quantity &&
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
        catalogRef.kind,
        catalogRef.entityType,
        catalogRef.id,
        createdAt?.toUtc(),
        isDigital,
        anchor?.apiValue,
        anchor?.editionId,
        anchor?.variantId,
        anchor?.bundleReleaseId,
        condition,
        grade,
        purchaseDate?.toUtc(),
        pricePaidCents,
        currency,
        personalNotes,
        quantity,
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

const Object _ownedUnset = Object();

DateTime? _date(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

bool _sameInstant(DateTime? first, DateTime? second) {
  return first?.toUtc() == second?.toUtc();
}
