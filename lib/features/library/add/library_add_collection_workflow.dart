import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryAddDefaults {
  const LibraryAddDefaults({
    this.condition,
    this.grade,
    this.purchaseDate,
    this.locationId,
    this.readStatus,
    this.tags,
  });

  final String? condition;
  final String? grade;
  final DateTime? purchaseDate;
  final String? locationId;
  final String? readStatus;
  final String? tags;

  LibraryAddCommonDraft toCommonDraft() {
    return LibraryAddCommonDraft(
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      locationId: locationId,
      readStatus: readStatus,
      tags: tags,
    );
  }
}

class LibraryAddEditionSelection {
  const LibraryAddEditionSelection({
    required this.editionId,
    this.variantId,
  });

  final String editionId;
  final String? variantId;
}

Future<void> addLibraryItemsToTarget({
  required CatalogCacheRepository catalog,
  required OwnedItemMutations ownedMutations,
  required WishlistMutations wishlistMutations,
  required TrackingMutations trackingMutations,
  required Iterable<LibraryMetadataItem> items,
  required LibraryAddTarget target,
  LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
  LibraryAddDefaults defaults = const LibraryAddDefaults(),
  LibraryAddCommonDraft? commonDraft,
  Map<String, LibraryAddKindDraft> kindDraftsByItemId = const {},
  Map<String, LibraryAddEditionSelection> editionSelectionsByItemId = const {},
  Map<String, String> bundleReleaseIdsByItemId = const {},
}) async {
  final values = items.toList(growable: false);
  if (values.isEmpty) {
    return;
  }

  final catalogItems = [for (final item in values) item.toCatalogItem()];
  await catalog.upsertAll(catalogItems);

  final baseCommon = commonDraft ?? defaults.toCommonDraft();

  for (final item in values) {
    final digitalOwnedItem = _digitalOwnedItemFlag(item);
    final isDigitalOwnedItem = digitalOwnedItem == true;
    final reference = _resolveReferenceForItem(
      item,
      referenceType: target == LibraryAddTarget.track
          ? LibraryAddReferenceType.media
          : referenceType,
      editionSelection: editionSelectionsByItemId[item.id],
      bundleReleaseId: bundleReleaseIdsByItemId[item.id],
    );

    final itemCommon = LibraryAddCommonDraft(
      condition: isDigitalOwnedItem ? null : baseCommon.condition,
      grade: isDigitalOwnedItem ? null : baseCommon.grade,
      purchaseDate: baseCommon.purchaseDate,
      pricePaidCents: baseCommon.pricePaidCents,
      currency: baseCommon.currency,
      personalNotes: baseCommon.personalNotes,
      quantity: baseCommon.quantity,
      rating: baseCommon.rating,
      readStatus: baseCommon.readStatus,
      startedAt: baseCommon.startedAt,
      finishedAt: baseCommon.finishedAt,
      tags: baseCommon.tags,
      locationId: isDigitalOwnedItem ? null : baseCommon.locationId,
      purchaseStore: baseCommon.purchaseStore,
      collectionStatus: baseCommon.collectionStatus,
      isDigital: digitalOwnedItem ?? baseCommon.isDigital,
      editionId: reference.editionId ?? baseCommon.editionId,
      variantId: reference.variantId ?? baseCommon.variantId,
      bundleReleaseId: reference.bundleReleaseId ?? baseCommon.bundleReleaseId,
    );

    switch (target) {
      case LibraryAddTarget.owned:
        final itemKind = catalogMediaKindFromApiValue(item.kind);
        final capability = libraryKindRuntimeForKind(itemKind).add;
        final addCmd = capability.buildCommand(
          item.toCatalogItem(),
          itemCommon,
          kindDraftsByItemId[item.id] ?? capability.createInitialDraft(),
        );
        final ownedItem = await ownedMutations.addOwnedItem(addCmd);
        await trackingMutations.syncOwnedTrackingEntry(
          ownedItem,
          editionId: reference.editionId,
          variantId: reference.variantId,
          status: mediaTrackingStatusFromValue(itemCommon.readStatus),
          rating: itemCommon.rating,
          startedAt: itemCommon.startedAt,
          finishedAt: itemCommon.finishedAt,
          notes: itemCommon.personalNotes,
        );
        break;
      case LibraryAddTarget.wishlist:
        await wishlistMutations.addToWishlist(
          item.id,
          fallbackKind: item.kind,
          anchorType: reference.anchorType,
          editionId: reference.editionId,
          variantId: reference.variantId,
          bundleReleaseId: reference.bundleReleaseId,
        );
        break;
      case LibraryAddTarget.track:
        await trackingMutations.addLocalOnlyTrackingEntry(
          item.toCatalogItem(),
          anchorType: reference.anchorType,
          editionId: reference.editionId,
          variantId: reference.variantId,
          bundleReleaseId: reference.bundleReleaseId,
          status: itemCommon.readStatus == null
              ? null
              : mediaTrackingStatusFromValue(itemCommon.readStatus),
          allowEmpty: true,
        );
        break;
    }
  }
}

bool? _digitalOwnedItemFlag(LibraryMetadataItem item) {
  return digitalPhysicalMediaFormatFlag(
    item.physicalFormat,
    label: item.physicalFormatLabel ?? item.variant,
  );
}

_ResolvedAddReference _resolveReferenceForItem(
  LibraryMetadataItem item, {
  required LibraryAddReferenceType referenceType,
  LibraryAddEditionSelection? editionSelection,
  String? bundleReleaseId,
}) {
  switch (referenceType) {
    case LibraryAddReferenceType.media:
      return const _ResolvedAddReference();
    case LibraryAddReferenceType.bundleRelease:
      final normalizedBundleId = bundleReleaseId?.trim();
      if (normalizedBundleId == null || normalizedBundleId.isEmpty) {
        return const _ResolvedAddReference();
      }
      return _ResolvedAddReference(
        anchorType: 'bundle_release',
        bundleReleaseId: normalizedBundleId,
      );
    case LibraryAddReferenceType.edition:
      final explicitEditionId = editionSelection?.editionId.trim();
      if (explicitEditionId != null && explicitEditionId.isNotEmpty) {
        return _ResolvedAddReference(
          anchorType: 'edition',
          editionId: explicitEditionId,
          variantId: editionSelection?.variantId?.trim().isEmpty == true
              ? null
              : editionSelection?.variantId?.trim(),
        );
      }
      final editions = item.editions;
      if (editions.isEmpty) {
        return const _ResolvedAddReference();
      }
      final firstEdition = editions.first;
      final explicitVariantId = editionSelection?.variantId?.trim();
      return _ResolvedAddReference(
        anchorType: 'edition',
        editionId: firstEdition.id,
        variantId:
            explicitVariantId?.isEmpty == true ? null : explicitVariantId,
      );
  }
}

class _ResolvedAddReference {
  const _ResolvedAddReference({
    this.anchorType,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
  });

  final String? anchorType;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
}
