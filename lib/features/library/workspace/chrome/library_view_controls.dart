import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _viewModeDropdownKey = Key('library-view-mode-dropdown');
const _detailsLayoutDropdownKey = Key('library-details-layout-dropdown');
const _viewModeDropdownHeight = 30.0;
const _librarySliderWidth = 100.0;

class LibraryViewModeDropdown extends StatelessWidget {
  const LibraryViewModeDropdown({
    super.key,
    required this.viewMode,
    required this.onChanged,
    this.iconOnly = false,
  });

  final LibraryViewMode viewMode;
  final ValueChanged<LibraryViewMode> onChanged;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    const menuText = Colors.white;
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w400,
          color: menuText,
        );
    final menuWidth = _measureViewDropdownWidth(
      context,
      textStyle: dropdownTextStyle,
    );
    final triggerWidth = iconOnly
        ? 46.0
        : _measureSplitTriggerWidth(
            context,
            leadingLabel: 'View',
            valueLabel: _viewModeLabel(viewMode),
          );
    return SizedBox(
      width: triggerWidth,
      child: PopupMenuButton<LibraryViewMode>(
        popUpAnimationStyle: AnimationStyle.noAnimation,
        key: _viewModeDropdownKey,
        tooltip: _viewModeTooltip(viewMode),
        onSelected: onChanged,
        padding: EdgeInsets.zero,
        color: libraryToolbarMenuSurface(context),
        surfaceTintColor: Colors.transparent,
        menuPadding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: double.infinity,
        ).copyWith(minWidth: menuWidth, maxWidth: menuWidth),
        shape: libraryToolbarDropdownMenuShape(context),
        itemBuilder: (context) => [
          for (final mode in const [
            LibraryViewMode.list,
            LibraryViewMode.card,
            LibraryViewMode.horizontalCards,
            LibraryViewMode.grid,
            LibraryViewMode.shelves,
            LibraryViewMode.cardFlow
          ])
            PopupMenuItem<LibraryViewMode>(
              height: _viewModeDropdownHeight,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              value: mode,
              child: LibraryWorkspaceMenuRow(
                padding: EdgeInsets.zero,
                label: _viewModeLabel(mode),
                leading: buildViewModeGlyph(
                  mode,
                  size: 17,
                  color: mode == viewMode ? accent : menuText,
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1,
                      fontWeight: FontWeight.w400,
                      color: mode == viewMode ? accent : menuText,
                    ),
              ),
            ),
        ],
        child: _LibraryToolbarSplitLabelTrigger(
          leadingLabel: 'View',
          valueLabel: _viewModeLabel(viewMode),
          valueWidget: buildViewModeGlyph(
            viewMode,
            color: libraryToolbarControlText(context),
            size: 15,
          ),
          iconOnly: iconOnly,
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
    this.iconOnly = false,
    this.inspectorStyle = false,
  });

  final LibraryDetailsLayout detailsLayout;
  final ValueChanged<LibraryDetailsLayout> onChanged;
  final bool iconOnly;
  final bool inspectorStyle;

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final menuText = libraryToolbarMenuText(context);
    final menuMuted = libraryToolbarMenuMutedText(context);
    final dropdownTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: FontWeight.w400,
          color: menuText,
        );
    final detailsMenuWidth = _measureDetailsDropdownWidth(
      context,
      textStyle: dropdownTextStyle,
    );
    final triggerWidth = iconOnly
        ? 46.0
        : _measureSplitTriggerWidth(
            context,
            leadingLabel: 'Layout',
            valueLabel: _detailsLayoutMenuLabel(detailsLayout),
          );
    final popup = PopupMenuButton<LibraryDetailsLayout>(
      popUpAnimationStyle: AnimationStyle.noAnimation,
      key: _detailsLayoutDropdownKey,
      tooltip: _detailsLayoutTooltip(detailsLayout),
      onSelected: onChanged,
      padding: EdgeInsets.zero,
      color: libraryToolbarMenuSurface(context),
      surfaceTintColor: Colors.transparent,
      menuPadding: EdgeInsets.zero,
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
            padding: const EdgeInsets.symmetric(horizontal: 7),
            value: layout,
            child: LibraryWorkspaceMenuRow(
              padding: EdgeInsets.zero,
              label: _detailsLayoutMenuLabel(layout),
              leading: Icon(
                _detailsLayoutIcon(layout),
                size: 17,
                color: layout == detailsLayout ? menuText : menuMuted,
              ),
              trailing: layout == detailsLayout
                  ? Icon(Icons.check, size: 16, color: accent)
                  : null,
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: menuText,
                  ),
            ),
          ),
      ],
      child: inspectorStyle
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _detailsLayoutIcon(detailsLayout),
                    size: 15,
                    color: menuText,
                  ),
                  if (!iconOnly) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Layout',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: menuText,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: menuMuted,
                    ),
                  ],
                ],
              ),
            )
          : _LibraryToolbarSplitLabelTrigger(
              leadingLabel: 'Layout',
              valueLabel: _detailsLayoutMenuLabel(detailsLayout),
              valueIcon: _detailsLayoutIcon(detailsLayout),
              iconOnly: iconOnly,
            ),
    );

    if (inspectorStyle) {
      return popup;
    }

    return SizedBox(
      width: triggerWidth,
      child: popup,
    );
  }
}

