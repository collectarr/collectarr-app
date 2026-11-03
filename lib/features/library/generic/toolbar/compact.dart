import 'package:collectarr_app/features/library/generic/toolbar/alphabet_row.dart';
import 'selection.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/generic/toolbar/alphabet_options.dart';
import 'package:collectarr_app/features/library/config/media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/selection/controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/utility_menu.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';

import 'chrome.dart';

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
    this.onManageColumnFavorites,
    this.canJumpToNumber = false,
    this.onJumpToNumberSubmitted,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onClearBucket,
    this.onRandomPick,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditSort,
    this.onCompareMetadataWithServer,
    this.extraActions = const [],
    this.availableLetters = const {},
    this.selectedLetter,
    this.alphabetOptions,
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
  final VoidCallback? onManageColumnFavorites;
  final bool canJumpToNumber;
  final ValueChanged<String>? onJumpToNumberSubmitted;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onClearBucket;
  final VoidCallback? onRandomPick;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditSort;
  final VoidCallback? onCompareMetadataWithServer;
  final List<LibraryUtilityMenuAction> extraActions;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final LibraryAlphabetOptions? alphabetOptions;
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
    final showChromeRow = !appPresentationPlatform.isNativeMobile &&
        onCollectionStatusScopeChanged != null;
    final showAlphabetRow =
        availableLetters.isNotEmpty && onLetterSelected != null;

    if (appPresentationPlatform.isNativeMobile) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        if (searchActive &&
            searchTargetOptions.isNotEmpty &&
            onSearchTargetChanged != null)
          PopupMenuButton<LibrarySearchTarget>(
              tooltip: 'Search scope',
              onSelected: onSearchTargetChanged,
              itemBuilder: (_) => [
                    for (final option in searchTargetOptions)
                      CheckedPopupMenuItem(
                          value: option,
                          checked: option == searchTarget,
                          child: Text(_librarySearchTargetLabel(option)))
                  ],
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_librarySearchTargetLabel(searchTarget)))),
        if (linkedMetadataFilterLabel != null)
          LibraryToolbarScopeChip(
              label: linkedMetadataFilterLabel!, onClear: onClearBucket),
        if (showAlphabetRow)
          LibraryToolbarAlphabetRow(
              letters: availableLetters,
              selectedLetter: selectedLetter,
              alphabetOptions: alphabetOptions,
              accent: accent,
              onLetterSelected: onLetterSelected!),
      ]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: LayoutBuilder(builder: (context, constraints) {
            final search = SearchBar(
              controller: searchController,
              constraints: const BoxConstraints.tightFor(height: 36),
              hintText: libraryPresentationForKind(type.kind)
                      .searchFieldLabels
                      .libraryHint ??
                  'Search ${type.identity.pluralLabel.toLowerCase()}...',
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
                  popUpAnimationStyle: AnimationStyle.noAnimation,
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
              if (!appPresentationPlatform.isNativeMobile)
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: libraryAccentActionColor(accent),
                    foregroundColor: appContrastingTextColor(
                        libraryAccentActionColor(accent)),
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
                onSmartLists: onSmartLists,
                onFolders: onFolders,
                onReadingQueue: onReadingQueue,
                onEditConditionPickList: onEditConditionPickList,
                onEditGradePickList: onEditGradePickList,
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
                      singularLabel: type.identity.singularLabel,
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
            onManageColumnFavorites: onManageColumnFavorites,
            canJumpToNumber: canJumpToNumber,
            onJumpToNumberSubmitted: onJumpToNumberSubmitted,
          ),
        ],
        if (showAlphabetRow) ...[
          const LibraryToolbarDividerLine(),
          LibraryToolbarAlphabetRow(
            letters: availableLetters,
            selectedLetter: selectedLetter,
            alphabetOptions: alphabetOptions,
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

String _librarySearchTargetLabel(LibrarySearchTarget target) {
  return switch (target) {
    LibrarySearchTarget.all => 'Albums & Tracks',
    LibrarySearchTarget.mediaOnly => 'Albums',
    LibrarySearchTarget.tracksOnly => 'Tracks',
  };
}
