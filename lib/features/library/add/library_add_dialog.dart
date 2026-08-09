import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_contracts.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_bottom_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_mode_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_shell.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

export 'controllers/library_add_dialog_requests.dart';
export 'controllers/library_add_manual_draft.dart';
export 'library_add_ranking.dart';
export 'panes/library_add_preview_pane.dart';

String buildPreviewCatalogItemId({
  required String kind,
  required String provider,
  required String providerItemId,
}) {
  final previewKey = '$kind:$provider:$providerItemId';
  return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
}

Widget buildDefaultManualPane(
    BuildContext context, LibraryAddManualPaneRequest request) {
  return LibraryAddManualPane(request: request);
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
  ConsumerState<LibraryAddDialog> createState() => LibraryAddDialogState();
}

class LibraryAddDialogState extends ConsumerState<LibraryAddDialog> {
  late final LibraryAddSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LibraryAddSessionController(
      kind: widget.type.workspace.kind,
      ownedMutations: ref.read(ownedItemMutationsProvider),
      wishlistMutations: ref.read(wishlistMutationsProvider),
      trackingMutations: ref.read(trackingMutationsProvider),
    );

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.updateQuery(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ?? widget.type.workspace.accent;
    final state = _controller.state;

    return LibraryAddShell(
      accent: accent,
      width: 1320.0,
      height: 860.0,
      minWidth: 760.0,
      maxWidth: 1800.0,
      minHeight: 560.0,
      maxHeight: 1200.0,
      onResizeWidth: (_) {},
      onResizeHeight: (_) {},
      header: AccentDialogHeader(
        title: 'Add ${widget.type.workspace.kind.apiValue}',
        accent: accent,
        onClose: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          LibraryAddModeBar(
            type: widget.type,
            accent: accent,
            isMovieDesktopChrome: widget.type.capabilities.wideDialog,
            mode: state.mode,
            canScanCover: false,
            isScanningCover: false,
            onScanCover: () {},
            onLookupBarcode: () {},
            onManual: () => _controller.setMode(LibraryAddDialogMode.manual),
            showAdvanced: false,
            onToggleAdvanced: () {},
            queryController: TextEditingController(text: state.search.query),
            barcodeController: TextEditingController(),
            seriesController: TextEditingController(),
            numberController: TextEditingController(),
            publisherController: TextEditingController(),
            yearController: TextEditingController(),
            isSearching: state.search.isSearching,
            isSearchingProvider: false,
            onModeChanged: _controller.setMode,
            onSearch: _controller.executeSearch,
            onQueryChanged: _controller.updateQuery,
            suggestions: const [],
            showSuggestions: false,
            onSelectSuggestion: (_) {},
            onDismissSuggestions: () {},
          ),
          Expanded(
            child: switch (state.mode) {
              LibraryAddDialogMode.search ||
              LibraryAddDialogMode.barcode =>
                LibraryAddSearchPane(
                  type: widget.type,
                  isBusy: state.search.isSearching,
                  isMovieDesktopChrome: widget.type.capabilities.wideDialog,
                  error: state.search.error,
                  accent: accent,
                  results: const [],
                  providerResults: const [],
                  queuedProviderIngests: const {},
                  selectedProvider: '',
                  searchedProvider: false,
                  selectedResultId: state.selection.selectedId,
                  selectedProviderCandidateId: null,
                  checkedResultIds: const {},
                  checkedProviderIds: const {},
                  ownedCatalogItemIds: const {},
                  providerQueryText: state.search.query,
                  providerSeriesText: '',
                  providerNumberText: '',
                  providerPublisherText: '',
                  providerYearText: '',
                  isWideLayout: true,
                  showCoreResults: true,
                  showProviderResults: true,
                  showMediaResults: true,
                  showSeasonResults: true,
                  showReleaseResults: true,
                  hideComicOwnedResults: false,
                  hideComicVariantResults: false,
                  compactComicIssues: false,
                  onSelectResult: _controller.selectResult,
                  onSelectProviderCandidate: (_) {},
                  onToggleResultCheck: (_) {},
                  onToggleProviderCheck: (_) {},
                  onShowCoreResultsChanged: (_) {},
                  onShowProviderResultsChanged: (_) {},
                  onShowMediaResultsChanged: (_) {},
                  onShowSeasonResultsChanged: (_) {},
                  onShowReleaseResultsChanged: (_) {},
                  onHideComicOwnedResultsChanged: (_) {},
                  onHideComicVariantResultsChanged: (_) {},
                  onCompactComicIssuesChanged: (_) {},
                  onSearchCore: _controller.executeSearch,
                ),
              LibraryAddDialogMode.manual => widget.manualPaneBuilder?.call(
                    context,
                    LibraryAddManualPaneRequest(
                      kind: widget.type.workspace.kind,
                      accent: accent,
                      type: widget.type,
                      commonDraft: state.commonDraft,
                      kindDraft: state.manualDraft,
                      onCommonDraftChanged: (common) =>
                          _controller.updateCommonDraft((_) => common),
                      onKindDraftChanged: (draft) =>
                          _controller.updateKindDraft((_) => draft),
                      titleController: TextEditingController(text: state.search.query),
                      numberController: TextEditingController(),
                      publisherController: TextEditingController(),
                      yearController: TextEditingController(),
                      barcodeController: TextEditingController(),
                      variantController: TextEditingController(),
                      physicalFormatLabelController: TextEditingController(),
                      coverController: TextEditingController(),
                      backCoverController: TextEditingController(),
                      creatorsController: TextEditingController(),
                      charactersController: TextEditingController(),
                      physicalFormats: const [],
                      physicalFormatId: null,
                      onPhysicalFormatChanged: (_) {},
                      onPhysicalFormatLabelChanged: (_) {},
                      isAdding: false,
                      defaultCondition: 'Near Mint',
                      defaultGrade: 'Ungraded',
                      defaultLocationLabel: null,
                      defaultPurchaseDate: null,
                      defaultTags: null,
                      onAddOwned: () {},
                      onAddWishlist: () {},
                      onAddTrack: () {},
                      editionTitleController: TextEditingController(),
                      releaseDateController: TextEditingController(),
                      pageCountController: TextEditingController(),
                      imprintController: TextEditingController(),
                      seriesGroupController: TextEditingController(),
                      countryController: TextEditingController(),
                      languageController: TextEditingController(),
                      ageRatingController: TextEditingController(),
                      genresEditController: TextEditingController(),
                      synopsisController: TextEditingController(),
                      tagsController: TextEditingController(),
                      publisherOptions: const [],
                      imprintOptions: const [],
                      seriesGroupOptions: const [],
                      physicalFormatOptions: const [],
                      seriesEntries: const [],
                      onManagePublishers: () {},
                      onManageImprints: () {},
                      onManageSeriesGroups: () {},
                      onManagePhysicalFormats: () {},
                      onManageSeries: () {},
                      onSeriesChanged: (_) {},
                      customFieldDefinitions: const [],
                      customFieldValues: const {},
                      onCustomFieldValuesChanged: (_) {},
                      itemImages: const [],
                      onItemImagesChanged: (_) {},
                    ),
                  ) ??
                  buildDefaultManualPane(
                    context,
                    LibraryAddManualPaneRequest(
                      kind: widget.type.workspace.kind,
                      accent: accent,
                      type: widget.type,
                      commonDraft: state.commonDraft,
                      kindDraft: state.manualDraft,
                      onCommonDraftChanged: (common) =>
                          _controller.updateCommonDraft((_) => common),
                      onKindDraftChanged: (draft) =>
                          _controller.updateKindDraft((_) => draft),
                      titleController: TextEditingController(text: state.search.query),
                      numberController: TextEditingController(),
                      publisherController: TextEditingController(),
                      yearController: TextEditingController(),
                      barcodeController: TextEditingController(),
                      variantController: TextEditingController(),
                      physicalFormatLabelController: TextEditingController(),
                      coverController: TextEditingController(),
                      backCoverController: TextEditingController(),
                      creatorsController: TextEditingController(),
                      charactersController: TextEditingController(),
                      physicalFormats: const [],
                      physicalFormatId: null,
                      onPhysicalFormatChanged: (_) {},
                      onPhysicalFormatLabelChanged: (_) {},
                      isAdding: false,
                      defaultCondition: 'Near Mint',
                      defaultGrade: 'Ungraded',
                      defaultLocationLabel: null,
                      defaultPurchaseDate: null,
                      defaultTags: null,
                      onAddOwned: () {},
                      onAddWishlist: () {},
                      onAddTrack: () {},
                      editionTitleController: TextEditingController(),
                      releaseDateController: TextEditingController(),
                      pageCountController: TextEditingController(),
                      imprintController: TextEditingController(),
                      seriesGroupController: TextEditingController(),
                      countryController: TextEditingController(),
                      languageController: TextEditingController(),
                      ageRatingController: TextEditingController(),
                      genresEditController: TextEditingController(),
                      synopsisController: TextEditingController(),
                      tagsController: TextEditingController(),
                      publisherOptions: const [],
                      imprintOptions: const [],
                      seriesGroupOptions: const [],
                      physicalFormatOptions: const [],
                      seriesEntries: const [],
                      onManagePublishers: () {},
                      onManageImprints: () {},
                      onManageSeriesGroups: () {},
                      onManagePhysicalFormats: () {},
                      onManageSeries: () {},
                      onSeriesChanged: (_) {},
                      customFieldDefinitions: const [],
                      customFieldValues: const {},
                      onCustomFieldValuesChanged: (_) {},
                      itemImages: const [],
                      onItemImagesChanged: (_) {},
                    ),
                  ),
            },
          ),
        ],
      ),
      footer: LibraryAddBottomBar(
        type: widget.type,
        isMovieDesktopChrome: widget.type.capabilities.wideDialog,
        conditions: const [],
        grades: const [],
        defaultTags: null,
        accent: accent,
        selectedItem: null,
        selectedCandidate: null,
        selectedQueuedIngest: null,
        providerLabel: 'Provider',
        addTarget: state.target,
        addCount: 1,
        isAdding: state.submitState.isLoading,
        isQueueingIngest: false,
        isAdmin: false,
        defaultCondition: 'Near Mint',
        defaultGrade: 'Ungraded',
        defaultLocationLabel: null,
        defaultPurchaseDate: null,
        onAddTargetChanged: _controller.setTarget,
        onDefaultConditionChanged: (_) {},
        onDefaultGradeChanged: (_) {},
        onEditDefaultTagsPressed: () {},
        onDefaultLocationPressed: () {},
        onDefaultPurchaseDateChanged: (_) {},
        onAdd: () async {
          if (state.selection.selectedId != null) {
            final item = CatalogItem(
              id: state.selection.selectedId!,
              kind: widget.type.workspace.kind.apiValue,
              title: state.selection.selectedId!,
            );
            final success = await _controller.submitSelectedItem(item);
            if (success && mounted) {
              Navigator.of(context).pop(true);
            }
          }
        },
        onQueueIngest: () {},
        onPropose: () {},
      ),
    );
  }
}