class LibraryGroupPresentationToggle extends StatelessWidget {
  const LibraryGroupPresentationToggle({
    super.key,
    required this.groupPresentation,
    required this.onChanged,
  });

  final LibraryGroupPresentation groupPresentation;
  final ValueChanged<LibraryGroupPresentation> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = libraryToolbarMenuText(context);
    final muted = libraryToolbarMenuMutedText(context);
    return Semantics(
      label: 'Shelf group display',
      child: SegmentedButton<LibraryGroupPresentation>(
        key: const ValueKey('library-group-presentation-toggle'),
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(72, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        segments: [
          ButtonSegment<LibraryGroupPresentation>(
            value: LibraryGroupPresentation.inlineHeaders,
            icon: Icon(
              LibraryGroupPresentation.inlineHeaders.icon,
              size: 17,
              color: groupPresentation == LibraryGroupPresentation.inlineHeaders
                  ? palette
                  : muted,
            ),
            tooltip: LibraryGroupPresentation.inlineHeaders.label,
          ),
          ButtonSegment<LibraryGroupPresentation>(
            value: LibraryGroupPresentation.folderGrid,
            icon: Icon(
              LibraryGroupPresentation.folderGrid.icon,
              size: 17,
              color: groupPresentation == LibraryGroupPresentation.folderGrid
                  ? palette
                  : muted,
            ),
            tooltip: LibraryGroupPresentation.folderGrid.label,
          ),
        ],
        selected: {groupPresentation},
        onSelectionChanged: (selected) {
          if (selected.isEmpty) {
            return;
          }
          onChanged(selected.first);
        },
      ),
    );
  }
}

class LibraryRangeSlider extends StatelessWidget {
  const LibraryRangeSlider(
      {super.key,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged});
  final double value, min, max;
  final ValueChanged<double>? onChanged;
  @override
  Widget build(BuildContext context) => SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 8,
          trackGap: 0,
          activeTrackColor: const Color(0xff717171),
          inactiveTrackColor: const Color(0xff717171),
          disabledActiveTrackColor: const Color(0xff717171),
          disabledInactiveTrackColor: const Color(0xff717171),
          thumbColor: Colors.white,
          disabledThumbColor: Colors.white54,
          overlayColor: Colors.transparent,
          overlayShape: SliderComponentShape.noOverlay,
          thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8, elevation: 0, pressedElevation: 0),
          trackShape: const RoundedRectSliderTrackShape(),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
            mouseCursor: WidgetStateMouseCursor.clickable),
      );
}

