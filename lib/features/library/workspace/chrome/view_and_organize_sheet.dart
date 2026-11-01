import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet for configuring view mode, sorting, and layout on compact screens.
Future<void> showViewAndOrganizeSheet({
  required BuildContext context,
  required LibraryViewMode currentViewMode,
  required ValueChanged<LibraryViewMode> onViewModeChanged,
  required LibraryDetailsLayout currentDetailsLayout,
  required ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged,
  required double currentCoverSize,
  required double minCoverSize,
  required double maxCoverSize,
  required ValueChanged<double> onCoverSizeChanged,
  double? currentSpacing,
  ValueChanged<double>? onSpacingChanged,
  VoidCallback? onOpenSortDialog,
  VoidCallback? onOpenFilterDialog,
  VoidCallback? onOpenColumnChooser,
}) {
  return showAppBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: appPalette(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return ViewAndOrganizeSheet(
        currentViewMode: currentViewMode,
        onViewModeChanged: onViewModeChanged,
        currentDetailsLayout: currentDetailsLayout,
        onDetailsLayoutChanged: onDetailsLayoutChanged,
        currentCoverSize: currentCoverSize,
        minCoverSize: minCoverSize,
        maxCoverSize: maxCoverSize,
        onCoverSizeChanged: onCoverSizeChanged,
        currentSpacing: currentSpacing,
        onSpacingChanged: onSpacingChanged,
        onOpenSortDialog: onOpenSortDialog,
        onOpenFilterDialog: onOpenFilterDialog,
        onOpenColumnChooser: onOpenColumnChooser,
      );
    },
  );
}

class ViewAndOrganizeSheet extends StatefulWidget {
  const ViewAndOrganizeSheet({
    super.key,
    required this.currentViewMode,
    required this.onViewModeChanged,
    required this.currentDetailsLayout,
    required this.onDetailsLayoutChanged,
    required this.currentCoverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.onCoverSizeChanged,
    this.currentSpacing,
    this.onSpacingChanged,
    this.onOpenSortDialog,
    this.onOpenFilterDialog,
    this.onOpenColumnChooser,
  });

  final LibraryViewMode currentViewMode;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final LibraryDetailsLayout currentDetailsLayout;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final double currentCoverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final double? currentSpacing;
  final ValueChanged<double>? onSpacingChanged;
  final VoidCallback? onOpenSortDialog;
  final VoidCallback? onOpenFilterDialog;
  final VoidCallback? onOpenColumnChooser;

  @override
  State<ViewAndOrganizeSheet> createState() => _ViewAndOrganizeSheetState();
}

