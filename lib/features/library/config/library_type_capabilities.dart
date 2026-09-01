import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';

export 'package:collectarr_app/features/library/config/library_ui_policy.dart';

enum LibraryContentHierarchy {
  flat,
  volumes,
  seasons,
}

class LibraryTypeCapabilities {
  const LibraryTypeCapabilities.empty() : this();

  const LibraryTypeCapabilities({
    this.showsSynopsis = true,
    this.showsCreatorSpotlight = false,
    this.showsTrackData = false,
    bool showsReadingQueue = false,
    bool? supportsReadingQueue,
    bool showsIndexReassignment = false,
    bool? supportsIndexReassignment,
    this.canScanCover = true,
    this.prefersSquareCovers = false,
    this.coverAspectRatio = 1.53,
    this.supportsOwnedItemImages = true,
    this.supportsMediaReleaseSplit = false,
    bool supportsMetadataCompareWithServer = false,
    bool? supportsMetadataCompare,
    this.supportsSeriesSubgroups = false,
    this.wideDialog = false,
    this.contentHierarchy = LibraryContentHierarchy.flat,
    this.groupModeCategoriesBuilder,
    this.mediaScopeGroupIds,
    this.releaseScopeGroupIds,
    this.mediaScopeSortIds,
    this.releaseScopeSortIds,
  })  : showsReadingQueue = supportsReadingQueue ?? showsReadingQueue,
        showsIndexReassignment =
            supportsIndexReassignment ?? showsIndexReassignment,
        supportsMetadataCompareWithServer =
            supportsMetadataCompare ?? supportsMetadataCompareWithServer;

  final bool showsSynopsis;
  final bool showsCreatorSpotlight;
  final bool showsTrackData;
  final bool showsReadingQueue;
  final bool showsIndexReassignment;
  final bool canScanCover;
  final bool prefersSquareCovers;
  final double coverAspectRatio;
  final bool supportsOwnedItemImages;
  final bool supportsMediaReleaseSplit;
  final bool supportsMetadataCompareWithServer;
  final bool supportsSeriesSubgroups;
  final bool wideDialog;
  final LibraryContentHierarchy contentHierarchy;
  final LibraryGroupModeCategoryBuilder? groupModeCategoriesBuilder;

  final Set<String>? mediaScopeGroupIds;
  final Set<String>? releaseScopeGroupIds;
  final Set<String>? mediaScopeSortIds;
  final Set<String>? releaseScopeSortIds;

  bool get supportsReadingQueue => showsReadingQueue;
  bool get supportsIndexReassignment => showsIndexReassignment;
  bool get supportsMetadataCompare => supportsMetadataCompareWithServer;

  bool get usesSeasonHierarchy =>
      contentHierarchy == LibraryContentHierarchy.seasons;

  bool get scopesOptionsByBrowserMode =>
      supportsMediaReleaseSplit &&
      (mediaScopeGroupIds != null ||
          releaseScopeGroupIds != null ||
          mediaScopeSortIds != null ||
          releaseScopeSortIds != null);

  LibraryUiPolicy get uiPolicy => LibraryUiPolicy(
        coverAspectRatio: prefersSquareCovers ? 1.0 : coverAspectRatio,
        wideDialog: wideDialog,
        prefersSquareCovers: prefersSquareCovers,
        canScanCover: canScanCover,
        supportsOwnedItemImages: supportsOwnedItemImages,
      );
}
