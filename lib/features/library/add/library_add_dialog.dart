import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/compact_controls.dart';
import 'package:collectarr_app/features/library/add/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
export 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/add/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part 'library_add_mode_bar.dart';
part 'library_add_search_pane.dart';
part 'library_add_search_comic.dart';
part 'library_add_search_unified.dart';
part 'library_add_preview_pane.dart';
part 'library_add_bottom_bar.dart';
part 'library_add_manual_pane.dart';
part 'library_add_dialog_selection_state.dart';
part 'library_add_provider_ingest.dart';

String buildPreviewCatalogItemId({
  required String kind,
  required String provider,
  required String providerItemId,
}) {
  final previewKey = '$kind:$provider:$providerItemId';
  return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
}

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
    required this.coverController,
    required this.backCoverController,
    required this.creatorsController,
    required this.charactersController,
    required this.physicalFormats,
    required this.physicalFormatId,
    required this.onPhysicalFormatChanged,
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
    required this.rawOrSlabbedController,
    required this.gradingCompanyController,
    required this.graderNotesController,
    required this.signedByController,
    required this.labelTypeController,
    required this.certificationNumberController,
    required this.coverPriceController,
    required this.purchasePriceController,
    required this.purchaseDateController,
    required this.purchaseStoreController,
    required this.soldPriceController,
    required this.soldDateController,
    required this.ownerLabelController,
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
  final TextEditingController coverController;
  final TextEditingController backCoverController;
  final TextEditingController creatorsController;
  final TextEditingController charactersController;
  final List<PhysicalMediaFormat> physicalFormats;
  final String? physicalFormatId;
  final ValueChanged<String?> onPhysicalFormatChanged;
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

  // Comics-specific / personal fields
  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController signedByController;
  final TextEditingController labelTypeController;
  final TextEditingController certificationNumberController;
  final TextEditingController coverPriceController;
  final TextEditingController purchasePriceController;
  final TextEditingController purchaseDateController;
  final TextEditingController purchaseStoreController;
  final TextEditingController soldPriceController;
  final TextEditingController soldDateController;
  final TextEditingController ownerLabelController;

  // Custom fields and images
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, String?> customFieldValues;
  final ValueChanged<Map<String, String?>> onCustomFieldValuesChanged;
  final List<ItemImage> itemImages;
  final ValueChanged<List<ItemImageEdit>> onItemImagesChanged;
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
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onToggleResultCheck,
    required this.onToggleProviderCheck,
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
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final ValueChanged<String> onToggleResultCheck;
  final ValueChanged<String> onToggleProviderCheck;
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

