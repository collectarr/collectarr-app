import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';

export 'package:collectarr_app/core/models/money.dart';
export 'package:collectarr_app/core/models/owned_item_details.dart';

const Object _ownedItemUnset = Object();

class OwnedItem {
  OwnedItem({
    required this.id,
    required this.catalogRef,
    this.createdAt,
    this.isDigital,
    PersonalItemAnchor? anchor,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    OwnedItemDetails? details,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.indexNumber,
    this.rating,
    this.readStatus,
    this.startedAt,
    this.finishedAt,
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
  })  : anchor = anchor ??
            PersonalItemAnchor.fromRaw(
              anchorType: anchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            ),
        details =
            details ?? OwnedItemDetails.defaultForKind(catalogRef.mediaKind);

  final String id;
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
  final int? rating;
  final String? readStatus;
  final DateTime? startedAt;
  final DateTime? finishedAt;
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
  final OwnedItemDetails details;

  ComicOwnedDetails? get comicDetails => details.comic;
  VideoOwnedDetails? get videoDetails => details.video;
  GameOwnedDetails? get gameDetails => details.game;
  MusicOwnedDetails? get musicDetails => details.music;
  BookOwnedDetails? get bookDetails => details.book;
  BoardgameOwnedDetails? get boardgameDetails => details.boardgame;

  String get itemId => catalogRef.id;

  OwnedItemId get typedId => OwnedItemId(id);
  Money? get pricePaid => Money.fromCents(pricePaidCents, currency);
  Money? get sellPrice => Money.fromCents(sellPriceCents, currency);
  Money? get marketValue => Money.fromCents(marketValueCents, currency);

  String? get anchorType => anchor?.apiValue;
  String? get editionId => anchor?.editionId;
  String? get variantId => anchor?.variantId;
  String? get bundleReleaseId => anchor?.bundleReleaseId;

  PersonalItemAnchorType? get personalAnchor => anchor?.type;

  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (isDigital != null) 'is_digital': isDigital,
      ...?anchor?.toSyncPayload(),
      'condition': condition,
      'grade': grade,
      'purchase_date': purchaseDate?.toUtc().toIso8601String(),
      'price_paid_cents': pricePaidCents,
      'currency': currency,
      'personal_notes': personalNotes,
      'quantity': quantity,
      'index_number': indexNumber,
      'rating': rating,
      'read_status': readStatus,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'finished_at': finishedAt?.toUtc().toIso8601String(),
      'tags': tags,
      'sold_at': soldAt?.toUtc().toIso8601String(),
      'sell_price_cents': sellPriceCents,
      'sold_to': soldTo,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (ownerLabel != null) 'owner_label': ownerLabel,
      'location_id': locationId,
      if (purchaseStore != null) 'purchase_store': purchaseStore,
      if (collectionStatus != null) 'collection_status': collectionStatus,
      if (marketValueCents != null) 'market_value_cents': marketValueCents,
      ...details.toJson(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catalog_ref': catalogRef.toJson(),
      'created_at': createdAt?.toUtc().toIso8601String(),
      'is_digital': isDigital,
      'anchor_type': anchorType,
      'edition_id': editionId,
      'variant_id': variantId,
      'bundle_release_id': bundleReleaseId,
      'condition': condition,
      'grade': grade,
      'purchase_date': purchaseDate?.toUtc().toIso8601String(),
      'price_paid_cents': pricePaidCents,
      'currency': currency,
      'personal_notes': personalNotes,
      'quantity': quantity,
      'index_number': indexNumber,
      'rating': rating,
      'read_status': readStatus,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'finished_at': finishedAt?.toUtc().toIso8601String(),
      'tags': tags,
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
      'sold_at': soldAt?.toUtc().toIso8601String(),
      'sell_price_cents': sellPriceCents,
      'sold_to': soldTo,
      'owner_user_id': ownerUserId,
      if (ownerLabel != null) 'owner_label': ownerLabel,
      'location_id': locationId,
      if (purchaseStore != null) 'purchase_store': purchaseStore,
      if (collectionStatus != null) 'collection_status': collectionStatus,
      if (marketValueCents != null) 'market_value_cents': marketValueCents,
      ...details.toJson(),
    };
  }

  factory OwnedItem.fromJson(Map<String, dynamic> json) {
    final catalogRefJson = json['catalog_ref'] as Map<String, dynamic>;
    final catalogRef = CatalogEntityRef.fromJson(catalogRefJson);
    final details = OwnedItemDetails.parseForKind(catalogRef.mediaKind, json);

    return OwnedItem(
      id: json['id'] as String,
      catalogRef: catalogRef,
      details: details,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      isDigital: json['is_digital'] as bool?,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: json['anchor_type'] as String?,
        editionId: json['edition_id'] as String?,
        variantId: json['variant_id'] as String?,
        bundleReleaseId: json['bundle_release_id'] as String?,
      ),
      condition: json['condition'] as String?,
      grade: json['grade'] as String?,
      purchaseDate: json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
      pricePaidCents: json['price_paid_cents'] as int?,
      currency: json['currency'] as String?,
      personalNotes: json['personal_notes'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      indexNumber: json['index_number'] as int?,
      rating: json['rating'] as int?,
      readStatus: json['read_status'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      tags: json['tags'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      soldAt: json['sold_at'] == null
          ? null
          : DateTime.parse(json['sold_at'] as String),
      sellPriceCents: json['sell_price_cents'] as int?,
      soldTo: json['sold_to'] as String?,
      ownerUserId: json['owner_user_id'] as String?,
      ownerLabel: json['owner_label'] as String?,
      locationId: json['location_id'] as String?,
      purchaseStore: json['purchase_store'] as String?,
      collectionStatus: json['collection_status'] as String?,
      marketValueCents: json['market_value_cents'] as int?,
    );
  }

  OwnedItem copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    DateTime? createdAt,
    bool? isDigital,
    Object? anchor = _ownedItemUnset,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    OwnedItemDetails? details,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    int? indexNumber,
    int? rating,
    String? readStatus,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    String? ownerUserId,
    String? ownerLabel,
    String? locationId,
    String? purchaseStore,
    String? collectionStatus,
    int? marketValueCents,
  }) {
    final resolvedAnchor = identical(anchor, _ownedItemUnset)
        ? PersonalItemAnchor.fromRaw(
            anchorType: anchorType ?? this.anchorType,
            editionId: editionId ?? this.editionId,
            variantId: variantId ?? this.variantId,
            bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
          )
        : anchor as PersonalItemAnchor?;

    return OwnedItem(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      createdAt: createdAt ?? this.createdAt,
      isDigital: isDigital ?? this.isDigital,
      anchor: resolvedAnchor,
      details: details ?? this.details,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      indexNumber: indexNumber ?? this.indexNumber,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      soldAt: soldAt ?? this.soldAt,
      sellPriceCents: sellPriceCents ?? this.sellPriceCents,
      soldTo: soldTo ?? this.soldTo,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerLabel: ownerLabel ?? this.ownerLabel,
      locationId: locationId ?? this.locationId,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      marketValueCents: marketValueCents ?? this.marketValueCents,
    );
  }
}
