import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';

/// Comic-owned personal-copy values for the Add command.
///
/// Universal-looking fields are intentionally repeated in each kind payload;
/// they are part of the kind's complete Owned lifecycle and not a shared
/// domain aggregate.
final class ComicOwnedItemCreatePayload implements OwnedItemCreatePayload {
  const ComicOwnedItemCreatePayload({
    required this.catalogRef,
    required this.details,
    this.quantity = 1,
    this.condition,
    this.grade,
    this.purchaseDate,
    this.pricePaidCents,
    this.currency,
    this.personalNotes,
    this.locationId,
    this.purchaseStore,
    this.collectionStatus,
    this.isDigital,
    this.tags,
  });

  factory ComicOwnedItemCreatePayload.fromOwnedItem(
    CatalogItem item,
    OwnedItem ownedItem,
  ) {
    return ComicOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: ComicOwnedDetailsCodec().draftFromDetails(
        ownedItem.details as ComicOwnedDetails,
      ),
      quantity: ownedItem.quantity,
      condition: ownedItem.condition,
      grade: ownedItem.grade,
      purchaseDate: ownedItem.purchaseDate,
      pricePaidCents: ownedItem.pricePaidCents,
      currency: ownedItem.currency,
      personalNotes: ownedItem.personalNotes,
      locationId: ownedItem.locationId,
      purchaseStore: ownedItem.purchaseStore,
      collectionStatus: ownedItem.collectionStatus,
      isDigital: ownedItem.isDigital,
      tags: ownedItem.tags,
    );
  }

  @override
  final CatalogEntityRef catalogRef;
  final ComicOwnedDetailsDraft details;

  @override
  ComicOwnedDetailsDraft get detailsDraft => details;
  final int quantity;
  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final String? locationId;
  final String? purchaseStore;
  final String? collectionStatus;
  final bool? isDigital;
  final String? tags;

  @override
  OwnedItem toLegacyOwnedItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required CatalogItem? existingCatalog,
    required PersonalItemAnchor? anchor,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    return OwnedItem(
      id: id,
      catalogRef: resolvedCatalogRef,
      createdAt: createdAt,
      isDigital: isDigital ?? existingCatalog?.physicalFormat == 'digital',
      anchor: anchor,
      details: details.toDetails(),
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity,
      locationId: locationId,
      purchaseStore: purchaseStore,
      collectionStatus: collectionStatus,
      tags: tags,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
      updatedAt: createdAt,
    );
  }
}
