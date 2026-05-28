import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';

const _viewModeDropdownKey = Key('library-view-mode-dropdown');
const _detailsLayoutDropdownKey = Key('library-details-layout-dropdown');
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
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w700,
          color: accent,
        );
    final dropdownWidth = _measureViewDropdownWidth(
      context,
      textStyle: dropdownTextStyle,
    );
    final detailsDropdownWidth = _measureDetailsDropdownWidth(
      context,
      textStyle: dropdownTextStyle,
    );
    final coverSizeEnabled = viewMode.supportsCoverSize;
    final iconColor = coverSizeEnabled
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).disabledColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: dropdownWidth,
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
              minWidth: 0,
              maxWidth: double.infinity,
            ).copyWith(minWidth: dropdownWidth, maxWidth: dropdownWidth),
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
                          style: dropdownTextStyle,
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
        SizedBox(
          width: detailsDropdownWidth,
          child: PopupMenuButton<LibraryDetailsLayout>(
            key: _detailsLayoutDropdownKey,
            tooltip: 'Details layout',
            initialValue: detailsLayout,
            onSelected: onDetailsLayoutChanged,
            padding: EdgeInsets.zero,
            color: palette.panelRaised,
            surfaceTintColor: Colors.transparent,
            menuPadding: const EdgeInsets.symmetric(vertical: 4),
            position: PopupMenuPosition.under,
            constraints: const BoxConstraints(
              minWidth: 0,
              maxWidth: double.infinity,
            ).copyWith(
              minWidth: detailsDropdownWidth,
              maxWidth: detailsDropdownWidth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: accent.withValues(alpha: 0.26)),
            ),
            itemBuilder: (context) => [
              for (final layout in LibraryDetailsLayout.values)
                PopupMenuItem<LibraryDetailsLayout>(
                  height: _viewModeDropdownHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  value: layout,
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Icon(
                          _detailsLayoutIcon(layout),
                          size: 17,
                          color: layout == detailsLayout
                              ? accent
                              : palette.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _detailsLayoutLabel(layout),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  height: 1,
                                  fontWeight: layout == detailsLayout
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: layout == detailsLayout
                                      ? accent
                                      : palette.textPrimary,
                                ),
                          ),
                        ),
                        if (layout == detailsLayout)
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
                      Icon(
                        _detailsLayoutIcon(detailsLayout),
                        size: 17,
                        color: accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _detailsLayoutLabel(detailsLayout),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dropdownTextStyle,
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

double _measureDetailsDropdownWidth(
  BuildContext context, {
  required TextStyle? textStyle,
}) {
  final textScaler = MediaQuery.textScalerOf(context);
  var maxLabelWidth = 0.0;
  for (final layout in LibraryDetailsLayout.values) {
    final painter = TextPainter(
      text: TextSpan(text: _detailsLayoutLabel(layout), style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    )..layout();
    if (painter.width > maxLabelWidth) {
      maxLabelWidth = painter.width;
    }
  }
  return (24 + 17 + 8 + maxLabelWidth + 28).clamp(116, double.infinity);
}

double _measureViewDropdownWidth(
  BuildContext context, {
  required TextStyle? textStyle,
}) {
  final textScaler = MediaQuery.textScalerOf(context);
  var maxLabelWidth = 0.0;
  for (final mode in LibraryViewMode.values) {
    final painter = TextPainter(
      text: TextSpan(text: _viewModeLabel(mode), style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    )..layout();
    if (painter.width > maxLabelWidth) {
      maxLabelWidth = painter.width;
    }
  }
  return (24 + 17 + 8 + maxLabelWidth + 28).clamp(108, double.infinity);
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

String _detailsLayoutLabel(LibraryDetailsLayout layout) {
  return switch (layout) {
    LibraryDetailsLayout.right => 'Details right',
    LibraryDetailsLayout.bottom => 'Details bottom',
    LibraryDetailsLayout.hidden => 'Details hidden',
  };
}

IconData _detailsLayoutIcon(LibraryDetailsLayout layout) {
  return switch (layout) {
    LibraryDetailsLayout.right => Icons.view_sidebar,
    LibraryDetailsLayout.bottom => Icons.vertical_split,
    LibraryDetailsLayout.hidden => Icons.visibility_off,
  };
}
