import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';

final class BookOwnedItemCreatePayload implements OwnedItemCreatePayload {
  const BookOwnedItemCreatePayload({
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

  factory BookOwnedItemCreatePayload.fromOwnedItem(
    CatalogItem item,
    OwnedItem ownedItem,
  ) {
    return BookOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: BookOwnedDetailsCodec().draftFromDetails(
        ownedItem.details as BookOwnedDetails,
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
  final BookOwnedDetailsDraft details;

  @override
  BookOwnedDetailsDraft get detailsDraft => details;
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
