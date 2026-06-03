part of 'page.dart';

abstract final class _LibraryFacetControllerOps {
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
    final cached = state._facetBucketsByMode[mode];
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
    final cached = state._facetBucketsByMode[mode];
    if (cached != null && cached.shelfSignature == signature) {
      return;
    }
    final loadKey = facetLoadKey(state, mode, signature);
    if (state._facetLoadsInFlight.contains(loadKey)) {
      return;
    }
    state._facetLoadsInFlight.add(loadKey);
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
        itemIds: shelfItemIds,
        signature: signature,
        isStoryArc: mode == LibraryGroupMode.storyArc,
        allBucketLabel: genericAllBucketLabel(state.widget.type),
      ).timeout(const Duration(seconds: 8));
      if (!state.mounted) return;
      final latestShelf = state.ref.read(shelfProvider).asData?.value;
      if (latestShelf == null ||
          genericShelfSignature(state, latestShelf) != signature) {
        return;
      }
      state._mutateState(() {
        state._facetBucketsByMode[mode] = buckets;
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
      state._mutateState(() {
        state._facetBucketsByMode[mode] = FacetBuckets(
          shelfSignature: signature,
          buckets: [
            LibrarySeriesBucket(
              title: genericAllBucketLabel(state.widget.type),
              count: shelfItemIds.length,
            ),
          ],
          itemIdsByBucket: const {},
        );
        state._selectedBucket = null;
      });
    } finally {
      state._facetLoadsInFlight.remove(loadKey);
      state._mutateState(() {});
    }
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
    final kind = state.widget.type.workspace.kind.apiValue;
    if (identical(state._cachedSignatureShelf, shelf) &&
        state._cachedSignatureKind == kind &&
        state._cachedShelfSignature != null) {
      return state._cachedShelfSignature!;
    }
    final signature = LibraryPageUtilities.shelfSignature([
      for (final item in libraryItemsForShelf(shelf, state.widget.type))
        item.entry.id,
    ]);
    state._cachedSignatureShelf = shelf;
    state._cachedSignatureKind = kind;
    state._cachedShelfSignature = signature;
    return signature;
  }
}
