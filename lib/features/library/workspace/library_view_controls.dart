import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

enum _LibraryViewOption { coverSmall, coverMedium, coverLarge }

class LibraryViewControls extends StatelessWidget {
  const LibraryViewControls({
    super.key,
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    this.onPresetSelected,
  });

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<LibraryWorkspacePreset>? onPresetSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<LibraryViewMode>(
          segments: const [
            ButtonSegment(
              value: LibraryViewMode.grid,
              icon: Tooltip(
                message: 'Cover view',
                child: Icon(Icons.grid_view),
              ),
            ),
            ButtonSegment(
              value: LibraryViewMode.card,
              icon: Tooltip(
                message: 'Card view',
                child: Icon(Icons.view_module),
              ),
            ),
            ButtonSegment(
              value: LibraryViewMode.list,
              icon: Tooltip(
                message: 'List view',
                child: Icon(Icons.view_list),
              ),
            ),
          ],
          selected: {viewMode},
          onSelectionChanged: (selection) => onViewModeChanged(selection.first),
          showSelectedIcon: false,
        ),
        const SizedBox(width: 8),
        SegmentedButton<LibraryDetailsLayout>(
          segments: const [
            ButtonSegment(
              value: LibraryDetailsLayout.right,
              icon: Tooltip(
                message: 'Details right',
                child: Icon(Icons.view_sidebar),
              ),
            ),
            ButtonSegment(
              value: LibraryDetailsLayout.bottom,
              icon: Tooltip(
                message: 'Details bottom',
                child: Icon(Icons.vertical_split),
              ),
            ),
            ButtonSegment(
              value: LibraryDetailsLayout.hidden,
              icon: Tooltip(
                message: 'Hide details',
                child: Icon(Icons.visibility_off),
              ),
            ),
          ],
          selected: {detailsLayout},
          onSelectionChanged: (selection) =>
              onDetailsLayoutChanged(selection.first),
          showSelectedIcon: false,
        ),
        const SizedBox(width: 8),
        PopupMenuButton<Object>(
          tooltip: 'View options',
          icon: const Icon(Icons.tune),
          onSelected: _handleViewOptionSelected,
          itemBuilder: (context) => [
            const PopupMenuItem<Object>(
              enabled: false,
              child: Text('Cover size'),
            ),
            PopupMenuItem<Object>(
              value: _LibraryViewOption.coverSmall,
              child: _ViewOptionTile(
                icon: Icons.photo_size_select_small,
                label: 'Small covers',
                selected: _isCoverSizeNear(minCoverSize),
              ),
            ),
            PopupMenuItem<Object>(
              value: _LibraryViewOption.coverMedium,
              child: _ViewOptionTile(
                icon: Icons.photo_size_select_actual_outlined,
                label: 'Medium covers',
                selected: _isCoverSizeNear(_mediumCoverSize),
              ),
            ),
            PopupMenuItem<Object>(
              value: _LibraryViewOption.coverLarge,
              child: _ViewOptionTile(
                icon: Icons.photo_size_select_large,
                label: 'Large covers',
                selected: _isCoverSizeNear(maxCoverSize),
              ),
            ),
            if (onPresetSelected != null) ...[
              const PopupMenuDivider(),
              const PopupMenuItem<Object>(
                enabled: false,
                child: Text('Presets'),
              ),
              for (final preset in LibraryWorkspacePreset.values)
                PopupMenuItem<Object>(
                  value: preset,
                  child: ListTile(
                    leading: Icon(preset.icon),
                    title: Text(preset.label),
                    dense: true,
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  double get _mediumCoverSize =>
      minCoverSize + (maxCoverSize - minCoverSize) / 2;

  bool _isCoverSizeNear(double size) {
    return (coverSize - size).abs() <= 8;
  }

  void _handleViewOptionSelected(Object option) {
    if (option is LibraryWorkspacePreset) {
      onPresetSelected?.call(option);
      return;
    }
    switch (option) {
      case _LibraryViewOption.coverSmall:
        onCoverSizeChanged(minCoverSize);
      case _LibraryViewOption.coverMedium:
        onCoverSizeChanged(_mediumCoverSize);
      case _LibraryViewOption.coverLarge:
        onCoverSizeChanged(maxCoverSize);
      default:
        break;
    }
  }
}

class _ViewOptionTile extends StatelessWidget {
  const _ViewOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, size: 18) : null,
    );
  }
}
