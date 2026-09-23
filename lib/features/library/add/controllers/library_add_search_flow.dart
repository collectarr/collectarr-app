part of 'library_add_session_controller.dart';

mixin _LibraryAddSearchFlow on ValueNotifier<LibraryAddSessionState> {
  LibraryAddSessionState get state;
  set state(LibraryAddSessionState value);
  CatalogMediaKind get kind;
  LibraryKindRegistration get type;
  ApiClient? get api;
  CatalogTransportRepository? get catalog;
  ProviderConnectorRegistry? get providerRegistry;
  LibraryAddSearchCapability get _searchCapability;
  LibraryAddSearchContext _searchContext({String? query});
  Future<bool> _handleAuthExpiration(Object error, String action);
  void selectResult(String id);
  Future<void> _ensureSelectedResultLoaded(String itemId);
  Future<void> _ensureBundleReleasesLoaded(String itemId);
  Future<void> _ensureProviderPreviewLoaded(String candidateId);
  Timer? _searchDebounceTimer;
  Timer? _autocompleteTimer;
  CancelToken? _coreSearchCancelToken;
  CancelToken? _suggestionsCancelToken;
  int _suggestionsGeneration = 0;
  ProviderCancellationToken? _providerSearchCancellationToken;

  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _autocompleteDebounce = Duration(milliseconds: 350);
  static const _autocompleteLimit = 8;
  void updateQuery(String query) {
    _suggestionsGeneration++;
    _suggestionsCancelToken?.cancel('Autocomplete query changed');
    _suggestionsCancelToken = null;
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

  void updateIdentifier(String identifierCode) {
    state = state.copyWith(
      search: state.search.copyWith(identifierCode: identifierCode),
    );
  }

  void updateAdvancedFilter(
      LibraryAddFilterId id, LibraryAddFilterValue? value) {
    final filters = Map<LibraryAddFilterId, LibraryAddFilterValue>.from(
      state.search.advancedFilters,
    );
    if (value == null) {
      filters.remove(id);
    } else {
      filters[id] = value;
    }
    state = state.copyWith(
      search: state.search.copyWith(advancedFilters: filters),
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

  Future<void> fetchSuggestions(String query) async {
    if (api == null || catalog == null) return;
    _suggestionsCancelToken?.cancel('Superseded by a newer autocomplete');
    final generation = ++_suggestionsGeneration;
    final cancelToken = CancelToken();
    _suggestionsCancelToken = cancelToken;
    try {
      final searchContext = _searchContext(query: query);
      final filtered = await fetchLibraryAddSuggestions(
        api: api!,
        type: type,
        catalog: catalog!,
        input: _searchCapability.coreSearchInputBuilder(
          searchContext,
          limit: _autocompleteLimit,
        ),
        ranking: _searchCapability.ranking,
        searchContext: searchContext,
        cancelToken: cancelToken,
      );
      if (generation != _suggestionsGeneration) return;
      state = state.copyWith(
        search: state.search.copyWith(
          suggestions: filtered,
          showSuggestions: filtered.isNotEmpty,
        ),
      );
    } catch (_) {
      // Autocomplete failures are non-fatal.
    } finally {
      if (identical(_suggestionsCancelToken, cancelToken)) {
        _suggestionsCancelToken = null;
      }
    }
  }

  void selectSuggestion(CatalogSearchCandidate item) {
    state = state.copyWith(
      search: state.search.copyWith(
        query: item.primaryLabel,
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
    _suggestionsGeneration++;
    _suggestionsCancelToken?.cancel('Autocomplete superseded by search');
    _suggestionsCancelToken = null;
    _coreSearchCancelToken?.cancel('Superseded by a newer search');
    _providerSearchCancellationToken?.cancel();
    _coreSearchCancelToken = null;
    _providerSearchCancellationToken = null;
    state = state.copyWith(
      search: state.search.copyWith(
        coreSearchGeneration: state.search.coreSearchGeneration + 1,
        providerSearchGeneration: state.search.providerSearchGeneration + 1,
        isSearching: false,
        isSearchingProvider: false,
      ),
    );
    final searchContext = _searchContext();
    if (!_searchCapability.hasSearchInput(searchContext)) {
      state = state.copyWith(
        search: state.search.copyWith(
          error: libraryPresentationForKind(type.kind)
              .searchFieldLabels
              .emptySearchMessage,
        ),
      );
      return;
    }

    final searchGeneration = state.search.coreSearchGeneration + 1;
    final cancelToken = CancelToken();
    _coreSearchCancelToken = cancelToken;
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
      if (identical(_coreSearchCancelToken, cancelToken)) {
        _coreSearchCancelToken = null;
      }
      state = state.copyWith(
        search: state.search.copyWith(isSearching: false),
      );
      if (libraryMetadataForKind(type.kind)
          .supportedProvidersForKind(type.kind)
          .isNotEmpty) {
        await searchProvider(
          queryOverride: searchContext.query,
          bypassDebounce: true,
        );
      }
      return;
    }

    try {
      final searchResult = await runLibraryAddCoreSearch(
        api: api!,
        type: type,
        catalog: catalog!,
        input: _searchCapability.coreSearchInputBuilder(
          searchContext,
          limit: 20,
        ),
        timeout: _coreSearchTimeout,
        ranking: _searchCapability.ranking,
        searchContext: searchContext,
        providerSearchAvailable: libraryMetadataForKind(type.kind)
            .supportedProvidersForKind(type.kind)
            .isNotEmpty,
        cancelToken: cancelToken,
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
          queryOverride: searchContext.query,
          bypassDebounce: true,
        );
      }
    } catch (error) {
      if (searchGeneration == state.search.coreSearchGeneration) {
        if (await _handleAuthExpiration(error, 'Core search')) {
          return;
        }
        final canFallbackToProvider = libraryMetadataForKind(type.kind)
            .supportedProvidersForKind(type.kind)
            .isNotEmpty;
        state = state.copyWith(
          search: state.search.copyWith(
            isSearching: false,
            error: canFallbackToProvider
                ? null
                : 'Core search failed: ${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')} Manual add still works.',
          ),
        );

        if (canFallbackToProvider) {
          await searchProvider(
            queryOverride: searchContext.query,
            bypassDebounce: true,
          );
        }
      }
    } finally {
      if (identical(_coreSearchCancelToken, cancelToken)) {
        _coreSearchCancelToken = null;
      }
      if (searchGeneration == state.search.coreSearchGeneration &&
          state.search.isSearching) {
        state = state.copyWith(
          search: state.search.copyWith(isSearching: false),
        );
      }
    }
  }

  String get _activeProvider {
    final providers =
        libraryMetadataForKind(type.kind).supportedProvidersForKind(type.kind);
    for (final provider in providers) {
      if (provider.id == state.search.selectedProvider) {
        return provider.id;
      }
    }
    return libraryMetadataForKind(type.kind)
            .defaultSupportedOption(type.kind)
            ?.id ??
        libraryMetadataForKind(type.kind).defaultProviderId;
  }

  Future<void> searchProvider({
    String? queryOverride,
    bool bypassDebounce = false,
  }) async {
    final searchContext = _searchContext(query: queryOverride);
    final query = _searchCapability.providerQueryBuilder(searchContext);
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
    _providerSearchCancellationToken?.cancel();
    final cancellationToken = ProviderCancellationToken();
    _providerSearchCancellationToken = cancellationToken;

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

    if (api == null && providerRegistry == null) {
      state = state.copyWith(
        search: state.search.copyWith(isSearchingProvider: false),
      );
      return;
    }

    try {
      final kindsToSearch =
          _searchCapability.providerKindOverrides(searchContext).toList();

      List<ProviderSearchCandidate> results;
      final failures = <LibraryAddProviderSearchFailure>[];
      if (kindsToSearch.length > 1) {
        final outcomes = await Future.wait(
          kindsToSearch.map((k) => runLibraryAddProviderSearch(
                api: api,
                type: type,
                provider: provider,
                query: query,
                ranking: _searchCapability.ranking,
                searchContext: searchContext,
                providerRegistry: providerRegistry,
                kindOverride: k,
                cancellationToken: cancellationToken,
              )),
        );
        results = outcomes.expand((outcome) => outcome.candidates).toList();
        failures.addAll(outcomes.expand((outcome) => outcome.failures));
      } else if (kindsToSearch.length == 1) {
        final outcome = await runLibraryAddProviderSearch(
          api: api,
          type: type,
          provider: provider,
          query: query,
          ranking: _searchCapability.ranking,
          searchContext: searchContext,
          providerRegistry: providerRegistry,
          kindOverride: kindsToSearch.first,
          cancellationToken: cancellationToken,
        );
        results = outcome.candidates;
        failures.addAll(outcome.failures);
      } else {
        final outcome = await runLibraryAddProviderSearch(
          api: api,
          type: type,
          provider: provider,
          query: query,
          ranking: _searchCapability.ranking,
          searchContext: searchContext,
          providerRegistry: providerRegistry,
          cancellationToken: cancellationToken,
        );
        results = outcome.candidates;
        failures.addAll(outcome.failures);
      }

      if (searchGeneration == state.search.providerSearchGeneration) {
        final failedSources = failures.map((failure) => failure.source).toSet();
        state = state.copyWith(
          search: state.search.copyWith(
            providerResults: results,
            isSearchingProvider: false,
            error: failures.isEmpty
                ? null
                : results.isEmpty
                    ? 'Provider search failed for: ${failedSources.join(', ')}.'
                    : 'Some providers failed (${failedSources.join(', ')}); showing the available results.',
            clearError: failures.isEmpty,
          ),
        );
        if (_searchCapability.shouldHydrateProviderGroups(searchContext)) {
          unawaited(
            _hydrateProviderGroups(
              results,
              searchGeneration,
            ),
          );
        }
      }
    } catch (error) {
      if (searchGeneration == state.search.providerSearchGeneration) {
        if (cancellationToken.isCancelled ||
            error is ProviderCancelledException) {
          return;
        }
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
                'Provider search failed: ${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')}',
          ),
        );
      }
    } finally {
      if (identical(_providerSearchCancellationToken, cancellationToken)) {
        _providerSearchCancellationToken = null;
      }
      if (searchGeneration == state.search.providerSearchGeneration &&
          state.search.isSearchingProvider) {
        state = state.copyWith(
          search: state.search.copyWith(isSearchingProvider: false),
        );
      }
    }
  }

  Future<void> _hydrateProviderGroups(
    List<ProviderSearchCandidate> candidates,
    int searchGeneration,
  ) async {
    for (final candidate in candidates) {
      if (searchGeneration != state.search.providerSearchGeneration) return;
      if (!libraryAddForKind(candidate.kind)
          .resultPolicy
          .isProviderGroupCandidate(candidate)) {
        continue;
      }
      await _ensureProviderPreviewLoaded(candidate.localCatalogId);
    }
  }

  void cancelSearch() {
    _searchDebounceTimer?.cancel();
    _autocompleteTimer?.cancel();
    _coreSearchCancelToken?.cancel('Add search cancelled');
    _coreSearchCancelToken = null;
    _suggestionsGeneration++;
    _suggestionsCancelToken?.cancel('Add search cancelled');
    _suggestionsCancelToken = null;
    _providerSearchCancellationToken?.cancel();
    _providerSearchCancellationToken = null;
    state = state.copyWith(
      search: state.search.copyWith(
        coreSearchGeneration: state.search.coreSearchGeneration + 1,
        providerSearchGeneration: state.search.providerSearchGeneration + 1,
        isSearching: false,
        isSearchingProvider: false,
        isScanningCover: false,
      ),
    );
  }

  Future<void> lookupIdentifier({String? identifierCode}) async {
    var code = identifierCode?.trim().isNotEmpty == true
        ? identifierCode!.trim()
        : state.search.identifierCode.trim();
    if (code.isEmpty) {
      state = state.copyWith(
        search: state.search.copyWith(
          error: 'Enter a barcode / UPC / ISBN.',
        ),
      );
      return;
    }

    final resolvedBarcode = resolveLibraryBarcodeForKind(type.kind, code);
    if (resolvedBarcode == null) {
      state = state.copyWith(
        mode: LibraryAddDialogMode.identifier,
        search: state.search.copyWith(
          identifierCode: code,
          error:
              'This code is not supported for ${type.identity.pluralLabel.toLowerCase()}.',
        ),
      );
      return;
    }
    code = resolvedBarcode;

    final searchGeneration = state.search.coreSearchGeneration + 1;
    _coreSearchCancelToken?.cancel('Superseded by identifier lookup');
    _providerSearchCancellationToken?.cancel();
    _coreSearchCancelToken = null;
    _providerSearchCancellationToken = null;
    state = state.copyWith(
      search: state.search.copyWith(
        providerSearchGeneration: state.search.providerSearchGeneration + 1,
        isSearchingProvider: false,
      ),
    );
    final cancelToken = CancelToken();
    _coreSearchCancelToken = cancelToken;
    state = state.copyWith(
      mode: LibraryAddDialogMode.identifier,
      search: state.search.copyWith(
        identifierCode: code,
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
      if (identical(_coreSearchCancelToken, cancelToken)) {
        _coreSearchCancelToken = null;
      }
      state = state.copyWith(
        search: state.search.copyWith(isSearching: false),
      );
      if (libraryMetadataForKind(type.kind)
          .supportedProvidersForKind(type.kind)
          .isNotEmpty) {
        await searchProvider(queryOverride: code);
      }
      return;
    }

    try {
      final lookupResult = await runLibraryAddIdentifierLookup(
        api: api!,
        type: type,
        catalog: catalog!,
        identifierCode: code,
        timeout: _coreSearchTimeout,
        providerSearchAvailable: libraryMetadataForKind(type.kind)
            .supportedProvidersForKind(type.kind)
            .isNotEmpty,
        cancelToken: cancelToken,
      );

      if (searchGeneration == state.search.coreSearchGeneration) {
        state = state.copyWith(
          search: state.search.copyWith(
            results: lookupResult.items,
            isSearching: false,
            error: lookupResult.items.isEmpty &&
                    libraryMetadataForKind(type.kind)
                        .supportedProvidersForKind(type.kind)
                        .isEmpty
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
        final canFallbackToProvider = libraryMetadataForKind(type.kind)
            .supportedProvidersForKind(type.kind)
            .isNotEmpty;
        state = state.copyWith(
          search: state.search.copyWith(
            isSearching: false,
            error: canFallbackToProvider
                ? null
                : 'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')} Manual add keeps the scanned code.',
          ),
        );

        if (canFallbackToProvider) {
          await searchProvider(queryOverride: code);
        }
      }
    } finally {
      if (identical(_coreSearchCancelToken, cancelToken)) {
        _coreSearchCancelToken = null;
      }
      if (searchGeneration == state.search.coreSearchGeneration &&
          state.search.isSearching) {
        state = state.copyWith(
          search: state.search.copyWith(isSearching: false),
        );
      }
    }
  }

  bool _isMissingBearerTokenError(Object error) {
    if (error is! DioException) return false;
    if (error.response?.statusCode != 401) return false;
    final data = error.response?.data;
    if (data is! Map) return false;
    return data['code']?.toString().trim() == 'missing_bearer_token';
  }
}
