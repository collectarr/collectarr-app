import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

final class LibraryAddSubmissionItem {
  const LibraryAddSubmissionItem({
    required this.candidate,
    required this.targetRef,
    required this.wishlistRef,
  });

  final CatalogSearchCandidate candidate;
  final CatalogEntityRef targetRef;
  final CatalogEntityRef wishlistRef;
}

final class LibraryAddSubmissionRequest {
  const LibraryAddSubmissionRequest({
    required this.items,
    required this.kind,
    required this.target,
    required this.commonDraft,
    required this.kindDraft,
    required this.trackingDraft,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    this.catalog,
    this.upsertCatalogItems = true,
  });

  final List<LibraryAddSubmissionItem> items;
  final CatalogMediaKind kind;
  final LibraryAddTarget target;
  final LibraryAddCommonDraft commonDraft;
  final LibraryAddKindDraft kindDraft;
  final LibraryAddTrackingDraft trackingDraft;
  final CatalogTransportRepository? catalog;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final bool upsertCatalogItems;
}

final class LibraryAddSubmissionResult {
  const LibraryAddSubmissionResult({required this.submittedCount});

  final int submittedCount;
}

final class LibraryAddBatchSubmissionResult {
  const LibraryAddBatchSubmissionResult({required this.submittedCount});

  final int submittedCount;
}

final class LibraryAddSubmissionService {
  const LibraryAddSubmissionService();

  Future<LibraryAddSubmissionResult> submit(
    LibraryAddSubmissionRequest request,
  ) async {
    if (request.items.isEmpty) {
      return const LibraryAddSubmissionResult(submittedCount: 0);
    }

    for (final item in request.items) {
      if (request.upsertCatalogItems && request.catalog != null) {
        await request.catalog!.upsertTransports([
          item.candidate.toImportTransport(),
        ]);
      }

      switch (request.target) {
        case LibraryAddTarget.owned:
          final command = libraryAddForKind(request.kind).buildCommand(
            item.candidate,
            request.commonDraft,
            request.kindDraft,
            targetRef: item.targetRef,
            tracking: request.trackingDraft,
          );
          final owned = await request.ownedMutations.addOwnedItem(command);
          final tracking = command.tracking;
          if (tracking != null) {
            await request.trackingMutations.syncOwnedTrackingState(
              owned,
              targetRef: command.targetRef,
              status: tracking.status,
              rating: tracking.rating,
              startedAt: tracking.startedAt,
              finishedAt: tracking.finishedAt,
              notes: tracking.notes,
            );
          }
        case LibraryAddTarget.wishlist:
          await request.wishlistMutations.addToWishlist(item.wishlistRef);
        case LibraryAddTarget.track:
          await request.trackingMutations.addLocalOnlyTrackingState(
            item.candidate.catalogRef,
            targetRef: item.targetRef,
          );
      }
    }

    return LibraryAddSubmissionResult(
      submittedCount: request.items.length,
    );
  }

  Future<LibraryAddBatchSubmissionResult> submitCoreBatch(
    LibraryAddBatchRequest request,
  ) async {
    final items = request.items.toList(growable: false);
    await const LibraryAddCoordinator().add(
      LibraryAddBatchRequest(
        dependencies: request.dependencies,
        items: items,
        target: request.target,
        referenceType: request.referenceType,
        defaults: request.defaults,
        commonDraft: request.commonDraft,
        trackingDraft: request.trackingDraft,
        kindDraftsByCatalogRef: request.kindDraftsByCatalogRef,
        editionSelectionsByCatalogRef: request.editionSelectionsByCatalogRef,
        bundleReleaseIdsByCatalogRef: request.bundleReleaseIdsByCatalogRef,
      ),
    );
    return LibraryAddBatchSubmissionResult(submittedCount: items.length);
  }
}
