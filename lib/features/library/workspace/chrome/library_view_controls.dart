import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
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
    final triggerWidth = _measureSplitTriggerWidth(
      context,
      leadingLabel: 'View',
      valueLabel: _viewModeLabel(viewMode),
    );
    return SizedBox(
      width: triggerWidth,
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
              child: LibraryWorkspaceMenuRow(
                label: _viewModeLabel(mode),
                leading: Icon(
                  _viewModeIcon(mode),
                  size: 17,
                  color: mode == viewMode ? menuText : menuMuted,
                ),
                trailing: mode == viewMode
                    ? Icon(Icons.check, size: 16, color: menuText)
                    : null,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1,
                      fontWeight:
                          mode == viewMode ? FontWeight.w700 : FontWeight.w500,
                      color: menuText,
                    ),
              ),
            ),
        ],
        child: _LibraryToolbarSplitLabelTrigger(
          leadingLabel: 'View',
          valueLabel: _viewModeLabel(viewMode),
          valueIcon: _viewModeIcon(viewMode),
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
    final triggerWidth = _measureSplitTriggerWidth(
      context,
      leadingLabel: 'Layout',
      valueLabel: _detailsLayoutMenuLabel(detailsLayout),
    );
    return SizedBox(
      width: triggerWidth,
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
              child: LibraryWorkspaceMenuRow(
                label: _detailsLayoutMenuLabel(layout),
                leading: Icon(
                  _detailsLayoutIcon(layout),
                  size: 17,
                  color: layout == detailsLayout ? menuText : menuMuted,
                ),
                trailing: layout == detailsLayout
                    ? Icon(Icons.check, size: 16, color: menuText)
                    : null,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1,
                      fontWeight: layout == detailsLayout
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: menuText,
                    ),
              ),
            ),
        ],
        child: _LibraryToolbarSplitLabelTrigger(
          leadingLabel: 'Layout',
          valueLabel: _detailsLayoutMenuLabel(detailsLayout),
          valueIcon: _detailsLayoutIcon(detailsLayout),
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
      text: TextSpan(text: _detailsLayoutMenuLabel(layout), style: textStyle),
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
    LibraryViewMode.grid => 'Covers',
    LibraryViewMode.card => 'Vertical Cards',
    LibraryViewMode.horizontalCards => 'Horizontal Cards',
    LibraryViewMode.cardFlow => 'Flow Carousel',
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
    LibraryViewMode.horizontalCards => Icons.view_agenda,
    LibraryViewMode.cardFlow => Icons.view_carousel,
    LibraryViewMode.list => Icons.view_list,
    LibraryViewMode.shelves => Icons.shelves,
  };
}

String _detailsLayoutMenuLabel(LibraryDetailsLayout layout) {
  return switch (layout) {
    LibraryDetailsLayout.right => 'Vertical Split',
    LibraryDetailsLayout.bottom => 'Horizontal Split',
    LibraryDetailsLayout.hidden => 'No Details',
  };
}

double _measureSplitTriggerWidth(
  BuildContext context, {
  required String leadingLabel,
  required String valueLabel,
}) {
  final textScaler = MediaQuery.textScalerOf(context);
  final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      );
  final valueStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      );
  final labelPainter = TextPainter(
    text: TextSpan(text: leadingLabel, style: labelStyle),
    maxLines: 1,
    textDirection: Directionality.of(context),
    textScaler: textScaler,
  )..layout();
  final valuePainter = TextPainter(
    text: TextSpan(text: valueLabel, style: valueStyle),
    maxLines: 1,
    textDirection: Directionality.of(context),
    textScaler: textScaler,
  )..layout();
  return 76 + labelPainter.width + valuePainter.width;
}

class _LibraryToolbarSplitLabelTrigger extends StatelessWidget {
  const _LibraryToolbarSplitLabelTrigger({
    required this.leadingLabel,
    required this.valueLabel,
    required this.valueIcon,
  });

  final String leadingLabel;
  final String valueLabel;
  final IconData valueIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: libraryToolbarDropdownDecoration(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              leadingLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: libraryToolbarControlMutedText(context),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 8),
            Icon(
              valueIcon,
              size: 15,
              color: libraryToolbarControlText(context),
            ),
            const SizedBox(width: 6),
            Text(
              valueLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: libraryToolbarControlText(context),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: libraryToolbarControlMutedText(context),
            ),
          ],
        ),
      ),
    );
  }
}

String _detailsLayoutTooltip(LibraryDetailsLayout layout) {
  return switch (layout) {
    LibraryDetailsLayout.right => 'Details split vertically',
    LibraryDetailsLayout.bottom => 'Details split horizontally',
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
