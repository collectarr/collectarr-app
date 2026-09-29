import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_summary.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_detail.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/foundation.dart';

class LibraryAddPreviewController {
  final hydratedResultsByRef = <CatalogEntityRef, CatalogSearchCandidate>{};
  final bundleReleasesByCatalogRef =
      <CatalogEntityRef, List<LibraryBundleSummary>>{};
  final bundleReleaseDetailsById = <String, LibraryBundleDetail>{};
  final pendingHydratedResultRefs = <CatalogEntityRef>{};
  final pendingBundleReleaseCatalogRefs = <CatalogEntityRef>{};
  final pendingBundleReleaseDetailIds = <String>{};

  CatalogSearchCandidate? hydratedResultFor(CatalogEntityRef ref) {
    return hydratedResultsByRef[ref];
  }

  bool hasHydratedResult(CatalogEntityRef ref) {
    return hydratedResultsByRef.containsKey(ref);
  }

  void setHydratedResult(CatalogEntityRef ref, CatalogSearchCandidate item) {
    hydratedResultsByRef[ref] = item;
    pendingHydratedResultRefs.remove(ref);
  }

  void markHydratedResultPending(CatalogEntityRef ref) {
    pendingHydratedResultRefs.add(ref);
  }

  bool isHydratedResultPending(CatalogEntityRef ref) {
    return pendingHydratedResultRefs.contains(ref);
  }

  List<LibraryBundleSummary>? bundleReleasesFor(CatalogEntityRef ref) {
    return bundleReleasesByCatalogRef[ref];
  }

  List<LibraryBundleSummary> bundleReleasesForItem(
    CatalogSearchCandidate? item,
  ) {
    if (item == null) {
      return const <LibraryBundleSummary>[];
    }
    return bundleReleasesByCatalogRef[item.reference] ??
        const <LibraryBundleSummary>[];
  }

  void setBundleReleases(
    CatalogEntityRef ref,
    List<LibraryBundleSummary> releases,
  ) {
    bundleReleasesByCatalogRef[ref] = List.unmodifiable(releases);
    pendingBundleReleaseCatalogRefs.remove(ref);
  }

  void markBundleReleasesPending(CatalogEntityRef ref) {
    pendingBundleReleaseCatalogRefs.add(ref);
  }

  bool isBundleReleasesPending(CatalogEntityRef ref) {
    return pendingBundleReleaseCatalogRefs.contains(ref);
  }

  LibraryBundleDetail? bundleReleaseDetailForId(String releaseId) {
    return bundleReleaseDetailsById[releaseId];
  }

  LibraryBundleDetail? bundleReleaseDetailFor(String releaseId) {
    return bundleReleaseDetailsById[releaseId];
  }

  void setBundleReleaseDetail(
    String releaseId,
    LibraryBundleDetail detail,
  ) {
    bundleReleaseDetailsById[releaseId] = detail;
    pendingBundleReleaseDetailIds.remove(releaseId);
  }

  void markBundleReleaseDetailPending(String releaseId) {
    pendingBundleReleaseDetailIds.add(releaseId);
  }

  bool isBundleReleaseDetailPending(String releaseId) {
    return pendingBundleReleaseDetailIds.contains(releaseId);
  }

  void clearSelectionCaches() {
    hydratedResultsByRef.clear();
    bundleReleasesByCatalogRef.clear();
    bundleReleaseDetailsById.clear();
    pendingHydratedResultRefs.clear();
    pendingBundleReleaseCatalogRefs.clear();
    pendingBundleReleaseDetailIds.clear();
  }

  void reset() {
    clearSelectionCaches();
  }

  void dispose() {
    hydratedResultsByRef.clear();
    bundleReleasesByCatalogRef.clear();
    bundleReleaseDetailsById.clear();
    pendingHydratedResultRefs.clear();
    pendingBundleReleaseCatalogRefs.clear();
    pendingBundleReleaseDetailIds.clear();
  }
}

@immutable
class LibraryAddPreviewState {
  const LibraryAddPreviewState({
    this.hydratedResultsByRef = const {},
    this.bundleReleasesByCatalogRef = const {},
    this.bundleReleaseDetailsById = const {},
    this.pendingHydratedResultRefs = const {},
    this.pendingBundleReleaseCatalogRefs = const {},
    this.pendingBundleReleaseDetailIds = const {},
  });

  const LibraryAddPreviewState.initial() : this();

  final Map<CatalogEntityRef, CatalogSearchCandidate> hydratedResultsByRef;
  final Map<CatalogEntityRef, List<LibraryBundleSummary>>
      bundleReleasesByCatalogRef;
  final Map<String, LibraryBundleDetail> bundleReleaseDetailsById;
  final Set<CatalogEntityRef> pendingHydratedResultRefs;
  final Set<CatalogEntityRef> pendingBundleReleaseCatalogRefs;
  final Set<String> pendingBundleReleaseDetailIds;

  CatalogSearchCandidate? hydratedResultFor(CatalogEntityRef ref) =>
      hydratedResultsByRef[ref];

  bool hasHydratedResult(CatalogEntityRef ref) =>
      hydratedResultsByRef.containsKey(ref);

  bool isHydratedResultPending(CatalogEntityRef ref) =>
      pendingHydratedResultRefs.contains(ref);

  List<LibraryBundleSummary>? bundleReleasesFor(CatalogEntityRef ref) =>
      bundleReleasesByCatalogRef[ref];

  List<LibraryBundleSummary> bundleReleasesForItem(
    CatalogSearchCandidate? item,
  ) {
    if (item == null) return const <LibraryBundleSummary>[];
    return bundleReleasesByCatalogRef[item.reference] ??
        const <LibraryBundleSummary>[];
  }

  bool isBundleReleasesPending(CatalogEntityRef ref) =>
      pendingBundleReleaseCatalogRefs.contains(ref);

  LibraryBundleDetail? bundleReleaseDetailForId(String releaseId) =>
      bundleReleaseDetailsById[releaseId];

  LibraryBundleDetail? bundleReleaseDetailFor(String releaseId) =>
      bundleReleaseDetailsById[releaseId];

  bool isBundleReleaseDetailPending(String releaseId) =>
      pendingBundleReleaseDetailIds.contains(releaseId);

  LibraryAddPreviewState copyWith({
    Map<CatalogEntityRef, CatalogSearchCandidate>? hydratedResultsByRef,
    Map<CatalogEntityRef, List<LibraryBundleSummary>>?
        bundleReleasesByCatalogRef,
    Map<String, LibraryBundleDetail>? bundleReleaseDetailsById,
    Set<CatalogEntityRef>? pendingHydratedResultRefs,
    Set<CatalogEntityRef>? pendingBundleReleaseCatalogRefs,
    Set<String>? pendingBundleReleaseDetailIds,
  }) {
    return LibraryAddPreviewState(
      hydratedResultsByRef: hydratedResultsByRef ?? this.hydratedResultsByRef,
      bundleReleasesByCatalogRef:
          bundleReleasesByCatalogRef ?? this.bundleReleasesByCatalogRef,
      bundleReleaseDetailsById:
          bundleReleaseDetailsById ?? this.bundleReleaseDetailsById,
      pendingHydratedResultRefs:
          pendingHydratedResultRefs ?? this.pendingHydratedResultRefs,
      pendingBundleReleaseCatalogRefs: pendingBundleReleaseCatalogRefs ??
          this.pendingBundleReleaseCatalogRefs,
      pendingBundleReleaseDetailIds:
          pendingBundleReleaseDetailIds ?? this.pendingBundleReleaseDetailIds,
    );
  }
}
