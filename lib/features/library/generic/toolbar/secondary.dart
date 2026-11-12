import 'package:collectarr_app/ui/adaptive/mobile_metrics.dart';
import 'package:collectarr_app/features/library/selection/commands.dart';
import 'package:collectarr_app/features/library/selection/action.dart';
import 'selection.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/ui/app_dark_chrome.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/workspace/chrome/view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/shelf_style_dropdown.dart';
import 'package:collectarr_app/features/library/workspace/chrome/chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/utility_menu.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/entry/view_state.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';

import 'alphabet_row.dart';
import 'package:collectarr_app/features/library/workspace/mobile/mobile_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/mobile/mobile_view_mode.dart';

import 'mobile/actions.dart';

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
    this.onManageColumnFavorites,
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
    this.linkedMetadataFilters = const [],
    required this.onRemoveLinkedMetadataFilter,
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
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
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
    this.selectionActions = const [],
    this.selectedCount = 0,
    this.currentSpacing,
    this.onSpacingChanged,
    this.totalSelectableCount = 0,
    this.showBottomBorder = true,
    this.showMobileFolderRoot = false,
    this.tabletPanes = false,
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
  });

  final double? currentSpacing;
  final ValueChanged<double>? onSpacingChanged;
  final LibraryKindRegistration type;
  final bool showMobileFolderRoot;

  /// The folder panel names the folder, so the toolbar has no folder button.
  final bool tabletPanes;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final LibraryWorkspaceViewState viewState;
  final LibraryToolbarCounts counts;
  final VoidCallback onEditColumns;
  final VoidCallback? onManageColumnFavorites;
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
  final List<LibraryLinkedMetadataFilter> linkedMetadataFilters;
  final ValueChanged<LibraryLinkedMetadataFilter> onRemoveLinkedMetadataFilter;
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
  final ShelfState? shelfState;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
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
  final LibrarySelectionStateCallbacks? selectionCallbacks;
  final List<ResolvedLibrarySelectionAction> selectionActions;
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
        actions: selectionActions,
        showBottomBorder: showBottomBorder,
      );
    }
    if (appPresentationPlatform.isNativeMobile) return _buildMobile(context);
    return AppDarkChrome(
        child: DecoratedBox(
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
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
                            onPinnedPresetsChanged:
                                onPinnedFolderPresetsChanged,
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
                          _LibraryDesktopToolbarSection(
                            label: 'Columns',
                            child: _LibraryColumnLauncher(
                              activeLabel: activeColumnFavoriteLabel,
                              onManageColumns: onEditColumns,
                              onManageColumnFavorites: onManageColumnFavorites,
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
                            label: 'Cover Size',
                            child: LibraryCoverSizeSlider(
                              viewMode: viewState.viewMode,
                              coverSize: viewState.coverSize,
                              minCoverSize: libraryViewProfileForKind(type.kind)
                                  .minCoverSize,
                              maxCoverSize: libraryViewProfileForKind(type.kind)
                                  .maxCoverSize,
                              onChanged: onCoverSizeChanged,
                            ),
                          ),
                        ] else if (viewState.viewMode.supportsCoverSize) ...[
                          const _LibraryDesktopToolbarSeparator(),
                          const SizedBox(width: 8),
                          _LibraryDesktopToolbarSection(
                            label: 'Covers & Spacing',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                      singularLabel: type.identity.singularLabel,
                      pluralLabel: type.identity.pluralLabel,
                    ),
                    LibraryToolsButton(
                      type: type,
                      counts: counts,
                      // The folder button already names the folder on a phone.
                      selectedBucket: libraryLinkedMetadataFiltersLabel(
                          linkedMetadataFilters),
                      quickView: quickView,
                      hasActiveFilters: hasActiveFilters,
                      onQuickViewSelected: onQuickViewSelected,
                      onClearFilters: onClearFilters,
                      onRandomPick: onRandomPick,
                      shelfState: shelfState,
                      onSmartLists: onSmartLists,
                      onFolders: onFolders,
                      onReadingQueue: onReadingQueue,
                      onEditConditionPickList: onEditConditionPickList,
                      onEditGradePickList: onEditGradePickList,
                      onShareCollection: onShareCollection,
                      onCompareMetadataWithServer: onCompareMetadataWithServer,
                      extraActions: extraActions,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Value chips accumulate, so they get a row that wraps instead of
          // pushing the toolbar's controls out of view.
          if (linkedMetadataFilters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final filter in linkedMetadataFilters)
                      LibraryToolbarScopeChip(
                        label: filter.chipLabel,
                        onClear: () => onRemoveLinkedMetadataFilter(filter),
                      ),
                  ],
                ),
              ),
            ),
        ]),
      ),
    ));
  }

  Widget _buildMobile(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final palette = appPalette(context);
      final background = (palette.isDark
              ? type.identity.mobileToolbarDark
              : type.identity.mobileToolbarLight) ??
          Color.alphaBlend(
              type.identity.accent.withValues(alpha: .2), palette.panel);
      return LibraryMobileToolbarActions(
        background: background,
        foreground: palette.textPrimary,
        actions: [
          if (onGroupModeChanged != null &&
              (!tabletPanes || !viewState.isSidebarVisible))
            Expanded(
                child: LibraryGroupModeMenuButton(
              key: const Key('library.mobile-folder'),
              type: type,
              folderPreset: folderPreset,
              selectedBucket: selectedBucket,
              accent: type.identity.accent,
              icon: Icons.folder_outlined,
              onChanged: onGroupModeChanged!,
              sidebarVisible: viewState.isSidebarVisible,
              onSidebarVisibilityChanged: onSidebarVisibilityChanged,
              onClearBucket: onClearBucket,
              availableModes: availableGroupModes,
              pinnedFolderPresets: pinnedFolderPresets,
              onPinnedPresetsChanged: onPinnedFolderPresetsChanged,
            ))
          else
            const Spacer(),
          if (!showMobileFolderRoot &&
              availableLetters.isNotEmpty &&
              onLetterSelected != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: LibraryMobileAlphabetButton(
                letters: availableLetters,
                alphabet: libraryToolbarAlphabet,
                selectedLetter: selectedLetter,
                background: libraryMobileToolbarButtonColor(context),
                onLetterSelected: onLetterSelected!,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: LibraryMobileViewMenu(
              viewMode: viewState.viewMode,
              background: libraryMobileToolbarButtonColor(context),
              onChanged: onViewModeChanged,
            ),
          ),
          if (onEditSort != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: IconButton(
                  key: const Key('library.mobile-sort'),
                  tooltip: 'Change Sorting',
                  style: IconButton.styleFrom(
                      backgroundColor: libraryMobileToolbarButtonColor(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      minimumSize: const Size.square(kMobileToolbarButtonSize),
                      fixedSize: const Size.square(kMobileToolbarButtonSize),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.sort_by_alpha,
                      size: kMobileToolbarIconSize),
                  onPressed: onEditSort),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: libraryMobileToolbarButtonColor(context),
                  borderRadius: BorderRadius.circular(5)),
              child: LibraryToolsButton(
                  type: type,
                  counts: counts,
                  // The folder button already names the folder on a phone.
                  selectedBucket:
                      libraryLinkedMetadataFiltersLabel(linkedMetadataFilters),
                  quickView: quickView,
                  hasActiveFilters: hasActiveFilters,
                  onQuickViewSelected: onQuickViewSelected,
                  onClearFilters: onClearFilters,
                  onRandomPick: onRandomPick,
                  shelfState: shelfState,
                  onSmartLists: onSmartLists,
                  onFolders: onFolders,
                  onReadingQueue: onReadingQueue,
                  onEditConditionPickList: onEditConditionPickList,
                  onEditGradePickList: onEditGradePickList,
                  onShareCollection: onShareCollection,
                  onCompareMetadataWithServer: onCompareMetadataWithServer,
                  extraActions: extraActions),
            ),
          ),
        ],
        coverSizeSlider: !showMobileFolderRoot &&
                LibraryMobileViewMode.from(viewState.viewMode) ==
                    LibraryMobileViewMode.images
            ? LibraryMobileCoverSizeSlider(
                value: viewState.coverSize,
                min: libraryViewProfileForKind(type.kind).minCoverSize,
                max: libraryViewProfileForKind(type.kind).maxCoverSize,
                onChanged: onCoverSizeChanged,
              )
            : null,
        countLabel: showMobileFolderRoot
            ? null
            : '${counts.shown}${counts.shown == counts.total ? '' : ' / ${counts.total}'} ${type.identity.countLabel(counts.shown).toLowerCase()}',
      );
    });
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
    this.onManageColumnFavorites,
    required this.pinnedPresets,
    required this.overflowPresets,
    required this.onPresetSelected,
  });

  final String? activeLabel;
  final VoidCallback onManageColumns;
  final VoidCallback? onManageColumnFavorites;
  final List<LibraryTableColumnPreset> pinnedPresets;
  final List<LibraryTableColumnPreset> overflowPresets;
  final ValueChanged<LibraryTableColumnPreset>? onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final entries = <LibraryDenseMenuEntry<Object>>[
      const LibraryDenseMenuEntry<Object>(
        value: _LibraryColumnLauncherAction.manage,
        label: 'Manage Favorites',
        icon: null,
        trailingIcon: AppIcons.settings,
        reserveLeadingSpace: false,
      ),
    ];
    final presets = [...pinnedPresets, ...overflowPresets];
    for (final preset in presets) {
      entries.add(LibraryDenseMenuEntry<Object>(
        value: preset,
        label: preset.label,
        icon: null,
        active: preset.label == activeLabel,
        // The reference heads the favorites below Manage Favorites.
        section: identical(preset, presets.first) ? 'Favorites' : null,
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
        (onManageColumnFavorites ?? onManageColumns)();
      },
      tone: LibraryDenseButtonTone.surface,
      tooltip: 'Change Columns',
    );
  }
}
