import 'package:collectarr_app/features/library/workspace/layout/library_folder_row.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
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
    this.bucketStatusSummary,
    this.onCollectionStatusScopeChanged,
    this.groupLoading = false,
    this.availableGroupModes,
    this.onClearFilter,
    this.onHideSidebar,
    this.onSidebarVisibilityChanged,
    this.onManageBuckets,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.folderDisplayMode = LibraryFolderDisplayMode.drilldown,
    this.onFolderDisplayModeChanged,
  });

  final LibraryKindRegistration type;
  final String groupMode;
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
  final LibraryBucketStatusSummary? bucketStatusSummary;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final bool groupLoading;
  final List<String>? availableGroupModes;
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final VoidCallback? onManageBuckets;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final LibraryFolderDisplayMode folderDisplayMode;
  final ValueChanged<LibraryFolderDisplayMode>? onFolderDisplayModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isRootScope = onClearFilter == null;
    final manageBuckets = onManageBuckets;
    final navigateBack = onNavigateBack;
    final clearFilter = onClearFilter;
    final hideSidebar = onHideSidebar;
    final actions = <_LibrarySidebarToolbarButton>[
      if (manageBuckets != null &&
          libraryGroupModeSupportsBucketManagement(type, groupMode))
        _LibrarySidebarToolbarButton(
          tooltip:
              'Manage ${genericGroupModeSidebarTitle(groupMode, type).toLowerCase()}',
          icon: Icons.format_list_bulleted,
          onPressed: manageBuckets,
        ),
      if (onFolderDisplayModeChanged != null)
        _LibrarySidebarToolbarButton(
          tooltip: folderDisplayMode == LibraryFolderDisplayMode.drilldown
              ? 'Switch to tree view'
              : 'Switch to drilldown view',
          icon: folderDisplayMode == LibraryFolderDisplayMode.drilldown
              ? Icons.account_tree_outlined
              : Icons.segment_outlined,
          onPressed: () => onFolderDisplayModeChanged!(
            folderDisplayMode == LibraryFolderDisplayMode.drilldown
                ? LibraryFolderDisplayMode.tree
                : LibraryFolderDisplayMode.drilldown,
          ),
          active: folderDisplayMode == LibraryFolderDisplayMode.tree,
          activeColor: accent,
        ),
      if (navigateBack != null || (!isRootScope && clearFilter != null))
        _LibrarySidebarToolbarButton(
          tooltip: navigateBack != null
              ? 'Back to previous scope'
              : 'Back to all ${type.identity.pluralLabel.toLowerCase()}',
          icon: Icons.arrow_back,
          onPressed: navigateBack ?? clearFilter!,
          active: true,
          activeColor: accent,
        ),
      if (hideSidebar != null)
        _LibrarySidebarToolbarButton(
          tooltip: 'Hide folders panel',
          icon: Icons.menu_open,
          onPressed: hideSidebar,
        ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: libraryFolderDepthColor(context, 0),
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: SizedBox(
        height: kLibraryToolbarBandHeight - 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (!constraints.hasBoundedWidth || width <= 0) {
              return const SizedBox.shrink();
            }
            // Retain the label until controls have moved into overflow. Only
            // the narrow rail uses the compact grouping trigger.
            final compact = width < 140;
            final selectorWidth = compact ? 52.0 : 100.0;
            final loadingWidth = groupLoading && width >= 140 ? 22.0 : 0.0;
            final available = width - selectorWidth - loadingWidth;
            final slots = (available / 34).floor().clamp(0, actions.length);
            final primaryCount = manageBuckets != null &&
                    libraryGroupModeSupportsBucketManagement(type, groupMode)
                ? 1
                : 0;
            final overflow =
                actions.length > primaryCount || slots < actions.length;
            final visibleCount =
                overflow ? (slots - 1).clamp(0, primaryCount) : slots;
            final hiddenActions = actions.skip(visibleCount).toList();
            final selector = DecoratedBox(
              decoration: BoxDecoration(
                color: libraryFolderDepthColor(context, 0),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 3),
                child: LibraryGroupModeMenuButton(
                  type: type,
                  folderPreset:
                      folderPreset ?? LibraryFolderPreset.single(groupMode),
                  availableModes: availableGroupModes,
                  accent: accent,
                  icon: icon,
                  onChanged: onChanged,
                  iconOnly: compact,
                  sidebarVisible: true,
                  onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                  pinnedFolderPresets: pinnedFolderPresets,
                  onPinnedPresetsChanged: onPinnedFolderPresetsChanged,
                ),
              ),
            );
            if (width < selectorWidth) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(width: selectorWidth, child: selector),
              );
            }
            return Row(
              children: [
                Expanded(child: selector),
                if (loadingWidth > 0) ...[
                  const SizedBox(width: 6),
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ],
                for (final action in actions.take(visibleCount)) ...[
                  const SizedBox(width: 4),
                  SizedBox(width: 30, height: 30, child: action),
                ],
                if (overflow && slots > 0) ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: PopupMenuButton<int>(
                      tooltip: 'More folder actions',
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_horiz,
                          size: 16, color: palette.textMuted),
                      onSelected: (index) => hiddenActions[index].onPressed(),
                      itemBuilder: (context) => [
                        for (var i = 0; i < hiddenActions.length; i++)
                          PopupMenuItem<int>(
                            value: i,
                            child: Row(children: [
                              Icon(hiddenActions[i].icon, size: 16),
                              const SizedBox(width: 8),
                              Text(hiddenActions[i].tooltip),
                            ]),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
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
