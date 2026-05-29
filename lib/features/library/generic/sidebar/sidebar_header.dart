import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_panels.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySidebarHeader extends StatelessWidget {
  const LibrarySidebarHeader({
    super.key,
    required this.type,
    required this.groupMode,
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
    this.pinnedGroupModes = const {},
    this.onTogglePin,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryGroupMode> onChanged;
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
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final isRootScope = onClearFilter == null;
    final scopeLabel = breadcrumbs.isNotEmpty
        ? breadcrumbs.last
        : (isRootScope ? 'All ${type.pluralLabel}' : selectedBucket);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      decoration: BoxDecoration(
        color: appPalette(context).surface,
        border: Border(bottom: BorderSide(color: appPalette(context).divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth),
                        child: LibraryGroupModeMenuButton(
                          type: type,
                          groupMode: groupMode,
                          accent: accent,
                          icon: icon,
                          onChanged: onChanged,
                          sidebarVisible: true,
                          onSidebarVisibilityChanged:
                              onSidebarVisibilityChanged,
                          pinnedGroupModes: pinnedGroupModes,
                          onTogglePin: onTogglePin,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (groupLoading) ...[
                const SizedBox(width: 4),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              if (onManageBuckets != null &&
                  libraryGroupModeSupportsBucketManagement(groupMode))
                IconButton(
                  tooltip:
                      'Manage ${genericGroupModeSidebarTitle(groupMode, type).toLowerCase()}',
                  onPressed: onManageBuckets,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              if (onHideSidebar != null)
                IconButton(
                  tooltip: 'Hide folders panel',
                  onPressed: onHideSidebar,
                  icon: const Icon(Icons.menu_open, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              if (onNavigateBack != null)
                IconButton(
                  tooltip: 'Back to previous scope',
                  onPressed: onNavigateBack,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                )
              else if (!isRootScope)
                IconButton(
                  tooltip: 'Back to all ${type.pluralLabel.toLowerCase()}',
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                )
              else
                IconButton(
                  tooltip: 'Clear group filter',
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
            ],
          ),
          if (breadcrumbs.length > 1) ...[
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < breadcrumbs.length; index++) ...[
                    if (index > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: appPalette(context).textMuted,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: index == breadcrumbs.length - 1
                          ? Text(
                              breadcrumbs[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            )
                          : ActionChip(
                              label: Text(
                                breadcrumbs[index],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onPressed: onNavigateToBreadcrumb == null
                                  ? null
                                  : () => onNavigateToBreadcrumb!(index),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            scopeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          LibrarySidebarFilteringPanel(
            type: type,
            activeSmartListName: activeSmartListName,
            quickView: quickView,
            collectionStatusScope: collectionStatusScope,
            collectionStatusScopeLabel: collectionStatusScopeLabel,
            searchQuery: searchQuery,
            linkedMetadataFilterLabel: linkedMetadataFilterLabel,
            selectedLetter: selectedLetter,
            filterSelection: filterSelection,
            hasActiveFilters: hasActiveFilters,
            onEditFilters: onEditFilters,
            onClearFilters: onClearFilters,
            onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
          ),
          if (seriesStatusSummary != null) ...[
            const SizedBox(height: 6),
            LibrarySidebarSeriesStatusPanel(
              summary: seriesStatusSummary!,
              selectedScope: collectionStatusScope,
              onScopeSelected: onCollectionStatusScopeChanged,
            ),
          ],
        ],
      ),
    );
  }
}