class LibraryCoverSizeSlider extends StatelessWidget {
  const LibraryCoverSizeSlider(
      {super.key,
      required this.viewMode,
      required this.coverSize,
      required this.minCoverSize,
      required this.maxCoverSize,
      required this.onChanged});
  final LibraryViewMode viewMode;
  final double coverSize, minCoverSize, maxCoverSize;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Cover Size',
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.photo_size_select_small,
              size: 18, color: appPalette(context).textPrimary),
          SizedBox(
              width: _librarySliderWidth,
              child: LibraryRangeSlider(
                  value: coverSize,
                  min: minCoverSize,
                  max: maxCoverSize,
                  onChanged: viewMode.supportsCoverSize ? onChanged : null)),
        ]),
      );
}

class LibrarySpacingSlider extends StatelessWidget {
  const LibrarySpacingSlider(
      {super.key,
      required this.spacing,
      required this.onChanged,
      this.minSpacing = 4,
      this.maxSpacing = 24,
      this.tooltip = 'Item Spacing',
      this.icon});
  final double spacing, minSpacing, maxSpacing;
  final ValueChanged<double> onChanged;
  final String tooltip;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon ?? Icons.format_line_spacing,
              size: 18, color: appPalette(context).textPrimary),
          SizedBox(
              width: _librarySliderWidth,
              child: LibraryRangeSlider(
                  value: spacing,
                  min: minSpacing,
                  max: maxSpacing,
                  onChanged: onChanged)),
        ]),
      );
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LibraryViewModeDropdown(
          viewMode: viewMode,
          onChanged: onViewModeChanged,
        ),
        LibraryDetailsLayoutDropdown(
          detailsLayout: detailsLayout,
          onChanged: onDetailsLayoutChanged,
        ),
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
  return (14 + 17 + 8 + maxLabelWidth).clamp(116, double.infinity);
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
  return (14 + 17 + 8 + maxLabelWidth).clamp(108, double.infinity);
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
  return '${_viewModeLabel(mode)} View';
}

IconData _viewModeIcon(LibraryViewMode mode) {
  return switch (mode) {
    LibraryViewMode.grid => AppIcons.viewCovers,
    LibraryViewMode.card => Icons.view_module,
    LibraryViewMode.horizontalCards => AppIcons.viewHorizontalCards,
    LibraryViewMode.cardFlow => Icons.view_carousel,
    LibraryViewMode.list => AppIcons.viewList,
    LibraryViewMode.shelves => Icons.shelves,
  };
}

Widget buildViewModeGlyph(
  LibraryViewMode mode, {
  required Color color,
  double size = 16,
}) {
  if (mode == LibraryViewMode.card) {
    return SvgPicture.asset(
      AppIcons.viewVerticalCardsSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
  return Icon(_viewModeIcon(mode), size: size, color: color);
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
        fontWeight: FontWeight.w700,
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
    this.valueIcon,
    this.valueWidget,
    this.iconOnly = false,
  }) : assert(valueIcon != null || valueWidget != null);

  final String leadingLabel;
  final String valueLabel;
  final IconData? valueIcon;
  final Widget? valueWidget;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final effectiveGlyph = valueWidget ??
        Icon(
          valueIcon!,
          size: 15,
          color: libraryToolbarControlText(context),
        );
    if (iconOnly) {
      return LibraryToolbarHoverSurface(
          child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              effectiveGlyph,
              const SizedBox(width: 4),
              Icon(AppIcons.chevronDown,
                  size: 12, color: libraryToolbarControlText(context)),
            ],
          ),
        ),
      ));
    }
    return LibraryToolbarHoverSurface(
        child: DecoratedBox(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            effectiveGlyph,
            if (!iconOnly) ...[
              const SizedBox(width: 8),
              Text(
                leadingLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: libraryToolbarControlMutedText(context),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: libraryToolbarControlText(context),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: libraryToolbarControlMutedText(context),
            ),
          ],
        ),
      ),
    ));
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
    LibraryDetailsLayout.bottom => Icons.splitscreen,
    LibraryDetailsLayout.hidden => Icons.visibility_off,
  };
}
