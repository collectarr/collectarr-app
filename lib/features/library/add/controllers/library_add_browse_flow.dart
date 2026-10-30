part of 'library_add_session_controller.dart';

/// The browse tab: search groups, open one to list its items as results,
/// and check all or some of them to add.
mixin _LibraryAddBrowseFlow on ValueNotifier<LibraryAddSessionState> {
  LibraryAddSessionState get state;
  set state(LibraryAddSessionState value);
  CatalogMediaKind get kind;
  ApiClient? get api;
  CatalogTransportRepository? get catalog;
  Future<bool> _handleAuthExpiration(Object error, String action);
  int _browseGeneration = 0;

  static const _browseTimeout = Duration(seconds: 35);

  LibraryAddBrowseCapability? get _browseCapability =>
      libraryAddForKind(kind).search.browse;

  Future<void> searchBrowseGroups(String query) async {
    final capability = _browseCapability;
    final text = query.trim();
    final generation = ++_browseGeneration;
    if (text.isEmpty) {
      state = state.copyWith(
        browse: state.browse.copyWith(
          query: query,
          error: capability?.hintText,
        ),
      );
      return;
    }
    state = state.copyWith(
      browse: LibraryAddBrowseState(query: query, isSearching: true),
      search: state.search.copyWith(results: const []),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
        checkedResultIds: const {},
      ),
    );
    if (api == null || capability == null) {
      state = state.copyWith(
        browse: state.browse.copyWith(isSearching: false, searched: true),
      );
      return;
    }
    try {
      final found = await capability
          .searchGroups(api!, text)
          .timeout(_LibraryAddBrowseFlow._browseTimeout);
      if (generation != _browseGeneration) return;
      state = state.copyWith(
        browse: state.browse.copyWith(
          found: found,
          isSearching: false,
          searched: true,
        ),
      );
    } catch (error) {
      if (generation != _browseGeneration) return;
      if (await _handleAuthExpiration(error, 'Core ${capability.label}')) {
        return;
      }
      state = state.copyWith(
        browse: state.browse.copyWith(
          isSearching: false,
          searched: true,
          error: 'Core ${capability.label} search failed: '
              '${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')}',
        ),
      );
    }
  }

  /// Up to five groups for the typed text, shown under the field while
  /// typing; Core failures leave the field without suggestions.
  Future<List<LibraryAddBrowseGroup>> suggestBrowseGroups(String query) async {
    final capability = _browseCapability;
    final text = query.trim();
    if (api == null || capability == null || text.length < 2) return const [];
    try {
      final found = await capability
          .searchGroups(api!, text)
          .timeout(_LibraryAddBrowseFlow._browseTimeout);
      return found.take(5).toList(growable: false);
    } on Exception {
      return const [];
    }
  }

  /// Opens a suggested group as the only one found, as the reference does.
  Future<void> pickBrowseGroup(LibraryAddBrowseGroup group, String query) {
    ++_browseGeneration;
    state = state.copyWith(
      browse:
          LibraryAddBrowseState(query: query, found: [group], searched: true),
    );
    return openBrowseGroup(group);
  }

  Future<void> openBrowseGroup(LibraryAddBrowseGroup group) async {
    final capability = _browseCapability;
    if (api == null || catalog == null || capability == null) return;
    final generation = ++_browseGeneration;
    state = state.copyWith(
      browse: state.browse.copyWith(
        opened: group,
        isLoadingItems: true,
        clearError: true,
      ),
      search: state.search.copyWith(results: const []),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
        checkedResultIds: const {},
      ),
    );
    try {
      final items = await loadLibraryAddBrowseGroupItems(
        api: api!,
        catalog: catalog!,
        capability: capability,
        group: group,
        timeout: _LibraryAddBrowseFlow._browseTimeout,
      );
      if (generation != _browseGeneration) return;
      state = state.copyWith(
        browse: state.browse.copyWith(isLoadingItems: false),
        search: state.search.copyWith(
          results: items,
          coreSearchGeneration: state.search.coreSearchGeneration + 1,
          hasMoreResults: false,
          nextOffset: 0,
          clearError: true,
        ),
      );
    } catch (error) {
      if (generation != _browseGeneration) return;
      if (await _handleAuthExpiration(error, 'Core ${group.title}')) return;
      state = state.copyWith(
        browse: state.browse.copyWith(
          isLoadingItems: false,
          error: 'Loading ${group.title} failed: '
              '${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')}',
        ),
      );
    }
  }

  /// Returns from the opened group to the found groups.
  void closeBrowseGroup() {
    _browseGeneration++;
    state = state.copyWith(
      browse: state.browse.copyWith(
        clearOpened: true,
        isLoadingItems: false,
        clearError: true,
      ),
      search: state.search.copyWith(results: const []),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
        checkedResultIds: const {},
      ),
    );
  }

  /// Checks or unchecks every listed item of the opened group.
  void setAllResultsChecked(Iterable<String> ids, bool checked) {
    state = state.copyWith(
      selection: state.selection.copyWith(
        checkedResultIds: checked ? ids.toSet() : const {},
      ),
    );
  }
}
