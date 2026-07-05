part of '../../page.dart';

abstract final class _LibraryProjectionControllerOps {
  static LibraryProjection projectionForShelf(
    GenericLibraryPageState state,
    ShelfState shelf,
    LibraryWorkspaceViewState viewState,
  ) {
    final mode = state._activeGroupMode;
    final facetBuckets = state._facetBucketsForMode(mode, shelf);
    final constrainedItemIds =
        (state._usesExternalFacetBuckets(mode) && state._selectedBucket != null)
            ? facetBuckets?.itemIdsByBucket[state._selectedBucket!]
            : null;
    final searchState = _LibraryPageSearchControllerOps.thisState(state);
    final searchPinnedItemIds = searchState.pinnedItemId == null
        ? null
        : <String>{searchState.pinnedItemId!};
    final effectiveConstrainedItemIds = _mergeConstrainedItemIds(
      constrainedItemIds,
      searchPinnedItemIds,
    );
    final bucketScopeFilters = state._sidebarBucketScopeFilters;
    final overrideBuckets = facetBuckets?.buckets;
    final linkedMetadataFilter = state._linkedMetadataFilter;
    final selectedBucket =
        state._usesExternalFacetBuckets(mode) ? null : state._selectedBucket;
    final selectedItemId = state._selectedId;
    final quickView = state._quickView;
    final collectionStatusScope = state._collectionStatusScope;
    final filterSelection = state._filterSelection;
    final projectionCache = state.ref.watch(
      libraryProjectionCacheProvider(state.widget.type.workspace.kind.apiValue),
    );
    final customFieldValues =
        projectionCache.asData?.value.valuesByItem ?? const <String, List<String>>{};
    final customFieldValuesByDefinition =
        projectionCache.asData?.value.valuesByDefinitionByItem ??
            const <String, Map<String, String>>{};
    final customFieldDefinitions =
        projectionCache.asData?.value.definitions ?? const [];
    final activeLoanOwnedItemIds = state._activeLoanOwnedItemIds;
    final query = searchState.query;
    final searchTarget = state._effectiveSearchTarget;
    final browserMode = state._activeBrowserMode;
    final releaseFolderTitleItemId = state.activeReleaseFolderTitleItemId;
    final signature = projectionSignature(
      state: state,
      shelf: shelf,
      viewState: viewState,
      query: query,
      searchTarget: searchTarget,
      browserMode: browserMode,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
      mode: mode,
      selectedBucket: selectedBucket,
      selectedItemId: selectedItemId,
      quickView: quickView,
      collectionStatusScope: collectionStatusScope,
      filterSelection: filterSelection,
      constrainedItemIds: constrainedItemIds,
      searchPinnedItemId: searchState.pinnedItemId,
      customFieldValuesByItem: customFieldValues,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinition,
      customFieldDefinitions: customFieldDefinitions,
      activeLoanOwnedItemIds: activeLoanOwnedItemIds,
    );
    return state.ref.watch(
      libraryProjectionProvider(
        LibraryProjectionRequest(
          signature: signature,
          shelf: shelf,
          type: state.widget.type,
          adapter: state._adapter,
          viewState: viewState,
          browserMode: browserMode,
          releaseFolderTitleItemId: releaseFolderTitleItemId,
          query: query,
          linkedMetadataFilter: linkedMetadataFilter,
          selectedBucket: selectedBucket,
          selectedItemId: selectedItemId,
          quickView: quickView,
          collectionStatusScope: collectionStatusScope,
          groupMode: mode,
          bucketScopeFilters: bucketScopeFilters,
          overrideBuckets: overrideBuckets,
          constrainedItemIds: effectiveConstrainedItemIds,
          filterSelection: filterSelection,
          customFieldValuesByItem: customFieldValues,
          customFieldValuesByDefinitionByItem: customFieldValuesByDefinition,
          customFieldDefinitions: customFieldDefinitions,
          activeLoanOwnedItemIds: activeLoanOwnedItemIds,
          searchTarget: searchTarget,
        ),
      ),
    );
  }

