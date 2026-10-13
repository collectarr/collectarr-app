import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/foundation.dart';

class LibraryAddPreviewController {
  final hydratedResultsByRef = <CatalogItemRef, CatalogSearchCandidate>{};
  final pendingHydratedResultRefs = <CatalogItemRef>{};

  CatalogSearchCandidate? hydratedResultFor(CatalogItemRef ref) =>
      hydratedResultsByRef[ref];

  bool hasHydratedResult(CatalogItemRef ref) =>
      hydratedResultsByRef.containsKey(ref);

  void setHydratedResult(CatalogItemRef ref, CatalogSearchCandidate item) {
    hydratedResultsByRef[ref] = item;
    pendingHydratedResultRefs.remove(ref);
  }

  void markHydratedResultPending(CatalogItemRef ref) {
    pendingHydratedResultRefs.add(ref);
  }

  bool isHydratedResultPending(CatalogItemRef ref) =>
      pendingHydratedResultRefs.contains(ref);

  void clearSelectionCaches() {
    hydratedResultsByRef.clear();
    pendingHydratedResultRefs.clear();
  }

  void reset() => clearSelectionCaches();

  void dispose() => clearSelectionCaches();
}

@immutable
class LibraryAddPreviewState {
  const LibraryAddPreviewState({
    this.hydratedResultsByRef = const {},
    this.pendingHydratedResultRefs = const {},
  });

  const LibraryAddPreviewState.initial() : this();

  final Map<CatalogItemRef, CatalogSearchCandidate> hydratedResultsByRef;
  final Set<CatalogItemRef> pendingHydratedResultRefs;

  CatalogSearchCandidate? hydratedResultFor(CatalogItemRef ref) =>
      hydratedResultsByRef[ref];

  bool hasHydratedResult(CatalogItemRef ref) =>
      hydratedResultsByRef.containsKey(ref);

  bool isHydratedResultPending(CatalogItemRef ref) =>
      pendingHydratedResultRefs.contains(ref);

  LibraryAddPreviewState copyWith({
    Map<CatalogItemRef, CatalogSearchCandidate>? hydratedResultsByRef,
    Set<CatalogItemRef>? pendingHydratedResultRefs,
  }) {
    return LibraryAddPreviewState(
      hydratedResultsByRef: hydratedResultsByRef ?? this.hydratedResultsByRef,
      pendingHydratedResultRefs:
          pendingHydratedResultRefs ?? this.pendingHydratedResultRefs,
    );
  }
}
