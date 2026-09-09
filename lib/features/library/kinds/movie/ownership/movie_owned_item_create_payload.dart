import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';

final class MovieOwnedItemCreatePayload implements OwnedItemCreatePayload {
  const MovieOwnedItemCreatePayload({
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

  factory MovieOwnedItemCreatePayload.fromOwnedItem(
    CatalogItemDto item,
    OwnedItem ownedItem,
  ) {
    return MovieOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: MovieOwnedDetailsCodec().draftFromDetails(
        ownedItem.details as MovieOwnedDetails,
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
  final MovieOwnedDetailsDraft details;

  @override
  MovieOwnedDetailsDraft get detailsDraft => details;
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
  @override
  final bool? isDigital;
  final String? tags;

  @override
  MovieOwnedItem toOwnedItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    return MovieOwnedItem(
      id: MovieOwnedItemId(id),
      catalogRef: resolvedCatalogRef,
      createdAt: createdAt,
      isDigital: isDigital ?? existingIsDigital,
      anchor: _legacyAnchorForCatalogRef(resolvedCatalogRef),
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

PersonalItemAnchor? _legacyAnchorForCatalogRef(CatalogEntityRef ref) {
  final rootId = ref.rootId ?? ref.id;
  return switch (ref.entityType.apiValue) {
    'edition' => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.edition.apiValue,
        editionId: ref.id,
      ),
    'release' => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.variant.apiValue,
        editionId: ref.parentId,
        variantId: ref.id,
      ),
    'bundle_release' => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.bundleRelease.apiValue,
        bundleReleaseId: ref.id,
      ),
    _ when rootId == ref.id => null,
    _ => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.item.apiValue,
      ),
  };
}
