import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:flutter/material.dart';

class LibraryToolsButton extends StatelessWidget {
  const LibraryToolsButton({
    super.key,
    required this.type,
    required this.counts,
    required this.selectedBucket,
    required this.quickView,
    required this.hasActiveFilters,
    required this.onQuickViewSelected,
    required this.onClearFilters,
    this.onRandomPick,
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditSort,
    this.onReassignIndex,
    this.onTransferFieldData,
    this.onShareCollection,
    this.onCompareMetadataWithServer,
    this.extraActions = const [],
  });

  final LibraryKindRegistration type;
  final LibraryToolbarCounts counts;
  final String? selectedBucket;
  final LibraryQuickView? quickView;
  final bool hasActiveFilters;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final VoidCallback onClearFilters;
  final VoidCallback? onRandomPick;
  final ShelfState? shelfState;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditSort;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onShareCollection;
  final VoidCallback? onCompareMetadataWithServer;
  final List<LibraryUtilityMenuAction> extraActions;

  @override
  Widget build(BuildContext context) {
    return LibraryUtilityMenu<LibraryQuickView>(
      buttonLabel: 'Tools',
      quickViewsLabel: '',
      quickViews: const [],
      selectedQuickView: quickView,
      onQuickViewSelected: onQuickViewSelected,
      badgeCount: _utilityBadgeCount,
      actions: [
        if (hasActiveFilters)
          LibraryUtilityMenuAction(
            icon: Icons.filter_alt_off,
            label: 'Clear filters',
            section: 'Filters',
            onSelected: onClearFilters,
          ),
        if (onEditSort != null)
          LibraryUtilityMenuAction(
            icon: Icons.sort,
            label: 'Sort...',
            section: 'Collection',
            onSelected: onEditSort!,
          ),
        if (onCompareMetadataWithServer != null)
          LibraryUtilityMenuAction(
            icon: Icons.compare_arrows,
            label: 'Compare metadata with server...',
            section: 'Collection',
            onSelected: onCompareMetadataWithServer!,
          ),
        ...extraActions,
        LibraryUtilityMenuAction(
          icon: Icons.auto_fix_high,
          label: 'Pre-fill settings...',
          section: 'Administration',
          onSelected: () {
            final accent = Theme.of(context).colorScheme.primary;
            showPrefillSettingsDialog(context: context, accent: accent);
          },
        ),
        if (onEditConditionPickList != null)
          LibraryUtilityMenuAction(
            icon: Icons.inventory_2_outlined,
            label: 'Condition values...',
            section: 'Administration',
            onSelected: onEditConditionPickList!,
          ),
        if (onEditGradePickList != null)
          LibraryUtilityMenuAction(
            icon: Icons.workspace_premium_outlined,
            label: 'Grade values...',
            section: 'Administration',
            onSelected: onEditGradePickList!,
          ),
        if (onTransferFieldData != null)
          LibraryUtilityMenuAction(
            icon: Icons.swap_horiz,
            label: 'Transfer field data...',
            section: 'Administration',
            onSelected: onTransferFieldData!,
          ),
        if (onReassignIndex != null)
          LibraryUtilityMenuAction(
            icon: Icons.format_list_numbered,
            label: 'Re-assign index values...',
            section: 'Administration',
            onSelected: onReassignIndex!,
          ),
        if (onSmartLists != null)
          LibraryUtilityMenuAction(
            icon: Icons.auto_awesome_mosaic,
            label: 'Smart Lists...',
            section: 'Lists',
            onSelected: onSmartLists!,
          ),
        if (onFolders != null)
          LibraryUtilityMenuAction(
            icon: Icons.folder_outlined,
            label: 'Folders...',
            section: 'Lists',
            onSelected: onFolders!,
          ),
        if (onReadingQueue != null)
          LibraryUtilityMenuAction(
            icon: Icons.bookmarks_outlined,
            label: 'Reading Queue...',
            section: 'Lists',
            onSelected: onReadingQueue!,
          ),
        if (onShareCollection != null)
          LibraryUtilityMenuAction(
            icon: Icons.share_outlined,
            label: 'Share collection...',
            section: 'Share',
            onSelected: onShareCollection!,
          ),
      ],
    );
  }

  int get _utilityBadgeCount {
    return (selectedBucket != null ? 1 : 0) + (quickView != null ? 1 : 0);
  }
}
