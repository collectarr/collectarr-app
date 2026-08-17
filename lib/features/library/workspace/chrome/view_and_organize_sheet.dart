import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet for configuring view mode, density, sorting, and layout on compact screens.
Future<void> showViewAndOrganizeSheet({
  required BuildContext context,
  required LibraryViewMode currentViewMode,
  required ValueChanged<LibraryViewMode> onViewModeChanged,
  required LibraryWorkspaceDensityPreset currentDensity,
  required ValueChanged<LibraryWorkspaceDensityPreset> onDensityChanged,
  required LibraryDetailsLayout currentDetailsLayout,
  required ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged,
  required double currentCoverSize,
  required double minCoverSize,
  required double maxCoverSize,
  required ValueChanged<double> onCoverSizeChanged,
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
        currentDensity: currentDensity,
        onDensityChanged: onDensityChanged,
        currentDetailsLayout: currentDetailsLayout,
        onDetailsLayoutChanged: onDetailsLayoutChanged,
        currentCoverSize: currentCoverSize,
        minCoverSize: minCoverSize,
        maxCoverSize: maxCoverSize,
        onCoverSizeChanged: onCoverSizeChanged,
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
    required this.currentDensity,
    required this.onDensityChanged,
    required this.currentDetailsLayout,
    required this.onDetailsLayoutChanged,
    required this.currentCoverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.onCoverSizeChanged,
    this.onOpenSortDialog,
    this.onOpenFilterDialog,
    this.onOpenColumnChooser,
  });

  final LibraryViewMode currentViewMode;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final LibraryWorkspaceDensityPreset currentDensity;
  final ValueChanged<LibraryWorkspaceDensityPreset> onDensityChanged;
  final LibraryDetailsLayout currentDetailsLayout;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final double currentCoverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback? onOpenSortDialog;
  final VoidCallback? onOpenFilterDialog;
  final VoidCallback? onOpenColumnChooser;

  @override
  State<ViewAndOrganizeSheet> createState() => _ViewAndOrganizeSheetState();
}

class _ViewAndOrganizeSheetState extends State<ViewAndOrganizeSheet> {
  late LibraryViewMode _viewMode;
  late LibraryWorkspaceDensityPreset _density;
  late LibraryDetailsLayout _detailsLayout;
  late double _coverSize;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.currentViewMode;
    _density = widget.currentDensity;
    _detailsLayout = widget.currentDetailsLayout;
    _coverSize = widget.currentCoverSize.clamp(
      widget.minCoverSize,
      widget.maxCoverSize,
    );
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
            Row(
              children: [
                Icon(Icons.tune, size: 20, color: accentData.accent),
                const SizedBox(width: 8),
                Text(
                  'View & Organize',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
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
                  icon: Icons.grid_view,
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
                  icon: Icons.view_module,
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
                  icon: Icons.view_list,
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
                    child: Slider(
                      key: const ValueKey('cover_size_slider'),
                      value: _coverSize,
                      min: widget.minCoverSize,
                      max: widget.maxCoverSize,
                      activeColor: accentData.accent,
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

            // Section 3: Density
            const SizedBox(height: 16),
            _buildSectionHeader('Density', palette),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    key: const ValueKey('density_comfortable'),
                    icon: Icons.density_medium,
                    label: 'Comfortable',
                    selected:
                        _density == LibraryWorkspaceDensityPreset.comfortable,
                    accent: accentData.accent,
                    palette: palette,
                    onTap: () {
                      setState(() =>
                          _density = LibraryWorkspaceDensityPreset.comfortable);
                      widget.onDensityChanged(
                          LibraryWorkspaceDensityPreset.comfortable);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceChip(
                    key: const ValueKey('density_compact'),
                    icon: Icons.density_small,
                    label: 'Compact',
                    selected: _density == LibraryWorkspaceDensityPreset.compact,
                    accent: accentData.accent,
                    palette: palette,
                    onTap: () {
                      setState(() =>
                          _density = LibraryWorkspaceDensityPreset.compact);
                      widget.onDensityChanged(
                          LibraryWorkspaceDensityPreset.compact);
                    },
                  ),
                ),
              ],
            ),

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
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: palette.textMuted,
      ),
    );
  }

  Widget _buildChoiceChip({
    Key? key,
    required IconData icon,
    required String label,
    required bool selected,
    required Color accent,
    required AppThemePalette palette,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
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
              Icon(
                icon,
                size: 16,
                color: selected ? accent : palette.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
