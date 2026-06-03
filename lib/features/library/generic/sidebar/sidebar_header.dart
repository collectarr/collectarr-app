import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySidebarHeader extends StatelessWidget {
  const LibrarySidebarHeader({
    super.key,
    required this.type,
    required this.groupMode,
    this.folderPreset,
    required this.accent,
    required this.icon,
    required this.onChanged,
    required this.breadcrumbs,
    this.onNavigateBack,
    this.onNavigateToBreadcrumb,
    required this.selectedBucket,
    this.searchQuery,
    this.activeSmartListName,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    this.onCollectionStatusScopeChanged,
    this.groupLoading = false,
    this.onClearFilter,
    this.onHideSidebar,
    this.onSidebarVisibilityChanged,
    this.onManageBuckets,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final LibraryFolderPreset? folderPreset;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryFolderPreset> onChanged;
  final List<String> breadcrumbs;
  final VoidCallback? onNavigateBack;
  final ValueChanged<int>? onNavigateToBreadcrumb;
  final String selectedBucket;
  final String? searchQuery;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final String? collectionStatusScopeLabel;
  final String? linkedMetadataFilterLabel;
  final String? selectedLetter;
  final LibrarySeriesStatusSummary? seriesStatusSummary;
  final LibraryFilterSelection filterSelection;
  final bool hasActiveFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onClearFilters;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final bool groupLoading;
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final VoidCallback? onManageBuckets;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isRootScope = onClearFilter == null;
    final manageBuckets = onManageBuckets;
    final editFilters = onEditFilters;
    final clearFilters = onClearFilters;
    final navigateBack = onNavigateBack;
    final clearFilter = onClearFilter;
    final hideSidebar = onHideSidebar;
    final manageFavorites = onPinnedFolderPresetsChanged;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border.all(color: palette.divider),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: LibraryGroupModeMenuButton(
                  type: type,
                  folderPreset:
                      folderPreset ?? LibraryFolderPreset.single(groupMode),
                  accent: accent,
                  icon: icon,
                  onChanged: onChanged,
                  sidebarVisible: true,
                  onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                  pinnedFolderPresets: pinnedFolderPresets,
                  onPinnedPresetsChanged: onPinnedFolderPresetsChanged,
                ),
              ),
            ),
          ),
          if (groupLoading) ...[
            const SizedBox(width: 6),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
          if (manageFavorites != null) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip: 'Manage favorites',
              icon: Icons.list_alt_outlined,
              onPressed: () async {
                final updated = await showLibraryFolderFavoritesDialog(
                  context: context,
                  type: type,
                  availableModes: libraryGroupModesForType(type),
                  initialFavorites: pinnedFolderPresets,
                );
                if (updated != null && context.mounted) {
                  manageFavorites(updated);
                }
              },
              active: pinnedFolderPresets.isNotEmpty,
              activeColor: accent,
            ),
          ],
          if (manageBuckets != null &&
              libraryGroupModeSupportsBucketManagement(type, groupMode)) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip:
                  'Manage ${genericGroupModeSidebarTitle(groupMode, type).toLowerCase()}',
              icon: Icons.edit_outlined,
              onPressed: manageBuckets,
              active: false,
            ),
          ],
          if (editFilters != null) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip: hasActiveFilters ? 'Edit filters (${filterSelection.activeFilterCount} active)' : 'Edit filters',
              icon: hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              onPressed: editFilters,
              active: hasActiveFilters || searchQuery?.trim().isNotEmpty == true || activeSmartListName?.trim().isNotEmpty == true || linkedMetadataFilterLabel != null || selectedLetter != null,
              activeColor: accent,
            ),
          ],
          if (hasActiveFilters && clearFilters != null) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip: 'Clear filters',
              icon: Icons.filter_alt_off,
              onPressed: clearFilters,
              active: false,
            ),
          ],
          if (navigateBack != null) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip: 'Back to previous scope',
              icon: Icons.arrow_back,
              onPressed: navigateBack,
              active: true,
              activeColor: accent,
            ),
          ] else if (!isRootScope && clearFilter != null) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip: 'Back to all ${type.pluralLabel.toLowerCase()}',
              icon: Icons.arrow_back,
              onPressed: clearFilter,
              active: true,
              activeColor: accent,
            ),
          ],
          if (hideSidebar != null) ...[
            const SizedBox(width: 4),
            _LibrarySidebarToolbarButton(
              tooltip: 'Hide folders panel',
              icon: Icons.menu_open,
              onPressed: hideSidebar,
              active: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _LibrarySidebarToolbarButton extends StatelessWidget {
  const _LibrarySidebarToolbarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.activeColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedActiveColor = activeColor ?? palette.textPrimary;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        style: IconButton.styleFrom(
          backgroundColor: active
              ? Color.alphaBlend(
                  resolvedActiveColor.withValues(alpha: 0.16),
                  palette.surface,
                )
              : palette.surface,
          side: BorderSide(
            color: active
                ? resolvedActiveColor.withValues(alpha: 0.6)
                : palette.divider,
          ),
          shape: const RoundedRectangleBorder(),
        ),
        icon: Icon(
          icon,
          size: 15,
          color: active ? resolvedActiveColor : palette.textMuted,
        ),
      ),
    );
  }
}
