import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CompactLibraryToolbar extends StatelessWidget {
  const CompactLibraryToolbar({
    super.key,
    required this.type,
    required this.searchController,
    required this.counts,
    required this.selectedBucket,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onRefreshMetadata,
    required this.onViewModeChanged,
    required this.onCoverSizeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.onRandomPick,
    this.onDownloadAllCovers,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onEditSort,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final LibraryToolbarCounts counts;
  final String? selectedBucket;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onRandomPick;
  final VoidCallback? onDownloadAllCovers;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onEditSort;

  @override
  Widget build(BuildContext context) {
    final targetAccent = libraryAccentForKind(type.workspace.kind);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetAccent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final accent = color ?? targetAccent;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Tooltip(
            message: 'Add ${type.pluralLabel}',
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SearchBar(
              controller: searchController,
              constraints: const BoxConstraints.tightFor(height: 32),
              hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
              leading: const Icon(Icons.search),
              onChanged: onSearchChanged,
              onSubmitted: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          LibraryToolsButton(
            type: type,
            counts: counts,
            selectedBucket: selectedBucket,
            quickView: quickView,
            hasActiveFilters: hasActiveFilters,
            onQuickViewSelected: onQuickViewSelected,
            onClearFilters: onClearFilters,
            onRandomPick: onRandomPick,
            onDownloadAllCovers: onDownloadAllCovers,
            onEditConditionPickList: onEditConditionPickList,
            onEditGradePickList: onEditGradePickList,
            onEditTagPickList: onEditTagPickList,
            onEditSort: onEditSort,
          ),
          Tooltip(
            message: 'Cover size',
            child: IconButton.filledTonal(
              onPressed: () => _showCompactCoverSizeSheet(
                context,
                onViewModeChanged,
                onCoverSizeChanged,
              ),
              icon: const Icon(Icons.photo_size_select_large_outlined),
            ),
          ),
          Tooltip(
            message: 'Scan barcode',
            child: IconButton.filledTonal(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ),
          Tooltip(
            message: 'Refresh metadata',
            child: IconButton.filledTonal(
              onPressed: onRefreshMetadata,
              icon: const Icon(Icons.sync),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

void _showCompactCoverSizeSheet(
  BuildContext context,
  ValueChanged<LibraryViewMode> onViewModeChanged,
  ValueChanged<double> onCoverSizeChanged,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Grid view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.grid);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Cards view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.card);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_agenda),
            title: const Text('Flow view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.cardFlow);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('List view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewModeChanged(LibraryViewMode.list);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_size_select_small),
            title: const Text('Small covers'),
            onTap: () {
              Navigator.of(context).pop();
              onCoverSizeChanged(96);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_size_select_large),
            title: const Text('Large covers'),
            onTap: () {
              Navigator.of(context).pop();
              onCoverSizeChanged(188);
            },
          ),
        ],
      ),
    ),
  );
}
