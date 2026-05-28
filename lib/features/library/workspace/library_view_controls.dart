import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const _viewModeDropdownKey = Key('library-view-mode-dropdown');

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 168,
          child: PopupMenuButton<LibraryViewMode>(
            key: _viewModeDropdownKey,
            tooltip: 'View mode',
            initialValue: viewMode,
            onSelected: onViewModeChanged,
            itemBuilder: (context) => [
              for (final mode in LibraryViewMode.values)
                PopupMenuItem<LibraryViewMode>(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(_viewModeIcon(mode), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_viewModeLabel(mode))),
                      if (mode == viewMode)
                        const Icon(Icons.check, size: 18),
                    ],
                  ),
                ),
            ],
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'View',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              child: Row(
                children: [
                  Icon(_viewModeIcon(viewMode), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_viewModeLabel(viewMode))),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                ],
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

String _viewModeLabel(LibraryViewMode mode) {
  return switch (mode) {
    LibraryViewMode.grid => 'Grid',
    LibraryViewMode.card => 'Cards',
    LibraryViewMode.cardFlow => 'Flow',
    LibraryViewMode.list => 'List',
    LibraryViewMode.shelves => 'Shelves',
  };
}

IconData _viewModeIcon(LibraryViewMode mode) {
  return switch (mode) {
    LibraryViewMode.grid => Icons.grid_view,
    LibraryViewMode.card => Icons.view_module,
    LibraryViewMode.cardFlow => Icons.view_agenda,
    LibraryViewMode.list => Icons.view_list,
    LibraryViewMode.shelves => Icons.shelves,
  };
}
