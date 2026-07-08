import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

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

  bool hasHydratedResult(String itemId) {
    return hydratedResults.containsKey(itemId);
  }

  LibraryMetadataItem? hydratedResultFor(String itemId) {
    return hydratedResults[itemId];
  }

  void setHydratedResult(String itemId, LibraryMetadataItem item) {
    hydratedResults[itemId] = item;
    pendingHydratedResultIds.remove(itemId);
  }

  bool isHydratedResultPending(String itemId) {
    return pendingHydratedResultIds.contains(itemId);
  }

  List<BundleReleaseSummary> bundleReleasesForItem(
    LibraryMetadataItem? item,
  ) {
    if (item == null) {
      return const <BundleReleaseSummary>[];
    }
    return bundleReleasesByItemId[item.id] ?? const <BundleReleaseSummary>[];
  }

  void setBundleReleases(
    String itemId,
    List<BundleReleaseSummary> releases,
  ) {
    bundleReleasesByItemId[itemId] = releases;
    pendingBundleReleaseItemIds.remove(itemId);
  }

  bool isBundleReleasesPending(String itemId) {
    return pendingBundleReleaseItemIds.contains(itemId);
  }

  BundleReleaseDetail? bundleReleaseDetailForId(String? bundleReleaseId) {
    if (bundleReleaseId == null) {
      return null;
    }
    return bundleReleaseDetailsById[bundleReleaseId];
  }

  void setBundleReleaseDetail(
    String bundleReleaseId,
    BundleReleaseDetail detail,
  ) {
    bundleReleaseDetailsById[bundleReleaseId] = detail;
    pendingBundleReleaseDetailIds.remove(bundleReleaseId);
  }

  bool isBundleReleaseDetailPending(String bundleReleaseId) {
    return pendingBundleReleaseDetailIds.contains(bundleReleaseId);
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

  void clearAllCaches() {
    clearProviderCaches();
    clearSelectionCaches();
  }
}
