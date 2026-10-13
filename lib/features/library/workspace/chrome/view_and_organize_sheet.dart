import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  return showModalBottomSheet<void>(
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
    final accentData = LibraryAccentScope.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

            // Section 1: View Layout Mode
            _buildSectionHeader('View Layout', palette),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChoiceChip(
                  key: const ValueKey('view_mode_grid'),
                  icon: AppIcons.viewCovers,
                  label: 'Grid',
                  selected: _viewMode == LibraryViewMode.grid,
                  accent: accentData.accent,
                  palette: palette,
                  onTap: () {
                    setState(() => _viewMode = LibraryViewMode.grid);
                    widget.onViewModeChanged(LibraryViewMode.grid);
                  },
                ),
                _buildChoiceChip(
                  key: const ValueKey('view_mode_card'),
                  leading: SvgPicture.asset(
                    AppIcons.viewVerticalCardsSvg,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      _viewMode == LibraryViewMode.card
                          ? accentData.accent
                          : palette.textMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Cards',
                  selected: _viewMode == LibraryViewMode.card,
                  accent: accentData.accent,
                  palette: palette,
                  onTap: () {
                    setState(() => _viewMode = LibraryViewMode.card);
                    widget.onViewModeChanged(LibraryViewMode.card);
                  },
                ),
                _buildChoiceChip(
                  key: const ValueKey('view_mode_list'),
                  icon: AppIcons.viewList,
                  label: 'List',
                  selected: _viewMode == LibraryViewMode.list,
                  accent: accentData.accent,
                  palette: palette,
                  onTap: () {
                    setState(() => _viewMode = LibraryViewMode.list);
                    widget.onViewModeChanged(LibraryViewMode.list);
                  },
                ),
                _buildChoiceChip(
                  key: const ValueKey('view_mode_shelves'),
                  icon: Icons.shelves,
                  label: 'Shelves',
                  selected: _viewMode == LibraryViewMode.shelves,
                  accent: accentData.accent,
                  palette: palette,
                  onTap: () {
                    setState(() => _viewMode = LibraryViewMode.shelves);
                    widget.onViewModeChanged(LibraryViewMode.shelves);
                  },
                ),
              ],
            ),

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
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    key: const ValueKey('details_layout_right'),
                    icon: Icons.dock,
                    label: 'Side',
                    selected: _detailsLayout == LibraryDetailsLayout.right,
                    accent: accentData.accent,
                    palette: palette,
                    onTap: () {
                      setState(
                          () => _detailsLayout = LibraryDetailsLayout.right);
                      widget.onDetailsLayoutChanged(LibraryDetailsLayout.right);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceChip(
                    key: const ValueKey('details_layout_bottom'),
                    icon: Icons.view_stream,
                    label: 'Bottom',
                    selected: _detailsLayout == LibraryDetailsLayout.bottom,
                    accent: accentData.accent,
                    palette: palette,
                    onTap: () {
                      setState(
                          () => _detailsLayout = LibraryDetailsLayout.bottom);
                      widget
                          .onDetailsLayoutChanged(LibraryDetailsLayout.bottom);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceChip(
                    key: const ValueKey('details_layout_hidden'),
                    icon: Icons.visibility_off_outlined,
                    label: 'Hidden',
                    selected: _detailsLayout == LibraryDetailsLayout.hidden,
                    accent: accentData.accent,
                    palette: palette,
                    onTap: () {
                      setState(
                          () => _detailsLayout = LibraryDetailsLayout.hidden);
                      widget
                          .onDetailsLayoutChanged(LibraryDetailsLayout.hidden);
                    },
                  ),
                ),
              ],
            ),

            // Section 5: Quick Tools / Dialog Openers
            const SizedBox(height: 16),
            _buildSectionHeader('Organization & Tools', palette),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('sheet_open_sort'),
              leading: Icon(Icons.sort, color: accentData.accent),
              title: const Text('Sort Rules & Columns',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.of(context).pop();
                widget.onOpenSortDialog?.call();
              },
            ),
            if (widget.onOpenFilterDialog != null)
              ListTile(
                key: const ValueKey('sheet_open_filters'),
                leading: Icon(Icons.filter_list, color: accentData.accent),
                title: const Text('Advanced Filters',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onOpenFilterDialog?.call();
                },
              ),
            if (widget.onOpenColumnChooser != null)
              ListTile(
                key: const ValueKey('sheet_open_columns'),
                leading:
                    Icon(Icons.view_column_outlined, color: accentData.accent),
                title: const Text('Visible Columns',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onOpenColumnChooser?.call();
                },
              ),
          ],
        ),
      ),
    );
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? accent : palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
