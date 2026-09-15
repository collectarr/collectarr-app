import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';

final class MusicOwnedItemCreatePayload implements OwnedItemCreatePayload {
  const MusicOwnedItemCreatePayload({
    required this.catalogRef,
    required this.details,
    this.releaseRef,
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
    this.indexNumber,
    this.marketValueCents,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
  });

  factory MusicOwnedItemCreatePayload.fromTypedItem(
    MusicOwnedItem item,
  ) {
    return MusicOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: MusicOwnedDetailsCodec().draftFromDetails(item.details),
      releaseRef: item.targetRef,
      quantity: item.quantity,
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
      indexNumber: item.indexNumber,
      marketValueCents: item.marketValueCents,
      soldAt: item.soldAt,
      sellPriceCents: item.sellPriceCents,
      soldTo: item.soldTo,
    );
  }

  @override
  final CatalogEntityRef catalogRef;
  final MusicOwnedDetailsDraft details;
  final CatalogEntityRef? releaseRef;

  @override
  MusicOwnedDetailsDraft get detailsDraft => details;
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
  final int? indexNumber;
  final int? marketValueCents;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;

  MusicOwnedItem toOwnedItem({
    required CatalogEntityRef resolvedCatalogRef,
    required String id,
    required DateTime createdAt,
    required bool? existingIsDigital,
    required String? ownerUserId,
    required String? ownerLabel,
  }) {
    final resolvedRelease = _resolveReleaseRef(resolvedCatalogRef);
    final rootRef = resolvedRelease.rootScope;
    final item = MusicOwnedItem(
      id: MusicOwnedItemId(id),
      catalogRef: rootRef,
      createdAt: createdAt,
      isDigital: isDigital ?? existingIsDigital,
      targetRef: resolvedRelease,
      details: details.toDetails(),
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity,
      indexNumber: indexNumber,
      locationId: locationId,
      purchaseStore: purchaseStore,
      collectionStatus: collectionStatus,
      tags: tags,
      marketValueCents: marketValueCents,
      soldAt: soldAt,
      sellPriceCents: sellPriceCents,
      soldTo: soldTo,
      ownerUserId: ownerUserId,
      ownerLabel: ownerLabel,
      updatedAt: createdAt,
    );
    item.validateReleaseOwnership();
    return item;
  }

  CatalogEntityRef _resolveReleaseRef(CatalogEntityRef resolvedCatalogRef) {
    final candidate =
        isMusicReleaseRef(resolvedCatalogRef) ? resolvedCatalogRef : releaseRef;
    requireMusicReleaseRef(candidate, label: 'Music owned copy releaseRef');
    final normalized = candidate!;
    if (normalized.rootScope.id != resolvedCatalogRef.rootScope.id) {
      throw StateError(
        'Music owned copy releaseRef must belong to the selected catalog root',
      );
    }
    return normalized;
  }
}
