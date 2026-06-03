part of 'page.dart';

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
    final bucketScopeFilters = state._sidebarBucketScopeFilters;
    final overrideBuckets = facetBuckets?.buckets;
    final linkedMetadataFilter = state._linkedMetadataFilter;
    final selectedBucket =
        state._usesExternalFacetBuckets(mode) ? null : state._selectedBucket;
    final selectedItemId = state._selectedId;
    final quickView = state._quickView;
    final collectionStatusScope = state._collectionStatusScope;
    final filterSelection = state._filterSelection;
    final customFieldValues = state.customFieldValuesByItem;
    final customFieldValuesByDefinition = state.customFieldValuesByDefinitionByItem;
    final activeLoanOwnedItemIds = state._activeLoanOwnedItemIds;
    final query = state._searchController.text;
    final signature = projectionSignature(
      state: state,
      shelf: shelf,
      viewState: viewState,
      query: query,
      mode: mode,
      selectedBucket: selectedBucket,
      selectedItemId: selectedItemId,
      quickView: quickView,
      collectionStatusScope: collectionStatusScope,
      filterSelection: filterSelection,
      constrainedItemIds: constrainedItemIds,
      customFieldValuesByItem: customFieldValues,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinition,
      activeLoanOwnedItemIds: activeLoanOwnedItemIds,
    );

    final canReuseProjection =
        state._cachedProjection != null &&
      state._cachedProjectionSignature == signature;

    if (canReuseProjection) {
      return state._cachedProjection!;
    }

    final projection = LibraryProjection.fromShelf(
      shelf: shelf,
      type: state.widget.type,
      adapter: state._adapter,
      viewState: viewState,
      query: query,
      linkedMetadataFilter: linkedMetadataFilter,
      selectedBucket: selectedBucket,
      selectedItemId: selectedItemId,
      quickView: quickView,
      collectionStatusScope: collectionStatusScope,
      groupMode: mode,
      bucketScopeFilters: bucketScopeFilters,
      overrideBuckets: overrideBuckets,
      constrainedItemIds: constrainedItemIds,
      filterSelection: filterSelection,
      customFieldValuesByItem: customFieldValues,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinition,
      activeLoanOwnedItemIds: activeLoanOwnedItemIds,
    );

    state._cachedProjectionSignature = signature;
    state._cachedProjection = projection;
    return projection;
  }

  static String projectionSignature({
    required GenericLibraryPageState state,
    required ShelfState shelf,
    required LibraryWorkspaceViewState viewState,
    required String query,
    required LibraryGroupMode mode,
    required String? selectedBucket,
    required String? selectedItemId,
    required LibraryQuickView? quickView,
    required LibraryCollectionStatusScope collectionStatusScope,
    required LibraryFilterSelection filterSelection,
    required Set<String>? constrainedItemIds,
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
      mode,
      selectedBucket,
      selectedItemId,
      quickView,
      collectionStatusScope,
      state._seriesCompletionScope,
      filterSelection.hashCode,
      state._linkedMetadataFilter?.value,
      stableSetSignature(constrainedItemIds),
      stableSetSignature(activeLoanOwnedItemIds),
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
    if (identical(state._cachedCustomFieldValuesForSignature, values) &&
        state._cachedCustomFieldValuesSignature != null) {
      return state._cachedCustomFieldValuesSignature!;
    }
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
    state._cachedCustomFieldValuesForSignature = values;
    state._cachedCustomFieldValuesSignature = signature;
    return signature;
  }

  static int customFieldValuesByDefinitionSignatureForProjection(
    GenericLibraryPageState state,
    Map<String, Map<String, String>> values,
  ) {
    if (identical(state._cachedCustomFieldValuesByDefinitionForSignature, values) &&
        state._cachedCustomFieldValuesByDefinitionSignature != null) {
      return state._cachedCustomFieldValuesByDefinitionSignature!;
    }
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
    state._cachedCustomFieldValuesByDefinitionForSignature = values;
    state._cachedCustomFieldValuesByDefinitionSignature = signature;
    return signature;
  }

  static int stableSetSignature(Set<String>? values) {
    if (values == null || values.isEmpty) {
      return 0;
    }
    final sorted = values.toList(growable: false)..sort();
    return Object.hash(values.length, Object.hashAll(sorted));
  }
}
