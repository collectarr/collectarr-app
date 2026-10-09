import 'dart:typed_data';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_export_capability.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum PrintSubset { all, currentList, checkboxed }

enum ExportMode { itemList, childList }

enum PdfOrientation { portrait, landscape }

enum PdfBorderType { none, middle, outside, all }

enum PdfMarginSetting {
  extraSmall('Extra small', 5),
  small('Small', 10),
  medium('Medium', 20),
  large('Large', 25),
  extraLarge('Extra large', 30);

  const PdfMarginSetting(this.label, this.mm);
  final String label;
  final double mm;
}

class PdfColumnDefinition {
  const PdfColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.widthFlex = 1.0,
    this.defaultVisible = true,
  });

  final String id;
  final String label;
  final String Function(LibraryProjectionView item) getValue;
  final double widthFlex;
  final bool defaultVisible;

  factory PdfColumnDefinition.fromExportColumn(
    ExportColumnDefinition column,
  ) =>
      PdfColumnDefinition(
        id: column.id,
        label: column.pdfLabel ?? column.label,
        getValue: column.pdfGetValue ?? column.getValue,
        widthFlex: column.pdfWidthFlex ?? 1.0,
        defaultVisible: column.pdfDefaultVisible ?? column.defaultVisible,
      );
}

class PdfChildColumnDefinition {
  const PdfChildColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.widthFlex = 1.0,
    this.defaultVisible = true,
  });

  factory PdfChildColumnDefinition.fromExportColumn(
    LibraryExportChildColumnDefinition column,
  ) =>
      PdfChildColumnDefinition(
        id: column.id,
        label: column.pdfLabel ?? column.label,
        getValue: column.pdfGetValue ?? column.getValue,
        widthFlex: column.pdfWidthFlex ?? 1.0,
        defaultVisible: column.pdfDefaultVisible ?? column.defaultVisible,
      );

  final String id;
  final String label;
  final String Function(LibraryExportChildRow row) getValue;
  final double widthFlex;
  final bool defaultVisible;
}

/// Full-page Print to PDF view matching the CLZ Web layout 1:1.
class LibraryPrintPdfPage extends StatefulWidget {
  const LibraryPrintPdfPage({
    super.key,
    required this.type,
    required this.items,
    this.allItems,
    this.selectedItemIds,
    this.allShelfEntries,
    this.initialTitle,
  });

  final LibraryKindRegistration type;
  final List<LibraryProjectionView> items;
  final List<LibraryProjectionView>? allItems;
  final Set<String>? selectedItemIds;
  final List<LibraryWorkspaceContext>? allShelfEntries;
  final String? initialTitle;

  @override
  State<LibraryPrintPdfPage> createState() => _LibraryPrintPdfPageState();
}

class _LibraryPrintPdfPageState extends State<LibraryPrintPdfPage> {
  PrintSubset _subset = PrintSubset.all;
  ExportMode _exportMode = ExportMode.itemList;
  PdfOrientation _orientation = PdfOrientation.portrait;
  late final TextEditingController _titleController;

  bool _wrapInsideColumn = true;
  bool _coverThumbnails = false;
  bool _showMoreSettings = false;

  PdfMarginSetting _margin = PdfMarginSetting.medium;
  String _fontFamily = 'Arial';
  int _fontSize = 10;
  Color _fontColor = const Color(0xFF333333);

  bool _repeatTitleOnEveryPage = false;
  bool _limitRowsPerPage = false;
  int _maxRowsPerPage = 25;
  bool _pageNumbers = true;
  bool _printDateTime = false;
  bool _repeatDateTime = false;
  bool _headerRow = true;
  bool _repeatHeaderRow = false;
  bool _alternatingRows = false;
  PdfBorderType _borderType = PdfBorderType.all;

  late List<PdfColumnDefinition> _availableItemColumns;
  late List<String> _selectedItemColumnIds;

  late List<PdfChildColumnDefinition> _availableChildColumns;
  late List<String> _selectedChildColumnIds;

  String _sortColumnId = 'artist';
  bool _sortAscending = true;

  bool _isGenerating = false;
  Uint8List? _generatedPdfBytes;
  String? _generatedFileSize;

  LibraryExportCapability? get _exportCapability =>
      libraryExportCapabilityForKind(widget.type.kind);

