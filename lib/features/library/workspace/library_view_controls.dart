import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:flutter/material.dart';

const _viewModeDropdownKey = Key('library-view-mode-dropdown');
const _detailsLayoutDropdownKey = Key('library-details-layout-dropdown');
const _viewModeDropdownHeight = 36.0;

class LibraryViewModeDropdown extends StatelessWidget {
  const LibraryViewModeDropdown({
    super.key,
    required this.viewMode,
    required this.onChanged,
  });

  final LibraryViewMode viewMode;
  final ValueChanged<LibraryViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final menuText = libraryToolbarMenuText(context);
    final menuMuted = libraryToolbarMenuMutedText(context);
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w700,
          color: menuText,
        );
    final menuWidth = _measureViewDropdownWidth(
      context,
      textStyle: dropdownTextStyle,
    );
    return SizedBox(
      width: kLibraryToolbarCompactDropdownWidth,
      child: PopupMenuButton<LibraryViewMode>(
        key: _viewModeDropdownKey,
        tooltip: _viewModeTooltip(viewMode),
        initialValue: viewMode,
        onSelected: onChanged,
        padding: EdgeInsets.zero,
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: double.infinity,
        ).copyWith(minWidth: menuWidth, maxWidth: menuWidth),
        shape: libraryToolbarDropdownMenuShape(context),
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
                      color: mode == viewMode ? menuText : menuMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _viewModeLabel(mode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1,
                              fontWeight: mode == viewMode
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: menuText,
                            ),
                      ),
                    ),
                    if (mode == viewMode)
                      Icon(Icons.check, size: 16, color: menuText),
                  ],
                ),
              ),
            ),
        ],
        child: LibraryToolbarCompactDropdownTrigger(
          icon: _viewModeIcon(viewMode),
        ),
      ),
    );
  }
}

class LibraryDetailsLayoutDropdown extends StatelessWidget {
  const LibraryDetailsLayoutDropdown({
    super.key,
    required this.detailsLayout,
    required this.onChanged,
  });

  final LibraryDetailsLayout detailsLayout;
  final ValueChanged<LibraryDetailsLayout> onChanged;

  @override
  Widget build(BuildContext context) {
    final menuText = libraryToolbarMenuText(context);
    final menuMuted = libraryToolbarMenuMutedText(context);
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w700,
          color: menuText,
        );
    final detailsMenuWidth = _measureDetailsDropdownWidth(
      context,
      textStyle: dropdownTextStyle,
    );
    return SizedBox(
      width: kLibraryToolbarCompactDropdownWidth,
      child: PopupMenuButton<LibraryDetailsLayout>(
        key: _detailsLayoutDropdownKey,
        tooltip: _detailsLayoutTooltip(detailsLayout),
        initialValue: detailsLayout,
        onSelected: onChanged,
        padding: EdgeInsets.zero,
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: double.infinity,
        ).copyWith(
          minWidth: detailsMenuWidth,
          maxWidth: detailsMenuWidth,
        ),
        shape: libraryToolbarDropdownMenuShape(context),
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
                      color: layout == detailsLayout ? menuText : menuMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _detailsLayoutLabel(layout),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1,
                              fontWeight: layout == detailsLayout
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: menuText,
                            ),
                      ),
                    ),
                    if (layout == detailsLayout)
                      Icon(Icons.check, size: 16, color: menuText),
                  ],
                ),
              ),
            ),
        ],
        child: LibraryToolbarCompactDropdownTrigger(
          icon: _detailsLayoutIcon(detailsLayout),
        ),
      ),
    );
  }
}

class LibraryCoverSizeSlider extends StatelessWidget {
  const LibraryCoverSizeSlider({
    super.key,
    required this.viewMode,
    required this.coverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.onChanged,
  });

  final LibraryViewMode viewMode;
  final double coverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final coverSizeEnabled = viewMode.supportsCoverSize;
    final iconColor = coverSizeEnabled
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).disabledColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  onChanged: coverSizeEnabled ? onChanged : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LibraryViewModeDropdown(
          viewMode: viewMode,
          onChanged: onViewModeChanged,
        ),
        const SizedBox(width: 8),
        LibraryDetailsLayoutDropdown(
          detailsLayout: detailsLayout,
          onChanged: onDetailsLayoutChanged,
        ),
        const SizedBox(width: 12),
        LibraryCoverSizeSlider(
          viewMode: viewMode,
          coverSize: coverSize,
          minCoverSize: minCoverSize,
          maxCoverSize: maxCoverSize,
          onChanged: onCoverSizeChanged,
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

String _viewModeTooltip(LibraryViewMode mode) {
  return '${_viewModeLabel(mode)} view';
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

String _detailsLayoutTooltip(LibraryDetailsLayout layout) {
  return _detailsLayoutLabel(layout);
}

IconData _detailsLayoutIcon(LibraryDetailsLayout layout) {
  return switch (layout) {
    LibraryDetailsLayout.right => Icons.view_sidebar,
    LibraryDetailsLayout.bottom => Icons.vertical_split,
    LibraryDetailsLayout.hidden => Icons.visibility_off,
  };
}
