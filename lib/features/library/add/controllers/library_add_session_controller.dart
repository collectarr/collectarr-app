import 'dart:async';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_state.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_state.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/add/services/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/services/library_add_hydration_service.dart';
import 'package:collectarr_app/features/library/add/services/library_add_submission_service.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'library_add_search_flow.dart';

class LibraryAddSessionController extends ValueNotifier<LibraryAddSessionState>
    with _LibraryAddSearchFlow {
  LibraryAddSessionController({
    required this.kind,
    LibraryKindRegistration? type,
    required this.entryMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    this.api,
    this.catalog,
    this.coverScanService = const LocalLibraryCoverScanService(),
    this.hydrationService = const LibraryAddHydrationService(),
    this.submissionService = const LibraryAddSubmissionService(),
    this.onAuthSessionExpired,
    LibraryAddSessionState? initialState,
  })  : _registration = type,
        super(
          initialState ??
              LibraryAddSessionState(
                mode: LibraryAddDialogMode.search,
                target: LibraryAddTarget.entry,
                search: LibraryAddSearchState.initial(
                  advancedFilters: libraryAddForKind(kind)
                      .search
                      .input
                      .initialAdvancedFilters,
                ),
                selection: LibraryAddSelectionState(
                  resultPolicyState:
                      libraryAddForKind(kind).resultPolicy.initialState,
                ),
                preview: const LibraryAddPreviewState.initial(),
                commonDraft: const LibraryAddCommonDraft(),
                trackingDraft: const LibraryAddTrackingDraft(),
                manualDraft: libraryAddForKind(kind).createInitialDraft(),
                submitState: const AsyncValue.data(null),
                defaultCondition: libraryEditPresentationForKind(
                  type?.kind ?? kind,
                ).defaultCondition,
              ),
        );

  @override
  final CatalogMediaKind kind;
  final LibraryKindRegistration? _registration;
  final LibraryEntryMutations entryMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;

  @override
  final ApiClient? api;
  @override
  final CatalogTransportRepository? catalog;
  final LibraryCoverScanService coverScanService;
  final LibraryAddHydrationService hydrationService;
  final LibraryAddSubmissionService submissionService;
  final Future<bool> Function(Object error, String action)?
      onAuthSessionExpired;

  List<String> _lastSubmittedItemIds = const [];

  List<String> get lastSubmittedItemIds => _lastSubmittedItemIds;

  @override
  LibraryKindRegistration get type =>
      _registration ?? libraryKindRegistrationForKind(kind);

  @override
  LibraryAddSessionState get state => value;
  @override
  set state(LibraryAddSessionState newState) => value = newState;

  LibraryAddSubmissionRequest _submissionRequest(
    List<CatalogSearchCandidate> candidates, {
    bool upsertCatalogItems = true,
    FutureOr<void> Function(LibraryEntryRef libraryEntryRef)?
        onLibraryEntryCreated,
    FutureOr<void> Function()? onSubmissionCommitted,
  }) {
    return LibraryAddSubmissionRequest(
      items: [
        for (final candidate in candidates)
          LibraryAddSubmissionItem(
            candidate: candidate,
          ),
      ],
      kind: kind,
      target: state.target,
      commonDraft: state.commonDraft,
      kindDraft: state.manualDraft,
      trackingDraft: state.trackingDraft,
      catalog: catalog,
      entryMutations: entryMutations,
      wishlistMutations: wishlistMutations,
      trackingMutations: trackingMutations,
      upsertCatalogItems: upsertCatalogItems,
      onLibraryEntryCreated: onLibraryEntryCreated,
      onSubmissionCommitted: onSubmissionCommitted,
    );
  }

  @override
  LibraryAddSearchCapability get _searchCapability =>
      libraryAddForKind(kind).search;

  @override
  LibraryAddSearchContext _searchContext({String? query}) {
    return LibraryAddSearchContext(
      query: query ?? state.search.query,
      identifierCode: state.search.identifierCode,
      advancedFilters: state.search.advancedFilters,
    );
  }

  void setMode(LibraryAddDialogMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setTarget(LibraryAddTarget target) {
    state = state.copyWith(target: target);
  }

  @override
  void selectResult(String id) {
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedResultId: id,
      ),
    );
    unawaited(_ensureSelectedResultLoaded(id));
  }

  void toggleCheckedResult(String id) {
    final updated = Set<String>.from(state.selection.checkedResultIds);
    if (!updated.remove(id)) {
      updated.add(id);
    }
    state = state.copyWith(
      selection: state.selection.copyWith(checkedResultIds: updated),
    );
  }

  void setResultPolicyOption(String id, bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(
        resultPolicyState: state.selection.resultPolicyState.withValue(
          id,
          value,
        ),
      ),
    );
  }

  void setResultPolicyState(LibraryAddResultPolicyState value) {
    state = state.copyWith(
      selection: state.selection.copyWith(resultPolicyState: value),
    );
  }

  Future<void> scanCover(BuildContext context) async {
    if (state.search.isScanningCover) return;
    state = state.copyWith(
      search: state.search.copyWith(
        isScanningCover: true,
        clearError: true,
      ),
    );

    try {
      final result = await coverScanService.scanCover(
        context: context,
        type: type,
      );
      if (result == null) return;

      if (!result.hasAnyHint) {
        state = state.copyWith(
          search: state.search.copyWith(
            error: result.warnings.isEmpty
                ? 'Cover scan did not extract usable search hints yet.'
                : result.warnings.first,
            clearCoverScanPrefill: true,
          ),
        );
        return;
      }

      final query =
          (_searchCapability.coverScan?.searchQuery(result) ?? result.query)
                  ?.trim() ??
              '';
      final advancedFilters =
          Map<LibraryAddFilterId, LibraryAddFilterValue>.from(
        state.search.advancedFilters,
      )..addAll(
              _searchCapability.coverScan?.filterValues(result) ?? const {},
            );
      state = state.copyWith(
        mode: LibraryAddDialogMode.search,
        search: state.search.copyWith(
          query: query,
          advancedFilters: advancedFilters,
          showAdvancedSearch: result.showAdvancedFields,
          coverScanPrefill: result,
          results: const [],
        ),
        selection: state.selection.copyWith(
          clearSelectedResultId: true,
        ),
        preview: const LibraryAddPreviewState.initial(),
      );

      await executeSearch();
    } finally {
      state = state.copyWith(
        search: state.search.copyWith(isScanningCover: false),
      );
    }
  }

  @override
  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (api == null) return;
    CatalogSearchCandidate? selected;
    for (final item in state.search.results) {
      if (item.reference.id == itemId) {
        selected = item;
        break;
      }
    }
    if (selected == null) return;
    final catalogRef = selected.reference;
    if (state.preview.hasHydratedResult(catalogRef) ||
        state.preview.isHydratedResultPending(catalogRef)) {
      return;
    }

    final searchGen = state.search.coreSearchGeneration;
    final pending = Set<CatalogItemRef>.from(
      state.preview.pendingHydratedResultRefs,
    )..add(catalogRef);
    state = state.copyWith(
      preview: state.preview.copyWith(pendingHydratedResultRefs: pending),
    );

    try {
      final hydrated = await hydrationService.hydrateCatalogCandidate(
        api: api!,
        type: type,
        fallback: selected,
        itemId: itemId,
      );

      if (searchGen != state.search.coreSearchGeneration) return;

      final mergedItem =
          libraryPresentationForKind(type.kind).builder.mergeHydratedAddItem(
                hydrated: hydrated,
                fallback: selected,
              );

      final hydratedMap = Map<CatalogItemRef, CatalogSearchCandidate>.from(
        state.preview.hydratedResultsByRef,
      );
      hydratedMap[catalogRef] = mergedItem;
      final pendingUpdated = Set<CatalogItemRef>.from(
        state.preview.pendingHydratedResultRefs,
      )..remove(catalogRef);
      state = state.copyWith(
        preview: state.preview.copyWith(
          hydratedResultsByRef: hydratedMap,
          pendingHydratedResultRefs: pendingUpdated,
        ),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to hydrate add-result metadata for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      final pendingUpdated = Set<CatalogItemRef>.from(
        state.preview.pendingHydratedResultRefs,
      )..remove(catalogRef);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingHydratedResultRefs: pendingUpdated,
        ),
      );
    }
  }

  void updateCommonDraft(
      LibraryAddCommonDraft Function(LibraryAddCommonDraft) update) {
    state = state.copyWith(commonDraft: update(state.commonDraft));
  }

  void updateTrackingDraft(
      LibraryAddTrackingDraft Function(LibraryAddTrackingDraft) update) {
    state = state.copyWith(trackingDraft: update(state.trackingDraft));
  }

  void updateKindDraft(
      LibraryAddKindDraft Function(LibraryAddKindDraft) update) {
    state = state.copyWith(manualDraft: update(state.manualDraft));
  }

  void setDefaultCondition(String condition) {
    state = state.copyWith(defaultCondition: condition);
  }

  void setDefaultPurchaseDate(DateTime? date) {
    state = state.copyWith(
      defaultPurchaseDate: date,
      clearDefaultPurchaseDate: date == null,
    );
  }

  void setDefaultLocationId(String? locationId) {
    state = state.copyWith(
      defaultLocationId: locationId,
      clearDefaultLocationId: locationId == null,
    );
  }

  void setDefaultReadStatus(String? readStatus) {
    state = state.copyWith(
      defaultReadStatus: readStatus,
      clearDefaultReadStatus: readStatus == null,
    );
  }

  void setDefaultTags(String? tags) {
    state = state.copyWith(
      defaultTags: tags,
      clearDefaultTags: tags == null,
    );
  }

  void clearSubmissionError() {
    state = state.copyWith(
      search: state.search.copyWith(clearError: true),
      submitState: const AsyncValue.data(null),
    );
  }

  void reportSubmissionError(String message) {
    state = state.copyWith(
      search: state.search.copyWith(error: message),
      submitState: const AsyncValue.data(null),
    );
  }

  void setPhysicalFormatId(String? formatId) {
    state = state.copyWith(
      physicalFormatId: formatId,
      clearPhysicalFormatId: formatId == null,
    );
  }

  Future<bool> submitSelectedItem(
    CatalogSearchCandidate item, {
    FutureOr<void> Function(LibraryEntryRef libraryEntryRef)?
        onLibraryEntryCreated,
    FutureOr<void> Function()? onSubmissionCommitted,
  }) async {
    if (state.isAdding || state.submitState.isLoading) return false;
    _lastSubmittedItemIds = const [];
    clearSubmissionError();
    state = state.copyWith(
      isAdding: true,
      submitState: const AsyncValue.loading(),
    );
    try {
      final result = await submissionService.submit(
        _submissionRequest(
          [item],
          onLibraryEntryCreated: onLibraryEntryCreated,
          onSubmissionCommitted: onSubmissionCommitted,
        ),
      );
      if (result.submittedCount == 0) {
        state = state.copyWith(
          isAdding: false,
          submitState: const AsyncValue.data(null),
        );
        reportSubmissionError('The item was not added. Please try again.');
        return false;
      }

      _lastSubmittedItemIds = result.itemIds;

      state = state.copyWith(
        isAdding: false,
        search: state.search.copyWith(clearError: true),
        submitState: const AsyncValue.data(null),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(
        isAdding: false,
        search: state.search.copyWith(error: e.toString()),
        submitState: AsyncValue.error(e, st),
      );
      return false;
    }
  }

  Future<int> _submitCoreCandidates(Set<String> checkedResultIds) async {
    if (checkedResultIds.isEmpty) return 0;

    final searchItems = state.search.results
        .where((item) => checkedResultIds.contains(item.reference.id))
        .toList(growable: false);
    if (searchItems.isEmpty) return 0;
    final catalogRepository = catalog;
    if (catalogRepository == null) {
      throw StateError('Catalog storage is unavailable for Core results.');
    }

    final itemsToAdd = <CatalogSearchCandidate>[];
    for (final fallback in searchItems) {
      final hydrated = state.preview.hydratedResultFor(fallback.reference);
      if (hydrated != null || api == null) {
        itemsToAdd.add(hydrated ?? fallback);
        continue;
      }
      try {
        final response = await hydrationService.hydrateCatalogCandidate(
          api: api!,
          type: type,
          fallback: fallback,
          itemId: fallback.reference.id,
        );
        itemsToAdd.add(
          libraryPresentationForKind(type.kind).builder.mergeHydratedAddItem(
                hydrated: response,
                fallback: fallback,
              ),
        );
      } catch (error, stackTrace) {
        logRecoverableError(
          source: 'library_add',
          message:
              'Could not hydrate checked catalog result ${fallback.reference.id}; using its search payload.',
          error: error,
          stackTrace: stackTrace,
        );
        itemsToAdd.add(fallback);
      }
    }

    final result = await submissionService.submitCoreBatch(
      LibraryAddBatchRequest(
        dependencies: LibraryAddMutationDependencies(
          catalog: catalogRepository,
          entryMutations: entryMutations,
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
        ),
        items: itemsToAdd,
        target: state.target,
        trackingDraft: LibraryAddTrackingDraft(
          rating: state.trackingDraft.rating,
          readStatus: state.defaultReadStatus ?? state.trackingDraft.readStatus,
          startedAt: state.trackingDraft.startedAt,
          finishedAt: state.trackingDraft.finishedAt,
        ),
        defaults: LibraryAddDefaults(
          condition: state.defaultCondition,
          purchaseDate: state.defaultPurchaseDate,
          locationId: state.defaultLocationId,
          readStatus: state.defaultReadStatus,
          tags: state.defaultTags,
        ),
      ),
    );
    _lastSubmittedItemIds = result.itemIds;
    return result.submittedCount;
  }

  Future<bool> submitCurrentSelection() async {
    if (state.isAdding || state.submitState.isLoading) return false;
    _lastSubmittedItemIds = const [];

    final selectedResult = state.selectedItem;
    final checkedResults = state.selection.checkedResultIds
        .where(
          (id) => state.search.results.any((item) => item.reference.id == id),
        )
        .toSet();
    final hasBulkSelection = checkedResults.isNotEmpty;
    if (!hasBulkSelection && selectedResult == null) {
      reportSubmissionError('Select an item before adding it.');
      return false;
    }

    clearSubmissionError();
    state = state.copyWith(
      isAdding: true,
      submitState: const AsyncValue.loading(),
    );

    try {
      var submittedCount = 0;
      if (hasBulkSelection) {
        submittedCount = await _submitCoreCandidates(checkedResults);
      } else if (selectedResult != null) {
        final result = await submissionService.submit(
          _submissionRequest(
            [selectedResult],
            upsertCatalogItems: true,
          ),
        );
        submittedCount = result.submittedCount;
        _lastSubmittedItemIds = result.itemIds;
      }

      if (submittedCount == 0) {
        state = state.copyWith(
          isAdding: false,
          submitState: const AsyncValue.data(null),
        );
        if (state.search.error == null) {
          reportSubmissionError(
            'No item was added. Check the selection and retry.',
          );
        }
        return false;
      }

      state = state.copyWith(
        isAdding: false,
        search: state.search.copyWith(clearError: true),
        submitState: const AsyncValue.data(null),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(
        isAdding: false,
        search: state.search.copyWith(error: e.toString()),
        submitState: AsyncValue.error(e, st),
      );
      return false;
    }
  }

  @override
  Future<bool> _handleAuthExpiration(Object error, String action) async {
    if (onAuthSessionExpired != null) {
      final cleared = await onAuthSessionExpired!(error, action);
      if (cleared) {
        state = state.copyWith(
          search: state.search.copyWith(
            isSearching: false,
            isScanningCover: false,
            error:
                'Saved metadata session was cleared after $action was rejected. '
                'Retry the action. Sign in again only if you need authenticated tools.',
          ),
          isAdding: false,
        );
        return true;
      }
    }
    return false;
  }

  void retry() {
    state = state.copyWith(submitState: const AsyncValue.data(null));
    executeSearch();
  }

  void reset() {
    cancelSearch();
    state = LibraryAddSessionState(
      mode: LibraryAddDialogMode.search,
      target: LibraryAddTarget.entry,
      search: LibraryAddSearchState.initial(
        advancedFilters: _searchCapability.input.initialAdvancedFilters,
      ),
      selection: LibraryAddSelectionState(
        resultPolicyState: libraryAddForKind(kind).resultPolicy.initialState,
      ),
      preview: const LibraryAddPreviewState.initial(),
      commonDraft: const LibraryAddCommonDraft(),
      trackingDraft: const LibraryAddTrackingDraft(),
      manualDraft: libraryAddForKind(kind).createInitialDraft(),
      submitState: const AsyncValue.data(null),
      defaultCondition:
          libraryEditPresentationForKind(type.kind).defaultCondition,
    );
  }

  @override
  void dispose() {
    cancelSearch();
    super.dispose();
  }
}
