import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_bundle_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/foundation.dart';

class LibraryAddPreviewController {
  final providerPreviews = <String, AdminProviderPreview>{};
  final hydratedResultsByRef = <CatalogEntityRef, CatalogSearchCandidate>{};
  final bundleReleasesByCatalogRef =
      <CatalogEntityRef, List<LibraryBundleSummary>>{};
  final bundleReleaseDetailsById = <String, BundleReleaseDetail>{};
  final queuedProviderIngests = <String, LibraryQueuedProviderIngest>{};
  final pendingHydratedResultRefs = <CatalogEntityRef>{};
  final pendingBundleReleaseCatalogRefs = <CatalogEntityRef>{};
  final pendingBundleReleaseDetailIds = <String>{};
  final pendingProviderPreviewIds = <String>{};
  bool isQueueingIngest = false;

  AdminProviderPreview? providerPreviewFor(String candidateId) {
    return providerPreviews[candidateId];
  }

  void setProviderPreview(String candidateId, AdminProviderPreview preview) {
    providerPreviews[candidateId] = preview;
    pendingProviderPreviewIds.remove(candidateId);
  }

  void markProviderPreviewPending(String candidateId) {
    pendingProviderPreviewIds.add(candidateId);
  }

  bool isProviderPreviewPending(String candidateId) {
    return pendingProviderPreviewIds.contains(candidateId);
  }

  LibraryQueuedProviderIngest? queuedProviderIngestFor(String candidateId) {
    return queuedProviderIngests[candidateId];
  }

  void setQueuedProviderIngest(
    String candidateId,
    LibraryQueuedProviderIngest ingest,
  ) {
    queuedProviderIngests[candidateId] = ingest;
  }

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
    return bundleReleasesByCatalogRef[item.catalogRef] ??
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

  BundleReleaseDetail? bundleReleaseDetailForId(String releaseId) {
    return bundleReleaseDetailsById[releaseId];
  }

  BundleReleaseDetail? bundleReleaseDetailFor(String releaseId) {
    return bundleReleaseDetailsById[releaseId];
  }

  void setBundleReleaseDetail(
    String releaseId,
    BundleReleaseDetail detail,
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

  void clearProviderCaches() {
    providerPreviews.clear();
    queuedProviderIngests.clear();
    pendingProviderPreviewIds.clear();
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
    clearProviderCaches();
    clearSelectionCaches();
  }

  void dispose() {
    providerPreviews.clear();
    hydratedResultsByRef.clear();
    bundleReleasesByCatalogRef.clear();
    bundleReleaseDetailsById.clear();
    queuedProviderIngests.clear();
    pendingHydratedResultRefs.clear();
    pendingBundleReleaseCatalogRefs.clear();
    pendingBundleReleaseDetailIds.clear();
    pendingProviderPreviewIds.clear();
  }
}

@immutable
class LibraryAddPreviewState {
  const LibraryAddPreviewState({
    this.providerPreviews = const {},
    this.hydratedResultsByRef = const {},
    this.bundleReleasesByCatalogRef = const {},
    this.bundleReleaseDetailsById = const {},
    this.queuedProviderIngests = const {},
    this.pendingHydratedResultRefs = const {},
    this.pendingBundleReleaseCatalogRefs = const {},
    this.pendingBundleReleaseDetailIds = const {},
    this.pendingProviderPreviewIds = const {},
    this.isQueueingIngest = false,
  });

  const LibraryAddPreviewState.initial() : this();

  final Map<String, AdminProviderPreview> providerPreviews;
  final Map<CatalogEntityRef, CatalogSearchCandidate> hydratedResultsByRef;
  final Map<CatalogEntityRef, List<LibraryBundleSummary>>
      bundleReleasesByCatalogRef;
  final Map<String, BundleReleaseDetail> bundleReleaseDetailsById;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final Set<CatalogEntityRef> pendingHydratedResultRefs;
  final Set<CatalogEntityRef> pendingBundleReleaseCatalogRefs;
  final Set<String> pendingBundleReleaseDetailIds;
  final Set<String> pendingProviderPreviewIds;
  final bool isQueueingIngest;

  AdminProviderPreview? providerPreviewFor(String candidateId) =>
      providerPreviews[candidateId];

  bool isProviderPreviewPending(String candidateId) =>
      pendingProviderPreviewIds.contains(candidateId);

  LibraryQueuedProviderIngest? queuedProviderIngestFor(String candidateId) =>
      queuedProviderIngests[candidateId];

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
    return bundleReleasesByCatalogRef[item.catalogRef] ??
        const <LibraryBundleSummary>[];
  }

  bool isBundleReleasesPending(CatalogEntityRef ref) =>
      pendingBundleReleaseCatalogRefs.contains(ref);

  BundleReleaseDetail? bundleReleaseDetailForId(String releaseId) =>
      bundleReleaseDetailsById[releaseId];

  BundleReleaseDetail? bundleReleaseDetailFor(String releaseId) =>
      bundleReleaseDetailsById[releaseId];

  bool isBundleReleaseDetailPending(String releaseId) =>
      pendingBundleReleaseDetailIds.contains(releaseId);

  LibraryAddPreviewState copyWith({
    Map<String, AdminProviderPreview>? providerPreviews,
    Map<CatalogEntityRef, CatalogSearchCandidate>? hydratedResultsByRef,
    Map<CatalogEntityRef, List<LibraryBundleSummary>>?
        bundleReleasesByCatalogRef,
    Map<String, BundleReleaseDetail>? bundleReleaseDetailsById,
    Map<String, LibraryQueuedProviderIngest>? queuedProviderIngests,
    Set<CatalogEntityRef>? pendingHydratedResultRefs,
    Set<CatalogEntityRef>? pendingBundleReleaseCatalogRefs,
    Set<String>? pendingBundleReleaseDetailIds,
    Set<String>? pendingProviderPreviewIds,
    bool? isQueueingIngest,
  }) {
    return LibraryAddPreviewState(
      providerPreviews: providerPreviews ?? this.providerPreviews,
      hydratedResultsByRef: hydratedResultsByRef ?? this.hydratedResultsByRef,
      bundleReleasesByCatalogRef:
          bundleReleasesByCatalogRef ?? this.bundleReleasesByCatalogRef,
      bundleReleaseDetailsById:
          bundleReleaseDetailsById ?? this.bundleReleaseDetailsById,
      queuedProviderIngests:
          queuedProviderIngests ?? this.queuedProviderIngests,
      pendingHydratedResultRefs:
          pendingHydratedResultRefs ?? this.pendingHydratedResultRefs,
      pendingBundleReleaseCatalogRefs: pendingBundleReleaseCatalogRefs ??
          this.pendingBundleReleaseCatalogRefs,
      pendingBundleReleaseDetailIds:
          pendingBundleReleaseDetailIds ?? this.pendingBundleReleaseDetailIds,
      pendingProviderPreviewIds:
          pendingProviderPreviewIds ?? this.pendingProviderPreviewIds,
      isQueueingIngest: isQueueingIngest ?? this.isQueueingIngest,
    );
  }
}
