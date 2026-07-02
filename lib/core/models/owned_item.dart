import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';

const Object _ownedItemUnset = Object();

class OwnedItem {
  OwnedItem({
    required this.id,
    required this.itemId,
    this.catalogRef,
    this.createdAt,
    this.isDigital,
    PersonalItemAnchor? anchor,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.quantity = 1,
    this.indexNumber,
    this.coverPriceCents,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
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
    this.features,
    this.hdrFormats = const <String>[],
    this.purchaseStore,
    this.boxSetId,
    this.boxSetName,
    this.storageDevice,
    this.storageSlot,
    this.region,
    this.packaging,
    this.distributor,
    this.collectionStatus,
    this.lastBagBoardDate,
    this.marketValueCents,
    this.gameCompleteness,
    this.gameHasBox,
    this.gameHasManual,
    this.gamePriceChartingId,
    this.gameCoreRegion,
    this.gameValueIsLocked,
  }) : anchor = anchor ??
            PersonalItemAnchor.fromRaw(
              anchorType: anchorType,
              editionId: editionId,
              variantId: variantId,
              bundleReleaseId: bundleReleaseId,
            );

  final String id;
  final String itemId;
  final CatalogEntityRef? catalogRef;
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
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? customLabel;
  final String? pageQuality;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
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
  final String? features;
  final List<String> hdrFormats;
  final String? purchaseStore;
  final String? boxSetId;
  final String? boxSetName;
  final String? storageDevice;
  final String? storageSlot;
  final String? region;
  final String? packaging;
  final String? distributor;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? marketValueCents;
  final String? gameCompleteness;
  final bool? gameHasBox;
  final bool? gameHasManual;
  final String? gamePriceChartingId;
  final String? gameCoreRegion;
  final bool? gameValueIsLocked;

  String? get anchorType => anchor?.apiValue;
  String? get editionId => anchor?.editionId;
  String? get variantId => anchor?.variantId;
  String? get bundleReleaseId => anchor?.bundleReleaseId;

  PersonalItemAnchorType? get personalAnchor => anchor?.type;

