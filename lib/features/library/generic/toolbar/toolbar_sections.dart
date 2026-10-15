import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_shelf_style_dropdown.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

const double _kLibraryToolbarBandVerticalPadding = 0;
const double _kLibraryToolbarBandHorizontalPadding = 4;

void _noopDensityPresetChanged(LibraryWorkspaceDensityPreset _) {}

class LibraryDesktopSecondaryToolbar extends StatelessWidget {
  const LibraryDesktopSecondaryToolbar({
    super.key,
    required this.type,
    required this.viewState,
    required this.counts,
    required this.onEditColumns,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    this.onDensityPresetChanged = _noopDensityPresetChanged,
    required this.onCoverSizeChanged,
    required this.selectedBucket,
    this.linkedMetadataFilterLabel,
    required this.onClearBucket,
    required this.quickView,
    required this.hasActiveFilters,
    required this.onQuickViewSelected,
    required this.onClearFilters,
    this.onEditSort,
    this.activeSortFavoriteId,
    this.sortFavorites = const [],
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.onManageSortFavorites,
    this.onRandomPick,
    this.onDownloadAllCovers,
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onTransferFieldData,
    this.onReassignIndex,
    this.onPrintReport,
    this.onExportCsvTxt,
    this.onShareCollection,
    this.onCompareMetadataWithServer,
    this.extraActions = const [],
    this.groupMode = 'all',
    this.folderPreset,
    this.groupPresentation = LibraryGroupPresentation.inlineHeaders,
    this.availableGroupModes,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.onGroupModeChanged,
    this.onGroupPresentationChanged,
    this.selectionCallbacks,
    this.selectedCount = 0,
    this.currentSpacing,
    this.onSpacingChanged,
    this.totalSelectableCount = 0,
    this.showBottomBorder = true,
  });

