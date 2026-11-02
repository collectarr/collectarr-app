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
import 'package:collectarr_app/features/library/selection/controls.dart';
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
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onTransferFieldData,
    this.onReassignIndex,
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
  final ShelfState? shelfState;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onReassignIndex;
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
                    singularLabel: type.identity.singularLabel,
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
                    shelfState: shelfState,
                    onSmartLists: onSmartLists,
                    onFolders: onFolders,
                    onReadingQueue: onReadingQueue,
                    onEditConditionPickList: onEditConditionPickList,
                    onEditGradePickList: onEditGradePickList,
                    onTransferFieldData: onTransferFieldData,
                    onReassignIndex: onReassignIndex,
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
              (constraints.maxWidth < 1000 || !viewState.isSidebarVisible))
            Expanded(
                child: LibraryGroupModeMenuButton(
              key: const Key('library.mobile-folder'),
              type: type,
              folderPreset: folderPreset,
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
          IconButton(
              key: const Key('library.mobile-views'),
              tooltip: 'Views and cover size',
              icon: const Icon(Icons.grid_view),
              onPressed: () => showViewAndOrganizeSheet(
                    context: context,
                    currentViewMode: viewState.viewMode,
                    onViewModeChanged: onViewModeChanged,
                    currentDetailsLayout: viewState.detailsLayout,
                    onDetailsLayoutChanged: onDetailsLayoutChanged,
                    currentCoverSize: viewState.coverSize,
                    minCoverSize:
                        libraryViewProfileForKind(type.kind).minCoverSize,
                    maxCoverSize:
                        libraryViewProfileForKind(type.kind).maxCoverSize,
                    onCoverSizeChanged: onCoverSizeChanged,
                    currentSpacing: currentSpacing,
                    onSpacingChanged: onSpacingChanged,
                    onOpenColumnChooser: onEditColumns,
                    onOpenSortDialog: onEditSort,
                  )),
          if (onEditSort != null)
            PopupMenuButton<Object>(
                key: const Key('library.mobile-sort'),
                tooltip: 'Change Sorting',
                style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: const Size.square(48)),
                icon: const Icon(Icons.sort_by_alpha),
                onSelected: (value) {
                  if (value == 'sort') {
                    onEditSort!();
                  } else if (value == 'manage') {
                    onManageSortFavorites?.call();
                  } else if (value is LibrarySortFavorite) {
                    onSortFavoriteSelected?.call(value);
                  }
                },
                itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'sort', height: 48, child: Text('Sort...')),
                      for (final favorite in sortFavorites)
                        CheckedPopupMenuItem(
                            value: favorite,
                            height: 48,
                            checked: favorite.id == activeSortFavoriteId,
                            child: Text(favorite.label)),
                      if (onManageSortFavorites != null)
                        const PopupMenuItem(
                            value: 'manage',
                            height: 48,
                            child: Text('Manage sorting favorites...')),
                    ]),
          LibraryToolsButton(
              type: type,
              counts: counts,
              selectedBucket: selectedBucket ?? linkedMetadataFilterLabel,
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
              onTransferFieldData: onTransferFieldData,
              onReassignIndex: onReassignIndex,
              onShareCollection: onShareCollection,
              onCompareMetadataWithServer: onCompareMetadataWithServer,
              extraActions: extraActions),
        ],
        countLabel:
            '${counts.shown}${counts.shown == counts.total ? '' : ' / ${counts.total}'} ${type.identity.countLabel(counts.shown).toLowerCase()}',
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
        icon: Icons.settings_outlined,
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