  bool get _supportsChildList =>
      _exportCapability?.supportsChildList == true &&
      _availableChildColumns.isNotEmpty;

  String get _itemLabel =>
      _exportCapability?.itemLabel ?? widget.type.identity.pluralLabel;

  String get _childLabel => _exportCapability?.childLabel ?? 'items';

  @override
  void initState() {
    super.initState();
    if (widget.selectedItemIds != null && widget.selectedItemIds!.isNotEmpty) {
      _subset = PrintSubset.checkboxed;
    }
    _titleController = TextEditingController(
      text: widget.initialTitle ??
          (_exportCapability?.pdfItemTitle ?? 'My $_itemLabel'),
    );
    _initColumns();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _initColumns() {
    final capability = _exportCapability;
    final contributedColumns = capability?.pdfItemColumns ?? const [];
    _availableItemColumns = contributedColumns.isNotEmpty
        ? [
            for (final column in contributedColumns)
              PdfColumnDefinition.fromExportColumn(column),
          ]
        : [
            PdfColumnDefinition(
              id: 'title',
              label: 'Title',
              getValue: (item) => item.dto.primaryLabel,
              widthFlex: 2.5,
            ),
            PdfColumnDefinition(
              id: 'secondary',
              label: 'Creator / Series',
              getValue: (item) => item.dto.secondaryLabel ?? '',
              widthFlex: 2.0,
            ),
            PdfColumnDefinition(
              id: 'format',
              label: 'Format',
              getValue: (item) => item.source.catalogSummary?.subtitle ?? '',
              widthFlex: 1.2,
            ),
            PdfColumnDefinition(
              id: 'status',
              label: 'Status',
              getValue: (item) => item.source.trackingStatusLabel,
              widthFlex: 1.0,
            ),
            PdfColumnDefinition(
              id: 'location',
              label: 'Location',
              getValue: (item) => item.source.locationPath ?? '',
              widthFlex: 1.5,
              defaultVisible: false,
            ),
            PdfColumnDefinition(
              id: 'price_paid',
              label: 'Price Paid',
              getValue: (item) => item.source.pricePaidCents != null
                  ? formatMoney(
                      item.source.pricePaidCents, item.source.currency)
                  : '',
              widthFlex: 1.0,
              defaultVisible: false,
            ),
            PdfColumnDefinition(
              id: 'value',
              label: 'Value',
              getValue: (item) => item.source.marketValueCents != null
                  ? formatMoney(
                      item.source.marketValueCents, item.source.currency)
                  : '',
              widthFlex: 1.0,
              defaultVisible: false,
            ),
          ];
    _selectedItemColumnIds = _availableItemColumns
        .where((column) => column.defaultVisible)
        .map((column) => column.id)
        .toList();
    _availableChildColumns = [
      for (final column in capability?.pdfChildColumns ??
          const <LibraryExportChildColumnDefinition>[])
        PdfChildColumnDefinition.fromExportColumn(column),
    ];
    _selectedChildColumnIds = _availableChildColumns
        .where((column) => column.defaultVisible)
        .map((column) => column.id)
        .toList();
    _sortColumnId = capability?.defaultSortColumnId ?? 'title';
  }

  List<LibraryProjectionView> get _allList => widget.allItems ?? widget.items;

  List<LibraryProjectionView> get _checkboxedList {
    final ids = widget.selectedItemIds;
    if (ids == null || ids.isEmpty) return const [];
    return _allList.where((item) => ids.contains(item.target.id)).toList();
  }

  List<LibraryProjectionView> get _activeItems {
    final list = switch (_subset) {
      PrintSubset.all => _allList,
      PrintSubset.currentList => widget.items,
      PrintSubset.checkboxed => _checkboxedList,
    };

    final sorted = List<LibraryProjectionView>.from(list);
    sorted.sort((a, b) {
      final col = _availableItemColumns.firstWhere(
        (c) => c.id == _sortColumnId,
        orElse: () => _availableItemColumns.first,
      );
      final valA = col.getValue(a).toLowerCase();
      final valB = col.getValue(b).toLowerCase();
      final cmp = valA.compareTo(valB);
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  List<LibraryExportChildRow> get _activeChildRows =>
      _exportCapability?.childRowsFor(_activeItems) ?? const [];

  int get _totalChildCount =>
      _exportCapability?.childRowsFor(widget.items).length ?? 0;

  String get _formattedCurrentDateTime {
    final now = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${pad(now.month)}-${pad(now.day)} ${pad(now.hour)}:${pad(now.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(widget.type.kind);
    final palette = appPalette(context);

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('print_pdf.back'),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Print to PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: Duration.zero,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Pane: Which items + optional child mode + Columns + Sort
                _buildTopSelectionPane(palette, accent),
                const SizedBox(height: 16),

                // 2. Pane: Page Setup
                _buildPageSetupPane(palette, accent),
                const SizedBox(height: 16),

                // 3. Pane: Preview
                _buildPreviewPane(palette, accent),
                const SizedBox(height: 20),

                // 4. Action bar: Generate PDF / Download / Print
                _buildActionsBar(palette, accent),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 1: TOP SELECTION & MODES
  // ==========================================
  Widget _buildTopSelectionPane(AppThemePalette palette, Color accent) {
    final isWide = MediaQuery.of(context).size.width >= 1050;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSubsetSection(palette)),
                const SizedBox(width: 16),
                if (_supportsChildList) ...[
                  Expanded(child: _buildExportModeSection(palette)),
                  const SizedBox(width: 16),
                ],
                Expanded(child: _buildColumnsSection(palette)),
                const SizedBox(width: 16),
                Expanded(child: _buildSortSection(palette)),
              ],
            )
          else ...[
            _buildSubsetSection(palette),
            const SizedBox(height: 16),
            if (_supportsChildList) ...[
              _buildExportModeSection(palette),
              const SizedBox(height: 16),
            ],
            _buildColumnsSection(palette),
            const SizedBox(height: 16),
            _buildSortSection(palette),
          ],
        ],
      ),
    );
  }

  Widget _buildSubsetSection(AppThemePalette palette) {
    final plural = _itemLabel;
    final allCount = _allList.length;
    final currentCount = widget.items.length;
    final checkboxedCount = _checkboxedList.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which $plural',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.field,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              _buildRadioRow(
                title: 'All $plural',
                count: allCount,
                selected: _subset == PrintSubset.all,
                onTap: () => setState(() => _subset = PrintSubset.all),
                palette: palette,
              ),
              Divider(height: 1, color: palette.divider),
              _buildRadioRow(
                title: 'Current List',
                count: currentCount,
                selected: _subset == PrintSubset.currentList,
                onTap: () => setState(() => _subset = PrintSubset.currentList),
                palette: palette,
              ),
              Divider(height: 1, color: palette.divider),
              _buildRadioRow(
                title: 'Checkboxed',
                count: checkboxedCount,
                selected: _subset == PrintSubset.checkboxed,
                disabled: checkboxedCount == 0,
                onTap: checkboxedCount == 0
                    ? () {}
                    : () => setState(() => _subset = PrintSubset.checkboxed),
                palette: palette,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportModeSection(AppThemePalette palette) {
    final capability = _exportCapability!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export mode',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.field,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              _buildRadioRow(
                title: capability.itemModeLabel,
                count: widget.items.length,
                selected: _exportMode == ExportMode.itemList,
                onTap: () => setState(() => _exportMode = ExportMode.itemList),
                palette: palette,
              ),
              Divider(height: 1, color: palette.divider),
              _buildRadioRow(
                title: capability.childModeLabel ??
                    '${capability.childLabel} list',
                count: _totalChildCount,
                selected: _exportMode == ExportMode.childList,
                onTap: () => setState(() => _exportMode = ExportMode.childList),
                palette: palette,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnsSection(AppThemePalette palette) {
    final activeLabels = _exportMode == ExportMode.itemList
        ? _availableItemColumns
            .where((c) => _selectedItemColumnIds.contains(c.id))
            .map((c) => c.label)
            .join(', ')
        : _availableChildColumns
            .where((c) => _selectedChildColumnIds.contains(c.id))
            .map((c) => c.label)
            .join(', ')
            .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Visible Columns',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              icon: const Icon(Icons.more_vert, size: 13),
              label: const Text('Manage', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
              onPressed: _showManageColumnsDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.field,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active columns (${_exportMode == ExportMode.itemList ? _selectedItemColumnIds.length : _selectedChildColumnIds.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeLabels.isEmpty ? 'None' : activeLabels,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortSection(AppThemePalette palette) {
    final currentSortLabel = _availableItemColumns
        .firstWhere((c) => c.id == _sortColumnId,
            orElse: () => _availableItemColumns.first)
        .label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Sort Order',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              icon: const Icon(Icons.more_vert, size: 13),
              label: const Text('Manage', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
              onPressed: _showManageSortDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.field,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    currentSortLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: palette.panel,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _sortAscending ? 'ASC' : 'DESC',
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Sorted by $currentSortLabel (${_sortAscending ? "ascending" : "descending"})',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioRow({
    required String title,
    required int count,
    required bool selected,
    required VoidCallback onTap,
    required AppThemePalette palette,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: disabled
                  ? palette.textMuted
                  : (selected ? palette.accent : palette.textSecondary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: disabled ? palette.textMuted : palette.textPrimary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: disabled ? palette.textMuted : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 2: PAGE SETUP
  // ==========================================
  Widget _buildPageSetupPane(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page Setup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  _showMoreSettings ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(
                  _showMoreSettings ? 'Less settings' : 'More settings',
                  style: const TextStyle(fontSize: 13),
                ),
                onPressed: () =>
                    setState(() => _showMoreSettings = !_showMoreSettings),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Row: Layout, Title, Checkboxes
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildLayoutControls(palette)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTitleControls(palette)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPrimaryCheckboxes(palette)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLayoutControls(palette),
                      const SizedBox(height: 12),
                      _buildTitleControls(palette),
                      const SizedBox(height: 12),
                      _buildPrimaryCheckboxes(palette),
                    ],
                  );
          }),

          // Expandable More Settings
          if (_showMoreSettings) ...[
            const SizedBox(height: 16),
            Divider(color: palette.divider),
            const SizedBox(height: 12),
            _buildMoreSettingsSection(palette),
          ],
        ],
      ),
    );
  }

  Widget _buildLayoutControls(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Layout',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary)),
        const SizedBox(height: 6),
        RadioGroup<PdfOrientation>(
          groupValue: _orientation,
          onChanged: (v) {
            if (v != null) setState(() => _orientation = v);
          },
          child: Row(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _orientation = PdfOrientation.portrait),
                child: const Row(
                  children: [
                    Radio<PdfOrientation>(value: PdfOrientation.portrait),
                    Text('Portrait', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () =>
                    setState(() => _orientation = PdfOrientation.landscape),
                child: const Row(
                  children: [
                    Radio<PdfOrientation>(value: PdfOrientation.landscape),
                    Text('Landscape', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleControls(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: palette.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: palette.cardBorder),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPrimaryCheckboxes(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _wrapInsideColumn = !_wrapInsideColumn),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _wrapInsideColumn,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => setState(() => _wrapInsideColumn = v ?? true),
              ),
              const SizedBox(width: 6),
              const Flexible(
                child:
                    Text('Wrap inside column', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => setState(() => _coverThumbnails = !_coverThumbnails),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _coverThumbnails,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => setState(() => _coverThumbnails = v ?? false),
              ),
              const SizedBox(width: 6),
              const Flexible(
                child: Text('Cover thumbnails', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreSettingsSection(AppThemePalette palette) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 700;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFontAndMarginsCol(palette)),
                const SizedBox(width: 16),
                Expanded(child: _buildPaginationCol(palette)),
                const SizedBox(width: 16),
                Expanded(child: _buildBordersCol(palette)),
              ],
            )
          else ...[
            _buildFontAndMarginsCol(palette),
            const SizedBox(height: 12),
            _buildPaginationCol(palette),
            const SizedBox(height: 12),
            _buildBordersCol(palette),
          ],
        ],
      );
    });
  }

  Widget _buildFontAndMarginsCol(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Margins',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<PdfMarginSetting>(
          initialValue: _margin,
          isDense: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: palette.field,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: palette.cardBorder)),
          ),
          items: PdfMarginSetting.values
              .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
              .toList(),
          onChanged: (v) => setState(() => _margin = v ?? _margin),
        ),
        const SizedBox(height: 10),
        Text('Font type:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _fontFamily,
          isDense: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: palette.field,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: palette.cardBorder)),
          ),
          items: const [
            DropdownMenuItem(value: 'Arial', child: Text('Arial')),
            DropdownMenuItem(
                value: 'Times New Roman', child: Text('Times New Roman')),
            DropdownMenuItem(value: 'Courier New', child: Text('Courier New')),
          ],
          onChanged: (v) => setState(() => _fontFamily = v ?? _fontFamily),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Font size:',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<int>(
                    initialValue: _fontSize,
                    isDense: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: palette.field,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: palette.cardBorder)),
                    ),
                    items: [8, 9, 10, 11, 12, 14, 16, 32]
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.toString())))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _fontSize = v ?? _fontSize),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color:',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _toggleColorChoice,
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: palette.field,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _fontColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleColorChoice() {
    final colors = [
      const Color(0xFF333333),
      const Color(0xFF000000),
      const Color(0xFF1B365D),
      const Color(0xFF555555),
    ];
    final curIdx = colors.indexOf(_fontColor);
    final nextIdx = (curIdx + 1) % colors.length;
    setState(() => _fontColor = colors[nextIdx]);
  }

  Widget _buildPaginationCol(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxRow('on every page (Title)', _repeatTitleOnEveryPage,
            (v) => setState(() => _repeatTitleOnEveryPage = v)),
        Row(
          children: [
            Checkbox(
              value: _limitRowsPerPage,
              onChanged: (v) => setState(() => _limitRowsPerPage = v ?? false),
            ),
            const Text('Max rows per page:', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            SizedBox(
              width: 44,
              height: 28,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: palette.field,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: palette.cardBorder),
                  ),
                ),
                controller:
                    TextEditingController(text: _maxRowsPerPage.toString()),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n > 0) _maxRowsPerPage = n;
                },
              ),
            ),
          ],
        ),
        _buildCheckboxRow('Page numbers', _pageNumbers,
            (v) => setState(() => _pageNumbers = v)),
        _buildCheckboxRow('Print date/time', _printDateTime,
            (v) => setState(() => _printDateTime = v)),
        _buildCheckboxRow('on every page (Date)', _repeatDateTime,
            (v) => setState(() => _repeatDateTime = v)),
      ],
    );
  }

  Widget _buildBordersCol(AppThemePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxRow('Column field names', _headerRow,
            (v) => setState(() => _headerRow = v)),
        _buildCheckboxRow('on every page (Header)', _repeatHeaderRow,
            (v) => setState(() => _repeatHeaderRow = v)),
        _buildCheckboxRow('Row shading', _alternatingRows,
            (v) => setState(() => _alternatingRows = v)),
        const SizedBox(height: 6),
        Text('Borders',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBorderOption(PdfBorderType.none, 'None', palette),
            _buildBorderOption(PdfBorderType.middle, 'Middle', palette),
            _buildBorderOption(PdfBorderType.outside, 'Outside', palette),
            _buildBorderOption(PdfBorderType.all, 'All', palette),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
          ),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildBorderOption(
      PdfBorderType type, String label, AppThemePalette palette) {
    final selected = _borderType == type;
    return InkWell(
      onTap: () => setState(() => _borderType = type),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: selected ? palette.accent : Colors.grey.shade400,
                width: selected ? 2 : 1,
              ),
            ),
            child: CustomPaint(painter: _BorderOptionPainter(type)),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: LIVE PREVIEW
  // ==========================================
  Widget _buildPreviewPane(AppThemePalette palette, Color accent) {
    final previewItems = _activeItems.take(15).toList();
    final isLandscape = _orientation == PdfOrientation.landscape;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Outer preview canvas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.cardBorder),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 1000 : 750,
                  minHeight: isLandscape ? 400 : 550,
                ),
                child: Container(
                  padding: EdgeInsets.all(_margin.mm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Document Title
                      Text(
                        _titleController.text.trim().isEmpty
                            ? 'My Collection'
                            : _titleController.text.trim(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _fontColor,
                          fontFamily: _fontFamily,
                        ),
                      ),
                      if (_printDateTime) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formattedCurrentDateTime,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Preview Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _exportMode == ExportMode.itemList
                            ? _buildItemPreviewTable(previewItems)
                            : _buildChildPreviewTable(),
                      ),

                      const SizedBox(height: 16),
                      if (_pageNumbers)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Page 1 of 1',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                              fontFamily: _fontFamily,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreviewTable(List<LibraryProjectionView> items) {
    final activeCols = _availableItemColumns
        .where((c) => _selectedItemColumnIds.contains(c.id))
        .toList();

    final border = switch (_borderType) {
      PdfBorderType.none => const TableBorder(),
      PdfBorderType.middle => TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade400, width: 0.5),
        ),
      PdfBorderType.outside => TableBorder.all(
          color: Colors.grey.shade400,
          width: 0.5,
        ),
      PdfBorderType.all => TableBorder.all(
          color: Colors.grey.shade400,
          width: 0.5,
        ),
    };

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: border,
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        if (_headerRow)
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              if (_coverThumbnails)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text('Cover',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              for (final col in activeCols)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    col.label,
                    style: TextStyle(
                      fontSize: _fontSize.toDouble(),
                      fontWeight: FontWeight.bold,
                      color: _fontColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ),
            ],
          ),
        for (var i = 0; i < items.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: _alternatingRows && i % 2 == 1
                  ? Colors.grey.shade100
                  : Colors.transparent,
            ),
            children: [
              if (_coverThumbnails)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    width: 28,
                    height: 28,
                    color: Colors.grey.shade300,
                    child: items[i].source.catalogSummary?.imageUrl != null &&
                            items[i]
                                .source
                                .catalogSummary!
                                .imageUrl!
                                .trim()
                                .isNotEmpty
                        ? Image.network(
                            items[i].source.catalogSummary!.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.album, size: 16),
                          )
                        : const Icon(Icons.album, size: 16),
                  ),
                ),
              for (final col in activeCols)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    col.getValue(items[i]),
                    softWrap: _wrapInsideColumn,
                    style: TextStyle(
                      fontSize: _fontSize.toDouble(),
                      color: _fontColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildChildPreviewTable() {
    final activeCols = _availableChildColumns
        .where((c) => _selectedChildColumnIds.contains(c.id))
        .toList();
    final rows = _activeChildRows.take(15).toList();

    final border = switch (_borderType) {
      PdfBorderType.none => const TableBorder(),
      PdfBorderType.middle => TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade400, width: 0.5),
        ),
      PdfBorderType.outside => TableBorder.all(
          color: Colors.grey.shade400,
          width: 0.5,
        ),
      PdfBorderType.all => TableBorder.all(
          color: Colors.grey.shade400,
          width: 0.5,
        ),
    };

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: border,
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        if (_headerRow)
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              for (final col in activeCols)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    col.label,
                    style: TextStyle(
                      fontSize: _fontSize.toDouble(),
                      fontWeight: FontWeight.bold,
                      color: _fontColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ),
            ],
          ),
        for (var i = 0; i < rows.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: _alternatingRows && i % 2 == 1
                  ? Colors.grey.shade100
                  : Colors.transparent,
            ),
            children: [
              for (final col in activeCols)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    col.getValue(rows[i]),
                    softWrap: _wrapInsideColumn,
                    style: TextStyle(
                      fontSize: _fontSize.toDouble(),
                      color: _fontColor,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: ACTIONS BAR
  // ==========================================
  Widget _buildActionsBar(AppThemePalette palette, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_generatedPdfBytes != null) ...[
          FilledButton.icon(
            key: const Key('print_pdf.download'),
            icon: const Icon(Icons.download, size: 16),
            label: Text('Download file (${_generatedFileSize ?? ""})'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF28A745),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed: _downloadPdf,
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            key: const Key('print_pdf.print'),
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Print / Open'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed: _openInSystemPrint,
          ),
          const SizedBox(width: 10),
        ],
        FilledButton.icon(
          key: const Key('print_pdf.generate'),
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf, size: 16),
          label:
              Text(_isGenerating ? 'Generating file...' : 'Generate PDF file'),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          onPressed: _isGenerating ? null : _generatePdf,
        ),
      ],
    );
  }

  // ==========================================
  // PDF GENERATION LOGIC
  // ==========================================
  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    try {
      final doc = pw.Document(
        title: _titleController.text.trim(),
        author: 'Collectarr',
      );

      final format = _orientation == PdfOrientation.landscape
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4.portrait;

      final marginEdge = pw.EdgeInsets.all(_margin.mm * PdfPageFormat.mm);
      final pdfFont = _fontFamily == 'Times New Roman'
          ? pw.Font.times()
          : (_fontFamily == 'Courier New'
              ? pw.Font.courier()
              : pw.Font.helvetica());
      final pdfBoldFont = _fontFamily == 'Times New Roman'
          ? pw.Font.timesBold()
          : (_fontFamily == 'Courier New'
              ? pw.Font.courierBold()
              : pw.Font.helveticaBold());

      final pdfColor = PdfColor.fromInt(_fontColor.toARGB32());

      final tableBorder = switch (_borderType) {
        PdfBorderType.none => const pw.TableBorder(),
        PdfBorderType.middle => pw.TableBorder.symmetric(
            inside: const pw.BorderSide(color: PdfColors.grey400, width: 0.5),
          ),
        PdfBorderType.outside => pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.5,
          ),
        PdfBorderType.all => pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.5,
          ),
      };

      if (_exportMode == ExportMode.itemList) {
        final items = _activeItems;
        final activeCols = _availableItemColumns
            .where((c) => _selectedItemColumnIds.contains(c.id))
            .toList();

        final itemsPerPage = _limitRowsPerPage ? _maxRowsPerPage : 35;
        final pages = <List<LibraryProjectionView>>[];
        for (var i = 0; i < items.length; i += itemsPerPage) {
          pages.add(items.sublist(
              i,
              i + itemsPerPage > items.length
                  ? items.length
                  : i + itemsPerPage));
        }
        if (pages.isEmpty) pages.add([]);

        for (var p = 0; p < pages.length; p++) {
          final pageItems = pages[p];
          doc.addPage(
            pw.Page(
              pageFormat: format,
              margin: marginEdge,
              build: (context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    if (p == 0 || _repeatTitleOnEveryPage) ...[
                      pw.Text(
                        _titleController.text.trim().isEmpty
                            ? 'My Collection'
                            : _titleController.text.trim(),
                        style: pw.TextStyle(
                          font: pdfBoldFont,
                          fontSize: 18,
                          color: pdfColor,
                        ),
                      ),
                      if (_printDateTime && (p == 0 || _repeatDateTime))
                        pw.Text(
                          _formattedCurrentDateTime,
                          style: pw.TextStyle(
                            font: pdfFont,
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                      pw.SizedBox(height: 10),
                    ],
                    pw.Table(
                      border: tableBorder,
                      children: [
                        if (_headerRow && (p == 0 || _repeatHeaderRow))
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.grey200),
                            children: [
                              for (final col in activeCols)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    col.label,
                                    style: pw.TextStyle(
                                      font: pdfBoldFont,
                                      fontSize: _fontSize.toDouble(),
                                      color: pdfColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        for (var i = 0; i < pageItems.length; i++)
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: _alternatingRows && i % 2 == 1
                                  ? PdfColors.grey100
                                  : PdfColors.white,
                            ),
                            children: [
                              for (final col in activeCols)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    col.getValue(pageItems[i]),
                                    style: pw.TextStyle(
                                      font: pdfFont,
                                      fontSize: _fontSize.toDouble(),
                                      color: pdfColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    pw.Spacer(),
                    if (_pageNumbers)
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Page ${p + 1} of ${pages.length}',
                          style: pw.TextStyle(
                            font: pdfFont,
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }
      } else {
        // Kind-owned child list export mode
        final rows = _activeChildRows;
        final activeCols = _availableChildColumns
            .where((c) => _selectedChildColumnIds.contains(c.id))
            .toList();

        final itemsPerPage = _limitRowsPerPage ? _maxRowsPerPage : 40;
        final pages = <List<LibraryExportChildRow>>[];
        for (var i = 0; i < rows.length; i += itemsPerPage) {
          pages.add(rows.sublist(i,
              i + itemsPerPage > rows.length ? rows.length : i + itemsPerPage));
        }
        if (pages.isEmpty) pages.add([]);

        for (var p = 0; p < pages.length; p++) {
          final pageRows = pages[p];
          doc.addPage(
            pw.Page(
              pageFormat: format,
              margin: marginEdge,
              build: (context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    if (p == 0 || _repeatTitleOnEveryPage) ...[
                      pw.Text(
                        _titleController.text.trim().isEmpty
                            ? (_exportCapability?.pdfChildTitle ??
                                'My $_childLabel')
                            : _titleController.text.trim(),
                        style: pw.TextStyle(
                          font: pdfBoldFont,
                          fontSize: 18,
                          color: pdfColor,
                        ),
                      ),
                      if (_printDateTime && (p == 0 || _repeatDateTime))
                        pw.Text(
                          _formattedCurrentDateTime,
                          style: pw.TextStyle(
                            font: pdfFont,
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                      pw.SizedBox(height: 10),
                    ],
                    pw.Table(
                      border: tableBorder,
                      children: [
                        if (_headerRow && (p == 0 || _repeatHeaderRow))
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.grey200),
                            children: [
                              for (final col in activeCols)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    col.label,
                                    style: pw.TextStyle(
                                      font: pdfBoldFont,
                                      fontSize: _fontSize.toDouble(),
                                      color: pdfColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        for (var i = 0; i < pageRows.length; i++)
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: _alternatingRows && i % 2 == 1
                                  ? PdfColors.grey100
                                  : PdfColors.white,
                            ),
                            children: [
                              for (final col in activeCols)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    col.getValue(pageRows[i]),
                                    style: pw.TextStyle(
                                      font: pdfFont,
                                      fontSize: _fontSize.toDouble(),
                                      color: pdfColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    pw.Spacer(),
                    if (_pageNumbers)
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Page ${p + 1} of ${pages.length}',
                          style: pw.TextStyle(
                            font: pdfFont,
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }
      }

      final bytes = await doc.save();
      final sizeKb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);
      setState(() {
        _generatedPdfBytes = bytes;
        _generatedFileSize = '$sizeKb KB';
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    final bytes = _generatedPdfBytes;
    if (bytes == null) return;
    final filename =
        '${_titleController.text.trim().replaceAll(RegExp(r"[^\w\s-]"), "")}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  Future<void> _openInSystemPrint() async {
    final bytes = _generatedPdfBytes;
    if (bytes == null) return;
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: _titleController.text.trim(),
    );
  }

  // ==========================================
  // MANAGE DIALOGS
  // ==========================================
  Future<void> _showManageColumnsDialog() async {
    final isChild = _exportMode == ExportMode.childList;
    final availableCols = isChild
        ? _availableChildColumns.map((c) => (id: c.id, label: c.label)).toList()
        : _availableItemColumns.map((c) => (id: c.id, label: c.label)).toList();

    var currentSelected = List<String>.from(
      isChild ? _selectedChildColumnIds : _selectedItemColumnIds,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Manage Columns'),
            content: SizedBox(
              width: 320,
              height: 380,
              child: ListView(
                children: [
                  for (final col in availableCols)
                    CheckboxListTile(
                      dense: true,
                      title: Text(col.label),
                      value: currentSelected.contains(col.id),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            currentSelected.add(col.id);
                          } else {
                            currentSelected.remove(col.id);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    if (isChild) {
                      _selectedChildColumnIds = currentSelected;
                    } else {
                      _selectedItemColumnIds = currentSelected;
                    }
                  });
                  Navigator.of(dialogCtx).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showManageSortDialog() async {
    var chosenColId = _sortColumnId;
    var chosenAsc = _sortAscending;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Manage Sort Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sort by:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: chosenColId,
                  items: _availableItemColumns
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => chosenColId = v ?? chosenColId),
                ),
                const SizedBox(height: 12),
                const Text('Direction:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                RadioGroup<bool>(
                  groupValue: chosenAsc,
                  onChanged: (v) {
                    if (v != null) setDialogState(() => chosenAsc = v);
                  },
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setDialogState(() => chosenAsc = true),
                        child: const Row(
                          children: [
                            Radio<bool>(value: true),
                            Text('Ascending (A-Z, 0-9)'),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setDialogState(() => chosenAsc = false),
                        child: const Row(
                          children: [
                            Radio<bool>(value: false),
                            Text('Descending (Z-A, 9-0)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _sortColumnId = chosenColId;
                    _sortAscending = chosenAsc;
                  });
                  Navigator.of(dialogCtx).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BorderOptionPainter extends CustomPainter {
  const _BorderOptionPainter(this.type);
  final PdfBorderType type;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    switch (type) {
      case PdfBorderType.none:
        break;
      case PdfBorderType.middle:
        canvas.drawLine(Offset(0, size.height / 2),
            Offset(size.width, size.height / 2), paint);
        break;
      case PdfBorderType.outside:
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        break;
      case PdfBorderType.all:
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        canvas.drawLine(Offset(0, size.height / 2),
            Offset(size.width, size.height / 2), paint);
        canvas.drawLine(Offset(size.width / 2, 0),
            Offset(size.width / 2, size.height), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
