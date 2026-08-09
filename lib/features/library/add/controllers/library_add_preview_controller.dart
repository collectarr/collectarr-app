import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/foundation.dart';

class LibraryAddPreviewController {
  final providerPreviews = <String, AdminProviderPreview>{};
  final hydratedResults = <String, LibraryMetadataItem>{};
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

  LibraryMetadataItem? hydratedResultFor(String itemId) {
    return hydratedResults[itemId];
  }

  void setHydratedResult(String itemId, LibraryMetadataItem item) {
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
  const LibraryAddPreviewState();
  const LibraryAddPreviewState.initial();
}