  static String projectionSignature({
    required GenericLibraryPageState state,
    required ShelfState shelf,
    required LibraryWorkspaceViewState viewState,
    required String query,
    required LibrarySearchTarget searchTarget,
    required LibraryWorkspaceBrowserMode browserMode,
    required String? releaseFolderTitleItemId,
    required LibraryGroupMode mode,
    required String? selectedBucket,
    required String? selectedItemId,
    required LibraryQuickView? quickView,
    required LibraryCollectionStatusScope collectionStatusScope,
    required LibraryFilterSelection filterSelection,
    required Set<String>? constrainedItemIds,
    required String? searchPinnedItemId,
    required List<CustomFieldDefinition> customFieldDefinitions,
    required Map<String, List<String>> customFieldValuesByItem,
    required Map<String, Map<String, String>>
        customFieldValuesByDefinitionByItem,
    required Set<String> activeLoanOwnedItemIds,
  }) {
    final shelfSignature = state._genericShelfSignature(shelf);
    final normalizedQuery = query.trim().toLowerCase();
    return Object.hashAll([
      shelfSignature,
      viewState.hashCode,
      normalizedQuery,
      searchTarget,
      browserMode,
      releaseFolderTitleItemId,
      mode,
      selectedBucket,
      selectedItemId,
      quickView,
      collectionStatusScope,
      state._seriesCompletionScope,
      filterSelection.hashCode,
      state._linkedMetadataFilter?.value,
      stableSetSignature(constrainedItemIds),
      searchPinnedItemId,
      stableSetSignature(activeLoanOwnedItemIds),
      _customFieldDefinitionsSignature(customFieldDefinitions),
      customFieldValuesSignatureForProjection(state, customFieldValuesByItem),
      customFieldValuesByDefinitionSignatureForProjection(
        state,
        customFieldValuesByDefinitionByItem,
      ),
    ]).toString();
  }

  static int customFieldValuesSignatureForProjection(
    GenericLibraryPageState state,
    Map<String, List<String>> values,
  ) {
    final sortedKeys = values.keys.toList(growable: false)..sort();
    var signature = values.length;
    for (final key in sortedKeys) {
      final entries = List<String>.from(values[key] ?? const <String>[])
        ..sort();
      signature = Object.hash(
      signature,
      key,
      entries.length,
      Object.hashAll(entries),
      );
    }
    return signature;
  }

  static int customFieldValuesByDefinitionSignatureForProjection(
    GenericLibraryPageState state,
    Map<String, Map<String, String>> values,
  ) {
    final sortedOuterKeys = values.keys.toList(growable: false)..sort();
    var signature = values.length;
    for (final outerKey in sortedOuterKeys) {
      final inner = values[outerKey] ?? const <String, String>{};
      final sortedInnerKeys = inner.keys.toList(growable: false)..sort();
      var innerSignature = inner.length;
      for (final innerKey in sortedInnerKeys) {
        innerSignature = Object.hash(innerSignature, innerKey, inner[innerKey]);
      }
      signature = Object.hash(signature, outerKey, innerSignature);
    }
    return signature;
  }

  static int _customFieldDefinitionsSignature(
    List<CustomFieldDefinition> definitions,
  ) {
    var signature = definitions.length;
    for (final definition in definitions) {
      signature = Object.hash(
        signature,
        definition.id,
        definition.name,
        definition.fieldType,
        definition.mediaKind,
        definition.editScope,
        definition.sortOrder,
      );
    }
    return signature;
  }

  static int stableSetSignature(Set<String>? values) {
    if (values == null || values.isEmpty) {
      return 0;
    }
    final sorted = values.toList(growable: false)..sort();
    return Object.hash(values.length, Object.hashAll(sorted));
  }

  static Set<String>? _mergeConstrainedItemIds(
    Set<String>? left,
    Set<String>? right,
  ) {
    if (left == null) {
      return right;
    }
    if (right == null) {
      return left;
    }
    return left.intersection(right);
  }
}
