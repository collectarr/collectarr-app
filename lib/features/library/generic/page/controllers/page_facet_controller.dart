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
    LibraryGroupMode mode,
  ) {
    final signature = genericShelfSignature(state, shelf);
    if (state._lastFacetEnsureSignature == signature &&
        state._lastFacetEnsureMode == mode) {
      return;
    }
    state._lastFacetEnsureSignature = signature;
    state._lastFacetEnsureMode = mode;
    ensureFacetBucketsLoaded(state, shelf, mode);
  }

  static bool usesExternalFacetBuckets(
    GenericLibraryPageState state,
    LibraryGroupMode mode,
  ) {
    return state.widget.type.presentation.externalFacetBucketModes.contains(mode);
  }

  static FacetBuckets? facetBucketsForMode(
    GenericLibraryPageState state,
    LibraryGroupMode mode,
    ShelfState shelf,
  ) {
    if (!usesExternalFacetBuckets(state, mode)) {
      return null;
    }
    final signature = genericShelfSignature(state, shelf);
    final cached = _controllerState(state).bucketsByMode[mode];
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
    LibraryGroupMode mode,
  ) {
    if (!usesExternalFacetBuckets(state, mode)) {
      return;
    }
    final signature = genericShelfSignature(state, shelf);
    final cached = _controllerState(state).bucketsByMode[mode];
    if (cached != null && cached.shelfSignature == signature) {
      return;
    }
    final loadKey = facetLoadKey(state, mode, signature);
    if (_controllerState(state).loadsInFlight.contains(loadKey)) {
      return;
    }
    _controllerNotifier(state).startLoad(loadKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state._mutateState(() {});
    });
    unawaited(loadFacetBuckets(state, mode, shelf, signature));
  }

  static Future<void> loadFacetBuckets(
    GenericLibraryPageState state,
    LibraryGroupMode mode,
    ShelfState shelf,
    String signature,
  ) async {
    final loadKey = facetLoadKey(state, mode, signature);
    final shelfItemIds = {
      for (final item in libraryItemsForShelf(shelf, state.widget.type))
        item.entry.id,
    };
    try {
      final buckets = await state.fetchFacetBuckets(
        type: state.widget.type,
        groupMode: mode,
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
      _controllerNotifier(state).setBuckets(mode, buckets);
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
      _controllerNotifier(state).setBuckets(mode, fallback);
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
    LibraryGroupMode mode,
    String signature,
  ) {
    return '${state.widget.type.workspace.kind.apiValue}|$mode|$signature';
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
