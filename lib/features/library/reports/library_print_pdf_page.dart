import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'library_report_generator.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/reports/library_report_field_dialogs.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'dart:typed_data';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_block_button.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:printing/printing.dart';

enum PrintSubset { all, currentList, checkboxed }

enum ExportMode { itemList, childList }

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
    this.metadata,
    this.widthFlex = 1.0,
    this.defaultVisible = true,
  });

  final LibraryKindFieldMetadata? metadata;
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
        metadata: column.metadata,
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

/// Print configuration and live document preview.
class LibraryPrintPdfPage extends StatefulWidget {
  const LibraryPrintPdfPage({
    super.key,
    required this.type,
    required this.items,
    this.allItems,
    this.selectedItemIds,
    this.allShelfEntries,
    this.initialTitle,
    this.generator = const LibraryReportGenerator(),
  });

  final LibraryKindRegistration type;
  final List<LibraryProjectionView> items;
  final List<LibraryProjectionView>? allItems;
  final Set<String>? selectedItemIds;
  final List<LibraryWorkspaceContext>? allShelfEntries;
  final String? initialTitle;
  final LibraryReportGenerator generator;

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
    final accent = appPalette(context).utilityAction;
    final basePalette = appPalette(context);
    final palette = basePalette.isDark
        ? basePalette.copyWith(
            field: const Color(0xFF444444),
            divider: const Color(0xFF666666),
            surface: const Color(0xFF262626),
            panel: const Color(0xFF383838))
        : basePalette;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppPageHeader(
          icon: AppIcons.print,
          leading: AppPageBackButton(
              key: const Key('print_pdf.back'),
              onPressed: () => Navigator.of(context).pop()),
          title: const Text('Print to PDF')),
      body: Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context).colorScheme.copyWith(primary: accent),
            radioTheme: RadioThemeData(
                fillColor: WidgetStatePropertyAll(palette.textPrimary)),
            checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStatePropertyAll(palette.textPrimary),
                checkColor: WidgetStatePropertyAll(palette.panel),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
          child: AppManagementContent(
              maxWidth: 960,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Pane: Which items + optional child mode + Columns + Sort
                        _buildTopSelectionPane(palette),
                        const SizedBox(height: 16),

                        // 2. Pane: Page Setup
                        _buildPageSetupPane(palette),
                        const SizedBox(height: 16),

                        // 3. Pane: Preview
                        _buildPreviewPane(palette, accent),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }

  // ==========================================
  // SECTION 1: TOP SELECTION & MODES
  // ==========================================
  TextStyle _heading(AppThemePalette palette) => TextStyle(
      fontFamily: appFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: palette.textPrimary);

  ButtonStyle _manageButtonStyle(AppThemePalette palette) =>
      OutlinedButton.styleFrom(
        backgroundColor:
            palette.isDark ? const Color(0xFF494949) : palette.field,
        foregroundColor: palette.textPrimary,
        side: BorderSide.none,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: TextStyle(
            fontFamily: appFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget _buildTopSelectionPane(AppThemePalette palette) => Container(
        padding: const EdgeInsets.all(10),
        color: palette.panel,
        child: LayoutBuilder(builder: (context, constraints) {
          final selection =
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _buildSubsetSection(palette)),
            if (_supportsChildList) ...[
              const SizedBox(width: 30),
              Expanded(child: _buildExportModeSection(palette)),
            ],
          ]);
          final fields =
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildColumnsSection(palette),
            const SizedBox(height: 16),
            _buildSortSection(palette),
          ]);
          return constraints.maxWidth >= 720
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: selection)),
                  const SizedBox(width: 15),
                  Expanded(child: fields),
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      selection,
                      const SizedBox(height: 16),
                      fields,
                    ]);
        }),
      );

  Widget _choiceBox(AppThemePalette palette, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(
                color:
                    palette.isDark ? const Color(0xFF262626) : palette.divider),
            borderRadius: BorderRadius.circular(3)),
        child: Column(children: children),
      );

  Widget _buildSubsetSection(AppThemePalette palette) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Which $_itemLabel', style: _heading(palette)),
          const SizedBox(height: 16),
          _choiceBox(palette, [
            _buildRadioRow(
                title: 'All $_itemLabel',
                count: _allList.length,
                selected: _subset == PrintSubset.all,
                onTap: () => setState(() => _subset = PrintSubset.all),
                palette: palette),
            _buildRadioRow(
                title: 'Current List',
                count: widget.items.length,
                selected: _subset == PrintSubset.currentList,
                onTap: () => setState(() => _subset = PrintSubset.currentList),
                palette: palette),
            _buildRadioRow(
                title: 'Checkboxed',
                count: _checkboxedList.length,
                selected: _subset == PrintSubset.checkboxed,
                disabled: _checkboxedList.isEmpty,
                onTap: () => setState(() => _subset = PrintSubset.checkboxed),
                palette: palette),
          ]),
        ],
      );

  Widget _buildExportModeSection(AppThemePalette palette) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Export mode', style: _heading(palette)),
          const SizedBox(height: 16),
          _choiceBox(palette, [
            _buildRadioRow(
                title: _exportCapability!.itemModeLabel,
                count: widget.items.length,
                selected: _exportMode == ExportMode.itemList,
                onTap: () => setState(() => _exportMode = ExportMode.itemList),
                palette: palette),
            _buildRadioRow(
                title: _exportCapability!.childModeLabel ?? '$_childLabel list',
                count: _totalChildCount,
                selected: _exportMode == ExportMode.childList,
                onTap: () => setState(() => _exportMode = ExportMode.childList),
                palette: palette),
          ]),
        ],
      );

  Widget _summarySection(AppThemePalette palette, String title,
          VoidCallback onManage, Widget child) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(title, style: _heading(palette))),
            OutlinedButton(
                onPressed: onManage,
                style: _manageButtonStyle(palette),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Manage'),
                  SizedBox(width: 6),
                  Icon(AppIcons.more, size: 14),
                ])),
          ]),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: palette.field,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: palette.divider)),
            child: child,
          ),
        ],
      );

  Widget _buildColumnsSection(AppThemePalette palette) {
    final labels = _exportMode == ExportMode.itemList
        ? [
            for (final id in _selectedItemColumnIds)
              _availableItemColumns.firstWhere((c) => c.id == id).label
          ]
        : [
            for (final id in _selectedChildColumnIds)
              _availableChildColumns.firstWhere((c) => c.id == id).label
          ];
    return _summarySection(
        palette,
        'Visible Columns',
        _showManageColumnsDialog,
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Active columns (${labels.length})',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary)),
          Text(labels.isEmpty ? 'None' : labels.join(', '),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: palette.textPrimary)),
        ]));
  }

  Widget _buildSortSection(AppThemePalette palette) {
    final label = _availableItemColumns
        .firstWhere((c) => c.id == _sortColumnId,
            orElse: () => _availableItemColumns.first)
        .label;
    return _summarySection(
        palette,
        'Sort Order',
        _showManageSortDialog,
        Row(children: [
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary))),
          Icon(
              _sortAscending ? AppIcons.sortAscending : AppIcons.sortDescending,
              size: 18,
              color: palette.textPrimary),
        ]));
  }

  Widget _buildRadioRow(
          {required String title,
          required int count,
          required bool selected,
          required VoidCallback onTap,
          required AppThemePalette palette,
          bool disabled = false}) =>
      Semantics(
          checked: selected,
          enabled: !disabled,
          child: InkWell(
            onTap: disabled ? null : onTap,
            mouseCursor:
                disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: Container(
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                    color: selected
                        ? (palette.isDark
                            ? const Color(0xFF464950)
                            : palette.highlight)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        selected ? Border.all(color: palette.divider) : null),
                child: Row(children: [
                  Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 13,
                      color:
                          disabled ? palette.textMuted : palette.textPrimary),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: disabled
                                  ? palette.textMuted
                                  : palette.textPrimary))),
                  const SizedBox(width: 4),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: selected || disabled
                              ? palette.textMuted.withValues(alpha: .4)
                              : palette.textPrimary,
                          borderRadius: BorderRadius.circular(3)),
                      child: Text('$count',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: selected || disabled
                                  ? palette.textPrimary
                                  : palette.panel))),
                ])),
          ));

  // ==========================================
  // SECTION 2: PAGE SETUP
  // ==========================================
  Widget _buildPageSetupPane(AppThemePalette palette) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.panel,
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
              OutlinedButton.icon(
                style: _manageButtonStyle(palette),
                iconAlignment: IconAlignment.end,
                icon: const Icon(AppIcons.more, size: 14),
                label: Text(
                  _showMoreSettings ? 'Less settings' : 'More settings',
                  style: const TextStyle(fontSize: 14),
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: palette.textPrimary)),
        const SizedBox(height: 6),
        RadioGroup<PdfOrientation>(
          groupValue: _orientation,
          onChanged: (v) {
            if (v != null) setState(() => _orientation = v);
          },
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _orientation = PdfOrientation.portrait),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<PdfOrientation>(value: PdfOrientation.portrait),
                    Text('Portrait',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              InkWell(
                onTap: () =>
                    setState(() => _orientation = PdfOrientation.landscape),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<PdfOrientation>(value: PdfOrientation.landscape),
                    Text('Landscape',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: palette.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          style: const TextStyle(fontSize: 14),
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
                    Text('Wrap inside column', style: TextStyle(fontSize: 14)),
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
                child: Text('Cover thumbnails', style: TextStyle(fontSize: 14)),
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: palette.textPrimary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<PdfMarginSetting>(
          style: Theme.of(context).textTheme.controlText,
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: palette.textPrimary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          style: Theme.of(context).textTheme.controlText,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: palette.textPrimary)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<int>(
                    style: Theme.of(context).textTheme.controlText,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
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
            const Text('Max rows per page:', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            SizedBox(
              width: 44,
              height: 28,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
                  style: const TextStyle(fontSize: 14),
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
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.panel,
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
              color: palette.surface,
              borderRadius: BorderRadius.circular(3),
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
          const SizedBox(height: 16),
          _buildActionsBar(palette, accent),
        ],
      ),
    );
  }

  Widget _buildItemPreviewTable(List<LibraryProjectionView> items) {
    final activeCols = [
      for (final id in _selectedItemColumnIds)
        _availableItemColumns.firstWhere((column) => column.id == id)
    ];

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
    final activeCols = [
      for (final id in _selectedChildColumnIds)
        _availableChildColumns.firstWhere((column) => column.id == id)
    ];
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
    return LayoutBuilder(
        builder: (context, constraints) => Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
                width: constraints.maxWidth >= 600
                    ? (constraints.maxWidth - 30) / 2
                    : constraints.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppBlockButton(
                      key: const Key('print_pdf.generate'),
                      label: _isGenerating
                          ? 'Generating file...'
                          : 'Generate PDF file',
                      icon: _isGenerating ? AppBlockButtonIcon.spinner : null,
                      color: accent,
                      onPressed: _isGenerating ? null : _generatePdf,
                    ),
                    if (_generatedPdfBytes != null) ...[
                      const SizedBox(height: 20),
                      AppBlockButton(
                        key: const Key('print_pdf.download'),
                        label: 'Download file (${_generatedFileSize ?? ""})',
                        icon: AppBlockButtonIcon.download,
                        color: kAppSuccessGreen,
                        onPressed: _downloadPdf,
                      ),
                    ],
                  ],
                ))));
  }

  // ==========================================
  // PDF GENERATION LOGIC
  // ==========================================
  LibraryPdfReport _capturePdfReport() {
    final child = _exportMode == ExportMode.childList;
    final List<String> headers;
    final List<List<String>> rows;
    if (child) {
      final columns = [
        for (final id in _selectedChildColumnIds)
          _availableChildColumns.firstWhere((column) => column.id == id)
      ];
      headers = [for (final column in columns) column.label];
      rows = [
        for (final row in _activeChildRows)
          [for (final column in columns) column.getValue(row)]
      ];
    } else {
      final columns = [
        for (final id in _selectedItemColumnIds)
          _availableItemColumns.firstWhere((column) => column.id == id)
      ];
      headers = [for (final column in columns) column.label];
      rows = [
        for (final row in _activeItems)
          [for (final column in columns) column.getValue(row)]
      ];
    }
    return LibraryPdfReport(
        title: _titleController.text.trim(),
        emptyTitle: child
            ? (_exportCapability?.pdfChildTitle ?? 'My $_childLabel')
            : 'My Collection',
        headers: headers,
        rows: rows,
        orientation: _orientation,
        marginMm: _margin.mm,
        fontFamily: _fontFamily,
        fontSize: _fontSize,
        fontColor: _fontColor.toARGB32(),
        rowsPerPage: _limitRowsPerPage ? _maxRowsPerPage : (child ? 40 : 35),
        repeatTitle: _repeatTitleOnEveryPage,
        dateTime: _printDateTime ? _formattedCurrentDateTime : null,
        repeatDateTime: _repeatDateTime,
        headerRow: _headerRow,
        repeatHeaderRow: _repeatHeaderRow,
        alternatingRows: _alternatingRows,
        pageNumbers: _pageNumbers,
        borderType: _borderType);
  }

  Future<void> _generatePdf() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final report = _capturePdfReport();
      final generator = widget.generator;
      final bytes = await runWithProgressDialog(
          context: context,
          title: 'Print to PDF',
          message: 'Generating your PDF file...',
          task: () => generator.pdf(report));
      if (!mounted) return;
      final sizeKb = (bytes.lengthInBytes / 1024).toStringAsFixed(1);
      setState(() {
        _generatedPdfBytes = bytes;
        _generatedFileSize = '$sizeKb KB';
      });
    } catch (error, stack) {
      logRecoverableError(
          source: 'reports',
          message: 'PDF generation failed',
          error: error,
          stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate PDF: $error')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _downloadPdf() async {
    final bytes = _generatedPdfBytes;
    if (bytes == null) return;
    final filename =
        '${_titleController.text.trim().replaceAll(RegExp(r"[^\w\s-]"), "")}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ==========================================
  // MANAGE DIALOGS
  // ==========================================
  Future<void> _showManageColumnsDialog() async {
    final isChild = _exportMode == ExportMode.childList;
    final columns = isChild
        ? [for (final c in _availableChildColumns) (id: c.id, label: c.label)]
        : [for (final c in _availableItemColumns) (id: c.id, label: c.label)];
    final result = await showLibraryReportColumns(context,
        fields: columns,
        selected: isChild ? _selectedChildColumnIds : _selectedItemColumnIds);
    if (!mounted || result == null) return;
    setState(() {
      if (isChild) {
        _selectedChildColumnIds = result.toList();
      } else {
        _selectedItemColumnIds = result.toList();
      }
      _generatedPdfBytes = null;
    });
  }

  Future<void> _showManageSortDialog() async {
    final result = await showLibraryReportSorts(context,
        fields: [
          for (final column in _availableItemColumns
              .where((column) => column.metadata?.sortable != false))
            (id: column.id, label: column.label)
        ],
        selected: [(id: _sortColumnId, ascending: _sortAscending)],
        multiple: false);
    if (!mounted || result == null) return;
    setState(() {
      _sortColumnId = result.first.id;
      _sortAscending = result.first.ascending;
      _generatedPdfBytes = null;
    });
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
