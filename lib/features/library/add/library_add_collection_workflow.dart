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
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';

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

Future<void> addLibraryItemsToTarget({
  required CatalogTransportRepository catalog,
  required OwnedItemMutations ownedMutations,
  required WishlistMutations wishlistMutations,
  required TrackingMutations trackingMutations,
  required Iterable<LibraryAddCatalogItem> items,
  required LibraryAddTarget target,
  LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
  LibraryAddDefaults defaults = const LibraryAddDefaults(),
  LibraryAddCommonDraft? commonDraft,
  LibraryAddTrackingDraft? trackingDraft,
  Map<String, LibraryAddKindDraft> kindDraftsByItemId = const {},
  Map<String, LibraryAddEditionSelection> editionSelectionsByItemId = const {},
  Map<String, String> bundleReleaseIdsByItemId = const {},
}) async {
  final values = items.toList(growable: false);
  if (values.isEmpty) {
    return;
  }

  await catalog.upsertMetadataItems(
    values.map((item) => item.toTransportItem()).toList(growable: false),
  );

  final baseCommon = commonDraft ?? defaults.toCommonDraft();
  final baseTracking = trackingDraft ?? defaults.toTrackingDraft();

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
      tags: baseCommon.tags,
      locationId: isDigitalOwnedItem ? null : baseCommon.locationId,
      purchaseStore: baseCommon.purchaseStore,
      collectionStatus: baseCommon.collectionStatus,
      isDigital: digitalOwnedItem ?? baseCommon.isDigital,
    );
    switch (target) {
      case LibraryAddTarget.owned:
        final itemKind = catalogMediaKindFromApiValue(item.kind);
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
          await trackingMutations.syncOwnedTrackingEntry(
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
        await trackingMutations.addLocalOnlyTrackingEntry(
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

bool? _digitalOwnedItemFlag(LibraryAddCatalogItem item) {
  final payload = item.payload;
  if (payload['is_digital'] is bool) {
    return payload['is_digital'] as bool;
  }
  final physicalFormat =
      (payload['physical_format'] ?? payload['physical_format_label'])
          ?.toString()
          .toLowerCase();
  if (physicalFormat == 'digital' ||
      physicalFormat == 'ebook' ||
      physicalFormat == 'web') {
    return true;
  }
  final dynamic series = payload['series'];
  if (series is Map && series['is_digital'] is bool) {
    return series['is_digital'] as bool;
  }
  final dynamic publishing = payload['publishing'];
  if (publishing is Map && publishing['is_digital'] is bool) {
    return publishing['is_digital'] as bool;
  }
  return null;
}

_ResolvedAddReference _resolveReferenceForItem(
  LibraryAddCatalogItem item, {
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
      final editions = item.editions;
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