class LibraryAddDialog extends ConsumerStatefulWidget {
  const LibraryAddDialog({
    super.key,
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialBarcode,
    this.autoLookupInitialBarcode = true,
    this.coverScanService = const LocalLibraryCoverScanService(),
    this.manualPaneBuilder,
    this.previewPaneBuilder,
    this.headerBuilder,
    this.modeBarBuilder,
    this.searchPaneBuilder,
    this.bottomBarBuilder,
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final LibraryTypeConfig type;
  final Color? accent;
  final String? initialQuery;
  final String? initialBarcode;
  final bool autoLookupInitialBarcode;
  final LibraryCoverScanService coverScanService;
  final LibraryAddManualPaneBuilder? manualPaneBuilder;
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  final LibraryAddHeaderBuilder? headerBuilder;
  final LibraryAddModeBarBuilder? modeBarBuilder;
  final LibraryAddSearchPaneBuilder? searchPaneBuilder;
  final LibraryAddBottomBarBuilder? bottomBarBuilder;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  @override
  ConsumerState<LibraryAddDialog> createState() => _LibraryAddDialogState();
}

class _LibraryAddDialogState extends ConsumerState<LibraryAddDialog> {
  /// Wrapper so part-file extensions can call setState without triggering
  /// invalid_use_of_protected_member.
  void _rebuild([VoidCallback? fn]) {
    // ignore: invalid_use_of_protected_member
    setState(fn ?? () {});
  }

  final _queryController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _variantController = TextEditingController();
  final _coverController = TextEditingController();
  final _backCoverController = TextEditingController();
  final _creatorsController = TextEditingController();
  final _charactersController = TextEditingController();
  final _editionTitleController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _imprintController = TextEditingController();
  final _seriesGroupController = TextEditingController();
  final _countryController = TextEditingController();
  final _languageController = TextEditingController();
  final _ageRatingController = TextEditingController();
  final _genresEditController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _tagsController = TextEditingController();
  final _rawOrSlabbedController = TextEditingController();
  final _gradingCompanyController = TextEditingController();
  final _graderNotesController = TextEditingController();
  final _signedByController = TextEditingController();
  final _labelTypeController = TextEditingController();
  final _certificationNumberController = TextEditingController();
  final _coverPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _purchaseStoreController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _ownerLabelController = TextEditingController();
  DateTime? _soldAt;
  final _uuid = const Uuid();

  // Advanced search fields
  final _searchSeriesController = TextEditingController();
  final _searchNumberController = TextEditingController();
  final _searchPublisherController = TextEditingController();
  final _searchYearController = TextEditingController();
  bool _showAdvancedSearch = false;

  List<LibraryMetadataItem> _results = const [];
  List<ProviderCandidate> _providerResults = const [];
  final _queuedProviderIngests = <String, LibraryQueuedProviderIngest>{};
  final _checkedResultIds = <String>{};
  final _checkedProviderIds = <String>{};
  String? _error;
  late String _selectedProvider;
  bool _searchedProvider = false;
  bool _isSearching = false;
  bool _isSearchingProvider = false;
  bool _isQueueingIngest = false;
  bool _isAdding = false;
  LibraryAddDialogMode _mode = LibraryAddDialogMode.search;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
  LibraryAddReferenceType _referenceType = LibraryAddReferenceType.media;
  String? _selectedResultId;
  String? _selectedProviderCandidateId;
  String? _selectedBundleReleaseId;
  String? _selectedReferenceEditionId;
  String? _selectedReferenceVariantId;
  final _providerPreviews = <String, AdminProviderPreview>{};
  final _hydratedResults = <String, LibraryMetadataItem>{};
  final _bundleReleasesByItemId = <String, List<BundleReleaseSummary>>{};
  final _bundleReleaseDetailsById = <String, BundleReleaseDetail>{};
  String? _physicalFormatId;
  String _defaultCondition = 'Near Mint';
  String _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  String? _defaultReadStatus;
  String? _defaultTags;
  String? _pendingLegacyLocationPrefill;
  DateTime? _lastProviderSearchAt;
  String? _lastProviderSearchSignature;
  int _coreSearchGeneration = 0;
  int _providerSearchGeneration = 0;
  final _pendingHydratedResultIds = <String>{};
  final _pendingBundleReleaseItemIds = <String>{};
  final _pendingBundleReleaseDetailIds = <String>{};
  final _pendingProviderPreviewIds = <String>{};
  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _tagOptions = const [];
  String? _defaultLocationId;
  // Manual pane transient state
  late Map<String, String?> _manualCustomFieldValues;
  late List<ItemImage> _manualItemImages;
  LibraryCoverScanResult? _coverScanPrefill;
  bool _isScanningCover = false;
  double _resultsPaneWidth = 480;
  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _minResultsPaneWidth = 280.0;
  static const _maxResultsPaneWidth = 860.0;
  static const _minPreviewPaneWidth = 360.0;
  double? _dialogWidth;
  double? _dialogHeight;
  static const _defaultDialogWidth = 1320.0;
  static const _defaultDialogHeight = 860.0;
  static const _minDialogWidth = 760.0;
  static const _maxDialogWidth = 1800.0;
  static const _minDialogHeight = 560.0;
  static const _maxDialogHeight = 1200.0;

  // ── Autocomplete ──
  Timer? _autocompleteTimer;
  List<LibraryMetadataItem> _suggestions = const [];
  bool _showSuggestions = false;
  static const _autocompleteDebounce = Duration(milliseconds: 350);
  static const _autocompleteLimit = 8;

  /// Video-kind filter for movie library: allows searching across movie + tv.
  late final Set<String> _videoKindFilters;

  bool get _isVideoKind => widget.type.capabilities.supportsVideoKindFilters;

  bool get _isMovieDesktopChrome => widget.type.capabilities.wideDialog;

  @override
  void initState() {
    super.initState();
    _videoKindFilters = {widget.type.workspace.kind.apiValue};
    if (_isMovieDesktopChrome) {
      _resultsPaneWidth = 720;
    }
    _selectedProvider = widget.type.defaultSupportedMetadataProvider;
    _conditionOptions = widget.type.conditions;
    _gradeOptions = widget.type.grades;
    _loadAvailableLocations();
    _loadPickListOptions();
    _loadPrefillDefaults();
    _queryController.text = widget.initialQuery?.trim() ?? '';
    _barcodeController.text = widget.initialBarcode?.trim() ?? '';
    _titleController.text = _queryController.text;
    // Manual custom field edits and item images default from widget inputs
    _manualCustomFieldValues = Map.of(widget.customFieldValues.asMap().map((k, v) => MapEntry(v.fieldDefinitionId, v.value)));
    _manualItemImages = List.of(widget.itemImages);
    if (_barcodeController.text.isNotEmpty && widget.autoLookupInitialBarcode) {
      _mode = LibraryAddDialogMode.barcode;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupBarcode());
    } else if (_barcodeController.text.isNotEmpty) {
      _mode = LibraryAddDialogMode.barcode;
    }
  }

  @override
  void dispose() {
    _autocompleteTimer?.cancel();
    _queryController.dispose();
    _barcodeController.dispose();
    _titleController.dispose();
    _numberController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _variantController.dispose();
    _coverController.dispose();
    _backCoverController.dispose();
    _creatorsController.dispose();
    _charactersController.dispose();
    _editionTitleController.dispose();
    _releaseDateController.dispose();
    _pageCountController.dispose();
    _imprintController.dispose();
    _seriesGroupController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _ageRatingController.dispose();
    _genresEditController.dispose();
    _synopsisController.dispose();
    _tagsController.dispose();
    _rawOrSlabbedController.dispose();
    _gradingCompanyController.dispose();
    _graderNotesController.dispose();
    _signedByController.dispose();
    _labelTypeController.dispose();
    _certificationNumberController.dispose();
    _coverPriceController.dispose();
    _priceController.dispose();
    _purchaseDateController.dispose();
    _purchaseStoreController.dispose();
    _sellPriceController.dispose();
    _ownerLabelController.dispose();
    _searchSeriesController.dispose();
    _searchNumberController.dispose();
    _searchPublisherController.dispose();
    _searchYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final physicalFormats = physicalMediaFormatsForKind(
      catalog,
      widget.type.workspace.kind,
    );
    final selectedProvider = _activeProvider;
    final isBusy = _isSearching || _isSearchingProvider;
    final accent = widget.accent ?? LibraryAccentScope.accentOf(context, fallback: kAppAccent);
    final selectedResult = _selectedResult;
    final selectedCandidate = _selectedProviderCandidate;
    final selectedProviderLabel = selectedCandidate == null
        ? widget.type.metadataProviderLabel(selectedProvider)
        : widget.type.metadataProviderLabel(selectedCandidate.provider);
    final selectedQueuedIngest = selectedCandidate == null
        ? null
        : _queuedProviderIngests[selectedCandidate.localCatalogId];
      final isFetchingSelectedResultPreview =
        selectedResult != null &&
        _pendingHydratedResultIds.contains(selectedResult.id) &&
        !_hydratedResults.containsKey(selectedResult.id);
    final isFetchingSelectedCandidatePreview =
      selectedCandidate != null &&
      _pendingProviderPreviewIds.contains(selectedCandidate.localCatalogId) &&
      !_providerPreviews.containsKey(selectedCandidate.localCatalogId);
    final ownedByCatalogId = ref.watch(collectionByCatalogItemProvider);
    final palette = appPalette(context);
    final movieDesktopWidth = _isMovieDesktopChrome ? 1540.0 : _defaultDialogWidth;
    final movieDesktopHeight = _isMovieDesktopChrome ? 920.0 : _defaultDialogHeight;
    final headerRequest = LibraryAddHeaderRequest(
      type: widget.type,
      accent: accent,
      isMovieDesktopChrome: _isMovieDesktopChrome,
      onClose: () => Navigator.of(context).pop(),
    );
    final modeBarRequest = LibraryAddModeBarRequest(
      type: widget.type,
      accent: accent,
      isMovieDesktopChrome: _isMovieDesktopChrome,
      mode: _mode,
      queryController: _queryController,
      barcodeController: _barcodeController,
      isSearching: _isSearching,
      isSearchingProvider: _isSearchingProvider,
      onModeChanged: (mode) => setState(() => _mode = mode),
      onSearch: () {
        _dismissSuggestions();
        _search();
      },
      onQueryChanged: _onQueryChanged,
      suggestions: _suggestions,
      showSuggestions: _showSuggestions,
      onSelectSuggestion: _selectSuggestion,
      onDismissSuggestions: _dismissSuggestions,
      canScanCover: widget.type.capabilities.canScanCover,
      isScanningCover: _isScanningCover,
      onScanCover: _scanCover,
      onLookupBarcode: _lookupBarcode,
      onManual: () => setState(() => _mode = LibraryAddDialogMode.manual),
      showAdvanced: _showAdvancedSearch,
      onToggleAdvanced: () =>
          setState(() => _showAdvancedSearch = !_showAdvancedSearch),
      seriesController: _searchSeriesController,
      numberController: _searchNumberController,
      publisherController: _searchPublisherController,
      yearController: _searchYearController,
      videoKindFilters: _isVideoKind ? _videoKindFilters : null,
      onVideoKindFilterChanged: _isVideoKind
          ? (kind, checked) {
              setState(() {
                if (checked) {
                  _videoKindFilters.add(kind);
                } else {
                  _videoKindFilters.remove(kind);
                }
              });
            }
          : null,
    );
    return Theme(
      data: buildLibraryAddDialogTheme(accent, palette),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (_dialogWidth ?? movieDesktopWidth)
                .clamp(_minDialogWidth, _maxDialogWidth),
            maxHeight: (_dialogHeight ?? movieDesktopHeight)
                .clamp(_minDialogHeight, _maxDialogHeight),
          ),
          child: _ResizableDialogShell(
            accent: accent,
            onResizeWidth: (delta) => setState(() {
              _dialogWidth = ((_dialogWidth ?? movieDesktopWidth) + delta)
                  .clamp(_minDialogWidth, _maxDialogWidth);
            }),
            onResizeHeight: (delta) => setState(() {
              _dialogHeight = ((_dialogHeight ?? movieDesktopHeight) + delta)
                  .clamp(_minDialogHeight, _maxDialogHeight);
            }),
            child: Column(
              children: [
                widget.headerBuilder?.call(context, headerRequest) ??
                    _DialogHeader(
                      type: headerRequest.type,
                      accent: headerRequest.accent,
                      isMovieDesktopChrome: headerRequest.isMovieDesktopChrome,
                    ),
                widget.modeBarBuilder?.call(context, modeBarRequest) ??
                    _LibraryAddModeBar(
                      type: modeBarRequest.type,
                      accent: modeBarRequest.accent,
                      isMovieDesktopChrome: modeBarRequest.isMovieDesktopChrome,
                      mode: modeBarRequest.mode,
                      queryController: modeBarRequest.queryController,
                      barcodeController: modeBarRequest.barcodeController,
                      isSearching: modeBarRequest.isSearching,
                      isSearchingProvider:
                          modeBarRequest.isSearchingProvider,
                      onModeChanged: modeBarRequest.onModeChanged,
                      onSearch: modeBarRequest.onSearch,
                      onQueryChanged: modeBarRequest.onQueryChanged,
                      suggestions: modeBarRequest.suggestions,
                      showSuggestions: modeBarRequest.showSuggestions,
                      onSelectSuggestion: modeBarRequest.onSelectSuggestion,
                      onDismissSuggestions:
                          modeBarRequest.onDismissSuggestions,
                      canScanCover: modeBarRequest.canScanCover,
                      isScanningCover: modeBarRequest.isScanningCover,
                      onScanCover: modeBarRequest.onScanCover,
                      onLookupBarcode: modeBarRequest.onLookupBarcode,
                      onManual: modeBarRequest.onManual,
                      showAdvanced: modeBarRequest.showAdvanced,
                      onToggleAdvanced: modeBarRequest.onToggleAdvanced,
                      seriesController: modeBarRequest.seriesController,
                      numberController: modeBarRequest.numberController,
                      publisherController: modeBarRequest.publisherController,
                      yearController: modeBarRequest.yearController,
                      videoKindFilters: modeBarRequest.videoKindFilters,
                      onVideoKindFilterChanged:
                          modeBarRequest.onVideoKindFilterChanged,
                    ),
                if (_barcodeController.text.trim().isNotEmpty)
                  _BarcodePrefillBanner(
                    type: widget.type,
                    barcode: _barcodeController.text.trim(),
                  ),
                if (_coverScanPrefill != null)
                  LibraryCoverScanPrefillBanner(result: _coverScanPrefill!),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final searchPaneRequest = LibraryAddSearchPaneRequest(
                        type: widget.type,
                        isBusy: isBusy,
                        isMovieDesktopChrome: _isMovieDesktopChrome,
                        error: _error,
                        accent: accent,
                        results: _results,
                        providerResults: _providerResults,
                        queuedProviderIngests: _queuedProviderIngests,
                        selectedProvider: selectedProvider,
                        searchedProvider: _searchedProvider,
                        selectedResultId: _selectedResultId,
                        selectedProviderCandidateId:
                            _selectedProviderCandidateId,
                        checkedResultIds: _checkedResultIds,
                        checkedProviderIds: _checkedProviderIds,
                        ownedCatalogItemIds: ownedByCatalogId.keys.toSet(),
                        providerQueryText: _queryController.text,
                        providerSeriesText: _searchSeriesController.text,
                        providerNumberText: _searchNumberController.text,
                        providerPublisherText: _searchPublisherController.text,
                        providerYearText: _searchYearController.text,
                        onSelectResult: (id) {
                          _selectCoreResult(id);
                        },
                        onSelectProviderCandidate: (id) {
                          _selectProviderCandidate(id);
                        },
                        onToggleResultCheck: (id) => setState(() {
                          if (!_checkedResultIds.remove(id)) {
                            _checkedResultIds.add(id);
                          }
                        }),
                        onToggleProviderCheck: (id) => setState(() {
                          if (!_checkedProviderIds.remove(id)) {
                            _checkedProviderIds.add(id);
                          }
                        }),
                        onSearchCore: _search,
                      );
                      final searchPane = widget.searchPaneBuilder
                              ?.call(context, searchPaneRequest) ??
                          _SearchPane(
                            type: searchPaneRequest.type,
                            isBusy: searchPaneRequest.isBusy,
                            isMovieDesktopChrome:
                                searchPaneRequest.isMovieDesktopChrome,
                            error: searchPaneRequest.error,
                            accent: searchPaneRequest.accent,
                            results: searchPaneRequest.results,
                            providerResults:
                                searchPaneRequest.providerResults,
                            queuedProviderIngests:
                                searchPaneRequest.queuedProviderIngests,
                            selectedProvider:
                                searchPaneRequest.selectedProvider,
                            searchedProvider:
                                searchPaneRequest.searchedProvider,
                            selectedResultId:
                                searchPaneRequest.selectedResultId,
                            selectedProviderCandidateId: searchPaneRequest
                                .selectedProviderCandidateId,
                            checkedResultIds:
                                searchPaneRequest.checkedResultIds,
                            checkedProviderIds:
                                searchPaneRequest.checkedProviderIds,
                            ownedCatalogItemIds:
                                searchPaneRequest.ownedCatalogItemIds,
                            providerQueryText:
                                searchPaneRequest.providerQueryText,
                            providerSeriesText:
                                searchPaneRequest.providerSeriesText,
                            providerNumberText:
                                searchPaneRequest.providerNumberText,
                            providerPublisherText:
                                searchPaneRequest.providerPublisherText,
                            providerYearText:
                                searchPaneRequest.providerYearText,
                            onSelectResult:
                                searchPaneRequest.onSelectResult,
                            onSelectProviderCandidate:
                                searchPaneRequest.onSelectProviderCandidate,
                            onToggleResultCheck:
                                searchPaneRequest.onToggleResultCheck,
                            onToggleProviderCheck:
                                searchPaneRequest.onToggleProviderCheck,
                            onSearchCore: searchPaneRequest.onSearchCore,
                          );
                      final previewPane = _LibraryAddPreviewPane(
                        type: widget.type,
                        accent: accent,
                        isMovieDesktopChrome: _isMovieDesktopChrome,
                        previewPaneBuilder: widget.previewPaneBuilder,
                        item: selectedResult,
                        candidate: selectedCandidate,
                        candidatePreview: selectedCandidate == null
                            ? null
                            : _providerPreviews[selectedCandidate.localCatalogId],
                        isFetchingPreview: isFetchingSelectedCandidatePreview ||
                            isFetchingSelectedResultPreview,
                        providerLabel: selectedProviderLabel,
                        searched: _results.isNotEmpty || _searchedProvider,
                        addTarget: _addTarget,
                        referenceType: _referenceType,
                        availableBundleReleases: selectedResult == null
                            ? const <BundleReleaseSummary>[]
                            : _bundleReleasesByItemId[selectedResult.id] ??
                                const <BundleReleaseSummary>[],
                        selectedBundleReleaseId: _selectedBundleReleaseId,
                        selectedBundleReleaseDetail:
                          _selectedBundleReleaseDetail,
                        selectedEditionId: _selectedReferenceEditionId,
                        selectedVariantId: _selectedReferenceVariantId,
                        isLoadingBundleReleases: selectedResult != null &&
                            _pendingBundleReleaseItemIds
                                .contains(selectedResult.id),
                        isLoadingBundleReleaseDetail:
                          _selectedBundleReleaseId != null &&
                            _pendingBundleReleaseDetailIds
                              .contains(_selectedBundleReleaseId),
                        onReferenceTypeChanged: (value) {
                          _handleReferenceTypeChanged(selectedResult, value);
                        },
                        onEditionSelected: (editionId) {
                          _handleReferenceEditionSelected(
                            _selectedResult,
                            editionId,
                          );
                        },
                        onVariantSelected: _handleReferenceVariantSelected,
                        onBundleReleaseSelected: (bundleReleaseId) {
                          _handleBundleReleaseSelected(bundleReleaseId);
                        },
                      );
                      final manualRequest = LibraryAddManualPaneRequest(
                        type: widget.type,
                        accent: accent,
                        titleController: _titleController,
                        numberController: _numberController,
                        publisherController: _publisherController,
                        yearController: _yearController,
                        barcodeController: _barcodeController,
                        variantController: _variantController,
                        coverController: _coverController,
                        backCoverController: _backCoverController,
                        creatorsController: _creatorsController,
                        charactersController: _charactersController,
                        physicalFormats: physicalFormats,
                        physicalFormatId: _physicalFormatId,
                        onPhysicalFormatChanged: _setPhysicalFormat,
                        isAdding: _isAdding,
                        defaultCondition: _defaultCondition,
                        defaultGrade: _defaultGrade,
                        defaultLocationLabel: _defaultLocationLabel,
                        defaultPurchaseDate: _defaultPurchaseDate,
                        defaultTags: _defaultTags,
                        onAddOwned: () => _addManual(LibraryAddTarget.owned),
                        onAddTrack: () => _addManual(LibraryAddTarget.track),
                        onAddWishlist: () => _addManual(LibraryAddTarget.wishlist),
                        editionTitleController: _editionTitleController,
                        releaseDateController: _releaseDateController,
                        pageCountController: _pageCountController,
                        imprintController: _imprintController,
                        seriesGroupController: _seriesGroupController,
                        countryController: _countryController,
                        languageController: _languageController,
                        ageRatingController: _ageRatingController,
                        genresEditController: _genresEditController,
                        synopsisController: _synopsisController,
                        tagsController: _tagsController,
                        rawOrSlabbedController: _rawOrSlabbedController,
                        gradingCompanyController: _gradingCompanyController,
                        graderNotesController: _graderNotesController,
                        signedByController: _signedByController,
                        labelTypeController: _labelTypeController,
                        certificationNumberController: _certificationNumberController,
                        coverPriceController: _coverPriceController,
                        purchasePriceController: _priceController,
                        purchaseDateController: _purchaseDateController,
                        purchaseStoreController: _purchaseStoreController,
                        soldPriceController: _sellPriceController,
                        soldDateController: TextEditingController(text: _soldAt == null ? '' : formatDate(_soldAt!)),
                        ownerLabelController: _ownerLabelController,
                        customFieldDefinitions: widget.customFieldDefinitions,
                        customFieldValues: _manualCustomFieldValues,
                        onCustomFieldValuesChanged: (m) => setState(() => _manualCustomFieldValues = Map.of(m)),
                        itemImages: _manualItemImages,
                        onItemImagesChanged: (edits) {
                          setState(() {
                            final byId = {for (final img in _manualItemImages) img.id: img};
                            final next = <ItemImage>[];
                            for (final e in edits) {
                              if (e.deleted) continue;
                              final existing = byId[e.id];
                              if (existing != null) {
                                next.add(existing.copyWith(
                                  imageData: e.imageData ?? existing.imageData,
                                  caption: e.caption ?? existing.caption,
                                  sortOrder: e.sortOrder,
                                ));
                              } else {
                                if (e.imageData != null) {
                                  next.add(ItemImage(
                                    id: e.id,
                                    ownedItemId: '',
                                    imageData: e.imageData!,
                                    caption: e.caption,
                                    sortOrder: e.sortOrder,
                                    createdAt: DateTime.now().toUtc(),
                                  ));
                                }
                              }
                            }
                            _manualItemImages = next;
                          });
                        },
                      );
                      final manualPane =
                          widget.manualPaneBuilder?.call(context, manualRequest) ??
                              _ManualPane(request: manualRequest);
                      if (_mode == LibraryAddDialogMode.manual) {
                        return manualPane;
                      }
                      if (constraints.maxWidth < 720) {
                        final searchHeight =
                            constraints.maxHeight > 400 ? 300.0 : constraints.maxHeight * 0.5;
                        return Column(
                          children: [
                            SizedBox(height: searchHeight, child: searchPane),
                            Expanded(child: previewPane),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: _clampedResultsPaneWidth(
                              constraints.maxWidth,
                            ),
                            child: searchPane,
                          ),
                          _LibraryAddPaneResizeDivider(
                            onDragDelta: (delta) => _resizeResultsPane(
                              delta,
                              constraints.maxWidth,
                            ),
                          ),
                          Expanded(child: previewPane),
                        ],
                      );
                    },
                  ),
                ),
                if (_mode != LibraryAddDialogMode.manual)
                  Builder(
                    builder: (context) {
                      final checkedItems = [
                        for (final item in _results)
                          if (_checkedResultIds.contains(item.id)) item,
                      ];
                      final addItems = checkedItems.isNotEmpty
                          ? checkedItems
                          : [if (selectedResult != null) selectedResult];
                      final addCount = addItems.length;
                        final selectedEditionSelection = selectedResult == null
                          ? null
                          : _selectedEditionSelectionForItem(selectedResult);
                        final requiresBundleSelection =
                          _addTarget != LibraryAddTarget.track &&
                            _referenceType ==
                              LibraryAddReferenceType.bundleRelease;
                        final requiresEditionSelection =
                          _addTarget != LibraryAddTarget.track &&
                            _referenceType ==
                              LibraryAddReferenceType.edition;
                        final canAddBundleSelection = !requiresBundleSelection ||
                          (addCount == 1 &&
                            selectedResult != null &&
                            _selectedBundleReleaseId != null);
                        final canAddEditionSelection =
                          !requiresEditionSelection ||
                            (addCount == 1 &&
                              selectedResult != null &&
                              selectedEditionSelection != null);
                      final bottomBarRequest = LibraryAddBottomBarRequest(
                        type: widget.type,
                        isMovieDesktopChrome: _isMovieDesktopChrome,
                        conditions: _conditionOptions,
                        grades: _gradeOptions,
                        defaultTags: _defaultTags,
                        accent: accent,
                        selectedItem: selectedResult,
                        selectedCandidate: selectedCandidate,
                        selectedQueuedIngest: selectedQueuedIngest,
                        providerLabel: selectedProviderLabel,
                        addTarget: _addTarget,
                        addCount: addCount,
                        isAdding: _isAdding,
                        isQueueingIngest: _isQueueingIngest,
                        isAdmin: ref.watch(authControllerProvider).isAdmin,
                        defaultCondition: _defaultCondition,
                        defaultGrade: _defaultGrade,
                        defaultLocationLabel: _defaultLocationLabel,
                        defaultPurchaseDate: _defaultPurchaseDate,
                        onAddTargetChanged: (value) => setState(() {
                          _addTarget = value;
                          if (value == LibraryAddTarget.track) {
                            _referenceType = LibraryAddReferenceType.media;
                            _selectedBundleReleaseId = null;
                            _selectedReferenceEditionId = null;
                            _selectedReferenceVariantId = null;
                          }
                        }),
                        onDefaultConditionChanged: (value) =>
                            setState(() => _defaultCondition = value),
                        onDefaultGradeChanged: (value) =>
                            setState(() => _defaultGrade = value),
                        onEditDefaultTagsPressed: _showDefaultTagsEditor,
                        onDefaultLocationPressed: _pickDefaultLocation,
                        onDefaultPurchaseDateChanged: (value) =>
                            setState(() => _defaultPurchaseDate = value),
                        onAdd: (addItems.isEmpty && selectedCandidate == null) ||
                                !canAddBundleSelection ||
                                !canAddEditionSelection
                            ? null
                            : () {
                                if (addItems.isNotEmpty) {
                                  _addItems(
                                    addItems,
                                    _addTarget,
                                    referenceType: _referenceType,
                                    editionSelectionsByItemId:
                                        selectedResult == null ||
                                                selectedEditionSelection == null ||
                                                addCount != 1
                                            ? const <String,
                                                LibraryAddEditionSelection>{}
                                            : <String,
                                                LibraryAddEditionSelection>{
                                                selectedResult.id:
                                                    selectedEditionSelection,
                                              },
                                    bundleReleaseIdsByItemId:
                                        selectedResult == null ||
                                                _selectedBundleReleaseId == null
                                            ? const <String, String>{}
                                            : <String, String>{
                                                selectedResult.id:
                                                    _selectedBundleReleaseId!,
                                              },
                                  );
                                  return;
                                }
                                final candidate = selectedCandidate;
                                if (candidate != null) {
                                  _addProviderCandidate(candidate, _addTarget);
                                }
                              },
                        onQueueIngest: selectedCandidate == null
                            ? null
                            : () => _queueProviderIngest(selectedCandidate),
                        onPropose: selectedCandidate == null
                            ? null
                            : () => _proposeCandidate(selectedCandidate),
                      );
                      return widget.bottomBarBuilder
                              ?.call(context, bottomBarRequest) ??
                          _LibraryAddBottomBar(
                            type: bottomBarRequest.type,
                            isMovieDesktopChrome:
                                bottomBarRequest.isMovieDesktopChrome,
                            conditions: bottomBarRequest.conditions,
                            grades: bottomBarRequest.grades,
                            defaultTags: bottomBarRequest.defaultTags,
                            accent: bottomBarRequest.accent,
                            selectedItem: bottomBarRequest.selectedItem,
                            selectedCandidate:
                                bottomBarRequest.selectedCandidate,
                            selectedQueuedIngest:
                                bottomBarRequest.selectedQueuedIngest,
                            providerLabel: bottomBarRequest.providerLabel,
                            addTarget: bottomBarRequest.addTarget,
                            addCount: bottomBarRequest.addCount,
                            isAdding: bottomBarRequest.isAdding,
                            isQueueingIngest:
                                bottomBarRequest.isQueueingIngest,
                            isAdmin: bottomBarRequest.isAdmin,
                            defaultCondition:
                                bottomBarRequest.defaultCondition,
                            defaultGrade: bottomBarRequest.defaultGrade,
                            defaultLocationLabel:
                                bottomBarRequest.defaultLocationLabel,
                            defaultPurchaseDate:
                                bottomBarRequest.defaultPurchaseDate,
                            onAddTargetChanged:
                                bottomBarRequest.onAddTargetChanged,
                            onDefaultConditionChanged:
                                bottomBarRequest.onDefaultConditionChanged,
                            onDefaultGradeChanged:
                                bottomBarRequest.onDefaultGradeChanged,
                            onEditDefaultTagsPressed:
                                bottomBarRequest.onEditDefaultTagsPressed,
                            onDefaultLocationPressed:
                                bottomBarRequest.onDefaultLocationPressed,
                            onDefaultPurchaseDateChanged:
                                bottomBarRequest.onDefaultPurchaseDateChanged,
                            onAdd: bottomBarRequest.onAdd,
                            onQueueIngest: bottomBarRequest.onQueueIngest,
                            onPropose: bottomBarRequest.onPropose,
                          );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _clampedResultsPaneWidth(double availableWidth) {
    final maxWidth = (availableWidth - _minPreviewPaneWidth)
        .clamp(_minResultsPaneWidth, _maxResultsPaneWidth)
        .toDouble();
    return _resultsPaneWidth.clamp(_minResultsPaneWidth, maxWidth).toDouble();
  }

  void _resizeResultsPane(double delta, double availableWidth) {
    setState(() {
      final maxWidth = (availableWidth - _minPreviewPaneWidth)
          .clamp(_minResultsPaneWidth, _maxResultsPaneWidth)
          .toDouble();
      _resultsPaneWidth =
          (_resultsPaneWidth + delta).clamp(_minResultsPaneWidth, maxWidth);
    });
  }

  Future<void> _search() async {
    final searchLabels = libraryMediaSearchFieldLabels(widget.type);
    final query = _queryController.text.trim();
    if (query.isEmpty &&
        _searchSeriesController.text.trim().isEmpty &&
        _searchNumberController.text.trim().isEmpty &&
        _searchPublisherController.text.trim().isEmpty &&
        _searchYearController.text.trim().isEmpty) {
      setState(() => _error = searchLabels.emptySearchMessage);
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _providerPreviews.clear();
      _searchedProvider = false;
    });
    final series = _searchSeriesController.text.trim();
    final issueNumber = _searchNumberController.text.trim();
    final publisher = _searchPublisherController.text.trim();
    final yearText = _searchYearController.text.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;
    try {
      final api = ref.read(apiClientProvider);
      final searchResult = await runLibraryAddCoreSearch(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: LibraryMetadataSearchInput(
          query: query.isNotEmpty ? query : null,
          series: series.isNotEmpty ? series : null,
          issueNumber: issueNumber.isNotEmpty ? issueNumber : null,
          publisher: publisher.isNotEmpty ? publisher : null,
          year: year,
          limit: 20,
        ),
        timeout: _coreSearchTimeout,
        rerankHints: _currentLocalRerankHints(),
        providerSearchAvailable:
            widget.type.supportedMetadataProviders.isNotEmpty,
      );
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = searchResult.items;
          _selectedResultId = null;
          _selectedProviderCandidateId = null;
          _resetReferenceSelection();
          _clearSelectionCaches();
        });
        _precacheMetadataCovers(searchResult.items);
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          searchResult.shouldSearchProvider) {
        await _searchProvider(
          queryOverride: query,
          bypassDebounce: true,
        );
      }
    } catch (error) {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        if (await _clearRejectedMetadataSession(error, 'Core search')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Core search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add still works.',
        );
      }
    } finally {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    if (query.length < 2) {
      _autocompleteTimer?.cancel();
      if (_showSuggestions) {
        setState(() {
          _suggestions = const [];
          _showSuggestions = false;
        });
      }
      return;
    }
    _autocompleteTimer?.cancel();
    _autocompleteTimer = Timer(_autocompleteDebounce, () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final api = ref.read(apiClientProvider);
      final filtered = await fetchLibraryAddSuggestions(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        query: query,
        limit: _autocompleteLimit,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = filtered;
        _showSuggestions = filtered.isNotEmpty;
      });
    } catch (_) {
      // Silently ignore autocomplete failures — the user can still press Search.
    }
  }

  void _selectSuggestion(LibraryMetadataItem item) {
    _queryController.text = item.title;
    setState(() {
      _showSuggestions = false;
      _suggestions = const [];
      _results = [item];
      _selectedResultId = item.id;
      _selectedProviderCandidateId = null;
      _resetReferenceSelection();
      _clearSelectionCaches();
    });
    _ensureSelectedResultLoaded(item.id);
    _ensureBundleReleasesLoaded(item.id);
  }

  void _dismissSuggestions() {
    if (_showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  Future<void> _scanCover() async {
    if (_isScanningCover) {
      return;
    }
    setState(() {
      _isScanningCover = true;
      _error = null;
    });
    try {
      final result = await widget.coverScanService.scanCover(
        context: context,
        type: widget.type,
      );
      if (!mounted || result == null) {
        return;
      }
      if (!result.hasAnyHint) {
        setState(() {
          _error = result.warnings.isEmpty
              ? 'Cover scan did not extract usable search hints yet.'
              : result.warnings.first;
          _coverScanPrefill = null;
        });
        return;
      }
      final query = (result.query ?? result.series ?? '').trim();
      setState(() {
        _mode = LibraryAddDialogMode.search;
        _queryController.text = query;
        _searchSeriesController.text = result.series?.trim() ?? '';
        _searchNumberController.text = result.issueNumber?.trim() ?? '';
        _searchPublisherController.text = result.publisher?.trim() ?? '';
        _searchYearController.text = result.year?.toString() ?? '';
        _showAdvancedSearch = result.showAdvancedFields;
        _coverScanPrefill = result;
        _results = const [];
        _providerResults = const [];
        _selectedResultId = null;
        _selectedProviderCandidateId = null;
        _resetReferenceSelection();
        _clearSelectionCaches();
        _providerPreviews.clear();
        _searchedProvider = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isScanningCover = false);
      }
    }
  }

  Future<void> _lookupBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() => _error = 'Enter a barcode / UPC / ISBN.');
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _providerPreviews.clear();
      _searchedProvider = false;
    });
    try {
      final api = ref.read(apiClientProvider);
      final lookupResult = await runLibraryAddBarcodeLookup(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        barcode: barcode,
        timeout: _coreSearchTimeout,
        providerSearchAvailable:
            widget.type.supportedMetadataProviders.isNotEmpty,
      );
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = lookupResult.items;
          _selectedResultId = null;
          _selectedProviderCandidateId = null;
          _resetReferenceSelection();
          _clearSelectionCaches();
          _error =
              lookupResult.items.isEmpty &&
                      widget.type.supportedMetadataProviders.isEmpty
                  ? 'No item found for barcode $barcode.'
                  : null;
        });
        _precacheMetadataCovers(lookupResult.items);
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          lookupResult.shouldSearchProvider) {
        await _searchProvider(queryOverride: barcode);
      }
    } catch (error) {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        if (await _clearRejectedMetadataSession(error, 'Barcode lookup')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add keeps the scanned code.',
        );
      }
    } finally {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _addManual(LibraryAddTarget target) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Manual item needs a title.');
      return;
    }
    final draft = _buildManualDraftItem();
    final customFieldValuesForEdit = _manualCustomFieldValues.entries
        .map((e) => CustomFieldValue(
              id: 'local-${e.key}-${_uuid.v4()}',
              ownedItemId: '',
              fieldDefinitionId: e.key,
              value: e.value,
              updatedAt: DateTime.now().toUtc(),
            ))
        .toList(growable: false);
    final result = await showLibraryEditDialog(
      context: context,
      request: LibraryEditDialogRequest(
        type: widget.type,
        item: draft,
        ownedItem: _manualDraftOwnedItem(draft, target),
        accent: LibraryAccentScope.accentOf(context),
        physicalFormats: _currentPhysicalFormats(),
        customFieldDefinitions: widget.customFieldDefinitions,
        customFieldValues: customFieldValuesForEdit,
        itemImages: _manualItemImages,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    await _addItems(
      [result.item],
      target,
      defaults: const LibraryAddDefaults(),
      ownedDetailsByItemId: result.personal == null
          ? const <String, LibraryAddOwnedDetails>{}
          : {
              result.item.id: _ownedDetailsFromSelection(result),
            },
    );
  }

  LibraryMetadataItem _buildManualDraftItem() {
    final year = int.tryParse(_yearController.text.trim());
    final coverUrl = _emptyToNull(_coverController.text);
    final releaseDate = parseDate(_releaseDateController.text);
    final pageCount = parseInt(_pageCountController.text);
        final genres = _genresEditController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
        final creatorNames = _creatorsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
        final creators = creatorNames.isEmpty ? null : [for (final n in creatorNames) {'name': n}];
        final characterNames = _charactersController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
        final characters = characterNames.isEmpty ? null : characterNames;
    return LibraryMetadataItem(
      id: 'local-${widget.type.workspace.kind.apiValue}-${_uuid.v4()}',
      kind: widget.type.workspace.kind.apiValue,
      title: _titleController.text.trim(),
      itemNumber: _emptyToNull(_numberController.text),
      editionTitle: _emptyToNull(_editionTitleController.text),
      physicalFormat: _physicalFormatId,
      physicalFormatLabel: _physicalFormatForId(_physicalFormatId)?.label,
      publisher: _emptyToNull(_publisherController.text),
      releaseDate: releaseDate,
      releaseYear: year,
      barcode: _emptyToNull(_barcodeController.text),
      variant: _emptyToNull(_variantController.text),
      coverImageUrl: coverUrl,
      thumbnailImageUrl: coverUrl,
      synopsis: _emptyToNull(_synopsisController.text),
      genres: genres.isEmpty ? null : genres,
      creators: creators,
      characters: characters,
      country: _emptyToNull(_countryController.text),
      language: _emptyToNull(_languageController.text),
      ageRating: _emptyToNull(_ageRatingController.text),
      publishing: (pageCount != null || _imprintController.text.trim().isNotEmpty || _seriesGroupController.text.trim().isNotEmpty)
          ? CatalogPublishingDetails(
              pageCount: pageCount,
              imprint: _emptyToNull(_imprintController.text),
              seriesGroup: _emptyToNull(_seriesGroupController.text),
            )
          : null,
    );
  }

  OwnedItem? _manualDraftOwnedItem(
    LibraryMetadataItem item,
    LibraryAddTarget target,
  ) {
    if (target != LibraryAddTarget.owned) {
      return null;
    }
    final purchaseDate = parseDate(_purchaseDateController.text) ?? _defaultPurchaseDate;
    final pricePaidCents = parseMoneyCents(_priceController.text);
    final coverPriceCents = parseMoneyCents(_coverPriceController.text);
    final sellPriceCents = parseMoneyCents(_sellPriceController.text);
    final soldAt = _soldAt;
    return OwnedItem(
      id: 'manual-owned-${_uuid.v4()}',
      itemId: item.id,
      condition: _defaultCondition,
      grade: _defaultGrade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: null,
      personalNotes: _graderNotesController.text.trim().isEmpty ? null : _graderNotesController.text.trim(),
      quantity: 1,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed: _rawOrSlabbedController.text.trim().isEmpty ? null : _rawOrSlabbedController.text.trim(),
      gradingCompany: _gradingCompanyController.text.trim().isEmpty ? null : _gradingCompanyController.text.trim(),
      graderNotes: _graderNotesController.text.trim().isEmpty ? null : _graderNotesController.text.trim(),
      signedBy: _signedByController.text.trim().isEmpty ? null : _signedByController.text.trim(),
      labelType: _labelTypeController.text.trim().isEmpty ? null : _labelTypeController.text.trim(),
      certificationNumber: _certificationNumberController.text.trim().isEmpty ? null : _certificationNumberController.text.trim(),
      updatedAt: DateTime.now().toUtc(),
      soldAt: soldAt,
      sellPriceCents: sellPriceCents,
      ownerLabel: _ownerLabelController.text.trim().isEmpty ? null : _ownerLabelController.text.trim(),
      locationId: _defaultLocationId,
      tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
      purchaseStore: _purchaseStoreController.text.trim().isEmpty ? null : _purchaseStoreController.text.trim(),
    );
  }

  LibraryAddOwnedDetails _ownedDetailsFromSelection(
    LibraryEditSelection selection,
  ) {
    final personal = selection.personal;
    if (personal == null) {
      return const LibraryAddOwnedDetails();
    }
    return LibraryAddOwnedDetails(
      editionId: personal.editionId,
      variantId: personal.variantId,
      condition: personal.condition,
      grade: personal.grade,
      purchaseDate: personal.purchaseDate,
      pricePaidCents: personal.pricePaidCents,
      currency: personal.currency,
      personalNotes: personal.personalNotes,
      quantity: personal.quantity,
      locationId: personal.locationId,
      coverPriceCents: personal.coverPriceCents,
      rawOrSlabbed: personal.rawOrSlabbed,
      gradingCompany: personal.gradingCompany,
      graderNotes: personal.graderNotes,
      signedBy: personal.signedBy,
      labelType: personal.labelType,
      certificationNumber: personal.certificationNumber,
      keyComic: personal.keyComic ?? false,
      keyReason: personal.keyReason,
      rating: selection.tracking?.rating,
      readStatus: selection.tracking?.readStatus,
      startedAt: selection.tracking?.startedAt,
      finishedAt: selection.tracking?.finishedAt,
      progressCurrent: selection.tracking?.progressCurrent,
      progressTotal: selection.tracking?.progressTotal,
      timesCompleted: selection.tracking?.timesCompleted,
      trackingNotes: selection.tracking?.notes,
      seasonNumber: selection.tracking?.seasonNumber,
      episodeNumber: selection.tracking?.episodeNumber,
      tags: personal.tags,
      soldAt: personal.soldAt,
      sellPriceCents: personal.sellPriceCents,
      soldTo: personal.soldTo,
    );
  }

  void _setPhysicalFormat(String? value) {
    final format = _physicalFormatForId(value);
    final previousFormat = _physicalFormatForId(_physicalFormatId);
    final shouldReplaceVariant = _variantController.text.trim().isEmpty ||
        previousFormat?.label == _variantController.text.trim();
    setState(() {
      _physicalFormatId = format?.id;
      if (format != null && shouldReplaceVariant) {
        _variantController.text = format.label;
      }
    });
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = _emptyToNull(id ?? '');
    if (normalized == null) {
      return null;
    }
    return physicalMediaFormatById(
      normalized,
      formats: _currentPhysicalFormats(),
    );
  }

  List<PhysicalMediaFormat> _currentPhysicalFormats() {
    return physicalMediaFormatsForKind(
      ref.read(mediaCatalogProvider).maybeWhen(
            data: (value) => value,
            orElse: () => fallbackMediaCatalog,
          ),
      widget.type.workspace.kind,
    );
  }

  Future<void> _searchProvider({
    String? queryOverride,
    bool bypassDebounce = false,
  }) async {
    final query = queryOverride?.trim().isNotEmpty == true
        ? queryOverride!.trim()
        : _providerQuery;
    if (query.isEmpty) {
      setState(() => _error = 'Enter a title, barcode, or keyword.');
      return;
    }
    final provider = _activeProvider;
    ++_providerSearchGeneration;
    final debounceDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: provider,
      query: query,
      debounce: _providerSearchDebounce,
      now: DateTime.now(),
      previousSignature: _lastProviderSearchSignature,
      previousAt: _lastProviderSearchAt,
    );
    _lastProviderSearchSignature = debounceDecision.signature;
    _lastProviderSearchAt = debounceDecision.at;
    if (_isSearchingProvider ||
        (!bypassDebounce && debounceDecision.shouldSkip)) {
      return;
    }
    setState(() {
      _isSearchingProvider = true;
      _searchedProvider = true;
      _providerResults = const [];
      _providerPreviews.clear();
      _pendingProviderPreviewIds.clear();
      _selectedProviderCandidateId = null;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final kindsToSearch = _isVideoKind
          ? (_videoKindFilters.isEmpty
              ? _VideoKindFilterRow.allKinds
              : _videoKindFilters.toList())
          : <String>[];
      final seriesText = _searchSeriesController.text.trim().isNotEmpty
          ? _searchSeriesController.text.trim()
          : null;
      final issueText = _searchNumberController.text.trim().isNotEmpty
          ? _searchNumberController.text.trim()
          : null;
      final yearValue = _searchYearController.text.trim().isNotEmpty
          ? int.tryParse(_searchYearController.text.trim())
          : null;
      final rerankHints = _currentLocalRerankHints();

      List<ProviderCandidate> results;
      if (kindsToSearch.length > 1) {
        // Run parallel provider searches for each checked video kind.
        final futures = kindsToSearch.map((kind) async {
          try {
            return await runLibraryAddProviderSearch(
              api: api,
              type: widget.type,
              provider: provider,
              query: query,
              rerankHints: rerankHints,
              series: seriesText,
              issueNumber: issueText,
              year: yearValue,
              kindOverride: kind,
            );
          } catch (_) {
            return <ProviderCandidate>[];
          }
        });
        final allResults = await Future.wait(futures);
        results = allResults.expand((r) => r).toList();
      } else if (kindsToSearch.length == 1) {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: widget.type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
          kindOverride: kindsToSearch.first,
        );
      } else {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: widget.type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _providerResults = results;
        _selectedProviderCandidateId = null;
        _pendingProviderPreviewIds.clear();
      });
      _precacheProviderCandidateCovers(results);
    } catch (error) {
      if (mounted) {
        if (await _clearRejectedMetadataSession(error, 'Provider search')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Provider search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingProvider = false);
      }
    }
  }

  Future<void> _ensureProviderPreviewLoaded(String candidateId) async {
    if (_providerPreviews.containsKey(candidateId) ||
        _pendingProviderPreviewIds.contains(candidateId)) {
      return;
    }
    ProviderCandidate? candidate;
    for (final value in _providerResults) {
      if (value.localCatalogId == candidateId) {
        candidate = value;
        break;
      }
    }
    if (candidate == null || candidate.isStub) {
      return;
    }
    final searchGeneration = _providerSearchGeneration;
    setState(() {
      _pendingProviderPreviewIds.add(candidateId);
    });
    try {
      final api = ref.read(apiClientProvider);
      final preview = await api.providerPreview(
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      );
      if (!mounted || searchGeneration != _providerSearchGeneration) {
        return;
      }
      setState(() {
        _providerPreviews[candidateId] = preview;
        _pendingProviderPreviewIds.remove(candidateId);
      });
      _precacheProviderPreviewCovers([preview]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message:
            'Failed to load provider preview for ${candidate.provider}:${candidate.providerItemId}.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _providerSearchGeneration) {
        return;
      }
      setState(() {
        _pendingProviderPreviewIds.remove(candidateId);
      });
    }
  }

  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (_hydratedResults.containsKey(itemId) ||
        _pendingHydratedResultIds.contains(itemId)) {
      return;
    }
    LibraryMetadataItem? selected;
    for (final item in _results) {
      if (item.id == itemId) {
        selected = item;
        break;
      }
    }
    if (selected == null) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingHydratedResultIds.add(itemId);
    });
    try {
      final hydrated = await ref.read(apiClientProvider).getMetadataItem(
            kind: selected.kind,
            id: itemId,
          );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      final hydratedItem = LibraryMetadataItem.fromCatalogItem(hydrated);
      final mergedItem = hydratedItem.displayCoverUrl != null
          ? hydratedItem
          : hydratedItem.copyWith(
              coverImageUrl: selected.coverImageUrl,
              thumbnailImageUrl:
                  selected.thumbnailImageUrl ?? selected.coverImageUrl,
            );
      setState(() {
        _hydratedResults[itemId] = mergedItem;
        _pendingHydratedResultIds.remove(itemId);
      });
      _precacheMetadataCovers([mergedItem]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to hydrate add-result metadata for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _pendingHydratedResultIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleasesLoaded(String itemId) async {
    if (_bundleReleasesByItemId.containsKey(itemId) ||
        _pendingBundleReleaseItemIds.contains(itemId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingBundleReleaseItemIds.add(itemId);
    });
    try {
      final bundleReleases =
          await ref.read(apiClientProvider).getItemBundleReleases(itemId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _bundleReleasesByItemId[itemId] = bundleReleases;
        _pendingBundleReleaseItemIds.remove(itemId);
        if (_selectedResultId == itemId &&
            _referenceType == LibraryAddReferenceType.bundleRelease &&
            _selectedBundleReleaseId == null &&
            bundleReleases.isNotEmpty) {
          _selectedBundleReleaseId = bundleReleases.first.id;
        }
      });
      final bundleReleaseId = _selectedResultId == itemId &&
              _referenceType == LibraryAddReferenceType.bundleRelease
          ? _selectedBundleReleaseId
          : null;
      if (bundleReleaseId != null) {
        await _ensureBundleReleaseDetailLoaded(bundleReleaseId);
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle releases for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _pendingBundleReleaseItemIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleaseDetailLoaded(String bundleReleaseId) async {
    if (_bundleReleaseDetailsById.containsKey(bundleReleaseId) ||
        _pendingBundleReleaseDetailIds.contains(bundleReleaseId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingBundleReleaseDetailIds.add(bundleReleaseId);
    });
    try {
      final bundleRelease =
          await ref.read(apiClientProvider).getBundleRelease(bundleReleaseId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _bundleReleaseDetailsById[bundleReleaseId] = bundleRelease;
        _pendingBundleReleaseDetailIds.remove(bundleReleaseId);
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle release detail for $bundleReleaseId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _pendingBundleReleaseDetailIds.remove(bundleReleaseId);
      });
    }
  }

  void _precacheMetadataCovers(List<LibraryMetadataItem> items) {
    unawaited(
      _precacheCoverUrls([
        for (final item in items) item.coverImageUrl,
        for (final item in items) item.thumbnailImageUrl,
      ]),
    );
  }

  void _precacheProviderCandidateCovers(List<ProviderCandidate> candidates) {
    unawaited(
      _precacheCoverUrls([
        for (final candidate in candidates) candidate.imageUrl,
      ]),
    );
  }

  void _precacheProviderPreviewCovers(Iterable<AdminProviderPreview> previews) {
    unawaited(
      _precacheCoverUrls([
        for (final preview in previews) preview.coverImageUrl,
      ]),
    );
  }

  Future<void> _precacheCoverUrls(Iterable<String?> urls) async {
    if (!mounted) {
      return;
    }
    final uniqueUrls = <String>{
      for (final value in urls)
        if (value != null && value.trim().isNotEmpty) value.trim(),
    };
    await Future.wait([
      for (final url in uniqueUrls)
        precacheImage(
          CachedNetworkImageProvider(url),
          context,
          onError: (_, __) {},
        ).catchError((_) {}),
    ]);
  }

  Future<bool> _clearRejectedMetadataSession(
    Object error,
    String action,
  ) async {
    final cleared =
        await ref.read(authControllerProvider.notifier).clearSessionIfRejected(
              error,
            );
    if (!cleared) {
      return false;
    }
    if (!mounted) {
      return true;
    }
    setState(() {
      _isSearching = false;
      _isSearchingProvider = false;
      _isAdding = false;
      _isQueueingIngest = false;
      _error = 'Saved metadata session was cleared after $action was rejected. '
          'Retry the action. Sign in again only if you need authenticated tools.';
    });
    return true;
  }

  Future<void> _addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) => addProviderCandidate(candidate, target);

  Future<void> _proposeCandidate(ProviderCandidate candidate) =>
      proposeCandidate(candidate);

  Future<void> _queueProviderIngest(ProviderCandidate candidate) =>
      queueProviderIngest(candidate);

  String get _activeProvider {
    final providers = widget.type.supportedMetadataProviders;
    for (final provider in providers) {
      if (provider.id == _selectedProvider) {
        return provider.id;
      }
    }
    return widget.type.defaultSupportedMetadataProvider;
  }

  LibraryMetadataItem? get _selectedResult {
    final id = _selectedResultId;
    if (id == null) {
      return null;
    }
    final hydrated = _hydratedResults[id];
    if (hydrated != null) {
      return hydrated;
    }
    for (final item in _results) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  BundleReleaseDetail? get _selectedBundleReleaseDetail {
    final bundleReleaseId = _selectedBundleReleaseId;
    if (bundleReleaseId == null) {
      return null;
    }
    return _bundleReleaseDetailsById[bundleReleaseId];
  }

  LibraryAddEditionSelection? _selectedEditionSelectionForItem(
    LibraryMetadataItem item,
  ) {
    final edition = _previewEditionForItem(item, _selectedReferenceEditionId);
    if (edition == null) {
      return null;
    }
    final variant = _selectedVariantForEdition(
      edition,
      _selectedReferenceVariantId,
    );
    return LibraryAddEditionSelection(
      editionId: edition.id,
      variantId: variant?.id,
    );
  }

  ProviderCandidate? get _selectedProviderCandidate {
    final id = _selectedProviderCandidateId;
    if (id == null) {
      return null;
    }
    for (final candidate in _providerResults) {
      if (candidate.localCatalogId == id) {
        return candidate;
      }
    }
    return null;
  }

  String get _providerQuery {
    return buildLibraryAddProviderQuery([
      _queryController.text,
      _searchSeriesController.text,
      _searchNumberController.text,
      _searchPublisherController.text,
      _searchYearController.text,
      _barcodeController.text,
    ]);
  }

  Future<void> _addItems(
    List<LibraryMetadataItem> items,
    LibraryAddTarget target,
    {
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults? defaults,
    Map<String, LibraryAddOwnedDetails> ownedDetailsByItemId =
        const <String, LibraryAddOwnedDetails>{},
    Map<String, LibraryAddEditionSelection> editionSelectionsByItemId =
      const <String, LibraryAddEditionSelection>{},
    Map<String, String> bundleReleaseIdsByItemId = const <String, String>{},
    }
  ) async {
    if (items.isEmpty || _isAdding) {
      return;
    }
    setState(() {
      _isAdding = true;
      _error = null;
    });
    try {
      await addLibraryItemsToTarget(
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        mutations: ref.read(collectionMutationsProvider),
        items: items,
        target: target,
        referenceType: referenceType,
        defaults: defaults ??
            LibraryAddDefaults(
              condition: _defaultCondition,
              grade: _defaultGrade,
              purchaseDate: _defaultPurchaseDate,
              locationId: _defaultLocationId,
              readStatus: _defaultReadStatus,
              tags: _defaultTags,
            ),
        ownedDetailsByItemId: ownedDetailsByItemId,
        editionSelectionsByItemId: editionSelectionsByItemId,
        bundleReleaseIdsByItemId: bundleReleaseIdsByItemId,
      );
      if (mounted) {
        Navigator.of(context).pop(
          LibraryAddDialogResult(
            target: target,
            itemIds: [for (final item in items) item.id],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Add failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _availableLocations = locations;
      _tryResolvePendingLegacyPrefill(locations);
    });
  }

  LibraryAddLocalRerankHints _currentLocalRerankHints() {
    return LibraryAddLocalRerankHints(
      query: _queryController.text.trim(),
      series: _searchSeriesController.text.trim(),
      issueNumber: _searchNumberController.text.trim(),
      publisher: _searchPublisherController.text.trim(),
      year: int.tryParse(_searchYearController.text.trim()),
    );
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) {
      return;
    }
    setState(() {
      if (defaults.condition?.trim().isNotEmpty == true) {
        _defaultCondition = defaults.condition!.trim();
      }
      if (defaults.grade?.trim().isNotEmpty == true) {
        _defaultGrade = defaults.grade!.trim();
      }
      _defaultReadStatus = defaults.readStatus;
      _defaultTags = defaults.tags;
      _defaultLocationId = defaults.locationId;
      _pendingLegacyLocationPrefill = defaults.legacyStorageBox;
      _tryResolvePendingLegacyPrefill(_availableLocations);
    });
    await _loadPickListOptions();
  }

  Future<void> _loadPickListOptions() async {
    final options = await loadConditionGradePickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInConditions: widget.type.conditions,
      builtInGrades: widget.type.grades,
      selectedCondition: _defaultCondition,
      selectedGrade: _defaultGrade,
    );
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_defaultTags),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _conditionOptions = options.conditions;
      _gradeOptions = options.grades;
      _tagOptions = tagOptions;
    });
  }

  Future<void> _showDefaultTagsEditor() async {
    final controller = TextEditingController(text: _defaultTags ?? '');
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Owned default tags'),
          content: SizedBox(
            width: 440,
            child: TagPickListField(
              controller: controller,
              options: _tagOptions,
              label: 'Tags',
              hint: 'Comma-separated tags',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                joinPickListValues(splitPickListValues(controller.text)) ?? '',
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (!mounted || result == null) {
        return;
      }
      setState(() {
        _defaultTags = result.isEmpty ? null : result;
      });
    } finally {
      controller.dispose();
    }
  }

  void _tryResolvePendingLegacyPrefill(List<StorageLocation> locations) {
    if (_defaultLocationId != null || locations.isEmpty) {
      return;
    }
    final legacy = _pendingLegacyLocationPrefill?.trim();
    if (legacy == null || legacy.isEmpty) {
      return;
    }
    final match = locations.cast<StorageLocation?>().firstWhere(
          (location) =>
              location != null &&
              (location.fullPath(locations) == legacy || location.name == legacy),
          orElse: () => null,
        );
    if (match != null) {
      _defaultLocationId = match.id;
      _pendingLegacyLocationPrefill = null;
    }
  }

  String? get _defaultLocationLabel =>
      locationPathForId(_availableLocations, _defaultLocationId);

  Future<void> _pickDefaultLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _defaultLocationId,
    );
    if (result == null) {
      return;
    }
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _defaultLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }
}

