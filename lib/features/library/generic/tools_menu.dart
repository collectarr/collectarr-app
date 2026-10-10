import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/keyboard/library_keyboard_shortcuts.dart';
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
    this.onDownloadAllCovers,
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onEditSort,
    this.onReassignIndex,
    this.onTransferFieldData,
    this.onPrintReport,
    this.onExportCsvTxt,
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
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onEditSort;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onPrintReport;
  final VoidCallback? onExportCsvTxt;
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
        if (onEditSort != null)
          LibraryUtilityMenuAction(
            icon: Icons.sort,
            label: 'Sort...',
            section: 'Collection',
            onSelected: onEditSort!,
          ),
        if (onDownloadAllCovers != null)
          LibraryUtilityMenuAction(
            icon: Icons.download_outlined,
            label: 'Download all covers',
            section: 'Collection',
            onSelected: onDownloadAllCovers!,
          ),
        LibraryUtilityMenuAction(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing covers',
          section: 'Collection',
          enabled: counts.missingCover > 0,
          trailing: Text(counts.missingCover.toString()),
          onSelected: () => onQuickViewSelected(LibraryQuickView.missingCovers),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.manage_search,
          label: 'Missing metadata',
          section: 'Collection',
          enabled: counts.missingMetadata > 0,
          trailing: Text(counts.missingMetadata.toString()),
          onSelected: () =>
              onQuickViewSelected(LibraryQuickView.missingMetadata),
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
        if (onEditTagPickList != null)
          LibraryUtilityMenuAction(
            icon: Icons.sell_outlined,
            label: 'Tag values...',
            section: 'Administration',
            onSelected: onEditTagPickList!,
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
        if (onPrintReport != null)
          LibraryUtilityMenuAction(
            icon: Icons.print_outlined,
            label: 'Print / PDF report',
            section: 'Share',
            onSelected: onPrintReport!,
          ),
        if (onExportCsvTxt != null)
          LibraryUtilityMenuAction(
            icon: Icons.table_view_outlined,
            label: 'Export to CSV / TXT',
            section: 'Share',
            onSelected: onExportCsvTxt!,
          ),
        if (onShareCollection != null)
          LibraryUtilityMenuAction(
            icon: Icons.share_outlined,
            label: 'Share collection...',
            section: 'Share',
            onSelected: onShareCollection!,
          ),
        LibraryUtilityMenuAction(
          icon: Icons.keyboard_command_key,
          label: 'Keyboard shortcuts',
          section: 'Help',
          onSelected: () => showKeyboardShortcutsDialog(context),
        ),
      ],
    );
  }

  int get _utilityBadgeCount {
    return (selectedBucket != null ? 1 : 0) + (quickView != null ? 1 : 0);
  }
}
