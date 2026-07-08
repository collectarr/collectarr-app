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

  void clearSelectionCaches() {
    hydratedResults.clear();
    bundleReleasesByItemId.clear();
    bundleReleaseDetailsById.clear();
    pendingHydratedResultIds.clear();
    pendingBundleReleaseItemIds.clear();
    pendingBundleReleaseDetailIds.clear();
  }

  List<BundleReleaseSummary> bundleReleasesForItem(
    LibraryMetadataItem? item,
  ) {
    if (item == null) {
      return const <BundleReleaseSummary>[];
    }
    return bundleReleasesByItemId[item.id] ?? const <BundleReleaseSummary>[];
  }

  BundleReleaseDetail? bundleReleaseDetailForId(String? bundleReleaseId) {
    if (bundleReleaseId == null) {
      return null;
    }
    return bundleReleaseDetailsById[bundleReleaseId];
  }
}
