import 'dart:async';

import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
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

final class LibraryAddMutationDependencies {
  const LibraryAddMutationDependencies({
    this.catalog,
    required this.entryMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
  });

  final CatalogTransportRepository? catalog;
  final LibraryEntryMutations entryMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
}

final class LibraryAddBatchRequest {
  const LibraryAddBatchRequest({
    required this.dependencies,
    required this.items,
    required this.target,
    this.defaults = const LibraryAddDefaults(),
    this.commonDraft,
    this.trackingDraft,
    this.kindDraftsByCatalogRef = const {},
    this.upsertCatalogItems = true,
    this.onLibraryEntryCreated,
    this.onSubmissionCommitted,
  });

  final LibraryAddMutationDependencies dependencies;
  final Iterable<CatalogSearchCandidate> items;
  final LibraryAddTarget target;
  final LibraryAddDefaults defaults;
  final LibraryAddCommonDraft? commonDraft;
  final LibraryAddTrackingDraft? trackingDraft;
  final Map<CatalogEntityRef, LibraryAddKindDraft> kindDraftsByCatalogRef;
  final bool upsertCatalogItems;
  final FutureOr<void> Function(LibraryEntryRef libraryEntryRef)?
      onLibraryEntryCreated;
  final FutureOr<void> Function()? onSubmissionCommitted;
}

/// Pure application orchestration for already-selected catalog results.
final class LibraryAddCoordinator {
  const LibraryAddCoordinator();

  Future<List<String>> add(LibraryAddBatchRequest request) async {
    final catalog = request.dependencies.catalog;
    final entryMutations = request.dependencies.entryMutations;
    final wishlistMutations = request.dependencies.wishlistMutations;
    final items = request.items;
    final target = request.target;
    final defaults = request.defaults;
    final commonDraft = request.commonDraft;
    final trackingDraft = request.trackingDraft;
    final kindDraftsByCatalogRef = request.kindDraftsByCatalogRef;

    final values = items.toList(growable: false);
    if (values.isEmpty) {
      return const [];
    }

    final baseCommon = commonDraft ?? defaults.toCommonDraft();
    final baseTracking = trackingDraft ?? defaults.toTrackingDraft();

    return entryMutations.mutationRunner.run(action: () async {
      final submittedItemIds = <String>[];
      if (request.upsertCatalogItems && catalog != null) {
        await catalog.upsertTransports(
          values.map((item) => item.kindCapability.toImportTransport()),
        );
      } else if (request.upsertCatalogItems) {
        throw StateError('Catalog storage is unavailable for Add.');
      }

      for (final item in values) {
        final digitalLibraryEntry =
            libraryAddForKind(item.summary.kind).digitalCopyFlag(item);
        final isDigitalLibraryEntry = digitalLibraryEntry == true;
        final reference = item.reference;

        final itemCommon = LibraryAddCommonDraft(
          condition: isDigitalLibraryEntry ? null : baseCommon.condition,
          purchaseDate: baseCommon.purchaseDate,
          pricePaidCents: baseCommon.pricePaidCents,
          currency: baseCommon.currency,
          personalNotes: baseCommon.personalNotes,
          tags: baseCommon.tags,
          locationId: isDigitalLibraryEntry ? null : baseCommon.locationId,
          purchaseStore: baseCommon.purchaseStore,
          ownerLabel: baseCommon.ownerLabel,
          collectionStatus: baseCommon.collectionStatus,
          isDigital: digitalLibraryEntry ?? baseCommon.isDigital,
        );
        switch (target) {
          case LibraryAddTarget.entry:
            final libraryEntry = await _createLibraryEntry(
              request: request,
              item: item,
              common: itemCommon,
              tracking: baseTracking,
              kindDraft: kindDraftsByCatalogRef[item.reference],
              catalog: catalog,
            );
            submittedItemIds.add(libraryEntry.id.value);
            break;
          case LibraryAddTarget.wishlist:
            await wishlistMutations.addToWishlist(
              reference.toCatalogItemRef(),
            );
            submittedItemIds.add(reference.id);
            break;
          case LibraryAddTarget.track:
            // Tracking is personal state and must always have a local entry
            // owner. A track-only Add therefore creates an independently
            // editable local entry before writing its tracking lifecycle.
            final trackDraft = baseTracking.readStatus == null
                ? baseTracking.copyWith(readStatus: 'planned')
                : baseTracking;
            final libraryEntry = await _createLibraryEntry(
              request: request,
              item: item,
              common: LibraryAddCommonDraft(
                personalNotes: itemCommon.personalNotes,
                tags: itemCommon.tags,
                collectionStatus: 'Not in Collection',
              ),
              tracking: trackDraft,
              kindDraft: kindDraftsByCatalogRef[item.reference],
              catalog: catalog,
            );
            submittedItemIds.add(libraryEntry.id.value);
            break;
        }
        await request.onSubmissionCommitted?.call();
      }
      return submittedItemIds;
    });
  }

  Future<LibraryEntryRef> _createLibraryEntry({
    required LibraryAddBatchRequest request,
    required CatalogSearchCandidate item,
    required LibraryAddCommonDraft common,
    required LibraryAddTrackingDraft tracking,
    required LibraryAddKindDraft? kindDraft,
    required CatalogTransportRepository? catalog,
  }) async {
    final entryMutations = request.dependencies.entryMutations;
    final itemKind = item.summary.kind;
    final capability = libraryAddForKind(itemKind);
    final command = capability.buildCommand(
      item,
      common,
      kindDraft ?? capability.createInitialDraft(),
      tracking: tracking,
    );
    final libraryEntry = await entryMutations.addLibraryEntry(
      command,
      enqueueSync: false,
    );
    await request.onLibraryEntryCreated?.call(libraryEntry);
    if (catalog != null && item.kindCapability.isPrivateLocal) {
      await catalog.removePrivateCandidate(item.reference);
    }

    // Attachments and custom fields are written before the one authoritative
    // entry snapshot. A failed callback rolls the enclosing Add transaction
    // back instead of leaving a partial row to retry.
    await entryMutations.syncQueue.enqueue(
      await entryMutations.libraryEntries.syncChangeForCurrentEntry(
        libraryEntry,
        action: 'upsert',
        changedAt: DateTime.now().toUtc(),
      ),
    );
    final trackingState = command.tracking;
    if (trackingState != null && trackingState.hasValues) {
      await request.dependencies.trackingMutations.syncEntryTrackingState(
        libraryEntry,
        status: trackingState.status,
        rating: trackingState.rating,
        startedAt: trackingState.startedAt,
        finishedAt: trackingState.finishedAt,
        notes: trackingState.notes,
      );
    }
    return libraryEntry;
  }
}
