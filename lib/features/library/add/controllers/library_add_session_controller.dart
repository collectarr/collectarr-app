import 'dart:async';

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_state.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_preview_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_add_proposal_flow_service.dart';
import 'package:collectarr_app/features/library/add/services/library_add_provider_flow_service.dart';
import 'package:collectarr_app/features/library/add/services/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/services/library_add_workflow_service.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_orchestration_service.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryAddSessionController
    extends ValueNotifier<LibraryAddSessionState> {
  LibraryAddSessionController({
    required this.kind,
    LibraryTypeConfig? type,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    this.api,
    this.catalog,
    this.providerRegistry,
    this.coverScanService = const LocalLibraryCoverScanService(),
    this.workflowService = const LibraryAddWorkflowService(),
    this.providerActionService = const LibraryProviderActionService(),
    this.providerOrchestrationService =
        const LibraryProviderOrchestrationService(),
    this.providerFlowService = const LibraryAddProviderFlowService(),
    this.proposalFlowService = const LibraryAddProposalFlowService(),
    this.onAuthSessionExpired,
    LibraryAddSessionState? initialState,
  })  : _typeConfig = type,
        super(
          initialState ??
              LibraryAddSessionState(
                mode: LibraryAddDialogMode.search,
                target: LibraryAddTarget.owned,
                search: LibraryAddSearchState.initial(
                  selectedProvider:
                      (type ?? libraryKindRuntimeForKind(kind).type)
                          .defaultSupportedMetadataProvider,
                  videoKindFilters:
                      (type ?? libraryKindRuntimeForKind(kind).type)
                          .addChrome
                          .defaultVideoKindFilters
                          .map((k) => catalogMediaKindFromValue(k).apiValue)
                          .toSet(),
                ),
                selection: const LibraryAddSelectionState(),
                preview: const LibraryAddPreviewState.initial(),
                commonDraft: const LibraryAddCommonDraft(),
                manualDraft: defaultLibraryKindRegistry
                    .getByKind(kind)
                    .add
                    .createInitialDraft(),
                submitState: const AsyncValue.data(null),
              ),
        );

  final CatalogMediaKind kind;
  final LibraryTypeConfig? _typeConfig;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final ApiClient? api;
  final CatalogCacheRepository? catalog;
  final ProviderRegistry? providerRegistry;
  final LibraryCoverScanService coverScanService;
  final LibraryAddWorkflowService workflowService;
  final LibraryProviderActionService providerActionService;
  final LibraryProviderOrchestrationService providerOrchestrationService;
  final LibraryAddProviderFlowService providerFlowService;
  final LibraryAddProposalFlowService proposalFlowService;
  final Future<bool> Function(Object error, String action)?
      onAuthSessionExpired;

  LibraryTypeConfig get type =>
      _typeConfig ?? libraryKindRuntimeForKind(kind).type;

  Timer? _searchDebounceTimer;
  Timer? _autocompleteTimer;

  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _autocompleteDebounce = Duration(milliseconds: 350);
  static const _autocompleteLimit = 8;

  LibraryAddSessionState get state => value;
  set state(LibraryAddSessionState newState) => value = newState;

  void setMode(LibraryAddDialogMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setTarget(LibraryAddTarget target) {
    state = state.copyWith(target: target);
  }

  void updateQuery(String query) {
    state = state.copyWith(
      search: state.search.copyWith(query: query),
    );
    _onQueryChanged(query);
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    _autocompleteTimer?.cancel();
    if (query.length < 2) {
      if (state.search.showSuggestions) {
        state = state.copyWith(
          search: state.search.copyWith(
            suggestions: const [],
            showSuggestions: false,
          ),
        );
      }
    } else {
      _autocompleteTimer = Timer(_autocompleteDebounce, () {
        fetchSuggestions(query);
      });
    }

    _searchDebounceTimer?.cancel();
    if (query.isNotEmpty) {
      _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
        executeSearch();
      });
    }
  }

  void updateBarcode(String barcode) {
    state = state.copyWith(
      search: state.search.copyWith(barcode: barcode),
    );
  }

  void updateSearchSeries(String series) {
    state = state.copyWith(
      search: state.search.copyWith(series: series),
    );
  }

  void updateSearchNumber(String number) {
    state = state.copyWith(
      search: state.search.copyWith(number: number),
    );
  }

  void updateSearchPublisher(String publisher) {
    state = state.copyWith(
      search: state.search.copyWith(publisher: publisher),
    );
  }

  void updateSearchYear(String year) {
    state = state.copyWith(
      search: state.search.copyWith(year: year),
    );
  }

  void toggleAdvancedSearch() {
    state = state.copyWith(
      search: state.search.copyWith(
        showAdvancedSearch: !state.search.showAdvancedSearch,
      ),
    );
  }

  void setSelectedProvider(String provider) {
    state = state.copyWith(
      search: state.search.copyWith(selectedProvider: provider),
    );
  }

  void setVideoKindFilter(String kind, bool enabled) {
    final canonicalKind = catalogMediaKindFromValue(kind).apiValue;
    final currentFilters = Set<String>.from(state.search.videoKindFilters);
    if (enabled) {
      currentFilters.add(canonicalKind);
    } else {
      currentFilters.remove(canonicalKind);
    }
    state = state.copyWith(
      search: state.search.copyWith(videoKindFilters: currentFilters),
    );
  }

  Future<void> fetchSuggestions(String query) async {
    if (api == null || catalog == null) return;
    try {
      final filtered = await fetchLibraryAddSuggestions(
        api: api!,
        type: type,
        catalog: catalog!,
        query: query,
        limit: _autocompleteLimit,
      );
      state = state.copyWith(
        search: state.search.copyWith(
          suggestions: filtered,
          showSuggestions: filtered.isNotEmpty,
        ),
      );
    } catch (_) {
      // Autocomplete failures are non-fatal.
    }
  }

  void selectSuggestion(LibraryMetadataItem item) {
    state = state.copyWith(
      search: state.search.copyWith(
        query: item.title,
        showSuggestions: false,
        suggestions: const [],
        results: [item],
      ),
      selection: state.selection.copyWith(
        selectedResultId: item.id,
        clearSelectedProviderCandidateId: true,
      ),
    );
    _ensureSelectedResultLoaded(item.id);
    _ensureBundleReleasesLoaded(item.id);
  }

  void dismissSuggestions() {
    if (state.search.showSuggestions) {
      state = state.copyWith(
        search: state.search.copyWith(showSuggestions: false),
      );
    }
  }

  Future<void> executeSearch() async {
    final searchLabels = libraryMediaSearchFieldLabels(type);
    final query = state.search.query.trim();
    final series = state.search.series.trim();
    final number = state.search.number.trim();
    final publisher = state.search.publisher.trim();
    final yearText = state.search.year.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;

    if (query.isEmpty &&
        series.isEmpty &&
        number.isEmpty &&
        publisher.isEmpty &&
        yearText.isEmpty) {
      state = state.copyWith(
        search: state.search.copyWith(
          error: searchLabels.emptySearchMessage,
        ),
      );
      return;
    }

    final searchGeneration = state.search.coreSearchGeneration + 1;
    state = state.copyWith(
      search: state.search.copyWith(
        isSearching: true,
        clearError: true,
        coreSearchGeneration: searchGeneration,
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

    if (api == null || catalog == null) {
      state = state.copyWith(
        search: state.search.copyWith(isSearching: false),
      );
      return;
    }

    try {
      final searchResult = await runLibraryAddCoreSearch(
        api: api!,
        type: type,
        catalog: catalog!,
        input: LibraryMetadataSearchInput(
          query: query.isNotEmpty ? query : null,
          series: series.isNotEmpty ? series : null,
          issueNumber: number.isNotEmpty ? number : null,
          publisher: publisher.isNotEmpty ? publisher : null,
          year: year,
          limit: 20,
        ),
        timeout: _coreSearchTimeout,
        rerankHints: state.search.buildLocalRerankHints(),
        providerSearchAvailable: type.supportedMetadataProviders.isNotEmpty,
      );

      if (searchGeneration == state.search.coreSearchGeneration) {
        state = state.copyWith(
          search: state.search.copyWith(
            results: searchResult.items,
            isSearching: false,
          ),
        );
      }

      if (searchGeneration == state.search.coreSearchGeneration &&
          searchResult.shouldSearchProvider) {
        await searchProvider(
          queryOverride: query,
          bypassDebounce: true,
        );
      }
    } catch (error) {
      if (searchGeneration == state.search.coreSearchGeneration) {
        if (await _handleAuthExpiration(error, 'Core search')) {
          return;
        }
        state = state.copyWith(
          search: state.search.copyWith(
            isSearching: false,
            error:
                'Core search failed: ${ConnectionDiagnostics.metadataError(error, api!.baseUrl)} Manual add still works.',
          ),
        );
      }
    } finally {
      if (searchGeneration == state.search.coreSearchGeneration &&
          state.search.isSearching) {
        state = state.copyWith(
          search: state.search.copyWith(isSearching: false),
        );
      }
    }
  }

  String get _activeProvider {
    final providers = type.supportedMetadataProviders;
    for (final provider in providers) {
      if (provider.id == state.search.selectedProvider) {
        return provider.id;
      }
    }
    return type.defaultSupportedMetadataProvider;
  }

  String get _providerQuery {
    return buildLibraryAddProviderQuery([
      state.search.query,
      state.search.series,
      state.search.number,
      state.search.publisher,
      state.search.year,
      state.search.barcode,
    ]);
  }

  Future<void> searchProvider({
    String? queryOverride,
    bool bypassDebounce = false,
  }) async {
    final query = queryOverride?.trim().isNotEmpty == true
        ? queryOverride!.trim()
        : _providerQuery;
    if (query.isEmpty) {
      state = state.copyWith(
        search: state.search.copyWith(
          error: 'Enter a title, barcode, or keyword.',
        ),
      );
      return;
    }

    final provider = _activeProvider;
    final searchGeneration = state.search.providerSearchGeneration + 1;
    final debounceDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: provider,
      query: query,
      debounce: _providerSearchDebounce,
      now: DateTime.now(),
      previousSignature: state.search.lastProviderSearchSignature,
      previousAt: state.search.lastProviderSearchAt,
    );

    if (state.search.isSearchingProvider ||
        (!bypassDebounce && debounceDecision.shouldSkip)) {
      return;
    }

    state = state.copyWith(
      search: state.search.copyWith(
        isSearchingProvider: true,
        searchedProvider: true,
        providerResults: const [],
        clearError: true,
        providerSearchGeneration: searchGeneration,
        lastProviderSearchSignature: debounceDecision.signature,
        lastProviderSearchAt: debounceDecision.at,
      ),
      selection: state.selection.copyWith(
        clearSelectedProviderCandidateId: true,
      ),
    );

    if (api == null) {
      state = state.copyWith(
        search: state.search.copyWith(isSearchingProvider: false),
      );
      return;
    }

    try {
      final isVideoKind = type.addChrome.videoKindFilterOptions.isNotEmpty;
      final kindsToSearch = isVideoKind
          ? (state.search.videoKindFilters.isEmpty
              ? (type.addChrome.videoKindFilterOptions
                  .map((o) => catalogMediaKindFromValue(o.kind).apiValue)
                  .toSet()
                  .toList())
              : state.search.videoKindFilters
                  .map((k) => catalogMediaKindFromValue(k).apiValue)
                  .toSet()
                  .toList())
          : <String>[];

      final seriesText = state.search.series.trim().isNotEmpty
          ? state.search.series.trim()
          : null;
      final issueText = state.search.number.trim().isNotEmpty
          ? state.search.number.trim()
          : null;
      final yearValue = state.search.year.trim().isNotEmpty
          ? int.tryParse(state.search.year.trim())
          : null;
      final rerankHints = state.search.buildLocalRerankHints();

      List<ProviderCandidate> results;
      if (kindsToSearch.length > 1) {
        final futures =
            kindsToSearch.map<Future<List<ProviderCandidate>>>((k) async {
          try {
            return await runLibraryAddProviderSearch(
              api: api,
              type: type,
              provider: provider,
              query: query,
              rerankHints: rerankHints,
              providerRegistry: providerRegistry,
              series: seriesText,
              issueNumber: issueText,
              year: yearValue,
              kindOverride: k,
            );
          } catch (_) {
            return <ProviderCandidate>[];
          }
        });
        final allResults = await Future.wait(futures);
        results =
            allResults.expand((r) => r).cast<ProviderCandidate>().toList();
      } else if (kindsToSearch.length == 1) {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          providerRegistry: providerRegistry,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
          kindOverride: kindsToSearch.first,
        );
      } else {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          providerRegistry: providerRegistry,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
        );
      }

      if (searchGeneration == state.search.providerSearchGeneration) {
        state = state.copyWith(
          search: state.search.copyWith(
            providerResults: results,
            isSearchingProvider: false,
          ),
        );
      }
    } catch (error) {
      if (searchGeneration == state.search.providerSearchGeneration) {
        if (_isMissingBearerTokenError(error)) {
          state = state.copyWith(
            search: state.search.copyWith(
              isSearchingProvider: false,
              clearError: true,
            ),
          );
          return;
        }
        if (await _handleAuthExpiration(error, 'Provider search')) {
          return;
        }
        state = state.copyWith(
          search: state.search.copyWith(
            isSearchingProvider: false,
            error:
                'Provider search failed: ${ConnectionDiagnostics.metadataError(error, api!.baseUrl)}',
          ),
        );
      }
    } finally {
      if (searchGeneration == state.search.providerSearchGeneration &&
          state.search.isSearchingProvider) {
        state = state.copyWith(
          search: state.search.copyWith(isSearchingProvider: false),
        );
      }
    }
  }

  void cancelSearch() {
    _searchDebounceTimer?.cancel();
    _autocompleteTimer?.cancel();
    state = state.copyWith(
      search: state.search.copyWith(
        isSearching: false,
        isSearchingProvider: false,
        isScanningCover: false,
      ),
    );
  }

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
    final selectedEdition = previewEditionForItem(item, editionId);
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedReferenceEditionId: selectedEdition?.id,
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

  void setShowMediaResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(showMediaResults: value),
    );
  }

  void setShowSeasonResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(showSeasonResults: value),
    );
  }

  void setShowReleaseResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(showReleaseResults: value),
    );
  }

  void setHideComicOwnedResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(hideComicOwnedResults: value),
    );
  }

  void setHideComicVariantResults(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(hideComicVariantResults: value),
    );
  }

  void setCompactComicIssues(bool value) {
    state = state.copyWith(
      selection: state.selection.copyWith(compactComicIssues: value),
    );
  }

  Future<void> lookupBarcode({String? barcode}) async {
    final code = barcode?.trim().isNotEmpty == true
        ? barcode!.trim()
        : state.search.barcode.trim();
    if (code.isEmpty) {
      state = state.copyWith(
        search: state.search.copyWith(
          error: 'Enter a barcode / UPC / ISBN.',
        ),
      );
      return;
    }

    final searchGeneration = state.search.coreSearchGeneration + 1;
    state = state.copyWith(
      mode: LibraryAddDialogMode.barcode,
      search: state.search.copyWith(
        barcode: code,
        isSearching: true,
        clearError: true,
        coreSearchGeneration: searchGeneration,
        providerResults: const [],
        searchedProvider: false,
      ),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
        clearSelectedProviderCandidateId: true,
      ),
      preview: const LibraryAddPreviewState.initial(),
    );

    if (api == null || catalog == null) {
      state = state.copyWith(
        search: state.search.copyWith(isSearching: false),
      );
      return;
    }

    try {
      final lookupResult = await runLibraryAddBarcodeLookup(
        api: api!,
        type: type,
        catalog: catalog!,
        barcode: code,
        timeout: _coreSearchTimeout,
        providerSearchAvailable: type.supportedMetadataProviders.isNotEmpty,
      );

      if (searchGeneration == state.search.coreSearchGeneration) {
        state = state.copyWith(
          search: state.search.copyWith(
            results: lookupResult.items,
            isSearching: false,
            error: lookupResult.items.isEmpty &&
                    type.supportedMetadataProviders.isEmpty
                ? 'No item found for barcode $code.'
                : null,
          ),
        );
        if (lookupResult.items.isNotEmpty) {
          selectResult(lookupResult.items.first.id);
        }
      }

      if (searchGeneration == state.search.coreSearchGeneration &&
          lookupResult.shouldSearchProvider) {
        await searchProvider(queryOverride: code);
      }
    } catch (error) {
      if (searchGeneration == state.search.coreSearchGeneration) {
        if (await _handleAuthExpiration(error, 'Barcode lookup')) {
          return;
        }
        state = state.copyWith(
          search: state.search.copyWith(
            isSearching: false,
            error:
                'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api!.baseUrl)} Manual add keeps the scanned code.',
          ),
        );
      }
    } finally {
      if (searchGeneration == state.search.coreSearchGeneration &&
          state.search.isSearching) {
        state = state.copyWith(
          search: state.search.copyWith(isSearching: false),
        );
      }
    }
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

      final query = (result.query ?? result.series ?? '').trim();
      state = state.copyWith(
        mode: LibraryAddDialogMode.search,
        search: state.search.copyWith(
          query: query,
          series: result.series?.trim() ?? '',
          number: result.issueNumber?.trim() ?? '',
          publisher: result.publisher?.trim() ?? '',
          year: result.year?.toString() ?? '',
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
    ProviderCandidate candidate, {
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

  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (api == null) return;
    if (state.preview.hasHydratedResult(itemId) ||
        state.preview.isHydratedResultPending(itemId)) {
      return;
    }

    LibraryMetadataItem? selected;
    for (final item in state.search.results) {
      if (item.id == itemId) {
        selected = item;
        break;
      }
    }
    if (selected == null) return;

    final searchGen = state.search.coreSearchGeneration;
    final pending = Set<String>.from(state.preview.pendingHydratedResultIds)
      ..add(itemId);
    state = state.copyWith(
      preview: state.preview.copyWith(pendingHydratedResultIds: pending),
    );

    try {
      final hydrated = await api!
          .getTypedMetadataItem(
        kind: selected.kind,
        id: itemId,
      )
          .then((dto) {
        final raw = mergeHydratedProviderAddResultRaw(
          raw: <String, dynamic>{
            ...dto.raw,
            'id': dto.id,
            'title': dto.title,
            'kind': dto.kind,
          },
          sourceSelection: selected!,
        );
        return CatalogItem.fromJson(raw);
      });

      if (searchGen != state.search.coreSearchGeneration) return;

      final hydratedItem = LibraryMetadataItem.fromCatalogItem(hydrated);
      final mergedCommon = hydratedItem.common.copyWith(
        coverImageUrl: hydratedItem.displayCoverUrl != null
            ? hydratedItem.coverImageUrl
            : selected.coverImageUrl,
        thumbnailImageUrl: hydratedItem.displayCoverUrl != null
            ? hydratedItem.thumbnailImageUrl
            : selected.thumbnailImageUrl ?? selected.coverImageUrl,
      );
      final hydratedPayload = hydratedItem.kindMetadata.toSyncPayload();
      final hydratedEditionsPayload = hydratedPayload['editions'] as List?;
      final selectedEditionsPayload =
          selected.kindMetadata.toSyncPayload()['editions'] as List?;
      final mergedPayload = {
        ...hydratedPayload,
        if ((hydratedEditionsPayload == null ||
                hydratedEditionsPayload.isEmpty) &&
            selectedEditionsPayload != null &&
            selectedEditionsPayload.isNotEmpty)
          'editions': selectedEditionsPayload,
      };
      final mergedItem = LibraryMetadataItem(
        identity: hydratedItem.identity,
        common: mergedCommon,
        kindMetadata: LibraryKindMetadataDecoders.decode(
          hydratedItem.mediaKind,
          mergedPayload,
        ),
      );

      final hydratedMap =
          Map<String, LibraryMetadataItem>.from(state.preview.hydratedResults);
      hydratedMap[itemId] = mergedItem;
      final pendingUpdated =
          Set<String>.from(state.preview.pendingHydratedResultIds)
            ..remove(itemId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          hydratedResults: hydratedMap,
          pendingHydratedResultIds: pendingUpdated,
        ),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to hydrate add-result metadata for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      final pendingUpdated =
          Set<String>.from(state.preview.pendingHydratedResultIds)
            ..remove(itemId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingHydratedResultIds: pendingUpdated,
        ),
      );
    }
  }

  Future<void> _ensureBundleReleasesLoaded(String itemId) async {
    if (api == null) return;
    if (state.preview.bundleReleasesByItemId.containsKey(itemId) ||
        state.preview.isBundleReleasesPending(itemId)) {
      return;
    }

    final searchGen = state.search.coreSearchGeneration;
    final pending = Set<String>.from(state.preview.pendingBundleReleaseItemIds)
      ..add(itemId);
    state = state.copyWith(
      preview: state.preview.copyWith(pendingBundleReleaseItemIds: pending),
    );

    try {
      final bundleReleases = await api!.getItemBundleReleases(itemId);
      if (searchGen != state.search.coreSearchGeneration) return;

      final firstBundleId = state.selection.selectedBundleReleaseId ??
          (bundleReleases.isNotEmpty ? bundleReleases.first.id : null);
      final releasesMap = Map<String, List<BundleReleaseSummary>>.from(
        state.preview.bundleReleasesByItemId,
      );
      releasesMap[itemId] = List.unmodifiable(bundleReleases);
      final pendingUpdated =
          Set<String>.from(state.preview.pendingBundleReleaseItemIds)
            ..remove(itemId);

      state = state.copyWith(
        preview: state.preview.copyWith(
          bundleReleasesByItemId: releasesMap,
          pendingBundleReleaseItemIds: pendingUpdated,
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
      final pendingUpdated =
          Set<String>.from(state.preview.pendingBundleReleaseItemIds)
            ..remove(itemId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          pendingBundleReleaseItemIds: pendingUpdated,
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

      final detailsMap = Map<String, BundleReleaseDetail>.from(
        state.preview.bundleReleaseDetailsById,
      );
      detailsMap[bundleReleaseId] = bundleRelease;
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

  Future<void> _ensureProviderPreviewLoaded(String candidateId) async {
    if (state.preview.providerPreviewFor(candidateId) != null ||
        state.preview.isProviderPreviewPending(candidateId)) {
      return;
    }

    ProviderCandidate? candidate;
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
      final adapter = providerRegistry?.get(candidate.provider);
      if (adapter != null) {
        final envelope = await adapter.fetchItem(
          candidate.providerItemId,
          kind: candidate.kind,
        );
        preview = providerPreviewFromEnvelope(envelope);
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
      previewsMap[candidateId] = preview;
      final pendingUpdated =
          Set<String>.from(state.preview.pendingProviderPreviewIds)
            ..remove(candidateId);
      state = state.copyWith(
        preview: state.preview.copyWith(
          providerPreviews: previewsMap,
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

  void updateKindDraft(
      LibraryAddKindDraft Function(LibraryAddKindDraft) update) {
    state = state.copyWith(manualDraft: update(state.manualDraft));
  }

  void setDefaultCondition(String condition) {
    state = state.copyWith(defaultCondition: condition);
  }

  void setDefaultGrade(String grade) {
    state = state.copyWith(defaultGrade: grade);
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

  Future<bool> submitSelectedItem(CatalogItem item) async {
    if (state.isAdding || state.submitState.isLoading) return false;
    state = state.copyWith(
      isAdding: true,
      submitState: const AsyncValue.loading(),
    );
    try {
      final capability = libraryKindRuntimeForKind(kind).add;
      final command = capability.buildCommand(
        item,
        state.commonDraft,
        state.manualDraft,
      );

      switch (state.target) {
        case LibraryAddTarget.owned:
          await ownedMutations.addOwnedItem(command);
        case LibraryAddTarget.wishlist:
          await wishlistMutations.addToWishlist(
            item.id,
            fallbackKind: item.kind,
          );
        case LibraryAddTarget.track:
          await trackingMutations.addLocalOnlyTrackingEntry(item);
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

  Future<bool> submitCurrentSelection({
    BuildContext? context,
    bool isAdmin = false,
  }) async {
    if (state.isAdding || state.submitState.isLoading) return false;

    final selectedCandidate = state.selectedCandidate;
    final selectedResult = state.selectedItem;
    final checkedResults = state.selection.checkedResultIds;

    state = state.copyWith(
      isAdding: true,
      submitState: const AsyncValue.loading(),
    );

    try {
      if (selectedCandidate != null) {
        if (api != null && catalog != null && context != null) {
          final previewController = LibraryAddPreviewController();
          for (final entry in state.preview.providerPreviews.entries) {
            previewController.setProviderPreview(entry.key, entry.value);
          }
          final physicalFormats = physicalMediaFormatsForKind(
            fallbackMediaCatalog,
            kind,
          );

          await workflowService.addProviderCandidate(
            context: context,
            api: api!,
            isAdmin: isAdmin,
            type: type,
            candidate: selectedCandidate,
            target: state.target,
            mounted: true,
            isAdding: false,
            rebuild: (_) {},
            setIsAdding: (_) {},
            setError: (msg) => state =
                state.copyWith(search: state.search.copyWith(error: msg)),
            onSuccess: (_) {},
            isMissingBearerTokenError: _isMissingBearerTokenError,
            catalog: catalog!,
            ownedMutations: ownedMutations,
            wishlistMutations: wishlistMutations,
            trackingMutations: trackingMutations,
            physicalFormats: physicalFormats,
            previewState: previewController,
            providerActionService: providerActionService,
            providerOrchestrationService: providerOrchestrationService,
            providerMapper:
                (libraryKindProviderMapperForType(type))?.buildCorrections ??
                    ((
                            {required LibraryMetadataItem edited,
                            required LibraryMetadataItem preview}) =>
                        const <String, Object?>{}),
            visibleProviderResults: () => state.visibleProviderResults(type),
            showEditDialog: (ctx, req) =>
                showLibraryEditDialog(context: ctx, request: req),
            clearRejectedMetadataSession: _handleAuthExpiration,
            referenceType: state.selection.referenceType,
            defaults: LibraryAddDefaults(
              condition: state.defaultCondition,
              grade: state.defaultGrade,
              purchaseDate: state.defaultPurchaseDate,
              locationId: state.defaultLocationId,
              readStatus: state.defaultReadStatus,
              tags: state.defaultTags,
            ),
          );
        } else {
          // Local-only add without Core ingest using deterministic provisional provider identity
          final preview = state.preview
              .providerPreviewFor(selectedCandidate.localCatalogId);
          final catalogItem = CatalogItem(
            id: selectedCandidate.localCatalogId,
            kind: selectedCandidate.kind,
            title: preview?.title ?? selectedCandidate.title,
            synopsis: preview?.synopsis ?? selectedCandidate.summary,
            coverImageUrl: preview?.coverImageUrl ?? selectedCandidate.imageUrl,
            thumbnailImageUrl:
                preview?.coverImageUrl ?? selectedCandidate.imageUrl,
            publisher: preview?.publisher ?? selectedCandidate.publisher,
            releaseYear: preview?.releaseDate?.year ??
                selectedCandidate.series?.volumeStartYear,
            series: preview?.series ?? selectedCandidate.series,
            publishing: preview?.publishing,
            game: preview?.game,
            music: preview?.music,
            video: preview?.video,
          );

          if (catalog != null) {
            await catalog!.upsertAll([catalogItem]);
          }

          final capability = libraryKindRuntimeForKind(kind).add;
          final command = capability.buildCommand(
            catalogItem,
            state.commonDraft,
            state.manualDraft,
          );

          switch (state.target) {
            case LibraryAddTarget.owned:
              await ownedMutations.addOwnedItem(command);
            case LibraryAddTarget.wishlist:
              await wishlistMutations.addToWishlist(
                catalogItem.id,
                fallbackKind: catalogItem.kind,
              );
            case LibraryAddTarget.track:
              await trackingMutations.addLocalOnlyTrackingEntry(catalogItem);
          }
        }
      } else if (checkedResults.isNotEmpty) {
        final itemsToAdd = state.search.results
            .where((item) => checkedResults.contains(item.id))
            .toList();
        if (catalog != null) {
          await workflowService.addItems(
            mounted: true,
            isAdding: false,
            rebuild: (_) {},
            setIsAdding: (_) {},
            setError: (msg) => state =
                state.copyWith(search: state.search.copyWith(error: msg)),
            onSuccess: (_) {},
            catalog: catalog!,
            ownedMutations: ownedMutations,
            wishlistMutations: wishlistMutations,
            trackingMutations: trackingMutations,
            items: itemsToAdd,
            target: state.target,
            referenceType: state.selection.referenceType,
            defaults: LibraryAddDefaults(
              condition: state.defaultCondition,
              grade: state.defaultGrade,
              purchaseDate: state.defaultPurchaseDate,
              locationId: state.defaultLocationId,
              readStatus: state.defaultReadStatus,
              tags: state.defaultTags,
            ),
          );
        }
      } else if (selectedResult != null) {
        final item = CatalogItem(
          id: selectedResult.id,
          kind: selectedResult.kind,
          title: selectedResult.title,
        );
        final capability = libraryKindRuntimeForKind(kind).add;
        final command = capability.buildCommand(
          item,
          state.commonDraft,
          state.manualDraft,
        );

        switch (state.target) {
          case LibraryAddTarget.owned:
            await ownedMutations.addOwnedItem(command);
          case LibraryAddTarget.wishlist:
            await wishlistMutations.addToWishlist(
              item.id,
              fallbackKind: item.kind,
            );
          case LibraryAddTarget.track:
            await trackingMutations.addLocalOnlyTrackingEntry(item);
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

  bool _isMissingBearerTokenError(Object error) {
    if (error is! DioException) return false;
    if (error.response?.statusCode != 401) return false;
    final data = error.response?.data;
    if (data is! Map) return false;
    return data['code']?.toString().trim() == 'missing_bearer_token';
  }

  void retry() {
    state = state.copyWith(submitState: const AsyncValue.data(null));
    executeSearch();
  }

  void reset() {
    _searchDebounceTimer?.cancel();
    _autocompleteTimer?.cancel();
    state = LibraryAddSessionState(
      mode: LibraryAddDialogMode.search,
      target: LibraryAddTarget.owned,
      search: LibraryAddSearchState.initial(
        selectedProvider: type.defaultSupportedMetadataProvider,
        videoKindFilters: type.addChrome.defaultVideoKindFilters
            .map((k) => catalogMediaKindFromValue(k).apiValue)
            .toSet(),
      ),
      selection: const LibraryAddSelectionState(),
      preview: const LibraryAddPreviewState.initial(),
      commonDraft: const LibraryAddCommonDraft(),
      manualDraft: libraryKindRuntimeForKind(kind).add.createInitialDraft(),
      submitState: const AsyncValue.data(null),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _autocompleteTimer?.cancel();
    super.dispose();
  }
}