  bool get isDeleted => deletedAt != null;
  bool get isSold => soldAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'item_id': itemId,
      if (catalogRef != null) 'catalog_ref': catalogRef!.toJson(),
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
      'cover_price_cents': coverPriceCents,
      'raw_or_slabbed': rawOrSlabbed,
      'grading_company': gradingCompany,
      'grader_notes': graderNotes,
      'signed_by': signedBy,
      'label_type': labelType,
      'custom_label': customLabel,
      'page_quality': pageQuality,
      'certification_number': certificationNumber,
      'key_comic': keyComic,
      'key_reason': keyReason,
      'key_category': keyCategory,
      'key_severity': keySeverity,
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
      if (features != null) 'features': features,
      if (hdrFormats.isNotEmpty) 'hdr_formats': hdrFormats,
      if (purchaseStore != null) 'purchase_store': purchaseStore,
      if (boxSetId != null) 'box_set_id': boxSetId,
      if (boxSetName != null) 'box_set_name': boxSetName,
      if (storageDevice != null) 'storage_device': storageDevice,
      if (storageSlot != null) 'storage_slot': storageSlot,
      if (region != null) 'region': region,
      if (packaging != null) 'packaging': packaging,
      if (distributor != null) 'distributor': distributor,
      if (collectionStatus != null) 'collection_status': collectionStatus,
      if (lastBagBoardDate != null)
        'last_bag_board_date': lastBagBoardDate!.toUtc().toIso8601String(),
      if (marketValueCents != null) 'market_value_cents': marketValueCents,
      if (gameCompleteness != null) 'game_completeness': gameCompleteness,
      if (gameHasBox != null) 'game_has_box': gameHasBox,
      if (gameHasManual != null) 'game_has_manual': gameHasManual,
      if (gamePriceChartingId != null)
        'game_pricecharting_id': gamePriceChartingId,
      if (gameCoreRegion != null) 'game_core_region': gameCoreRegion,
      if (gameValueIsLocked != null)
        'game_value_is_locked': gameValueIsLocked,
    };
  }

  factory OwnedItem.fromJson(Map<String, dynamic> json) {
    return OwnedItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      catalogRef: json['catalog_ref'] is Map<String, dynamic>
          ? CatalogEntityRef.fromJson(json['catalog_ref'] as Map<String, dynamic>)
          : null,
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
      coverPriceCents: json['cover_price_cents'] as int?,
      rawOrSlabbed: json['raw_or_slabbed'] as String?,
      gradingCompany: json['grading_company'] as String?,
      graderNotes: json['grader_notes'] as String?,
      signedBy: json['signed_by'] as String?,
      labelType: json['label_type'] as String?,
      customLabel: json['custom_label'] as String?,
      pageQuality: json['page_quality'] as String?,
      certificationNumber: json['certification_number'] as String?,
      keyComic: json['key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      keyCategory: json['key_category'] as String?,
      keySeverity: json['key_severity'] as String?,
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
      features: json['features'] as String?,
      hdrFormats: (json['hdr_formats'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      purchaseStore: json['purchase_store'] as String?,
      boxSetId: json['box_set_id'] as String?,
      boxSetName: json['box_set_name'] as String?,
      storageDevice: json['storage_device'] as String?,
      storageSlot: json['storage_slot'] as String?,
      region: json['region'] as String?,
      packaging: json['packaging'] as String?,
      distributor: json['distributor'] as String?,
      collectionStatus: json['collection_status'] as String?,
      lastBagBoardDate: json['last_bag_board_date'] == null
          ? null
          : DateTime.parse(json['last_bag_board_date'] as String),
      marketValueCents: json['market_value_cents'] as int?,
      gameCompleteness: json['game_completeness'] as String?,
      gameHasBox: json['game_has_box'] as bool?,
      gameHasManual: json['game_has_manual'] as bool?,
      gamePriceChartingId: json['game_pricecharting_id'] as String?,
      gameCoreRegion: json['game_core_region'] as String?,
      gameValueIsLocked: json['game_value_is_locked'] as bool?,
    );
  }

  OwnedItem copyWith({
    String? id,
    String? itemId,
    CatalogEntityRef? catalogRef,
    DateTime? createdAt,
    bool? isDigital,
    Object? anchor = _ownedItemUnset,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    String? labelType,
    String? customLabel,
    String? pageQuality,
    String? certificationNumber,
    bool? keyComic,
    String? keyReason,
    String? keyCategory,
    String? keySeverity,
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
    String? features,
    List<String>? hdrFormats,
    String? purchaseStore,
    String? boxSetId,
    String? boxSetName,
    String? storageDevice,
    String? storageSlot,
    String? region,
    String? packaging,
    String? distributor,
    String? collectionStatus,
    DateTime? lastBagBoardDate,
    int? marketValueCents,
    String? gameCompleteness,
    bool? gameHasBox,
    bool? gameHasManual,
    String? gamePriceChartingId,
    String? gameCoreRegion,
    bool? gameValueIsLocked,
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
      itemId: itemId ?? this.itemId,
      catalogRef: catalogRef ?? this.catalogRef,
      createdAt: createdAt ?? this.createdAt,
      isDigital: isDigital ?? this.isDigital,
      anchor: resolvedAnchor,
      condition: condition ?? this.condition,
      grade: grade ?? this.grade,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      indexNumber: indexNumber ?? this.indexNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      rawOrSlabbed: rawOrSlabbed ?? this.rawOrSlabbed,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      graderNotes: graderNotes ?? this.graderNotes,
      signedBy: signedBy ?? this.signedBy,
      labelType: labelType ?? this.labelType,
      customLabel: customLabel ?? this.customLabel,
      pageQuality: pageQuality ?? this.pageQuality,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      keyComic: keyComic ?? this.keyComic,
      keyReason: keyReason ?? this.keyReason,
      keyCategory: keyCategory ?? this.keyCategory,
      keySeverity: keySeverity ?? this.keySeverity,
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
      features: features ?? this.features,
      hdrFormats: hdrFormats ?? this.hdrFormats,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      boxSetId: boxSetId ?? this.boxSetId,
      boxSetName: boxSetName ?? this.boxSetName,
      storageDevice: storageDevice ?? this.storageDevice,
      storageSlot: storageSlot ?? this.storageSlot,
      region: region ?? this.region,
      packaging: packaging ?? this.packaging,
      distributor: distributor ?? this.distributor,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      lastBagBoardDate: lastBagBoardDate ?? this.lastBagBoardDate,
      marketValueCents: marketValueCents ?? this.marketValueCents,
      gameCompleteness: gameCompleteness ?? this.gameCompleteness,
      gameHasBox: gameHasBox ?? this.gameHasBox,
      gameHasManual: gameHasManual ?? this.gameHasManual,
      gamePriceChartingId: gamePriceChartingId ?? this.gamePriceChartingId,
      gameCoreRegion: gameCoreRegion ?? this.gameCoreRegion,
      gameValueIsLocked: gameValueIsLocked ?? this.gameValueIsLocked,
    );
  }
}
