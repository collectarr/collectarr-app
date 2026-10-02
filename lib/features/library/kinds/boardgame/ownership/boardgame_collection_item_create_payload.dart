import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/features/library/config/collection_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';

final class BoardgameCollectionItemCreatePayload implements CollectionItemCreatePayload {
  const BoardgameCollectionItemCreatePayload({
    required this.catalogRef,
    required this.details,
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

  factory BoardgameCollectionItemCreatePayload.fromTypedItem(
    BoardGameCollectionItem item,
  ) {
    return BoardgameCollectionItemCreatePayload(
      catalogRef: item.catalogRef,
      details: BoardgameOwnedDetailsCodec().draftFromDetails(item.details),
      condition: item.condition,
      grade: item.grade,
      purchaseDate: item.purchaseDate,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      personalNotes: item.personalNotes,
      locationId: item.locationId,
      purchaseStore: item.purchaseStore,
      collectionStatus: item.collectionStatus,
      isDigital: item.isDigital,
      tags: item.tags,
    );
  }

  @override
  final CatalogEntityRef catalogRef;
  final BoardgameOwnedDetailsDraft details;

  @override
  BoardgameOwnedDetailsDraft get detailsDraft => details;
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

  BoardGameCollectionItem toCollectionItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    return BoardGameCollectionItem(
      id: CollectionItemId(id),
      catalogRef: resolvedCatalogRef,
      createdAt: createdAt,
      isDigital: isDigital ?? existingIsDigital,
      details: details.toDetails(),
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
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
