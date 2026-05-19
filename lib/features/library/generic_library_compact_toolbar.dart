import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/generic_library_tools_menu.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class GenericCompactLibraryToolbar extends StatelessWidget {
  const GenericCompactLibraryToolbar({
    super.key,
    required this.type,
    required this.searchController,
    required this.counts,
    required this.selectedBucket,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onRefreshMetadata,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.onRandomPick,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final GenericToolbarCounts counts;
  final String? selectedBucket;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
  final GenericQuickView? quickView;
  final ValueChanged<GenericQuickView> onQuickViewSelected;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onRandomPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Tooltip(
            message: 'Add ${type.pluralLabel}',
            child: IconButton.filled(
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
          GenericLibraryToolsButton(
            type: type,
            counts: counts,
            selectedBucket: selectedBucket,
            quickView: quickView,
            hasActiveFilters: hasActiveFilters,
            onQuickViewSelected: onQuickViewSelected,
            onClearFilters: onClearFilters,
            onRandomPick: onRandomPick,
          ),
          Tooltip(
            message: 'Cover size',
            child: IconButton.filledTonal(
              onPressed: () => _showCompactCoverSizeSheet(
                context,
                onViewPresetSelected,
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
  }
}

void _showCompactCoverSizeSheet(
  BuildContext context,
  ValueChanged<LibraryWorkspacePreset> onViewPresetSelected,
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
            title: const Text('Cover view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewPresetSelected(LibraryWorkspacePreset.cover);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Card view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewPresetSelected(LibraryWorkspacePreset.card);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('List view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewPresetSelected(LibraryWorkspacePreset.list);
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
