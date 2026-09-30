import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/foundation.dart';

class LibraryAddPreviewController {
  final hydratedResultsByRef = <CatalogEntityRef, CatalogSearchCandidate>{};
  final pendingHydratedResultRefs = <CatalogEntityRef>{};

  CatalogSearchCandidate? hydratedResultFor(CatalogEntityRef ref) =>
      hydratedResultsByRef[ref];

  bool hasHydratedResult(CatalogEntityRef ref) =>
      hydratedResultsByRef.containsKey(ref);

  void setHydratedResult(CatalogEntityRef ref, CatalogSearchCandidate item) {
    hydratedResultsByRef[ref] = item;
    pendingHydratedResultRefs.remove(ref);
  }

  void markHydratedResultPending(CatalogEntityRef ref) {
    pendingHydratedResultRefs.add(ref);
  }

  bool isHydratedResultPending(CatalogEntityRef ref) =>
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

  final Map<CatalogEntityRef, CatalogSearchCandidate> hydratedResultsByRef;
  final Set<CatalogEntityRef> pendingHydratedResultRefs;

  CatalogSearchCandidate? hydratedResultFor(CatalogEntityRef ref) =>
      hydratedResultsByRef[ref];

  bool hasHydratedResult(CatalogEntityRef ref) =>
      hydratedResultsByRef.containsKey(ref);

  bool isHydratedResultPending(CatalogEntityRef ref) =>
      pendingHydratedResultRefs.contains(ref);

  LibraryAddPreviewState copyWith({
    Map<CatalogEntityRef, CatalogSearchCandidate>? hydratedResultsByRef,
    Set<CatalogEntityRef>? pendingHydratedResultRefs,
  }) {
    return LibraryAddPreviewState(
      hydratedResultsByRef: hydratedResultsByRef ?? this.hydratedResultsByRef,
      pendingHydratedResultRefs:
          pendingHydratedResultRefs ?? this.pendingHydratedResultRefs,
    );
  }
}
