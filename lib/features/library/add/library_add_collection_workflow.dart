import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

class LibraryAddDefaults {
  const LibraryAddDefaults({
    this.condition,
    this.purchaseDate,
    this.locationId,
    this.readStatus,
    this.tags,
  });

  final String? condition;
  final DateTime? purchaseDate;
  final String? locationId;
  final String? readStatus;
  final String? tags;

  LibraryAddCommonDraft toCommonDraft() {
    return LibraryAddCommonDraft(
      condition: condition,
      purchaseDate: purchaseDate,
      locationId: locationId,
      tags: tags,
    );
  }

  LibraryAddTrackingDraft toTrackingDraft() {
    return LibraryAddTrackingDraft(readStatus: readStatus);
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

final class LibraryAddMutationDependencies {
  const LibraryAddMutationDependencies({
    required this.catalog,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
  });

  final CatalogTransportRepository catalog;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
}

final class LibraryAddBatchRequest {
  const LibraryAddBatchRequest({
    required this.dependencies,
    required this.items,
    required this.target,
    this.referenceType = LibraryAddReferenceType.media,
    this.defaults = const LibraryAddDefaults(),
    this.commonDraft,
    this.trackingDraft,
    this.kindDraftsByItemId = const {},
    this.editionSelectionsByItemId = const {},
    this.bundleReleaseIdsByItemId = const {},
  });

  final LibraryAddMutationDependencies dependencies;
  final Iterable<CatalogSearchCandidate> items;
  final LibraryAddTarget target;
  final LibraryAddReferenceType referenceType;
  final LibraryAddDefaults defaults;
  final LibraryAddCommonDraft? commonDraft;
  final LibraryAddTrackingDraft? trackingDraft;
  final Map<String, LibraryAddKindDraft> kindDraftsByItemId;
  final Map<String, LibraryAddEditionSelection> editionSelectionsByItemId;
  final Map<String, String> bundleReleaseIdsByItemId;
}

/// Pure application orchestration for already-selected catalog results.
final class LibraryAddCoordinator {
  const LibraryAddCoordinator();

  Future<void> add(LibraryAddBatchRequest request) async {
    final catalog = request.dependencies.catalog;
    final ownedMutations = request.dependencies.ownedMutations;
    final wishlistMutations = request.dependencies.wishlistMutations;
    final trackingMutations = request.dependencies.trackingMutations;
    final items = request.items;
    final target = request.target;
    final referenceType = request.referenceType;
    final defaults = request.defaults;
    final commonDraft = request.commonDraft;
    final trackingDraft = request.trackingDraft;
    final kindDraftsByItemId = request.kindDraftsByItemId;
    final editionSelectionsByItemId = request.editionSelectionsByItemId;
    final bundleReleaseIdsByItemId = request.bundleReleaseIdsByItemId;

    final values = items.toList(growable: false);
    if (values.isEmpty) {
      return;
    }

    await catalog.upsertImportSnapshots(
      values.map((item) => item.toImportSnapshot()).toList(growable: false),
    );

    final baseCommon = commonDraft ?? defaults.toCommonDraft();
    final baseTracking = trackingDraft ?? defaults.toTrackingDraft();

    for (final item in values) {
      final digitalOwnedItem =
          libraryKindModuleForKind(item.mediaKind).add.digitalCopyFlag(item);
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
        purchaseDate: baseCommon.purchaseDate,
        pricePaidCents: baseCommon.pricePaidCents,
        currency: baseCommon.currency,
        personalNotes: baseCommon.personalNotes,
        quantity: baseCommon.quantity,
        tags: baseCommon.tags,
        locationId: isDigitalOwnedItem ? null : baseCommon.locationId,
        purchaseStore: baseCommon.purchaseStore,
        collectionStatus: baseCommon.collectionStatus,
        isDigital: digitalOwnedItem ?? baseCommon.isDigital,
      );
      switch (target) {
        case LibraryAddTarget.owned:
          final itemKind = item.mediaKind;
          final capability = libraryKindModuleForKind(itemKind).add;
          final addCmd = capability.buildCommand(
            item,
            itemCommon,
            kindDraftsByItemId[item.id] ?? capability.createInitialDraft(),
            targetRef: reference.catalogRef,
            tracking: baseTracking,
          );
          final ownedItem = await ownedMutations.addOwnedItem(addCmd);
          final tracking = addCmd.tracking;
          if (tracking != null) {
            await trackingMutations.syncOwnedTrackingLifecycle(
              ownedItem,
              targetRef: reference.catalogRef,
              status: tracking.status,
              rating: tracking.rating,
              startedAt: tracking.startedAt,
              finishedAt: tracking.finishedAt,
              notes: tracking.notes,
            );
          }
          break;
        case LibraryAddTarget.wishlist:
          await wishlistMutations.addToWishlist(
            reference.catalogRef,
          );
          break;
        case LibraryAddTarget.track:
          await trackingMutations.addLocalOnlyTrackingLifecycle(
            item.catalogRef,
            targetRef: reference.catalogRef,
            status: baseTracking.readStatus == null
                ? null
                : mediaTrackingStatusFromValue(baseTracking.readStatus),
            allowEmpty: true,
          );
          break;
      }
    }
  }
}

_ResolvedAddReference _resolveReferenceForItem(
  CatalogSearchCandidate item, {
  required LibraryAddReferenceType referenceType,
  LibraryAddEditionSelection? editionSelection,
  String? bundleReleaseId,
}) {
  switch (referenceType) {
    case LibraryAddReferenceType.media:
      return _ResolvedAddReference(
        catalogRef: item.catalogRef,
      );
    case LibraryAddReferenceType.bundleRelease:
      return _ResolvedAddReference(
        catalogRef: catalogRefForLibrarySelection(
          item.catalogRef,
          bundleReleaseId: bundleReleaseId,
        ),
      );
    case LibraryAddReferenceType.edition:
      final explicitEditionId = editionSelection?.editionId.trim();
      if (explicitEditionId != null && explicitEditionId.isNotEmpty) {
        final variantId = editionSelection?.variantId?.trim();
        return _ResolvedAddReference(
          catalogRef: catalogRefForLibrarySelection(
            item.catalogRef,
            editionId: explicitEditionId,
            variantId: variantId?.isEmpty == true ? null : variantId,
          ),
        );
      }
      final editions = libraryKindModuleForKind(item.mediaKind)
          .presentation
          .builder
          .buildReleaseEditions(item: item);
      if (editions.isEmpty) {
        return _ResolvedAddReference(catalogRef: item.catalogRef);
      }
      final firstEdition = editions.first;
      final explicitVariantId = editionSelection?.variantId?.trim();
      return _ResolvedAddReference(
        catalogRef: catalogRefForLibrarySelection(
          item.catalogRef,
          editionId: firstEdition.id,
          variantId:
              explicitVariantId?.isEmpty == true ? null : explicitVariantId,
        ),
      );
  }
}

class _ResolvedAddReference {
  const _ResolvedAddReference({required this.catalogRef});

  final CatalogEntityRef catalogRef;
}
