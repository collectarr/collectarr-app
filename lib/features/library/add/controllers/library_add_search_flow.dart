part of 'library_add_session_controller.dart';

mixin _LibraryAddSearchFlow on ValueNotifier<LibraryAddSessionState> {
  LibraryAddSessionState get state;
  set state(LibraryAddSessionState value);
  CatalogMediaKind get kind;
  LibraryKindRegistration get type;
  ApiClient? get api;
  CatalogTransportRepository? get catalog;
  LibraryAddSearchCapability get _searchCapability;
  LibraryAddSearchContext _searchContext({String? query});
  Future<bool> _handleAuthExpiration(Object error, String action);
  void selectResult(String id);
  Future<void> _ensureSelectedResultLoaded(String itemId);
  Future<void> _ensureBundleReleasesLoaded(String itemId);
  Timer? _searchDebounceTimer;
  Timer? _autocompleteTimer;
  CancelToken? _coreSearchCancelToken;
  CancelToken? _suggestionsCancelToken;
  int _suggestionsGeneration = 0;

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
        input: _searchCapability.core.inputBuilder(
          searchContext,
          limit: _autocompleteLimit,
        ),
        ranking: _searchCapability.provider.ranking,
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
        query: item.summary.primaryLabel,
        showSuggestions: false,
        suggestions: const [],
        results: [item],
      ),
      selection: state.selection.copyWith(
        selectedResultId: item.reference.id,
      ),
    );
    _ensureSelectedResultLoaded(item.reference.id);
    _ensureBundleReleasesLoaded(item.reference.id);
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
    _coreSearchCancelToken = null;
    state = state.copyWith(
      search: state.search.copyWith(
        coreSearchGeneration: state.search.coreSearchGeneration + 1,
        isSearching: false,
      ),
    );
    final searchContext = _searchContext();
    if (!_searchCapability.input.hasSearchInput(searchContext)) {
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
      ),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
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
      return;
    }

    try {
      final searchResult = await runLibraryAddCoreSearch(
        api: api!,
        type: type,
        catalog: catalog!,
        input: _searchCapability.core.inputBuilder(
          searchContext,
          limit: 20,
        ),
        timeout: _coreSearchTimeout,
        ranking: _searchCapability.provider.ranking,
        searchContext: searchContext,
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
    } catch (error) {
      if (searchGeneration == state.search.coreSearchGeneration) {
        if (await _handleAuthExpiration(error, 'Core search')) {
          return;
        }
        state = state.copyWith(
          search: state.search.copyWith(
            isSearching: false,
            error:
                'Core search failed: ${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')} Manual add and proposals still work.',
          ),
        );
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

  void cancelSearch() {
    _searchDebounceTimer?.cancel();
    _autocompleteTimer?.cancel();
    _coreSearchCancelToken?.cancel('Add search cancelled');
    _coreSearchCancelToken = null;
    _suggestionsGeneration++;
    _suggestionsCancelToken?.cancel('Add search cancelled');
    _suggestionsCancelToken = null;
    state = state.copyWith(
      search: state.search.copyWith(
        coreSearchGeneration: state.search.coreSearchGeneration + 1,
        isSearching: false,
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
    _coreSearchCancelToken = null;
    state = state.copyWith(
      search: state.search.copyWith(),
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
      ),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
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
      return;
    }

    try {
      final lookupResult = await runLibraryAddIdentifierLookup(
        api: api!,
        type: type,
        catalog: catalog!,
        identifierCode: code,
        timeout: _coreSearchTimeout,
        cancelToken: cancelToken,
      );

      if (searchGeneration == state.search.coreSearchGeneration) {
        state = state.copyWith(
          search: state.search.copyWith(
            results: lookupResult.items,
            isSearching: false,
            error: lookupResult.items.isEmpty
                ? 'No Core item found for barcode $code. You can add or propose it manually.'
                : null,
          ),
        );
        if (lookupResult.items.isNotEmpty) {
          selectResult(lookupResult.items.first.reference.id);
        }
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
                'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')} Manual add keeps the scanned code.',
          ),
        );
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
}
