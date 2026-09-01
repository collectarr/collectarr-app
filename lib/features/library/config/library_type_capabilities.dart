import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/material.dart';

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
    this.supportsTrackSearch = false,
    this.usesTrackListCard = false,
    this.showsSeasonGroupProgress = false,
    this.usesCompactTableLayout = false,
    this.compactBucketIcon = Icons.folder,
    this.emptyStateProviderSummarySuffix = '',
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
  final bool supportsTrackSearch;
  final bool usesTrackListCard;
  final bool showsSeasonGroupProgress;
  final bool usesCompactTableLayout;
  final IconData compactBucketIcon;
  final String emptyStateProviderSummarySuffix;
  final bool showsReadingQueue;
  final bool showsIndexReassignment;
  final bool canScanCover;
  final bool prefersSquareCovers;
  final double coverAspectRatio;
  final bool supportsOwnedItemImages;
  final bool supportsMediaReleaseSplit;
  final bool supportsMetadataCompareWithServer;
  final bool wideDialog;
  final LibraryContentHierarchy contentHierarchy;
  final LibraryGroupModeCategoryBuilder? groupModeCategoriesBuilder;

  final Set<LibraryGroupIdRuntime>? mediaScopeGroupIds;
  final Set<LibraryGroupIdRuntime>? releaseScopeGroupIds;
  final Set<LibrarySortIdRuntime>? mediaScopeSortIds;
  final Set<LibrarySortIdRuntime>? releaseScopeSortIds;

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