  final double? currentSpacing;
  final ValueChanged<double>? onSpacingChanged;
  final LibraryKindRegistration type;
  final LibraryWorkspaceViewState viewState;
  final LibraryToolbarCounts counts;
  final VoidCallback onEditColumns;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspaceDensityPreset> onDensityPresetChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback? onEditSort;
  final String? selectedBucket;
  final String? linkedMetadataFilterLabel;
  final VoidCallback onClearBucket;
  final LibraryQuickView? quickView;
  final bool hasActiveFilters;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final VoidCallback onClearFilters;
  final String? activeSortFavoriteId;
  final List<LibrarySortFavorite> sortFavorites;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final VoidCallback? onManageSortFavorites;
  final VoidCallback? onRandomPick;
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onPrintReport;
  final VoidCallback? onExportCsvTxt;
  final VoidCallback? onShareCollection;
  final VoidCallback? onCompareMetadataWithServer;
  final List<LibraryUtilityMenuAction> extraActions;
  final LibraryFolderPreset? folderPreset;
  final String? groupMode;
  final LibraryGroupPresentation? groupPresentation;
  final List<String>? availableGroupModes;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final ValueChanged<LibraryFolderPreset>? onGroupModeChanged;
  final ValueChanged<LibraryGroupPresentation>? onGroupPresentationChanged;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final int selectedCount;
  final int totalSelectableCount;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final pinnedColumnPresets = [
      for (final preset in columnFavoritePresets)
        if (pinnedColumnFavoriteKeys.contains(libraryColumnFavoriteKey(preset)))
          preset,
    ];
    final overflowColumnPresets = [
      for (final preset in columnFavoritePresets)
        if (!pinnedColumnFavoriteKeys
            .contains(libraryColumnFavoriteKey(preset)))
          preset,
    ];
    final selectionMode = selectionCallbacks != null && selectedCount > 0;
    if (selectionMode) {
      return LibrarySelectionToolbarBand(
        selectedCount: selectedCount,
        totalSelectableCount: totalSelectableCount,
        callbacks: selectionCallbacks!,
        accent: type.identity.accent,
        itemPluralLabel: type.identity.pluralLabel,
        showBottomBorder: showBottomBorder,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: libraryWorkspaceToolbarColor(context),
        border:
            showBottomBorder ? libraryWorkspaceToolbarBorder(context) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kLibraryToolbarBandHorizontalPadding,
          vertical: _kLibraryToolbarBandVerticalPadding,
        ),
        child: SizedBox(
          height: kLibraryToolbarBandHeight,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (!viewState.isSidebarVisible &&
                          onGroupModeChanged != null) ...[
                        LibraryGroupModeMenuButton(
                          type: type,
                          folderPreset: folderPreset,
                          availableModes: availableGroupModes,
                          accent: type.identity.accent,
                          icon: folderPreset == null
                              ? Icons.account_tree_outlined
                              : genericFolderPresetIcon(folderPreset!, type),
                          onChanged: onGroupModeChanged!,
                          sidebarVisible: viewState.isSidebarVisible,
                          onSidebarVisibilityChanged:
                              onSidebarVisibilityChanged,
                          onClearBucket: onClearBucket,
                          pinnedFolderPresets: pinnedFolderPresets,
                          onPinnedPresetsChanged: onPinnedFolderPresetsChanged,
                          iconOnly: true,
                        ),
                        const SizedBox(width: 4),
                      ],
                      LibraryViewModeDropdown(
                        viewMode: viewState.viewMode,
                        onChanged: onViewModeChanged,
                        iconOnly: true,
                      ),
                      if (onEditSort != null)
                        const _LibraryDesktopToolbarSeparator(),
                      if (onEditSort != null)
                        LibraryToolbarSortButton(
                          fieldLabel: (id) {
                            final fields =
                                libraryKindWorkspaceForKind(type.kind)
                                    .workspaceFields;
                            return fields
                                .sortDefinitionFor(fields.decodeSortId(id))
                                .label;
                          },
                          onPressed: onEditSort!,
                          sortFavorites: sortFavorites,
                          activeSortFavoriteId: activeSortFavoriteId,
                          pinnedSortFavoriteIds: pinnedSortFavoriteIds,
                          onSortFavoriteSelected: onSortFavoriteSelected,
                          onManageFavoritesPressed: onManageSortFavorites,
                          iconOnly: true,
                        ),
                      if (viewState.viewMode == LibraryViewMode.list) ...[
                        const _LibraryDesktopToolbarSeparator(),
                        const SizedBox(width: 8),
                        _LibraryDesktopToolbarSection(
                          label: 'Columns',
                          child: _LibraryColumnLauncher(
                            activeLabel: activeColumnFavoriteLabel,
                            onManageColumns: onEditColumns,
                            pinnedPresets: pinnedColumnPresets,
                            overflowPresets: overflowColumnPresets,
                            onPresetSelected: onColumnFavoriteSelected,
                          ),
                        ),
                      ],
                      if (viewState.detailsLayout ==
                          LibraryDetailsLayout.hidden) ...[
                        const _LibraryDesktopToolbarSeparator(),
                        LibraryDetailsLayoutDropdown(
                          detailsLayout: viewState.detailsLayout,
                          onChanged: onDetailsLayoutChanged,
                          iconOnly: true,
                        ),
                      ],
                      if (viewState.viewMode == LibraryViewMode.list) ...[
                        const _LibraryDesktopToolbarSeparator(),
                        const SizedBox(width: 8),
                        _LibraryDesktopToolbarSection(
                          label: 'Item Spacing',
                          child: _buildSpacingSlider(
                            context,
                            tooltip: 'Item Spacing',
                          ),
                        ),
                      ] else ...[
                        const _LibraryDesktopToolbarSeparator(),
                        const SizedBox(width: 8),
                        _LibraryDesktopToolbarSection(
                          label: viewState.viewMode.supportsCoverSize
                              ? 'Covers & Spacing'
                              : 'Spacing',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (viewState.viewMode.supportsCoverSize)
                                LibraryCoverSizeSlider(
                                  viewMode: viewState.viewMode,
                                  coverSize: viewState.coverSize,
                                  minCoverSize:
                                      libraryViewProfileForKind(type.kind)
                                          .minCoverSize,
                                  maxCoverSize:
                                      libraryViewProfileForKind(type.kind)
                                          .maxCoverSize,
                                  onChanged: onCoverSizeChanged,
                                ),
                              if (viewState.viewMode.supportsCoverSize)
                                const SizedBox(width: 8),
                              _buildSpacingSlider(
                                context,
                                tooltip: 'Item Spacing',
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (viewState.viewMode == LibraryViewMode.shelves) ...[
                        const _LibraryDesktopToolbarSeparator(),
                        const LibraryShelfStyleDropdown(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              LibraryWorkspaceControlStrip(
                children: [
                  LibraryItemCountLabel(
                    shown: counts.shown,
                    total: counts.total,
                    pluralLabel: type.identity.pluralLabel,
                  ),
                  if (linkedMetadataFilterLabel != null)
                    LibraryToolbarScopeChip(
                      label: linkedMetadataFilterLabel!,
                      onClear: onClearBucket,
                    ),
                  LibraryToolsButton(
                    type: type,
                    counts: counts,
                    selectedBucket: selectedBucket ?? linkedMetadataFilterLabel,
                    quickView: quickView,
                    hasActiveFilters: hasActiveFilters,
                    onQuickViewSelected: onQuickViewSelected,
                    onClearFilters: onClearFilters,
                    onRandomPick: onRandomPick,
                    onDownloadAllCovers: onDownloadAllCovers,
                    shelfState: shelfState,
                    onSmartLists: onSmartLists,
                    onFolders: onFolders,
                    onReadingQueue: onReadingQueue,
                    onEditConditionPickList: onEditConditionPickList,
                    onEditGradePickList: onEditGradePickList,
                    onEditTagPickList: onEditTagPickList,
                    onTransferFieldData: onTransferFieldData,
                    onReassignIndex: onReassignIndex,
                    onPrintReport: onPrintReport,
                    onExportCsvTxt: onExportCsvTxt,
                    onShareCollection: onShareCollection,
                    onCompareMetadataWithServer: onCompareMetadataWithServer,
                    extraActions: extraActions,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpacingSlider(BuildContext context, {required String tooltip}) {
    if (onSpacingChanged != null) {
      return LibrarySpacingSlider(
        spacing: currentSpacing ?? 10.0,
        tooltip: tooltip,
        onChanged: onSpacingChanged!,
      );
    }
    final hasProvider = context
                .findAncestorWidgetOfExactType<ProviderScope>() !=
            null ||
        context.findAncestorWidgetOfExactType<UncontrolledProviderScope>() !=
            null;
    if (!hasProvider) {
      return LibrarySpacingSlider(
        spacing: currentSpacing ?? 10.0,
        tooltip: tooltip,
        onChanged: onSpacingChanged ?? (_) {},
      );
    }
    return Consumer(
      builder: (context, ref, _) {
        final uiPrefs = ref.watch(uiPreferencesProvider);
        return LibrarySpacingSlider(
          spacing: uiPrefs.gridSpacing,
          tooltip: tooltip,
          onChanged: (val) =>
              ref.read(uiPreferencesProvider.notifier).setGridSpacing(val),
        );
      },
    );
  }
}

class _LibraryDesktopToolbarSection extends StatelessWidget {
  const _LibraryDesktopToolbarSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _LibraryDesktopToolbarSeparator extends StatelessWidget {
  const _LibraryDesktopToolbarSeparator();
  @override
  Widget build(BuildContext context) => const LibraryWorkspaceSeparator();
}

enum _LibraryColumnLauncherAction { manage }

class _LibraryColumnLauncher extends StatelessWidget {
  const _LibraryColumnLauncher({
    required this.activeLabel,
    required this.onManageColumns,
    required this.pinnedPresets,
    required this.overflowPresets,
    required this.onPresetSelected,
  });

  final String? activeLabel;
  final VoidCallback onManageColumns;
  final List<LibraryTableColumnPreset> pinnedPresets;
  final List<LibraryTableColumnPreset> overflowPresets;
  final ValueChanged<LibraryTableColumnPreset>? onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final entries = <LibraryDenseMenuEntry<Object>>[
      const LibraryDenseMenuEntry<Object>(
        value: _LibraryColumnLauncherAction.manage,
        label: 'Manage Favorites',
        icon: Icons.settings_outlined,
      ),
    ];
    for (final preset in [...pinnedPresets, ...overflowPresets]) {
      entries.add(LibraryDenseMenuEntry<Object>(
        value: preset,
        label: preset.label,
        icon: null,
        active: preset.label == activeLabel,
      ));
    }
    return LibraryDenseSplitButton<Object>(
      key: const ValueKey('library-column-split-button'),
      label: 'Change columns',
      iconOnly: true,
      icon: AppIcons.columns,
      onPressed: onManageColumns,
      entries: entries,
      onSelected: (value) {
        if (value is LibraryTableColumnPreset) {
          onPresetSelected?.call(value);
          return;
        }
        onManageColumns();
      },
      tone: LibraryDenseButtonTone.surface,
      tooltip: 'Change Columns',
    );
  }
}

class LibraryDesktopFilteringToolbar extends StatelessWidget {
  const LibraryDesktopFilteringToolbar({
    super.key,
    required this.type,
    required this.accent,
    required this.searchController,
    required this.collectionStatusScope,
    required this.availableLetters,
    required this.onAdd,
    required this.onScan,
    required this.onRefreshMetadata,
    required this.onSearchChanged,
    this.onSearchInputChanged,
    this.onClearSearch,
    this.searchActive = false,
    this.searchSuggestions = const <LibraryToolbarSearchSuggestion>[],
    this.onSearchSuggestionSelected,
    this.onCollectionStatusScopeChanged,
    this.selectedLetter,
    this.onLetterSelected,
    this.onRandomPick,
    this.onScanCover,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
  });

  final LibraryKindRegistration type;
  final Color accent;
  final TextEditingController searchController;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchInputChanged;
  final VoidCallback? onClearSearch;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> searchSuggestions;
  final ValueChanged<LibraryToolbarSearchSuggestion>?
      onSearchSuggestionSelected;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;

  @override
  Widget build(BuildContext context) {
    final showChromeRow = onCollectionStatusScopeChanged != null;
    final narrow = MediaQuery.sizeOf(context).width < 900;
    final showAlphabetRow = onLetterSelected != null && !narrow;
    final leftControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!narrow)
          LibraryToolbarPrimaryActions(
            addLabel: 'Add ${type.identity.pluralLabel}',
            onAdd: onAdd,
            onScanBarcode: onScan,
            onRefreshMetadata: onRefreshMetadata,
            onRandomPick: onRandomPick,
            onScanCover: onScanCover,
            addBackgroundColor: accent,
            addForegroundColor: Colors.white,
          ),
        if (showChromeRow) ...[
          const LibraryWorkspaceSeparator(),
          LibraryCollectionStatusScopeDropdown(
            collectionStatusScope: collectionStatusScope,
            onCollectionStatusScopeChanged: onCollectionStatusScopeChanged!,
          ),
          const LibraryWorkspaceSeparator(),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sideWidth =
              (constraints.maxWidth * 0.3).clamp(0.0, 420.0).toDouble();
          final searchWidth = (constraints.maxWidth * (narrow ? 0.58 : 0.3))
              .clamp(0.0, 480.0)
              .toDouble();
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sideWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: leftControls,
                ),
              ),
              const SizedBox(width: 6),
              if (showAlphabetRow)
                Expanded(
                  child: LibraryToolbarAlphabetRow(
                    letters: availableLetters,
                    selectedLetter: selectedLetter,
                    accent: accent,
                    onLetterSelected: onLetterSelected!,
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),
              const SizedBox(width: 6),
              SizedBox(
                width: searchWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LibraryToolbarSearch(
                    controller: searchController,
                    hintText:
                        'Search ${type.identity.pluralLabel.toLowerCase()}...',
                    onScanBarcode: onScan,
                    onScanCover: onScanCover,
                    onRandomPick: onRandomPick,
                    onSearch: onSearchChanged,
                    onChanged: onSearchInputChanged,
                    selectionColor: appPalette(context).utilityAction,
                    searchTarget: searchTarget,
                    searchTargetOptions: searchTargetOptions,
                    onSearchTargetChanged: onSearchTargetChanged,
                    onClearSearch: onClearSearch,
                    searchActive: searchActive,
                    suggestions: searchSuggestions,
                    onSuggestionSelected: onSearchSuggestionSelected,
                    maxWidth: 380,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LibraryToolbarDividerLine extends StatelessWidget {
  const LibraryToolbarDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: appPalette(context).divider,
    );
  }
}

class LibrarySelectionToolbarBand extends StatelessWidget {
  const LibrarySelectionToolbarBand({
    super.key,
    required this.selectedCount,
    required this.totalSelectableCount,
    required this.callbacks,
    this.accent,
    this.itemPluralLabel,
    this.showBottomBorder = true,
  });

  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySelectionCallbacks callbacks;
  final Color? accent;
  final String? itemPluralLabel;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final effectiveAccent = accent ?? palette.accent;

    final borderTop = Color.lerp(effectiveAccent, Colors.white, 0.28)!;
    final borderBottom = Color.lerp(effectiveAccent, Colors.black, 0.22)!;
    final badgeBg = Color.lerp(effectiveAccent, Colors.black, 0.20)!;
    final badgeBorder = Color.lerp(effectiveAccent, Colors.white, 0.28)!;
    final dividerLeft = Color.lerp(effectiveAccent, Colors.black, 0.09)!;
    final dividerRight = Color.lerp(effectiveAccent, Colors.white, 0.11)!;

    final actionButtonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      overlayColor: Colors.white.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: TextStyle(
          fontFamily: appFontFamily,
          fontFamilyFallback: kAppFontFamilyFallback,
          fontSize: 13,
          fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );

    final isAllSelected =
        selectedCount == totalSelectableCount && totalSelectableCount > 0;

    final mergeLabel =
        itemPluralLabel != null && itemPluralLabel!.toLowerCase() == 'music'
            ? 'Merge Albums'
            : 'Merge ${itemPluralLabel ?? 'Albums'}';

    return AnimatedLibraryChrome(
      accent: effectiveAccent,
      borderBuilder: (animatedAccent, _) => Border(
        top: BorderSide(color: borderTop),
        bottom: showBottomBorder
            ? BorderSide(color: borderBottom)
            : BorderSide.none,
      ),
      child: SizedBox(
        width: double.infinity,
        height: kLibraryToolbarBandHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final leftOptions = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    onPressed: callbacks.onClearSelection,
                    style: actionButtonStyle,
                    icon: const Icon(
                      AppIcons.close,
                      size: 13,
                      color: Colors.white,
                    ),
                    label: const Text('Cancel'),
                  ),
                  LibrarySelectionToolbarDivider(
                    dividerLeft: dividerLeft,
                    dividerRight: dividerRight,
                  ),
                  Tooltip(
                    message: 'Select all visible items',
                    child: TextButton.icon(
                      onPressed: callbacks.onSelectAll,
                      style: actionButtonStyle,
                      icon: Icon(
                        isAllSelected
                            ? AppIcons.selectAll
                            : AppIcons.selectNone,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text('All'),
                    ),
                  ),
                ],
              );

              final centerActions = LibrarySelectionControls(
                callbacks: callbacks,
                onAccent: true,
                accent: effectiveAccent,
                mergeLabel: mergeLabel,
              );

              final rightCountPill = DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: badgeBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: Text(
                    '$selectedCount of $totalSelectableCount selected',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                  ),
                ),
              );

              const minWidthForSpacedLayout = 880.0;
              final useSpacedLayout = constraints.hasBoundedWidth &&
                  constraints.maxWidth >= minWidthForSpacedLayout;

              if (useSpacedLayout) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftOptions,
                    const SizedBox(width: 12),
                    centerActions,
                    const Spacer(),
                    Center(child: rightCountPill),
                  ],
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: kLibraryToolbarBandHeight - 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftOptions,
                      const SizedBox(width: 12),
                      centerActions,
                      const SizedBox(width: 16),
                      Center(child: rightCountPill),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LibraryCompactToolbarContent extends StatelessWidget {
  const LibraryCompactToolbarContent({
    super.key,
    required this.type,
    required this.searchController,
    required this.accent,
    required this.counts,
    required this.viewMode,
    required this.selectedBucket,
    this.linkedMetadataFilterLabel,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    this.onSearchInputChanged,
    required this.onRefreshMetadata,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onDensityPresetChanged,
    required this.onCoverSizeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.pinnedViewPresets = const {},
    this.onTogglePinnedViewPreset,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    this.onTogglePinnedColumnFavorite,
    required this.onManageColumns,
    this.canJumpToNumber = false,
    this.onJumpToNumberSubmitted,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onClearBucket,
    this.onRandomPick,
    this.onDownloadAllCovers,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onEditSort,
    this.onCompareMetadataWithServer,
    this.extraActions = const [],
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
    this.selectionCallbacks,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
    this.onClearSearch,
    this.searchActive = false,
    this.groupPresentation,
    this.onGroupPresentationChanged,
  });

  final LibraryKindRegistration type;
  final TextEditingController searchController;
  final Color accent;
  final LibraryToolbarCounts counts;
  final LibraryViewMode viewMode;
  final String? selectedBucket;
  final String? linkedMetadataFilterLabel;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchInputChanged;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspaceDensityPreset> onDensityPresetChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final VoidCallback onManageColumns;
  final bool canJumpToNumber;
  final ValueChanged<String>? onJumpToNumberSubmitted;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onClearBucket;
  final VoidCallback? onRandomPick;
  final VoidCallback? onDownloadAllCovers;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onEditSort;
  final VoidCallback? onCompareMetadataWithServer;
  final List<LibraryUtilityMenuAction> extraActions;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback? onClearSearch;
  final bool searchActive;
  final LibraryGroupPresentation? groupPresentation;
  final ValueChanged<LibraryGroupPresentation>? onGroupPresentationChanged;

  @override
  Widget build(BuildContext context) {
    final showChromeRow = onCollectionStatusScopeChanged != null;
    final showAlphabetRow =
        availableLetters.isNotEmpty && onLetterSelected != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: LayoutBuilder(builder: (context, constraints) {
            final search = SearchBar(
              controller: searchController,
              constraints: const BoxConstraints.tightFor(height: 36),
              hintText: 'Search ${type.identity.pluralLabel.toLowerCase()}...',
              leading: const Icon(Icons.search),
              trailing: searchActive
                  ? [
                      IconButton(
                        tooltip: 'Clear search',
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.clear, size: 18),
                      ),
                    ]
                  : null,
              onChanged: onSearchInputChanged,
              onSubmitted: onSearchChanged,
            );
            final actions = <Widget>[
              if (searchTargetOptions.isNotEmpty &&
                  onSearchTargetChanged != null) ...[
                const SizedBox(width: 6),
                PopupMenuButton<LibrarySearchTarget>(
                  tooltip: 'Search scope',
                  color: libraryToolbarMenuSurface(context),
                  shape: libraryToolbarDropdownMenuShape(context),
                  surfaceTintColor: Colors.transparent,
                  position: PopupMenuPosition.under,
                  menuPadding: EdgeInsets.zero,
                  onSelected: onSearchTargetChanged,
                  itemBuilder: (context) => [
                    for (final option in searchTargetOptions)
                      PopupMenuItem<LibrarySearchTarget>(
                        value: option,
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(_librarySearchTargetLabel(option)),
                      ),
                  ],
                  child: _CompactSearchScopeTrigger(
                    label: _librarySearchTargetLabel(searchTarget),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: libraryAccentActionColor(accent),
                  foregroundColor:
                      appContrastingTextColor(libraryAccentActionColor(accent)),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Add ${type.identity.pluralLabel}',
              ),
              const SizedBox(width: 4),
              if (onFolders != null) ...[
                Tooltip(
                  message: 'Folders',
                  child: IconButton.filledTonal(
                    onPressed: onFolders,
                    icon: const Icon(Icons.folder_outlined),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              LibraryToolsButton(
                type: type,
                counts: counts,
                selectedBucket: selectedBucket ?? linkedMetadataFilterLabel,
                quickView: quickView,
                hasActiveFilters: hasActiveFilters,
                onQuickViewSelected: onQuickViewSelected,
                onClearFilters: onClearFilters,
                onRandomPick: onRandomPick,
                onDownloadAllCovers: onDownloadAllCovers,
                onSmartLists: onSmartLists,
                onFolders: onFolders,
                onReadingQueue: onReadingQueue,
                onEditConditionPickList: onEditConditionPickList,
                onEditGradePickList: onEditGradePickList,
                onEditTagPickList: onEditTagPickList,
                onEditSort: onEditSort,
                onCompareMetadataWithServer: onCompareMetadataWithServer,
                extraActions: extraActions,
              ),
            ];
            if (constraints.maxWidth < 560) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: 6),
                    Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 4,
                        children: actions),
                  ]);
            }
            return Row(children: [Expanded(child: search), ...actions]);
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.start,
                  children: [
                    Tooltip(
                      message: viewMode.supportsCoverSize
                          ? 'Views and cover size'
                          : 'Views (cover size unavailable in this view)',
                      child: IconButton.filledTonal(
                        onPressed: () => showLibraryCompactCoverSizeSheet(
                          context,
                          viewMode,
                          onViewModeChanged,
                          onDetailsLayoutChanged,
                          onCoverSizeChanged,
                        ),
                        icon: const Icon(
                          Icons.photo_size_select_large_outlined,
                        ),
                      ),
                    ),
                    if (linkedMetadataFilterLabel != null)
                      LibraryToolbarScopeChip(
                        label: linkedMetadataFilterLabel!,
                        onClear: onClearBucket,
                      ),
                    LibraryItemCountLabel(
                      shown: counts.shown,
                      total: counts.total,
                      pluralLabel: type.identity.pluralLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectionCallbacks != null && selectedCount > 0) ...[
          const LibraryToolbarDividerLine(),
          LibrarySelectionToolbarBand(
            selectedCount: selectedCount,
            totalSelectableCount: totalSelectableCount,
            callbacks: selectionCallbacks!,
            accent: accent,
            itemPluralLabel: type.identity.pluralLabel,
            showBottomBorder: !showChromeRow,
          ),
        ],
        if (showChromeRow) ...[
          const LibraryToolbarDividerLine(),
          LibraryToolbarChromeRow(
            collectionStatusScope: collectionStatusScope,
            onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
            activeViewPreset: activeViewPreset,
            onViewPresetSelected: onViewPresetSelected,
            pinnedViewPresets: pinnedViewPresets,
            onTogglePinnedViewPreset: onTogglePinnedViewPreset,
            sortFavorites: sortFavorites,
            activeSortFavoriteId: activeSortFavoriteId,
            onSortFavoriteSelected: onSortFavoriteSelected,
            pinnedSortFavoriteIds: pinnedSortFavoriteIds,
            onTogglePinnedSortFavorite: onTogglePinnedSortFavorite,
            columnFavoritePresets: columnFavoritePresets,
            activeColumnFavoriteLabel: activeColumnFavoriteLabel,
            onColumnFavoriteSelected: onColumnFavoriteSelected,
            pinnedColumnFavoriteKeys: pinnedColumnFavoriteKeys,
            onTogglePinnedColumnFavorite: onTogglePinnedColumnFavorite,
            onManageColumns: onManageColumns,
            canJumpToNumber: canJumpToNumber,
            onJumpToNumberSubmitted: onJumpToNumberSubmitted,
          ),
        ],
        if (showAlphabetRow) ...[
          const LibraryToolbarDividerLine(),
          LibraryToolbarAlphabetRow(
            letters: availableLetters,
            selectedLetter: selectedLetter,
            accent: accent,
            onLetterSelected: onLetterSelected!,
          ),
        ],
      ],
    );
  }
}

class _CompactSearchScopeTrigger extends StatefulWidget {
  const _CompactSearchScopeTrigger({required this.label});
  final String label;

  @override
  State<_CompactSearchScopeTrigger> createState() =>
      _CompactSearchScopeTriggerState();
}

class _CompactSearchScopeTriggerState
    extends State<_CompactSearchScopeTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = appPalette(context);
    final bgColor = _hovered
        ? (palette.isDark ? const Color(0xFF4A4A4A) : palette.surfaceBright)
        : Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _hovered
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: LayoutBuilder(
            builder: (context, constraints) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune, size: 16),
                    if (constraints.maxWidth >= 50) ...[
                      const SizedBox(width: 4),
                      Flexible(
                          child: Text(widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium)),
                    ],
                  ],
                )),
      ),
    );
  }
}

class LibraryToolbarChromeRow extends StatelessWidget {
  const LibraryToolbarChromeRow({
    super.key,
    required this.collectionStatusScope,
    this.onCollectionStatusScopeChanged,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.pinnedViewPresets = const {},
    this.onTogglePinnedViewPreset,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    this.onTogglePinnedColumnFavorite,
    required this.onManageColumns,
    this.canJumpToNumber = false,
    this.onJumpToNumberSubmitted,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final VoidCallback onManageColumns;
  final bool canJumpToNumber;
  final ValueChanged<String>? onJumpToNumberSubmitted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: onCollectionStatusScopeChanged == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.centerLeft,
                child: LibraryCollectionStatusScopeDropdown(
                  collectionStatusScope: collectionStatusScope,
                  onCollectionStatusScopeChanged:
                      onCollectionStatusScopeChanged!,
                ),
              ),
      );
}

String _librarySearchTargetLabel(LibrarySearchTarget target) {
  return switch (target) {
    LibrarySearchTarget.all => 'Albums & Tracks',
    LibrarySearchTarget.mediaOnly => 'Albums',
    LibrarySearchTarget.tracksOnly => 'Tracks',
  };
}
