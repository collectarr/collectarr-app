part of 'session_controller.dart';

/// A tab the kind contributes: its controls choose what to list, and the
/// listed catalog items are checked to add, like an opened browse group.
mixin _LibraryAddKindTabFlow on ValueNotifier<LibraryAddSessionState> {
  LibraryAddSessionState get state;
  set state(LibraryAddSessionState value);
  CatalogTransportRepository? get catalog;
  ApiClient? get api;
  Future<bool> _handleAuthExpiration(Object error, String action);
  int _kindTabGeneration = 0;

  static const _kindTabTimeout = Duration(seconds: 35);

  /// Opens the kind's tab at [index] with nothing listed yet.
  void openKindTab(int index) {
    _kindTabGeneration++;
    state = state.copyWith(
      mode: LibraryAddDialogMode.kindTab,
      kindTab: index,
      search: state.search.copyWith(results: const [], clearError: true),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
        checkedResultIds: const {},
      ),
    );
  }

  /// Lists the Core search envelopes [rows] resolves to, replacing what the
  /// tab listed before.
  Future<void> listKindTabRows(
      Future<List<Map<String, dynamic>>> rows, String label) async {
    final generation = ++_kindTabGeneration;
    state = state.copyWith(
      search: state.search
          .copyWith(isSearching: true, results: const [], clearError: true),
      selection: state.selection.copyWith(
        clearSelectedResultId: true,
        checkedResultIds: const {},
      ),
    );
    try {
      final loaded = await rows.timeout(_kindTabTimeout);
      final items = catalog == null
          ? const <CatalogSearchCandidate>[]
          : await cacheLibraryAddCoreRows(catalog: catalog!, rows: loaded);
      if (generation != _kindTabGeneration) return;
      state = state.copyWith(
        search: state.search.copyWith(
          isSearching: false,
          results: items,
          coreSearchGeneration: state.search.coreSearchGeneration + 1,
          hasMoreResults: false,
          nextOffset: 0,
        ),
      );
    } catch (error) {
      if (generation != _kindTabGeneration) return;
      if (await _handleAuthExpiration(error, 'Core $label')) return;
      state = state.copyWith(
        search: state.search.copyWith(
          isSearching: false,
          error: 'Loading $label failed: '
              '${ConnectionDiagnostics.metadataError(error, api?.baseUrl ?? '')}',
        ),
      );
    }
  }
}
