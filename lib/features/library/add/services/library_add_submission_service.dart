import 'dart:async';

import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
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
  });

  final CatalogSearchCandidate candidate;
}

final class LibraryAddSubmissionRequest {
  const LibraryAddSubmissionRequest({
    required this.items,
    required this.kind,
    required this.target,
    required this.commonDraft,
    required this.kindDraft,
    required this.trackingDraft,
    required this.entryMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    this.catalog,
    this.upsertCatalogItems = true,
    this.onLibraryEntryCreated,
    this.onSubmissionCommitted,
  });

  final List<LibraryAddSubmissionItem> items;
  final CatalogMediaKind kind;
  final LibraryAddTarget target;
  final LibraryAddCommonDraft commonDraft;
  final LibraryAddKindDraft kindDraft;
  final LibraryAddTrackingDraft trackingDraft;
  final CatalogTransportRepository? catalog;
  final LibraryEntryMutations entryMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final bool upsertCatalogItems;
  final FutureOr<void> Function(LibraryEntryRef libraryEntryRef)?
      onLibraryEntryCreated;
  final FutureOr<void> Function()? onSubmissionCommitted;
}

final class LibraryAddSubmissionResult {
  const LibraryAddSubmissionResult({
    required this.submittedCount,
    this.itemIds = const [],
  });

  final int submittedCount;
  final List<String> itemIds;
}

final class LibraryAddBatchSubmissionResult {
  const LibraryAddBatchSubmissionResult({
    required this.submittedCount,
    this.itemIds = const [],
  });

  final int submittedCount;
  final List<String> itemIds;
}

final class LibraryAddSubmissionService {
  const LibraryAddSubmissionService();

  Future<LibraryAddSubmissionResult> submit(
    LibraryAddSubmissionRequest request,
  ) async {
    if (request.items.isEmpty) {
      return const LibraryAddSubmissionResult(submittedCount: 0);
    }
    final candidates = [for (final item in request.items) item.candidate];
    final itemIds = await const LibraryAddCoordinator().add(
      LibraryAddBatchRequest(
        dependencies: LibraryAddMutationDependencies(
          catalog: request.catalog,
          entryMutations: request.entryMutations,
          wishlistMutations: request.wishlistMutations,
          trackingMutations: request.trackingMutations,
        ),
        items: candidates,
        target: request.target,
        commonDraft: request.commonDraft,
        trackingDraft: request.trackingDraft,
        kindDraftsByCatalogRef: {
          for (final candidate in candidates)
            candidate.reference: request.kindDraft,
        },
        upsertCatalogItems:
            request.upsertCatalogItems && request.catalog != null,
        onLibraryEntryCreated: request.onLibraryEntryCreated,
        onSubmissionCommitted: request.onSubmissionCommitted,
      ),
    );

    if (itemIds.length != request.items.length) {
      throw StateError(
        'Add submitted ${request.items.length} item(s), but returned '
        '${itemIds.length} local identity(ies).',
      );
    }

    return LibraryAddSubmissionResult(
      submittedCount: itemIds.length,
      itemIds: itemIds,
    );
  }

  Future<LibraryAddBatchSubmissionResult> submitCoreBatch(
    LibraryAddBatchRequest request,
  ) async {
    final items = request.items.toList(growable: false);
    final itemIds = await const LibraryAddCoordinator().add(
      LibraryAddBatchRequest(
        dependencies: request.dependencies,
        items: items,
        target: request.target,
        defaults: request.defaults,
        commonDraft: request.commonDraft,
        trackingDraft: request.trackingDraft,
        kindDraftsByCatalogRef: request.kindDraftsByCatalogRef,
        upsertCatalogItems: request.upsertCatalogItems,
        onLibraryEntryCreated: request.onLibraryEntryCreated,
        onSubmissionCommitted: request.onSubmissionCommitted,
      ),
    );
    if (itemIds.length != items.length) {
      throw StateError(
        'Add submitted ${items.length} item(s), but returned '
        '${itemIds.length} local identity(ies).',
      );
    }
    return LibraryAddBatchSubmissionResult(
      submittedCount: itemIds.length,
      itemIds: itemIds,
    );
  }
}
