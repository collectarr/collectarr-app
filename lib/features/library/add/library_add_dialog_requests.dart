part of 'library_add_dialog.dart';

// Pluggable pane builder typedefs and their request payloads for the
// library add dialog. Extracted from library_add_dialog.dart to keep the
// dialog state file focused on behavior.

typedef LibraryAddManualPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddManualPaneRequest request,
);

typedef LibraryAddPreviewPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddPreviewPaneRequest request,
);

typedef LibraryAddHeaderBuilder = Widget Function(
  BuildContext context,
  LibraryAddHeaderRequest request,
);

typedef LibraryAddModeBarBuilder = Widget Function(
  BuildContext context,
  LibraryAddModeBarRequest request,
);

typedef LibraryAddSearchPaneBuilder = Widget Function(
  BuildContext context,
  LibraryAddSearchPaneRequest request,
);

typedef LibraryAddBottomBarBuilder = Widget Function(
  BuildContext context,
  LibraryAddBottomBarRequest request,
);

class LibraryAddManualPaneRequest {
  const LibraryAddManualPaneRequest({
    required this.type,
    required this.accent,
    required this.titleController,
    required this.numberController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.variantController,
    required this.physicalFormatLabelController,
    required this.coverController,
    required this.backCoverController,
    required this.creatorsController,
    required this.charactersController,
    required this.physicalFormats,
    required this.physicalFormatId,
    required this.onPhysicalFormatChanged,
    required this.onPhysicalFormatLabelChanged,
    required this.isAdding,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.defaultTags,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onAddTrack,
    required this.editionTitleController,
    required this.releaseDateController,
    required this.pageCountController,
    required this.imprintController,
    required this.seriesGroupController,
    required this.countryController,
    required this.languageController,
    required this.ageRatingController,
    required this.genresEditController,
    required this.synopsisController,
    required this.tagsController,
    required this.publisherOptions,
    required this.imprintOptions,
    required this.seriesGroupOptions,
    required this.physicalFormatOptions,
    required this.seriesEntries,
    required this.onManagePublishers,
    required this.onManageImprints,
    required this.onManageSeriesGroups,
    required this.onManagePhysicalFormats,
    required this.onManageSeries,
    required this.onSeriesChanged,
    this.kindSpecific = const {},
    required this.customFieldDefinitions,
    required this.customFieldValues,
    required this.onCustomFieldValuesChanged,
    required this.itemImages,
    required this.onItemImagesChanged,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final TextEditingController titleController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatLabelController;
  final TextEditingController coverController;
  final TextEditingController backCoverController;
  final TextEditingController creatorsController;
  final TextEditingController charactersController;
  final List<PhysicalMediaFormat> physicalFormats;
  final String? physicalFormatId;
  final ValueChanged<String?> onPhysicalFormatChanged;
  final ValueChanged<String?> onPhysicalFormatLabelChanged;
  final bool isAdding;
  final String defaultCondition;
  final String defaultGrade;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final String? defaultTags;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;
  final VoidCallback onAddTrack;

  // Additional catalog & personal fields for the tabbed manual interface
  final TextEditingController editionTitleController;
  final TextEditingController releaseDateController;
  final TextEditingController pageCountController;
  final TextEditingController imprintController;
  final TextEditingController seriesGroupController;
  final TextEditingController countryController;
  final TextEditingController languageController;
  final TextEditingController ageRatingController;
  final TextEditingController genresEditController;
  final TextEditingController synopsisController;
  final TextEditingController tagsController;
  final List<String> publisherOptions;
  final List<String> imprintOptions;
  final List<String> seriesGroupOptions;
  final List<String> physicalFormatOptions;
  final List<SeriesRegistryEntry> seriesEntries;
  final VoidCallback onManagePublishers;
  final VoidCallback onManageImprints;
  final VoidCallback onManageSeriesGroups;
  final VoidCallback onManagePhysicalFormats;
  final VoidCallback onManageSeries;
  final ValueChanged<String?> onSeriesChanged;
  final Map<String, dynamic> kindSpecific;

  // Custom fields and images
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, String?> customFieldValues;
  final ValueChanged<Map<String, String?>> onCustomFieldValuesChanged;
  final List<ItemImage> itemImages;
  final ValueChanged<List<ItemImageEdit>> onItemImagesChanged;

  // (kindSpecific declared above)
}

// Public default manual pane builder so kinds can register a fallback that
// delegates to the generic tabbed manual UI implemented in this library.
Widget buildDefaultManualPane(
    BuildContext context, LibraryAddManualPaneRequest request) {
  return _ManualPane(request: request);
}

class LibraryAddPreviewPaneRequest {
  const LibraryAddPreviewPaneRequest({
    required this.type,
    required this.accent,
    required this.item,
    required this.candidate,
    required this.candidatePreview,
    required this.isFetchingPreview,
    required this.providerLabel,
    required this.searched,
    required this.addTarget,
    required this.referenceType,
    required this.availableBundleReleases,
    required this.selectedBundleReleaseId,
    required this.selectedBundleReleaseDetail,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.isLoadingBundleReleases,
    required this.isLoadingBundleReleaseDetail,
    required this.onReferenceTypeChanged,
    required this.onEditionSelected,
    required this.onVariantSelected,
    required this.onBundleReleaseSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryMetadataItem? item;
  final ProviderCandidate? candidate;
  final AdminProviderPreview? candidatePreview;
  final bool isFetchingPreview;
  final String providerLabel;
  final bool searched;
  final LibraryAddTarget addTarget;
  final LibraryAddReferenceType referenceType;
  final List<BundleReleaseSummary> availableBundleReleases;
  final String? selectedBundleReleaseId;
  final BundleReleaseDetail? selectedBundleReleaseDetail;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final bool isLoadingBundleReleases;
  final bool isLoadingBundleReleaseDetail;
  final ValueChanged<LibraryAddReferenceType> onReferenceTypeChanged;
  final ValueChanged<String> onEditionSelected;
  final ValueChanged<String> onVariantSelected;
  final ValueChanged<String> onBundleReleaseSelected;
}

class LibraryAddHeaderRequest {
  const LibraryAddHeaderRequest({
    required this.type,
    required this.accent,
    required this.isMovieDesktopChrome,
    required this.onClose,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final bool isMovieDesktopChrome;
  final VoidCallback onClose;
}

class LibraryAddModeBarRequest {
  const LibraryAddModeBarRequest({
    required this.type,
    required this.accent,
    required this.isMovieDesktopChrome,
    required this.mode,
    required this.queryController,
    required this.barcodeController,
    required this.isSearching,
    required this.isSearchingProvider,
    required this.onModeChanged,
    required this.onSearch,
    required this.onQueryChanged,
    required this.suggestions,
    required this.showSuggestions,
    required this.onSelectSuggestion,
    required this.onDismissSuggestions,
    required this.canScanCover,
    required this.isScanningCover,
    required this.onScanCover,
    required this.onLookupBarcode,
    required this.onManual,
    required this.showAdvanced,
    required this.onToggleAdvanced,
    required this.seriesController,
    required this.numberController,
    required this.publisherController,
    required this.yearController,
    required this.videoKindFilters,
    required this.onVideoKindFilterChanged,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final bool isMovieDesktopChrome;
  final LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isSearchingProvider;
  final ValueChanged<LibraryAddDialogMode> onModeChanged;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final List<LibraryMetadataItem> suggestions;
  final bool showSuggestions;
  final ValueChanged<LibraryMetadataItem> onSelectSuggestion;
  final VoidCallback onDismissSuggestions;
  final bool canScanCover;
  final bool isScanningCover;
  final VoidCallback onScanCover;
  final VoidCallback onLookupBarcode;
  final VoidCallback onManual;
  final bool showAdvanced;
  final VoidCallback onToggleAdvanced;
  final TextEditingController seriesController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final Set<String>? videoKindFilters;
  final void Function(String kind, bool checked)? onVideoKindFilterChanged;
}

class LibraryAddSearchPaneRequest {
  const LibraryAddSearchPaneRequest({
    required this.type,
    required this.isBusy,
    required this.isMovieDesktopChrome,
    required this.error,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedProvider,
    required this.searchedProvider,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.checkedResultIds,
    required this.checkedProviderIds,
    required this.ownedCatalogItemIds,
    required this.providerQueryText,
    required this.providerSeriesText,
    required this.providerNumberText,
    required this.providerPublisherText,
    required this.providerYearText,
    required this.showCoreResults,
    required this.showProviderResults,
    required this.showMediaResults,
    required this.showReleaseResults,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
    required this.onShowCoreResultsChanged,
    required this.onShowProviderResultsChanged,
    required this.onShowMediaResultsChanged,
    required this.onShowReleaseResultsChanged,
    required this.onSearchCore,
  });

  final LibraryTypeConfig type;
  final bool isBusy;
  final bool isMovieDesktopChrome;
  final String? error;
  final Color accent;
  final List<LibraryMetadataItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, LibraryQueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final bool searchedProvider;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final Set<String> checkedResultIds;
  final Set<String> checkedProviderIds;
  final Set<String> ownedCatalogItemIds;
  final String providerQueryText;
  final String providerSeriesText;
  final String providerNumberText;
  final String providerPublisherText;
  final String providerYearText;
  final bool showCoreResults;
  final bool showProviderResults;
  final bool showMediaResults;
  final bool showReleaseResults;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
  final ValueChanged<bool> onShowCoreResultsChanged;
  final ValueChanged<bool> onShowProviderResultsChanged;
  final ValueChanged<bool> onShowMediaResultsChanged;
  final ValueChanged<bool> onShowReleaseResultsChanged;
  final VoidCallback onSearchCore;
}

class LibraryAddBottomBarRequest {
  const LibraryAddBottomBarRequest({
    required this.type,
    required this.isMovieDesktopChrome,
    required this.conditions,
    required this.grades,
    required this.defaultTags,
    required this.accent,
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedQueuedIngest,
    required this.providerLabel,
    required this.addTarget,
    required this.addCount,
    required this.isAdding,
    required this.isQueueingIngest,
    required this.isAdmin,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultLocationLabel,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onDefaultGradeChanged,
    required this.onEditDefaultTagsPressed,
    required this.onDefaultLocationPressed,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onQueueIngest,
    required this.onPropose,
  });

  final LibraryTypeConfig type;
  final bool isMovieDesktopChrome;
  final List<String> conditions;
  final List<String> grades;
  final String? defaultTags;
  final Color accent;
  final LibraryMetadataItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final LibraryQueuedProviderIngest? selectedQueuedIngest;
  final String providerLabel;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isAdding;
  final bool isQueueingIngest;
  final bool isAdmin;
  final String defaultCondition;
  final String defaultGrade;
  final String? defaultLocationLabel;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String> onDefaultConditionChanged;
  final ValueChanged<String> onDefaultGradeChanged;
  final VoidCallback onEditDefaultTagsPressed;
  final VoidCallback onDefaultLocationPressed;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onQueueIngest;
  final VoidCallback? onPropose;
}