class _ViewAndOrganizeSheetState extends State<ViewAndOrganizeSheet> {
  late LibraryViewMode _viewMode;
  late LibraryDetailsLayout _detailsLayout;
  late double _coverSize;
  double? _spacing;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.currentViewMode;
    _detailsLayout = widget.currentDetailsLayout;
    _coverSize = widget.currentCoverSize.clamp(
      widget.minCoverSize,
      widget.maxCoverSize,
    );
    _spacing = widget.currentSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);

    return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AccentDialogHeader(
                title: 'View & Organize',
                icon: AppIcons.toolbarTools,
                onClose: () => Navigator.of(context).pop()),
            const Divider(height: 20),
          ])),
      Flexible(
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: View Layout Mode
                    _buildSectionHeader('View Layout', palette),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final mode in LibraryViewMode.values)
                        _buildChoiceChip(
                          key: ValueKey('view_mode_${mode.name}'),
                          leading: buildViewModeGlyph(mode,
                              size: 20,
                              color: _viewMode == mode
                                  ? palette.utilityAction
                                  : palette.textMuted),
                          label: switch (mode) {
                            LibraryViewMode.grid => 'Grid',
                            LibraryViewMode.card => 'Cards',
                            LibraryViewMode.horizontalCards =>
                              'Horizontal cards',
                            LibraryViewMode.cardFlow => 'Flow carousel',
                            LibraryViewMode.list => 'List',
                            LibraryViewMode.shelves => 'Shelves',
                          },
                          selected: _viewMode == mode,
                          accent: palette.utilityAction,
                          palette: palette,
                          onTap: () {
                            setState(() => _viewMode = mode);
                            widget.onViewModeChanged(mode);
                          },
                        ),
                    ]),

                    // Section 2: Cover Size (when supported)
                    if (_viewMode.supportsCoverSize) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader('Cover Size', palette),
                      Row(
                        children: [
                          Icon(Icons.photo_size_select_small,
                              size: 16, color: palette.textMuted),
                          Expanded(
                            child: LibraryRangeSlider(
                              key: const ValueKey('cover_size_slider'),
                              value: _coverSize,
                              min: widget.minCoverSize,
                              max: widget.maxCoverSize,
                              onChanged: (val) {
                                setState(() => _coverSize = val);
                                widget.onCoverSizeChanged(val);
                              },
                            ),
                          ),
                          Icon(Icons.photo_size_select_large,
                              size: 20, color: palette.textMuted),
                        ],
                      ),
                    ],

                    // Section: Spacing / Row Height
                    if (widget.onSpacingChanged != null) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        _viewMode == LibraryViewMode.list
                            ? 'Item Spacing'
                            : 'Item Spacing',
                        palette,
                      ),
                      Row(
                        children: [
                          Icon(Icons.format_line_spacing,
                              size: 16, color: palette.textMuted),
                          Expanded(
                            child: LibraryRangeSlider(
                              key: const ValueKey('spacing_slider'),
                              value: (_spacing ?? 10.0).clamp(4.0, 24.0),
                              min: 4,
                              max: 24,
                              onChanged: (val) {
                                setState(() => _spacing = val);
                                widget.onSpacingChanged!(val);
                              },
                            ),
                          ),
                          Icon(Icons.format_line_spacing,
                              size: 20, color: palette.textMuted),
                        ],
                      ),
                    ],

                    // Section 4: Details Panel Layout
                    const SizedBox(height: 16),
                    _buildSectionHeader('Details Inspector', palette),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final layout in LibraryDetailsLayout.values)
                        _buildChoiceChip(
                          key: ValueKey('details_layout_${layout.name}'),
                          icon: switch (layout) {
                            LibraryDetailsLayout.right => Icons.dock,
                            LibraryDetailsLayout.bottom => Icons.view_stream,
                            LibraryDetailsLayout.hidden =>
                              Icons.visibility_off_outlined
                          },
                          label: switch (layout) {
                            LibraryDetailsLayout.right => 'Side',
                            LibraryDetailsLayout.bottom => 'Bottom',
                            LibraryDetailsLayout.hidden => 'Hidden'
                          },
                          selected: _detailsLayout == layout,
                          accent: palette.utilityAction,
                          palette: palette,
                          onTap: () {
                            setState(() => _detailsLayout = layout);
                            widget.onDetailsLayoutChanged(layout);
                          },
                        ),
                    ]),

                    // Section 5: Quick Tools / Dialog Openers
                    const SizedBox(height: 16),
                    _buildSectionHeader('Organization & Tools', palette),
                    const SizedBox(height: 8),
                    ListTile(
                      key: const ValueKey('sheet_open_sort'),
                      leading: Icon(Icons.sort, color: palette.utilityAction),
                      title: const Text('Sort Rules & Columns',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onOpenSortDialog?.call();
                      },
                    ),
                    if (widget.onOpenFilterDialog != null)
                      ListTile(
                        key: const ValueKey('sheet_open_filters'),
                        leading: Icon(Icons.filter_list,
                            color: palette.utilityAction),
                        title: const Text('Advanced Filters',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onOpenFilterDialog?.call();
                        },
                      ),
                    if (widget.onOpenColumnChooser != null)
                      ListTile(
                        key: const ValueKey('sheet_open_columns'),
                        leading: Icon(Icons.view_column_outlined,
                            color: palette.utilityAction),
                        title: const Text('Visible Columns',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onOpenColumnChooser?.call();
                        },
                      ),
                  ]))),
    ]));
  }

  Widget _buildSectionHeader(String title, AppThemePalette palette) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: palette.textMuted,
      ),
    );
  }

  Widget _buildChoiceChip({
    Key? key,
    IconData? icon,
    Widget? leading,
    required String label,
    required bool selected,
    required Color accent,
    required AppThemePalette palette,
    required VoidCallback onTap,
  }) {
    assert(icon != null || leading != null);
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: palette.isDark ? 0.22 : 0.12)
                : palette.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accent : palette.divider,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading ??
                  Icon(
                    icon!,
                    size: 16,
                    color: selected ? accent : palette.textMuted,
                  ),
              const SizedBox(width: 6),
              Flexible(
                  child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? accent : palette.textPrimary,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
