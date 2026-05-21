import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

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
  });

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;

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
              value: LibraryViewMode.cardFlow,
              icon: Tooltip(
                message: 'Card flow',
                child: Icon(Icons.view_agenda),
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
        const SizedBox(width: 12),
        Tooltip(
          message: 'Cover size',
          child: Icon(Icons.photo_size_select_small, size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        SizedBox(
          width: 120,
          child: SliderTheme(
            data: SliderThemeData(
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
            ),
            child: Slider(
              value: coverSize.clamp(minCoverSize, maxCoverSize),
              min: minCoverSize,
              max: maxCoverSize,
              onChanged: onCoverSizeChanged,
            ),
          ),
        ),
      ],
    );
  }
}
