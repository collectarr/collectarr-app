part of '../generic_library_page.dart';

abstract final class _LibraryFacetControllerOps {
  static LibraryFacetControllerState _controllerState(
    GenericLibraryPageState state,
  ) {
    return state.ref.read(
      libraryFacetControllerProvider(state.widget.type.workspace.kind.apiValue),
    );
  }

  static LibraryFacetControllerNotifier _controllerNotifier(
    GenericLibraryPageState state,
  ) {
    return state.ref.read(
      libraryFacetControllerProvider(
        state.widget.type.workspace.kind.apiValue,
      ).notifier,
    );
  }

  static void maybeEnsureFacetBucketsLoaded(
    GenericLibraryPageState state,
    ShelfState shelf,
    String mode,
  ) {
    final signature = genericShelfSignature(state, shelf);
    final facetId = facetIdForMode(state, mode);
    if (facetId == null) {
      state._lastFacetEnsureSignature = signature;
      state._lastFacetEnsureFacetId = null;
      return;
    }
    if (state._lastFacetEnsureSignature == signature &&
        state._lastFacetEnsureFacetId == facetId) {
      return;
    }
    state._lastFacetEnsureSignature = signature;
    state._lastFacetEnsureFacetId = facetId;
    ensureFacetBucketsLoaded(state, shelf, mode, facetId);
  }

  static bool usesExternalFacetBuckets(
    GenericLibraryPageState state,
    String mode,
  ) {
    return facetIdForMode(state, mode) != null;
  }

  static String? facetIdForMode(
    GenericLibraryPageState state,
    String mode,
  ) {
    return state.widget.type.presentation.externalFacetBucketIdsByMode[mode];
  }

  static FacetBuckets? facetBucketsForMode(
    GenericLibraryPageState state,
    String mode,
    ShelfState shelf,
  ) {
    final facetId = facetIdForMode(state, mode);
    if (facetId == null) {
      return null;
    }
    final signature = genericShelfSignature(state, shelf);
    final cached = _controllerState(state).bucketsByFacetId[facetId];
    if (cached != null && cached.shelfSignature == signature) {
      return cached;
    }
    return FacetBuckets(
      shelfSignature: signature,
      buckets: [
        LibrarySeriesBucket(
          title: genericAllBucketLabel(state.widget.type),
          count: libraryItemsForShelf(shelf, state.widget.type).length,
        ),
      ],
      itemIdsByBucket: const {},
    );
  }

  static void ensureFacetBucketsLoaded(
    GenericLibraryPageState state,
    ShelfState shelf,
    String mode,
    String facetId,
  ) {
    final signature = genericShelfSignature(state, shelf);
    final cached = _controllerState(state).bucketsByFacetId[facetId];
    if (cached != null && cached.shelfSignature == signature) {
      return;
    }
    final loadKey = facetLoadKey(state, facetId, signature);
    if (_controllerState(state).loadsInFlight.contains(loadKey)) {
      return;
    }
    _controllerNotifier(state).startLoad(loadKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state._mutateState(() {});
    });
    unawaited(loadFacetBuckets(state, mode, facetId, shelf, signature));
  }

  static Future<void> loadFacetBuckets(
    GenericLibraryPageState state,
    String mode,
    String facetId,
    ShelfState shelf,
    String signature,
  ) async {
    final loadKey = facetLoadKey(state, facetId, signature);
    final shelfItemIds = {
      for (final item in libraryItemsForShelf(shelf, state.widget.type))
        item.entry.id,
    };
    try {
      final buckets = await state.fetchFacetBuckets(
        type: state.widget.type,
        facetId: facetId,
        itemIds: shelfItemIds,
        signature: signature,
        allBucketLabel: genericAllBucketLabel(state.widget.type),
      ).timeout(const Duration(seconds: 8));
      if (!state.mounted) return;
      final latestShelf = state.ref.read(shelfProvider).asData?.value;
      if (latestShelf == null ||
          genericShelfSignature(state, latestShelf) != signature) {
        return;
      }
      _controllerNotifier(state).setBuckets(facetId, buckets);
      state._mutateState(() {
        if (state._selectedBucket != null &&
            !buckets.buckets.any((b) => b.title == state._selectedBucket)) {
          state._selectedBucket = null;
        }
      });
    } catch (e, st) {
      logRecoverableError(
        source: 'GenericLibraryPage',
        message: 'Facet load failed for $mode',
        error: e,
        stackTrace: st,
      );
      if (!state.mounted) {
        return;
      }
      final latestShelf = state.ref.read(shelfProvider).asData?.value;
      if (latestShelf == null ||
          genericShelfSignature(state, latestShelf) != signature) {
        return;
      }
      final fallback = FacetBuckets(
        shelfSignature: signature,
        buckets: [
          LibrarySeriesBucket(
            title: genericAllBucketLabel(state.widget.type),
            count: shelfItemIds.length,
          ),
        ],
        itemIdsByBucket: const {},
      );
      _controllerNotifier(state).setBuckets(facetId, fallback);
      state._mutateState(() {
        state._selectedBucket = null;
      });
    } finally {
      if (state.mounted) {
        _controllerNotifier(state).finishLoad(loadKey);
        state._mutateState(() {});
      }
    }
  }

  static bool isFacetLoadInFlight(
    GenericLibraryPageState state,
    String loadKey,
  ) {
    return _controllerState(state).loadsInFlight.contains(loadKey);
  }

  static String facetLoadKey(
    GenericLibraryPageState state,
    String facetId,
    String signature,
  ) {
    return '${state.widget.type.workspace.kind.apiValue}|$facetId|$signature';
  }

  static String genericShelfSignature(
    GenericLibraryPageState state,
    ShelfState shelf,
  ) {
    return LibraryPageUtilities.shelfSignature([
      for (final item in libraryItemsForShelf(shelf, state.widget.type))
        item.entry.id,
    ]);
  }
}
