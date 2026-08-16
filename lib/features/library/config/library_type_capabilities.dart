import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';

enum LibraryContentHierarchy {
  flat,
  volumes,
  seasons,
}

class LibraryTypeCapabilities {
  const LibraryTypeCapabilities.empty() : this();

  const LibraryTypeCapabilities({
    this.showsSynopsis = false,
    this.showsImprint = false,
    this.showsGenre = true,
    this.showsRating = false,
    this.showsAudienceRating = false,
    this.showsLanguage = false,
    this.showsCountry = false,
    this.showsOriginalLanguage = false,
    this.showsOriginalCountry = false,
    this.showsOriginalTitle = false,
    this.showsCondition = true,
    this.showsGrade = false,
    this.showsGradingNotes = false,
    this.showsGradingCertificate = false,
    this.showsGradingCompany = false,
    this.showsSignedBy = false,
    this.showsKeyReason = false,
    this.showsLocation = true,
    this.showsStorageBox = false,
    this.showsQuantity = false,
    this.showsCurrency = true,
    this.showsPricePaid = true,
    this.showsEstimatedValue = false,
    this.showsNotes = true,
    this.showsTags = true,
    bool showsReadingQueue = false,
    bool? supportsReadingQueue,
    this.showsReadingProgress = false,
    this.showsReadingDates = false,
    this.showsReadStatus = false,
    this.showsCreatorSpotlight = false,
    this.showsTrackSpotlight = false,
    this.showsTrackData = false,
    bool showsIndexReassignment = false,
    bool? supportsIndexReassignment,
    this.showsBarcodeScan = true,
    this.showsCoverImageScan = true,
    this.showsBulkEdit = true,
    this.showsExport = true,
    this.canScanBarcode = true,
    this.canScanCover = true,
    this.prefersSquareCovers = false,
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
  final bool showsImprint;
  final bool showsGenre;
  final bool showsRating;
  final bool showsAudienceRating;
  final bool showsLanguage;
  final bool showsCountry;
  final bool showsOriginalLanguage;
  final bool showsOriginalCountry;
  final bool showsOriginalTitle;
  final bool showsCondition;
  final bool showsGrade;
  final bool showsGradingNotes;
  final bool showsGradingCertificate;
  final bool showsGradingCompany;
  final bool showsSignedBy;
  final bool showsKeyReason;
  final bool showsLocation;
  final bool showsStorageBox;
  final bool showsQuantity;
  final bool showsCurrency;
  final bool showsPricePaid;
  final bool showsEstimatedValue;
  final bool showsNotes;
  final bool showsTags;
  final bool showsReadingQueue;
  final bool showsReadingProgress;
  final bool showsReadingDates;
  final bool showsReadStatus;
  final bool showsCreatorSpotlight;
  final bool showsTrackSpotlight;
  final bool showsTrackData;
  final bool showsIndexReassignment;
  final bool showsBarcodeScan;
  final bool showsCoverImageScan;
  final bool showsBulkEdit;
  final bool showsExport;
  final bool canScanBarcode;
  final bool canScanCover;
  final bool prefersSquareCovers;
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
}
