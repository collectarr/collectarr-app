import 'dart:async';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_state.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_state.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_summary.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_detail.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_preview_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_add_proposal_flow_service.dart';
import 'package:collectarr_app/features/library/add/services/library_add_provider_flow_service.dart';
import 'package:collectarr_app/features/library/add/services/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_add_coordinator.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_add_request.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_orchestration_service.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'library_add_search_flow.dart';

class LibraryAddSessionController extends ValueNotifier<LibraryAddSessionState>
    with _LibraryAddSearchFlow {
  LibraryAddSessionController({
    required this.kind,
    LibraryKindRegistration? type,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    this.api,
    this.catalog,
    this.providerRegistry,
    this.coverScanService = const LocalLibraryCoverScanService(),
    this.providerAddCoordinator = const LibraryProviderAddCoordinator(),
    this.providerActionService = const LibraryProviderActionService(),
    this.providerOrchestrationService =
        const LibraryProviderOrchestrationService(),
    this.providerFlowService = const LibraryAddProviderFlowService(),
    this.proposalFlowService = const LibraryAddProposalFlowService(),
    this.onAuthSessionExpired,
    LibraryAddSessionState? initialState,
  })  : _registration = type,
        super(
          initialState ??
              LibraryAddSessionState(
                mode: LibraryAddDialogMode.search,
                target: LibraryAddTarget.owned,
                search: LibraryAddSearchState.initial(
                  selectedProvider: libraryMetadataForKind(type?.kind ?? kind)
                          .defaultSupportedOption(kind)
                          ?.id ??
                      libraryMetadataForKind(kind).defaultProviderId,
                  advancedFilters:
                      libraryAddForKind(kind).search.initialAdvancedFilters,
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
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;

  Future<void> _addOwnedItemWithTracking(AddOwnedItemCommand command) async {
    final ownedItem = await ownedMutations.addOwnedItem(command);
    final tracking = command.tracking;
    if (tracking == null) {
      return;
    }
    await trackingMutations.syncOwnedTrackingState(
      ownedItem,
      targetRef: command.targetRef,
      status: tracking.status,
      rating: tracking.rating,
      startedAt: tracking.startedAt,
      finishedAt: tracking.finishedAt,
      notes: tracking.notes,
    );
  }

  @override
  final ApiClient? api;
  @override
  final CatalogTransportRepository? catalog;
  @override
  final ProviderConnectorRegistry? providerRegistry;
  final LibraryCoverScanService coverScanService;
  final LibraryProviderAddCoordinator providerAddCoordinator;
  final LibraryProviderActionService providerActionService;
  final LibraryProviderOrchestrationService providerOrchestrationService;
  final LibraryAddProviderFlowService providerFlowService;
  final LibraryAddProposalFlowService proposalFlowService;
  final Future<bool> Function(Object error, String action)?
      onAuthSessionExpired;

  @override
  LibraryKindRegistration get type =>
      _registration ?? libraryKindRegistrationForKind(kind);

  @override
  LibraryAddSessionState get state => value;
  @override
  set state(LibraryAddSessionState newState) => value = newState;

  CatalogEntityRef _selectedWishlistRef(CatalogSearchCandidate item) {
    final selection = state.selection;
    return libraryCatalogTargetForKind(item.mediaKind).resolve(
      item.catalogRef,
      LibraryCatalogTargetSelection(
        referenceType: selection.referenceType,
        firstId: selection.selectedReferenceEditionId,
        secondId: selection.selectedReferenceVariantId,
        groupId: selection.selectedBundleReleaseId,
      ),
    );
  }

  CatalogEntityRef _selectedTargetRef(CatalogSearchCandidate item) {
    final selection = state.selection;
    final resolved = libraryCatalogTargetForKind(item.mediaKind).resolve(
      item.catalogRef,
      LibraryCatalogTargetSelection(
        referenceType: selection.referenceType,
        firstId: selection.selectedReferenceEditionId,
        secondId: selection.selectedReferenceVariantId,
        groupId: selection.selectedBundleReleaseId,
      ),
    );
    if (resolved == item.catalogRef) {
      return libraryAddForKind(item.mediaKind).mediaTargetRef(item) ?? resolved;
    }
    return resolved;
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
        clearSelectedProviderCandidateId: true,
        clearSelectedBundleReleaseId: true,
        clearSelectedReferenceEditionId: true,
        clearSelectedReferenceVariantId: true,
        referenceType: LibraryAddReferenceType.media,
      ),
    );
    unawaited(_ensureSelectedResultLoaded(id));
    unawaited(_ensureBundleReleasesLoaded(id));
  }

  void selectProviderCandidate(String id) {
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedProviderCandidateId: id,
        clearSelectedResultId: true,
        clearSelectedBundleReleaseId: true,
        clearSelectedReferenceEditionId: true,
        clearSelectedReferenceVariantId: true,
        referenceType: LibraryAddReferenceType.media,
      ),
    );
    unawaited(_ensureProviderPreviewLoaded(id));
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

  void toggleCheckedProvider(String id) {
    final updated = Set<String>.from(state.selection.checkedProviderIds);
    if (!updated.remove(id)) {
      updated.add(id);
    }
    state = state.copyWith(
      selection: state.selection.copyWith(checkedProviderIds: updated),
    );
  }

  void setReferenceType(LibraryAddReferenceType value) {
    if (state.target == LibraryAddTarget.track) return;
    final bundles = state.preview.bundleReleasesForItem(state.selectedItem);
    String? firstBundleId;
    if (value == LibraryAddReferenceType.bundleRelease) {
      firstBundleId = state.selection.selectedBundleReleaseId ??
          (bundles.isNotEmpty ? bundles.first.id : null);
    }
    state = state.copyWith(
      selection: state.selection.copyWith(
        referenceType: value,
        selectedBundleReleaseId: firstBundleId,
        clearSelectedBundleReleaseId:
            value != LibraryAddReferenceType.bundleRelease,
        clearSelectedReferenceEditionId:
            value != LibraryAddReferenceType.edition,
        clearSelectedReferenceVariantId:
            value != LibraryAddReferenceType.edition,
      ),
    );
    if (value == LibraryAddReferenceType.bundleRelease &&
        firstBundleId != null) {
      unawaited(_ensureBundleReleaseDetailLoaded(firstBundleId));
    }
  }

  void selectReferenceEdition(String editionId) {
    final item = state.selectedItem;
    if (item == null) return;
    final releases = libraryPresentationForKind(item.mediaKind)
        .builder
        .buildReleaseOptions(item: item);
    final selectedRelease = previewReleaseForItem(releases, editionId);
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedReferenceEditionId: selectedRelease?.id,
        clearSelectedReferenceVariantId: true,
      ),
    );
  }

  void selectReferenceVariant(String variantId) {
    final normalized = variantId.trim().isEmpty ? null : variantId.trim();
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedReferenceVariantId: normalized,
        clearSelectedReferenceVariantId: normalized == null,
      ),
    );
  }

  void selectBundleRelease(String bundleReleaseId) {
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedBundleReleaseId: bundleReleaseId,
      ),
    );
    unawaited(_ensureBundleReleaseDetailLoaded(bundleReleaseId));
  }

  void setShowCoreResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(showCoreResults: value),
    );
  }

  void setShowProviderResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(showProviderResults: value),
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

      final query = (_searchCapability.coverScanQuery(result) ?? '').trim();
      final advancedFilters =
          Map<LibraryAddFilterId, Object?>.from(state.search.advancedFilters)
            ..addAll(_searchCapability.coverScanFilterValues(result));
      state = state.copyWith(
        mode: LibraryAddDialogMode.search,
        search: state.search.copyWith(
          query: query,
          advancedFilters: advancedFilters,
          showAdvancedSearch: result.showAdvancedFields,
          coverScanPrefill: result,
          results: const [],
          providerResults: const [],
          searchedProvider: false,
        ),
        selection: state.selection.copyWith(
          clearSelectedResultId: true,
          clearSelectedProviderCandidateId: true,
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

  Future<void> queueProviderIngest(
    ProviderSearchCandidate candidate, {
    required BuildContext context,
  }) async {
    if (api == null) return;
    if (state.preview.isQueueingIngest ||
        state.preview.queuedProviderIngests
            .containsKey(candidate.localCatalogId)) {
      return;
    }

    state = state.copyWith(
      preview: state.preview.copyWith(isQueueingIngest: true),
    );

    final previewController = LibraryAddPreviewController();
    for (final entry in state.preview.queuedProviderIngests.entries) {
      previewController.setQueuedProviderIngest(entry.key, entry.value);
    }

    await providerFlowService.queueProviderIngest(
      context: context,
      api: api!,
      candidate: candidate,
      providerActionService: providerActionService,
      mounted: true,
      isQueueingIngest: false,
      clearRejectedMetadataSession: _handleAuthExpiration,
      rebuild: (fn) {},
      setQueueingIngest: (val) {
        state = state.copyWith(
          preview: state.preview.copyWith(isQueueingIngest: val),
        );
      },
      onQueued: (ingest) {
        final updated = Map<String, LibraryQueuedProviderIngest>.from(
          state.preview.queuedProviderIngests,
        );
        updated[candidate.localCatalogId] = ingest;
        state = state.copyWith(
          preview: state.preview.copyWith(
            queuedProviderIngests: updated,
            isQueueingIngest: false,
          ),
        );
      },
      setError: (msg) {
        state = state.copyWith(
          search: state.search.copyWith(error: msg),
          preview: state.preview.copyWith(isQueueingIngest: false),
        );
      },
    );
  }

  @override
  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (api == null) return;
    CatalogSearchCandidate? selected;
    for (final item in state.search.results) {
      if (item.id == itemId) {
        selected = item;
        break;
      }
    }
    if (selected == null) return;
    final catalogRef = selected.catalogRef;
    if (state.preview.hasHydratedResult(catalogRef) ||
        state.preview.isHydratedResultPending(catalogRef)) {
      return;
    }

    final searchGen = state.search.coreSearchGeneration;
    final pending = Set<CatalogEntityRef>.from(
      state.preview.pendingHydratedResultRefs,
    )..add(catalogRef);
    state = state.copyWith(
      preview: state.preview.copyWith(pendingHydratedResultRefs: pending),
    );

    try {
      final CatalogSearchCandidate hydrated = await api!
          .getTypedMetadataItem(
        kind: selected.mediaKind,
        id: itemId,
      )
          .then<CatalogSearchCandidate>((dto) {
        final item = CatalogSearchCandidate.fromJson({
          ...dto.raw,
          'id': dto.id,
          'title': dto.title,
          'kind': dto.kind,
        });
        final merged =
            libraryPresentationForKind(type.kind).builder.mergeHydratedAddItem(
                  hydrated: item,
                  fallback: selected!,
                );
        return libraryAddForKind(type.kind).catalogCandidateFromCoreItem(
          merged,
        );
      });

      if (searchGen != state.search.coreSearchGeneration) return;

      final mergedItem =
          libraryPresentationForKind(type.kind).builder.mergeHydratedAddItem(
                hydrated: hydrated,
                fallback: selected,
              );

      final hydratedMap = Map<CatalogEntityRef, CatalogSearchCandidate>.from(
        state.preview.hydratedResultsByRef,
      );
      hydratedMap[catalogRef] = mergedItem;
      final pendingUpdated = Set<CatalogEntityRef>.from(
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
      final pendingUpdated = Set<CatalogEntityRef>.from(
        state.preview.pendingHydratedResultRefs,
      )..remove(catalogRef);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingHydratedResultRefs: pendingUpdated,
        ),
      );
    }
  }

  @override
  Future<void> _ensureBundleReleasesLoaded(String itemId) async {
    if (api == null) return;
    final selected =
        state.search.results.where((item) => item.id == itemId).firstOrNull;
    if (selected == null) return;
    final catalogRef = selected.catalogRef;
    if (state.preview.bundleReleasesByCatalogRef.containsKey(catalogRef) ||
        state.preview.isBundleReleasesPending(catalogRef)) {
      return;
    }

    final searchGen = state.search.coreSearchGeneration;
    final pending = Set<CatalogEntityRef>.from(
      state.preview.pendingBundleReleaseCatalogRefs,
    )..add(catalogRef);
    state = state.copyWith(
      preview: state.preview.copyWith(
        pendingBundleReleaseCatalogRefs: pending,
      ),
    );

    try {
      final bundleReleases = await api!.getItemBundleReleases(itemId);
      if (searchGen != state.search.coreSearchGeneration) return;

      final firstBundleId = state.selection.selectedBundleReleaseId ??
          (bundleReleases.isNotEmpty ? bundleReleases.first.id : null);
      final releasesMap =
          Map<CatalogEntityRef, List<LibraryBundleSummary>>.from(
        state.preview.bundleReleasesByCatalogRef,
      );
      releasesMap[catalogRef] = [
        for (final bundle in bundleReleases)
          LibraryBundleSummary.fromTransport(bundle),
      ];
      final pendingUpdated = Set<CatalogEntityRef>.from(
        state.preview.pendingBundleReleaseCatalogRefs,
      )..remove(catalogRef);

      state = state.copyWith(
        preview: state.preview.copyWith(
          bundleReleasesByCatalogRef: releasesMap,
          pendingBundleReleaseCatalogRefs: pendingUpdated,
        ),
        selection: state.selection.referenceType ==
                LibraryAddReferenceType.bundleRelease
            ? state.selection.copyWith(selectedBundleReleaseId: firstBundleId)
            : null,
      );

      if (state.selection.referenceType ==
              LibraryAddReferenceType.bundleRelease &&
          firstBundleId != null) {
        unawaited(_ensureBundleReleaseDetailLoaded(firstBundleId));
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle releases for $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      final pendingUpdated = Set<CatalogEntityRef>.from(
        state.preview.pendingBundleReleaseCatalogRefs,
      )..remove(catalogRef);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingBundleReleaseCatalogRefs: pendingUpdated,
        ),
      );
    }
  }

  Future<void> _ensureBundleReleaseDetailLoaded(String bundleReleaseId) async {
    if (api == null) return;
    if (state.preview.bundleReleaseDetailsById.containsKey(bundleReleaseId) ||
        state.preview.isBundleReleaseDetailPending(bundleReleaseId)) {
      return;
    }

    final searchGen = state.search.coreSearchGeneration;
    final pending =
        Set<String>.from(state.preview.pendingBundleReleaseDetailIds)
          ..add(bundleReleaseId);
    state = state.copyWith(
      preview: state.preview.copyWith(pendingBundleReleaseDetailIds: pending),
    );

    try {
      final bundleRelease = await api!.getBundleRelease(bundleReleaseId);
      if (searchGen != state.search.coreSearchGeneration) return;

      final detailsMap = Map<String, LibraryBundleDetail>.from(
        state.preview.bundleReleaseDetailsById,
      );
      detailsMap[bundleReleaseId] =
          LibraryBundleDetail.fromTransport(bundleRelease);
      final pendingUpdated =
          Set<String>.from(state.preview.pendingBundleReleaseDetailIds)
            ..remove(bundleReleaseId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          bundleReleaseDetailsById: detailsMap,
          pendingBundleReleaseDetailIds: pendingUpdated,
        ),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle release detail for $bundleReleaseId.',
        error: error,
        stackTrace: stackTrace,
      );
      final pendingUpdated =
          Set<String>.from(state.preview.pendingBundleReleaseDetailIds)
            ..remove(bundleReleaseId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingBundleReleaseDetailIds: pendingUpdated,
        ),
      );
    }
  }

  @override
  Future<void> _ensureProviderPreviewLoaded(String candidateId) async {
    if (state.preview.providerPreviewFor(candidateId) != null ||
        state.preview.isProviderPreviewPending(candidateId)) {
      return;
    }

    ProviderSearchCandidate? candidate;
    for (final value in state.search.providerResults) {
      if (value.localCatalogId == candidateId) {
        candidate = value;
        break;
      }
    }
    if (candidate == null || candidate.isStub) return;

    final searchGen = state.search.providerSearchGeneration;
    final pending = Set<String>.from(state.preview.pendingProviderPreviewIds)
      ..add(candidateId);
    state = state.copyWith(
      preview: state.preview.copyWith(pendingProviderPreviewIds: pending),
    );

    try {
      AdminProviderPreview? preview;
      ProviderSearchCandidate? hydratedCandidate;
      final adapter = providerRegistry?.get(candidate.provider);
      final typedLoader = _searchCapability.typedProviderCandidatePreviewLoader;
      if (adapter != null && typedLoader != null) {
        final loaded = await typedLoader(adapter, candidate);
        if (loaded != null) {
          hydratedCandidate = loaded.candidate;
          preview = loaded.preview;
        }
      }
      if (preview == null) {
        throw ProviderNotFoundException(
          provider: candidate.provider,
          message:
              'No preview available for ${candidate.provider}:${candidate.providerItemId}',
        );
      }

      if (searchGen != state.search.providerSearchGeneration) return;

      final previewsMap = Map<String, AdminProviderPreview>.from(
        state.preview.providerPreviews,
      );
      final typedCandidatesMap = Map<String, ProviderSearchCandidate>.from(
        state.preview.typedProviderCandidates,
      );
      previewsMap[candidateId] = preview;
      if (hydratedCandidate != null) {
        typedCandidatesMap[candidateId] = hydratedCandidate;
      }
      final groupCandidateForPreview = hydratedCandidate ?? candidate;
      final previewChildren = _searchCapability.filterProviderSearchResults(
        libraryPresentationForKind(candidate.kind)
            .builder
            .buildProviderGroupPreviewChildrenForSearchCandidate(
              groupCandidate: groupCandidateForPreview,
              preview: preview,
            ),
        _searchContext(),
      );
      final providerResults = List<ProviderSearchCandidate>.from(
        state.search.providerResults,
      );
      if (hydratedCandidate != null) {
        final index = providerResults.indexWhere(
          (value) => value.localCatalogId == candidateId,
        );
        if (index >= 0) {
          providerResults[index] = groupCandidateForPreview;
        }
      }
      final isGroupCandidate = libraryAddForKind(candidate.kind)
          .resultPolicy
          .isProviderGroupCandidate(candidate);
      if (_searchCapability.removeProviderGroupsWithoutVisibleChildren &&
          isGroupCandidate &&
          previewChildren.isEmpty) {
        providerResults.removeWhere(
          (value) => value.localCatalogId == candidateId,
        );
      }
      final providerResultIds =
          providerResults.map((value) => value.localCatalogId).toSet();
      for (final child in previewChildren) {
        if (providerResultIds.add(child.localCatalogId)) {
          providerResults.add(child);
        }
      }
      final pendingUpdated =
          Set<String>.from(state.preview.pendingProviderPreviewIds)
            ..remove(candidateId);
      state = state.copyWith(
        search: state.search.copyWith(providerResults: providerResults),
        preview: state.preview.copyWith(
          providerPreviews: previewsMap,
          typedProviderCandidates: typedCandidatesMap,
          pendingProviderPreviewIds: pendingUpdated,
        ),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message:
            'Failed to load provider preview for ${candidate.provider}:${candidate.providerItemId}.',
        error: error,
        stackTrace: stackTrace,
      );
      final pendingUpdated =
          Set<String>.from(state.preview.pendingProviderPreviewIds)
            ..remove(candidateId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingProviderPreviewIds: pendingUpdated,
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

  void setPhysicalFormatId(String? formatId) {
    state = state.copyWith(
      physicalFormatId: formatId,
      clearPhysicalFormatId: formatId == null,
    );
  }

  Future<bool> submitSelectedItem(CatalogSearchCandidate item) async {
    if (state.isAdding || state.submitState.isLoading) return false;
    state = state.copyWith(
      isAdding: true,
      submitState: const AsyncValue.loading(),
    );
    try {
      final capability = libraryAddForKind(kind);
      if (catalog != null) {
        await catalog!.upsertTransports([item.toImportTransport()]);
      }
      final command = capability.buildCommand(
        item,
        state.commonDraft,
        state.manualDraft,
        targetRef: _selectedTargetRef(item),
        tracking: state.trackingDraft,
      );

      switch (state.target) {
        case LibraryAddTarget.owned:
          await _addOwnedItemWithTracking(command);
        case LibraryAddTarget.wishlist:
          await wishlistMutations.addToWishlist(
            _selectedWishlistRef(item),
          );
        case LibraryAddTarget.track:
          await trackingMutations.addLocalOnlyTrackingState(
            item.catalogRef,
            targetRef: _selectedTargetRef(item),
          );
      }

      state = state.copyWith(
        isAdding: false,
        submitState: const AsyncValue.data(null),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(
        isAdding: false,
        submitState: AsyncValue.error(e, st),
      );
      return false;
    }
  }

  Future<void> _submitProviderCandidates({
    required List<ProviderSearchCandidate> candidates,
    required BuildContext? context,
    required bool isAdmin,
    required bool allowNavigation,
  }) async {
    if (candidates.isEmpty) return;

    final candidatesToSubmit =
        await _hydrateProviderCandidatesForSubmission(candidates);

    if (api != null && catalog != null && context != null && context.mounted) {
      final previewController = LibraryAddPreviewController();
      for (final entry in state.preview.providerPreviews.entries) {
        previewController.setProviderPreview(entry.key, entry.value);
      }
      for (final entry in state.preview.typedProviderCandidates.entries) {
        previewController.setTypedProviderCandidate(entry.key, entry.value);
      }
      final physicalFormats = physicalMediaFormatsForKind(
        fallbackMediaCatalog,
        kind,
      );
      final request = LibraryProviderAddRequest(
        api: api!,
        isAdmin: isAdmin,
        type: type,
        candidate: candidatesToSubmit.first,
        target: state.target,
        accent: LibraryAccentScope.accentOf(context),
        dependencies: LibraryProviderAddDependencies(
          catalog: catalog!,
          ownedMutations: ownedMutations,
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          physicalFormats: physicalFormats,
          previewState: previewController,
          providerActionService: providerActionService,
          providerOrchestrationService: providerOrchestrationService,
          providerMapper: _providerCorrectionsForKind(type.kind),
          visibleProviderResults: () => state.visibleProviderResults(
            libraryAddForKind(type.kind).resultPolicy,
          ),
          showEditDialog: (req) =>
              showLibraryEditDialog(context: context, request: req),
          closeEditDialog: () => Navigator.of(context).pop(),
          clearRejectedMetadataSession: _handleAuthExpiration,
        ),
        referenceType: state.selection.referenceType,
        defaults: LibraryAddDefaults(
          condition: state.defaultCondition,
          purchaseDate: state.defaultPurchaseDate,
          locationId: state.defaultLocationId,
          readStatus: state.defaultReadStatus,
          tags: state.defaultTags,
        ),
        allowNavigation: allowNavigation,
        reportError: (message) => state = state.copyWith(
          search: state.search.copyWith(error: message),
        ),
      );
      if (candidatesToSubmit.length == 1 && allowNavigation) {
        await providerAddCoordinator.addProviderCandidate(request);
      } else {
        await providerAddCoordinator.addProviderCandidates(
          request,
          candidatesToSubmit,
        );
      }
      return;
    }

    for (final candidate in candidatesToSubmit) {
      final metadataItem = libraryAddForKind(type.kind)
          .catalogCandidateFromProviderCandidate(candidate);

      if (catalog != null) {
        await catalog!.upsertTransports([metadataItem.toImportTransport()]);
      }

      final capability = libraryAddForKind(kind);
      final command = capability.buildCommand(
        metadataItem,
        state.commonDraft,
        state.manualDraft,
        targetRef: _selectedTargetRef(metadataItem),
        tracking: state.trackingDraft,
      );

      switch (state.target) {
        case LibraryAddTarget.owned:
          await _addOwnedItemWithTracking(command);
        case LibraryAddTarget.wishlist:
          await wishlistMutations.addToWishlist(
            _selectedWishlistRef(metadataItem),
          );
        case LibraryAddTarget.track:
          await trackingMutations.addLocalOnlyTrackingState(
            metadataItem.catalogRef,
            targetRef: _selectedTargetRef(metadataItem),
          );
      }
    }
  }

  Future<List<ProviderSearchCandidate>> _hydrateProviderCandidatesForSubmission(
    List<ProviderSearchCandidate> candidates,
  ) async {
    final loader =
        libraryAddForKind(kind).search.typedProviderCandidatePreviewLoader;
    if (loader == null || providerRegistry == null) return candidates;

    final prepared = <ProviderSearchCandidate>[];
    final hydratedCandidates = <String, ProviderSearchCandidate>{};
    final hydratedPreviews = <String, AdminProviderPreview>{};
    var didHydrate = false;

    for (final candidate in candidates) {
      final candidateId = candidate.localCatalogId;
      final effective =
          state.preview.typedProviderCandidateFor(candidateId) ?? candidate;
      final provider = providerRegistry!.get(effective.provider);
      if (provider == null) {
        prepared.add(effective);
        continue;
      }

      final loaded = await loader(provider, effective);
      if (loaded == null) {
        prepared.add(effective);
        continue;
      }

      prepared.add(loaded.candidate);
      hydratedCandidates[candidateId] = loaded.candidate;
      hydratedPreviews[candidateId] = loaded.preview;
      didHydrate = true;
    }

    if (didHydrate) {
      final typedCandidates = Map<String, ProviderSearchCandidate>.from(
        state.preview.typedProviderCandidates,
      )..addAll(hydratedCandidates);
      final previews = Map<String, AdminProviderPreview>.from(
        state.preview.providerPreviews,
      )..addAll(hydratedPreviews);
      state = state.copyWith(
        preview: state.preview.copyWith(
          typedProviderCandidates: typedCandidates,
          providerPreviews: previews,
        ),
      );
    }
    return List<ProviderSearchCandidate>.unmodifiable(prepared);
  }

  Future<void> _submitCoreCandidates(Set<String> checkedResultIds) async {
    if (catalog == null || checkedResultIds.isEmpty) return;

    final itemsToAdd = state.search.results
        .where((item) => checkedResultIds.contains(item.id))
        .toList(growable: false);
    if (itemsToAdd.isEmpty) return;

    await const LibraryAddCoordinator().add(
      LibraryAddBatchRequest(
        dependencies: LibraryAddMutationDependencies(
          catalog: catalog!,
          ownedMutations: ownedMutations,
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
        referenceType: state.selection.referenceType,
        defaults: LibraryAddDefaults(
          condition: state.defaultCondition,
          purchaseDate: state.defaultPurchaseDate,
          locationId: state.defaultLocationId,
          readStatus: state.defaultReadStatus,
          tags: state.defaultTags,
        ),
      ),
    );
  }

  Future<bool> submitCurrentSelection({
    BuildContext? context,
    bool isAdmin = false,
  }) async {
    if (state.isAdding || state.submitState.isLoading) return false;

    final selectedCandidate = state.selectedCandidate;
    final selectedResult = state.selectedItem;
    final checkedResults = state.selection.checkedResultIds;
    final checkedProviderCandidates = [
      for (final candidate in state.search.providerResults)
        if (state.selection.checkedProviderIds.contains(
              candidate.localCatalogId,
            ) &&
            !candidate.previewOnly)
          candidate,
    ];

    state = state.copyWith(
      isAdding: true,
      submitState: const AsyncValue.loading(),
    );

    try {
      var submittedBulkSelection = false;
      if (checkedProviderCandidates.isNotEmpty) {
        await _submitProviderCandidates(
          candidates: checkedProviderCandidates,
          context: context,
          isAdmin: isAdmin,
          allowNavigation: false,
        );
        submittedBulkSelection = true;
      }
      if (checkedResults.isNotEmpty) {
        await _submitCoreCandidates(checkedResults);
        submittedBulkSelection = true;
      }
      if (!submittedBulkSelection && selectedCandidate != null) {
        final selectedContext = context;
        if (selectedContext != null && !selectedContext.mounted) {
          state = state.copyWith(
            isAdding: false,
            submitState: const AsyncValue.data(null),
          );
          return false;
        }
        await _submitProviderCandidates(
          candidates: [selectedCandidate],
          context: selectedContext,
          isAdmin: isAdmin,
          allowNavigation: true,
        );
      } else if (!submittedBulkSelection && selectedResult != null) {
        final capability = libraryAddForKind(kind);
        final command = capability.buildCommand(
          selectedResult,
          state.commonDraft,
          state.manualDraft,
          targetRef: _selectedTargetRef(selectedResult),
          tracking: state.trackingDraft,
        );

        switch (state.target) {
          case LibraryAddTarget.owned:
            await _addOwnedItemWithTracking(command);
          case LibraryAddTarget.wishlist:
            await wishlistMutations.addToWishlist(
              _selectedWishlistRef(selectedResult),
            );
          case LibraryAddTarget.track:
            await trackingMutations.addLocalOnlyTrackingState(
              selectedResult.catalogRef,
              targetRef: _selectedTargetRef(selectedResult),
            );
        }
      }

      state = state.copyWith(
        isAdding: false,
        submitState: const AsyncValue.data(null),
      );
      return true;
    } catch (e, st) {
      state = state.copyWith(
        isAdding: false,
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
            isSearchingProvider: false,
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
      target: LibraryAddTarget.owned,
      search: LibraryAddSearchState.initial(
        selectedProvider: libraryMetadataForKind(type.kind)
                .defaultSupportedOption(type.kind)
                ?.id ??
            libraryMetadataForKind(type.kind).defaultProviderId,
        advancedFilters: _searchCapability.initialAdvancedFilters,
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

ProviderCorrectionPatch _emptyProviderCorrections({
  required CatalogSearchCandidate edited,
  required CatalogSearchCandidate preview,
}) =>
    const EmptyProviderCorrectionPatch();

BuildProviderCorrections _providerCorrectionsForKind(CatalogMediaKind kind) {
  final builder = libraryKindProviderCorrectionBuilderForKind(kind);
  if (builder == null) return _emptyProviderCorrections;
  return ({
    required CatalogSearchCandidate edited,
    required CatalogSearchCandidate preview,
  }) =>
      builder(
        preview: preview,
        edited: edited,
      );
}
