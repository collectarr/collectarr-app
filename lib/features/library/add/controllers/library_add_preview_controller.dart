import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/foundation.dart';

class LibraryAddPreviewController {
  final providerPreviews = <String, AdminProviderPreview>{};
  final hydratedResults = <String, CatalogItem>{};
  final bundleReleasesByItemId = <String, List<BundleReleaseSummary>>{};
  final bundleReleaseDetailsById = <String, BundleReleaseDetail>{};
  final queuedProviderIngests = <String, LibraryQueuedProviderIngest>{};
  final pendingHydratedResultIds = <String>{};
  final pendingBundleReleaseItemIds = <String>{};
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

  CatalogItem? hydratedResultFor(String itemId) {
    return hydratedResults[itemId];
  }

  bool hasHydratedResult(String itemId) {
    return hydratedResults.containsKey(itemId);
  }

  void setHydratedResult(String itemId, CatalogItem item) {
    hydratedResults[itemId] = item;
    pendingHydratedResultIds.remove(itemId);
  }

  void markHydratedResultPending(String itemId) {
    pendingHydratedResultIds.add(itemId);
  }

  bool isHydratedResultPending(String itemId) {
    return pendingHydratedResultIds.contains(itemId);
  }

  List<BundleReleaseSummary>? bundleReleasesFor(String itemId) {
    return bundleReleasesByItemId[itemId];
  }

  List<BundleReleaseSummary> bundleReleasesForItem(CatalogItem? item) {
    if (item == null) {
      return const <BundleReleaseSummary>[];
    }
    return bundleReleasesByItemId[item.id] ?? const <BundleReleaseSummary>[];
  }

  void setBundleReleases(
    String itemId,
    List<BundleReleaseSummary> releases,
  ) {
    bundleReleasesByItemId[itemId] = List.unmodifiable(releases);
    pendingBundleReleaseItemIds.remove(itemId);
  }

  void markBundleReleasesPending(String itemId) {
    pendingBundleReleaseItemIds.add(itemId);
  }

  bool isBundleReleasesPending(String itemId) {
    return pendingBundleReleaseItemIds.contains(itemId);
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
    hydratedResults.clear();
    bundleReleasesByItemId.clear();
    bundleReleaseDetailsById.clear();
    pendingHydratedResultIds.clear();
    pendingBundleReleaseItemIds.clear();
    pendingBundleReleaseDetailIds.clear();
  }

  void reset() {
    clearProviderCaches();
    clearSelectionCaches();
  }

  void dispose() {
    providerPreviews.clear();
    hydratedResults.clear();
    bundleReleasesByItemId.clear();
    bundleReleaseDetailsById.clear();
    queuedProviderIngests.clear();
    pendingHydratedResultIds.clear();
    pendingBundleReleaseItemIds.clear();
    pendingBundleReleaseDetailIds.clear();
    pendingProviderPreviewIds.clear();
  }
}

@immutable
class LibraryAddPreviewState {
  const LibraryAddPreviewState({
    this.providerPreviews = const {},
    this.hydratedResults = const {},
    this.bundleReleasesByItemId = const {},
    this.bundleReleaseDetailsById = const {},
    this.queuedProviderIngests = const {},
    this.pendingHydratedResultIds = const {},
    this.pendingBundleReleaseItemIds = const {},
    this.pendingBundleReleaseDetailIds = const {},
    this.pendingProviderPreviewIds = const {},
    this.isQueueingIngest = false,
  });

  const LibraryAddPreviewState.initial() : this();

  final Map<String, AdminProviderPreview> providerPreviews;
  final Map<String, CatalogItem> hydratedResults;
  final Map<String, List<BundleReleaseSummary>> bundleReleasesByItemId;
  final Map<String, BundleReleaseDetail> bundleReleaseDetailsById;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final Set<String> pendingHydratedResultIds;
  final Set<String> pendingBundleReleaseItemIds;
  final Set<String> pendingBundleReleaseDetailIds;
  final Set<String> pendingProviderPreviewIds;
  final bool isQueueingIngest;

  AdminProviderPreview? providerPreviewFor(String candidateId) =>
      providerPreviews[candidateId];

  bool isProviderPreviewPending(String candidateId) =>
      pendingProviderPreviewIds.contains(candidateId);

  LibraryQueuedProviderIngest? queuedProviderIngestFor(String candidateId) =>
      queuedProviderIngests[candidateId];

  CatalogItem? hydratedResultFor(String itemId) =>
      hydratedResults[itemId];

  bool hasHydratedResult(String itemId) => hydratedResults.containsKey(itemId);

  bool isHydratedResultPending(String itemId) =>
      pendingHydratedResultIds.contains(itemId);

  List<BundleReleaseSummary>? bundleReleasesFor(String itemId) =>
      bundleReleasesByItemId[itemId];

  List<BundleReleaseSummary> bundleReleasesForItem(CatalogItem? item) {
    if (item == null) return const <BundleReleaseSummary>[];
    return bundleReleasesByItemId[item.id] ?? const <BundleReleaseSummary>[];
  }

  bool isBundleReleasesPending(String itemId) =>
      pendingBundleReleaseItemIds.contains(itemId);

  BundleReleaseDetail? bundleReleaseDetailForId(String releaseId) =>
      bundleReleaseDetailsById[releaseId];

  BundleReleaseDetail? bundleReleaseDetailFor(String releaseId) =>
      bundleReleaseDetailsById[releaseId];

  bool isBundleReleaseDetailPending(String releaseId) =>
      pendingBundleReleaseDetailIds.contains(releaseId);

  LibraryAddPreviewState copyWith({
    Map<String, AdminProviderPreview>? providerPreviews,
    Map<String, CatalogItem>? hydratedResults,
    Map<String, List<BundleReleaseSummary>>? bundleReleasesByItemId,
    Map<String, BundleReleaseDetail>? bundleReleaseDetailsById,
    Map<String, LibraryQueuedProviderIngest>? queuedProviderIngests,
    Set<String>? pendingHydratedResultIds,
    Set<String>? pendingBundleReleaseItemIds,
    Set<String>? pendingBundleReleaseDetailIds,
    Set<String>? pendingProviderPreviewIds,
    bool? isQueueingIngest,
  }) {
    return LibraryAddPreviewState(
      providerPreviews: providerPreviews ?? this.providerPreviews,
      hydratedResults: hydratedResults ?? this.hydratedResults,
      bundleReleasesByItemId:
          bundleReleasesByItemId ?? this.bundleReleasesByItemId,
      bundleReleaseDetailsById:
          bundleReleaseDetailsById ?? this.bundleReleaseDetailsById,
      queuedProviderIngests:
          queuedProviderIngests ?? this.queuedProviderIngests,
      pendingHydratedResultIds:
          pendingHydratedResultIds ?? this.pendingHydratedResultIds,
      pendingBundleReleaseItemIds:
          pendingBundleReleaseItemIds ?? this.pendingBundleReleaseItemIds,
      pendingBundleReleaseDetailIds:
          pendingBundleReleaseDetailIds ?? this.pendingBundleReleaseDetailIds,
      pendingProviderPreviewIds:
          pendingProviderPreviewIds ?? this.pendingProviderPreviewIds,
      isQueueingIngest: isQueueingIngest ?? this.isQueueingIngest,
    );
  }
}
