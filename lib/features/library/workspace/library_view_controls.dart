import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const _viewModeMenuOrder = [
  LibraryViewMode.list,
  LibraryViewMode.card,
  LibraryViewMode.cardFlow,
  LibraryViewMode.grid,
  LibraryViewMode.shelves,
];

String _viewModeLabel(LibraryViewMode mode) {
  return switch (mode) {
    LibraryViewMode.list => 'List',
    LibraryViewMode.card => 'Cards',
    LibraryViewMode.cardFlow => 'Flow',
    LibraryViewMode.grid => 'Grid',
    LibraryViewMode.shelves => 'Shelves',
  };
}

IconData _viewModeIcon(LibraryViewMode mode) {
  return switch (mode) {
    LibraryViewMode.list => Icons.view_list,
    LibraryViewMode.card => Icons.view_stream,
    LibraryViewMode.cardFlow => Icons.view_agenda,
    LibraryViewMode.grid => Icons.grid_view,
    LibraryViewMode.shelves => Icons.shelves,
  };
}

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
    final coverSizeEnabled = viewMode.supportsCoverSize;
    final iconColor = coverSizeEnabled
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).disabledColor;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Views',
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: scheme.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<LibraryViewMode>(
                key: const Key('library-view-mode-dropdown'),
                value: viewMode,
                isDense: true,
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.only(left: 10, right: 6),
                icon: Icon(Icons.arrow_drop_down, color: scheme.onSecondaryContainer),
                dropdownColor: scheme.surfaceContainerHigh,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                selectedItemBuilder: (context) => [
                  for (final mode in _viewModeMenuOrder)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _viewModeIcon(mode),
                          size: 18,
                          color: scheme.onSecondaryContainer,
                        ),
                      ],
                    ),
                ],
                items: [
                  for (final mode in _viewModeMenuOrder)
                    DropdownMenuItem<LibraryViewMode>(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(_viewModeIcon(mode), size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_viewModeLabel(mode))),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onViewModeChanged(value);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SegmentedButton<LibraryDetailsLayout>(
          segments: const [
            ButtonSegment(
              value: LibraryDetailsLayout.right,
              icon: Tooltip(
                message: 'Details panel right',
                child: Icon(Icons.view_sidebar),
              ),
            ),
            ButtonSegment(
              value: LibraryDetailsLayout.bottom,
              icon: Tooltip(
                message: 'Details panel bottom',
                child: Icon(Icons.vertical_split),
              ),
            ),
            ButtonSegment(
              value: LibraryDetailsLayout.hidden,
              icon: Tooltip(
                message: 'Hide details panel',
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
          message: coverSizeEnabled
              ? 'Cover size'
              : 'Cover size is unavailable in this view',
          child: Icon(
            Icons.photo_size_select_small,
            size: 18,
            color: iconColor,
          ),
        ),
        Opacity(
          opacity: coverSizeEnabled ? 1 : 0.45,
          child: SizedBox(
            width: 120,
            child: IgnorePointer(
              ignoring: !coverSizeEnabled,
              child: SliderTheme(
                data: SliderThemeData(
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: coverSize.clamp(minCoverSize, maxCoverSize),
                  min: minCoverSize,
                  max: maxCoverSize,
                  onChanged: coverSizeEnabled ? onCoverSizeChanged : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
