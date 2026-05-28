import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

const _viewModeDropdownKey = Key('library-view-mode-dropdown');
const _viewModeDropdownWidth = 168.0;
const _viewModeDropdownHeight = 36.0;

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
    final palette = appPalette(context);
    final accent = LibraryAccentScope.accentOf(context, fallback: palette.accent);
    final coverSizeEnabled = viewMode.supportsCoverSize;
    final iconColor = coverSizeEnabled
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).disabledColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _viewModeDropdownWidth,
          child: PopupMenuButton<LibraryViewMode>(
            key: _viewModeDropdownKey,
            tooltip: 'View mode',
            initialValue: viewMode,
            onSelected: onViewModeChanged,
            padding: EdgeInsets.zero,
            color: palette.panelRaised,
            surfaceTintColor: Colors.transparent,
            menuPadding: const EdgeInsets.symmetric(vertical: 4),
            position: PopupMenuPosition.under,
            constraints: const BoxConstraints(
              minWidth: _viewModeDropdownWidth,
              maxWidth: _viewModeDropdownWidth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: accent.withValues(alpha: 0.26)),
            ),
            itemBuilder: (context) => [
              for (final mode in LibraryViewMode.values)
                PopupMenuItem<LibraryViewMode>(
                  height: _viewModeDropdownHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  value: mode,
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Icon(
                          _viewModeIcon(mode),
                          size: 17,
                          color: mode == viewMode
                              ? accent
                              : palette.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _viewModeLabel(mode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  height: 1,
                                  fontWeight: mode == viewMode
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: mode == viewMode
                                      ? accent
                                      : palette.textPrimary,
                                ),
                          ),
                        ),
                        if (mode == viewMode)
                          Icon(Icons.check, size: 16, color: accent),
                      ],
                    ),
                  ),
                ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: accent.withValues(alpha: 0.42)),
              ),
              child: SizedBox(
                height: _viewModeDropdownHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(_viewModeIcon(viewMode), size: 17, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _viewModeLabel(viewMode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down, size: 20, color: accent),
                    ],
                  ),
                ),
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
