import 'package:collectarr_app/features/library/reports/library_report_field_dialogs.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'dart:convert';
import 'package:collectarr_app/core/platform/save_export_file.dart';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/ui/app_block_button.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';

enum ExportSubset { all, currentList, checkboxed }

enum ExportMode { itemList, childList }

enum ExportFileType { csv, txt }

enum FieldDelimiter {
  semicolon('Semicolon', ';'),
  comma('Comma', ','),
  tab('Tab', '\t'),
  space('Space', ' ');

  const FieldDelimiter(this.label, this.char);
  final String label;
  final String char;
}

enum FieldEnclosure {
  doubleQuote('Double Quote', '"'),
  singleQuote('Single Quote', "'"),
  none('None', '');

  const FieldEnclosure(this.label, this.char);
  final String label;
  final String char;
}

/// Full-page Export to CSV / TXT view matching the CLZ Web layout 1:1.
class LibraryExportCsvTxtPage extends StatefulWidget {
  const LibraryExportCsvTxtPage({
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
  State<LibraryExportCsvTxtPage> createState() =>
      _LibraryExportCsvTxtPageState();
}

class _LibraryExportCsvTxtPageState extends State<LibraryExportCsvTxtPage> {
  ExportSubset _subset = ExportSubset.all;
  ExportMode _exportMode = ExportMode.itemList;
  ExportFileType _fileType = ExportFileType.csv;
  FieldDelimiter _delimiter = FieldDelimiter.comma;
  FieldEnclosure _enclosure = FieldEnclosure.doubleQuote;
  bool _includeHeaderRow = true;

  late final TextEditingController _filenameController;

  late List<ExportColumnDefinition> _availableAlbumColumns;
  late List<String> _selectedAlbumColumnIds;

  late List<LibraryExportChildColumnDefinition> _availableChildColumns;
  late List<String> _selectedChildColumnIds;

  List<({String id, bool ascending})> _sortFields = const [];

  bool _isGenerating = false;
  String? _generatedContent;
  String? _generatedFileSize;

  LibraryExportCapability? get _exportCapability =>
      libraryExportCapabilityForKind(widget.type.kind);

  bool get _supportsChildList => _exportCapability?.supportsChildList ?? false;

  String get _itemListLabel =>
      _exportCapability?.itemLabel ?? widget.type.identity.pluralLabel;

  String get _itemModeLabel =>
      _exportCapability?.itemModeLabel ?? widget.type.identity.pluralLabel;

  String get _activeListLabel =>
      _supportsChildList && _exportMode == ExportMode.childList
          ? _exportCapability!.childLabel!
          : _itemListLabel;

  @override
  void initState() {
    super.initState();
    if (widget.selectedItemIds != null && widget.selectedItemIds!.isNotEmpty) {
      _subset = ExportSubset.checkboxed;
    }
    _filenameController = TextEditingController(
      text: _exportCapability?.itemFileName ??
          'export_${widget.type.identity.pluralLabel.toLowerCase()}',
    );
    _initColumns();
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  void _initColumns() {
    final capability = _exportCapability;
    _availableAlbumColumns = capability?.itemColumns ??
        [
          ExportColumnDefinition(
            id: 'title',
            label: 'Title',
            getValue: (item) => item.dto.primaryLabel,
          ),
          ExportColumnDefinition(
            id: 'secondary',
            label: 'Creator / Series',
            getValue: (item) => item.dto.secondaryLabel ?? '',
          ),
          ExportColumnDefinition(
            id: 'format',
            label: 'Format',
            getValue: (item) => item.source.catalogSummary?.subtitle ?? '',
          ),
          ExportColumnDefinition(
            id: 'status',
            label: 'Status',
            getValue: (item) => item.source.trackingStatusLabel,
          ),
          ExportColumnDefinition(
            id: 'added_date',
            label: 'Added Date',
            getValue: (item) {
              final date = item.source.addedAt;
              if (date == null) return '';
              return '${_monthAbbr(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
            },
          ),
          ExportColumnDefinition(
            id: 'location',
            label: 'Location',
            getValue: (item) => item.source.locationPath ?? '',
            defaultVisible: false,
          ),
          ExportColumnDefinition(
            id: 'price_paid',
            label: 'Price Paid',
            getValue: (item) => item.source.pricePaidCents != null
                ? formatMoney(item.source.pricePaidCents, item.source.currency)
                : '',
            defaultVisible: false,
          ),
          ExportColumnDefinition(
            id: 'value',
            label: 'Value',
            getValue: (item) => item.source.marketValueCents != null
                ? formatMoney(
                    item.source.marketValueCents, item.source.currency)
                : '',
            defaultVisible: false,
          ),
        ];
    _selectedAlbumColumnIds = _availableAlbumColumns
        .where((column) => column.defaultVisible)
        .map((column) => column.id)
        .toList();

    _availableChildColumns = capability?.childColumns ?? const [];
    _selectedChildColumnIds = _availableChildColumns
        .where((column) => column.defaultVisible)
        .map((column) => column.id)
        .toList();
    _sortFields = [
      (id: capability?.defaultSortColumnId ?? 'title', ascending: true)
    ];
  }

  static String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  List<LibraryProjectionView> get _allList => widget.allItems ?? widget.items;

  List<LibraryProjectionView> get _checkboxedList {
    final ids = widget.selectedItemIds;
    if (ids == null || ids.isEmpty) return const [];
    return _allList.where((item) => ids.contains(item.target.id)).toList();
  }

  List<LibraryProjectionView> get _activeItems {
    final list = switch (_subset) {
      ExportSubset.all => _allList,
      ExportSubset.currentList => widget.items,
      ExportSubset.checkboxed => _checkboxedList,
    };

    final sorted = List<LibraryProjectionView>.from(list);
    final sorts = [
      for (final rule in _sortFields)
        (
          column: _availableAlbumColumns
              .firstWhere((column) => column.id == rule.id),
          ascending: rule.ascending
        )
    ];
    final positions = {for (var i = 0; i < sorted.length; i++) sorted[i]: i};
    sorted.sort((a, b) {
      for (final rule in sorts) {
        final cmp = rule.column
            .getValue(a)
            .toLowerCase()
            .compareTo(rule.column.getValue(b).toLowerCase());
        if (cmp != 0) return rule.ascending ? cmp : -cmp;
      }
      return positions[a]!.compareTo(positions[b]!);
    });
    return sorted;
  }

  List<LibraryExportChildRow> get _activeChildRows =>
      _exportCapability?.childRowsFor(_activeItems) ?? const [];

  void _onFileTypeChanged(ExportFileType type) {
    setState(() {
      _fileType = type;
      if (type == ExportFileType.csv) {
        _delimiter = FieldDelimiter.comma;
        _enclosure = FieldEnclosure.doubleQuote;
      } else {
        _delimiter = FieldDelimiter.tab;
        _enclosure = FieldEnclosure.none;
      }
      _invalidateGenerated();
    });
  }

  void _invalidateGenerated() {
    _generatedContent = null;
    _generatedFileSize = null;
  }

  String _formatCell(String value) {
    final delim = _delimiter.char;
    final enc = _enclosure.char;

    if (enc.isEmpty) {
      return value.replaceAll(delim, ' ').replaceAll('\n', ' ');
    }

    final needsQuote = value.contains(delim) ||
        value.contains(enc) ||
        value.contains('\n') ||
        value.contains('\r') ||
        _enclosure == FieldEnclosure.doubleQuote;

    if (needsQuote) {
      final escaped = value.replaceAll(enc, '$enc$enc');
      return '$enc$escaped$enc';
    }

    return value;
  }

  String _generateRowString(List<String> cells) {
    return cells.map(_formatCell).join(_delimiter.char);
  }

  List<String> _buildPreviewLines({int limit = 30}) {
    final lines = <String>[];
    final isChildList =
        _supportsChildList && _exportMode == ExportMode.childList;

    if (isChildList) {
      final activeColumns = [
        for (final id in _selectedChildColumnIds)
          _availableChildColumns.firstWhere((col) => col.id == id)
      ];

      if (_includeHeaderRow) {
        lines.add(
            _generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      final tracks = _activeChildRows;
      final previewCount = tracks.length > limit ? limit : tracks.length;
      for (var i = 0; i < previewCount; i++) {
        final pair = tracks[i];
        final cells = activeColumns.map((col) => col.getValue(pair)).toList();
        lines.add(_generateRowString(cells));
      }
    } else {
      final activeColumns = [
        for (final id in _selectedAlbumColumnIds)
          _availableAlbumColumns.firstWhere((col) => col.id == id)
      ];

      if (_includeHeaderRow) {
        lines.add(
            _generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      final items = _activeItems;
      final previewCount = items.length > limit ? limit : items.length;
      for (var i = 0; i < previewCount; i++) {
        final item = items[i];
        final cells = activeColumns.map((col) => col.getValue(item)).toList();
        lines.add(_generateRowString(cells));
      }
    }

    return lines;
  }

  String _generateFullExportContent() {
    final buffer = StringBuffer();
    final isChildList =
        _supportsChildList && _exportMode == ExportMode.childList;

    if (isChildList) {
      final activeColumns = [
        for (final id in _selectedChildColumnIds)
          _availableChildColumns.firstWhere((col) => col.id == id)
      ];

      if (_includeHeaderRow) {
        buffer.writeln(
            _generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      for (final pair in _activeChildRows) {
        final cells = activeColumns.map((col) => col.getValue(pair)).toList();
        buffer.writeln(_generateRowString(cells));
      }
    } else {
      final activeColumns = [
        for (final id in _selectedAlbumColumnIds)
          _availableAlbumColumns.firstWhere((col) => col.id == id)
      ];

      if (_includeHeaderRow) {
        buffer.writeln(
            _generateRowString(activeColumns.map((c) => c.label).toList()));
      }

      for (final item in _activeItems) {
        final cells = activeColumns.map((col) => col.getValue(item)).toList();
        buffer.writeln(_generateRowString(cells));
      }
    }

    return buffer.toString();
  }

  Future<void> _handleGenerate() async {
    setState(() => _isGenerating = true);
    final type = _fileType == ExportFileType.csv ? 'CSV' : 'TXT';
    final content = await runWithProgressDialog(
        context: context,
        title: 'Export to $type',
        message: 'Generating your $type file...',
        task: () async => _generateFullExportContent());
    if (!mounted) return;
    final kb = utf8.encode(content).length / 1024;
    final sizeStr = kb >= 1024
        ? '${(kb / 1024).toStringAsFixed(1)} MB'
        : '${kb.toStringAsFixed(1)} KB';

    setState(() {
      _generatedContent = content;
      _generatedFileSize = sizeStr;
      _isGenerating = false;
    });
  }

  Future<void> _handleDownload() async {
    if (_generatedContent == null) return;
    final ext = _fileType == ExportFileType.csv ? 'csv' : 'txt';
    final rawBase = _filenameController.text.trim();
    final base = rawBase.isEmpty ? 'export' : rawBase;
    final suggestedName = '$base.$ext';

    try {
      final saved = await saveExportText(
          filename: suggestedName,
          content: _generatedContent!,
          mimeType: ext == 'csv' ? 'text/csv' : 'text/plain');
      if (!saved) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved $suggestedName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  void _handleCopyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedContent!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export content copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = appPalette(context).utilityAction;
    final basePalette = appPalette(context);
    final palette = basePalette.isDark
        ? basePalette.copyWith(
            surface: const Color(0xff444444),
            field: const Color(0xff444444),
            divider: const Color(0xff666666),
            cardBorder: const Color(0xff262626),
          )
        : basePalette;

    final itemLabel = _activeListLabel;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppPageHeader(
          icon: Icons.file_download_outlined,
          leading: AppPageBackButton(
              key: const Key('export_csv_txt.back'),
              onPressed: () => Navigator.of(context).pop()),
          title: const Text('Export to CSV / TXT')),
      body: AppManagementContent(
          maxWidth: 992,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Page Title
                    Text(
                      'Export ${widget.type.identity.title.toLowerCase()} to CSV / TXT: $itemLabel',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top Options Pane
                    _buildTopOptionsPane(palette, accent),
                    const SizedBox(height: 20),

                    // Filetype Tabs
                    _buildFiletypeTabs(palette, accent),

                    // 1. Settings Pane
                    ColoredBox(
                        color: palette.panel,
                        child: Column(children: [
                          _buildSettingsPane(palette, accent),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: _buildPreviewPane(palette, accent)),
                        ])),
                    const SizedBox(height: 20),

                    // Bottom Action Button
                    _buildBottomActions(palette, accent),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // ==========================================
  // SECTION: TOP OPTIONS PANE
  // ==========================================
  Widget _buildTopOptionsPane(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.panel,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSubsetSection(palette, accent)),
                      if (_supportsChildList) ...[
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildExportModeSection(palette, accent)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildVisibleColumnsSection(palette, accent),
                      const SizedBox(height: 16),
                      _buildSortOrderSection(palette, accent),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSubsetSection(palette, accent),
              if (_supportsChildList) ...[
                const SizedBox(height: 16),
                _buildExportModeSection(palette, accent),
              ],
              const SizedBox(height: 16),
              _buildVisibleColumnsSection(palette, accent),
              const SizedBox(height: 16),
              _buildSortOrderSection(palette, accent),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubsetSection(AppThemePalette palette, Color accent) {
    final allCount = _allList.length;
    final currentCount = widget.items.length;
    final checkboxedCount = _checkboxedList.length;
    final allIds = _allList.map((item) => item.target.id).toSet();
    final sameAsAll = currentCount == allCount &&
        widget.items.every((item) => allIds.contains(item.target.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Which $_itemListLabel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'All $_itemListLabel',
                count: allCount,
                selected: _subset == ExportSubset.all,
                enabled: true,
                onTap: () {
                  setState(() {
                    _subset = ExportSubset.all;
                    _invalidateGenerated();
                  });
                },
              ),
              Divider(height: 1, color: palette.cardBorder),
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'Current List',
                count: currentCount,
                selected: _subset == ExportSubset.currentList,
                enabled: currentCount > 0 && !sameAsAll,
                onTap: () {
                  setState(() {
                    _subset = ExportSubset.currentList;
                    _invalidateGenerated();
                  });
                },
              ),
              Divider(height: 1, color: palette.cardBorder),
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: 'Checkboxed',
                count: checkboxedCount,
                selected: _subset == ExportSubset.checkboxed,
                enabled: checkboxedCount > 0,
                onTap: () {
                  setState(() {
                    _subset = ExportSubset.checkboxed;
                    _invalidateGenerated();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportModeSection(AppThemePalette palette, Color accent) {
    final albumCount = _activeItems.length;
    final childCount = _activeChildRows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Export mode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panelRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            children: [
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: _itemModeLabel,
                count: albumCount,
                selected: _exportMode == ExportMode.itemList,
                enabled: true,
                onTap: () {
                  setState(() {
                    _exportMode = ExportMode.itemList;
                    _filenameController.text = _exportCapability!.itemFileName;
                    _invalidateGenerated();
                  });
                },
              ),
              Divider(height: 1, color: palette.cardBorder),
              _buildRadioOption(
                palette: palette,
                accent: accent,
                title: _exportCapability!.childModeLabel ??
                    '${_exportCapability!.childLabel} list',
                count: childCount,
                selected: _exportMode == ExportMode.childList,
                enabled: true,
                onTap: () {
                  setState(() {
                    _exportMode = ExportMode.childList;
                    _filenameController.text =
                        _exportCapability!.childFileName!;
                    _invalidateGenerated();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required AppThemePalette palette,
    required Color accent,
    required String title,
    required int count,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final textColor = enabled
        ? (selected ? Colors.white : palette.textPrimary)
        : palette.textMuted;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? palette.surfaceBright : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? palette.divider : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: enabled
                  ? palette.textPrimary
                  : palette.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    selected ? const Color(0xff888888) : palette.surfaceBright,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : palette.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibleColumnsSection(AppThemePalette palette, Color accent) {
    final isChildList =
        _supportsChildList && _exportMode == ExportMode.childList;
    final columnNames = (isChildList
            ? [
                for (final id in _selectedChildColumnIds)
                  _availableChildColumns
                      .firstWhere((column) => column.id == id)
                      .label
              ]
            : [
                for (final id in _selectedAlbumColumnIds)
                  _availableAlbumColumns
                      .firstWhere((column) => column.id == id)
                      .label
              ])
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visible Columns',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: palette.textPrimary,
                backgroundColor: palette.isDark
                    ? const Color(0xff494949)
                    : palette.surfaceBright,
                side: BorderSide.none,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () => _showManageColumnsDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Manage', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.more_vert, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My List View columns',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                columnNames.isEmpty ? 'No columns selected' : columnNames,
                style: TextStyle(
                  fontSize: 12,
                  color: palette.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOrderSection(AppThemePalette palette, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sort Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: palette.textPrimary,
                backgroundColor: palette.isDark
                    ? const Color(0xff494949)
                    : palette.surfaceBright,
                side: BorderSide.none,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () => _showManageSortDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Manage', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.more_vert, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.divider),
          ),
          child: Wrap(spacing: 8, runSpacing: 4, children: [
            for (final rule in _sortFields)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                    _availableAlbumColumns
                        .firstWhere((column) => column.id == rule.id)
                        .label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 3),
                DecoratedBox(
                    decoration: BoxDecoration(
                        color: palette.textPrimary,
                        borderRadius: BorderRadius.circular(3)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        child: Text(rule.ascending ? 'ASC' : 'DESC',
                            style: TextStyle(
                                color: palette.panel, fontSize: 10)))),
              ]),
          ]),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION: FILETYPE TABS (CSV / TXT)
  // ==========================================
  Widget _buildFiletypeTabs(AppThemePalette palette, Color accent) =>
      LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(children: [
            for (final type in ExportFileType.values) ...[
              SizedBox(
                width: (constraints.maxWidth - 20) / 4,
                height: 34,
                child: Material(
                  color: type == _fileType
                      ? palette.panel
                      : (palette.isDark
                          ? const Color(0xff131313)
                          : palette.surfaceSubtle),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  child: InkWell(
                    onTap: () => _onFileTypeChanged(type),
                    mouseCursor: SystemMouseCursors.click,
                    child: Center(
                        child: Text(type.name.toUpperCase(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: palette.textPrimary))),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ]
          ]),
        ),
      );

  // ==========================================
  // SECTION: 1. SETTINGS PANE
  // ==========================================
  Widget _buildSettingsPane(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.panel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '1. Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDelimiterCard(palette, accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildEnclosureCard(palette, accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _buildOptionsCard(palette, accent),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildDelimiterCard(palette, accent),
                  const SizedBox(height: 16),
                  _buildEnclosureCard(palette, accent),
                  const SizedBox(height: 16),
                  _buildOptionsCard(palette, accent),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDelimiterCard(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Field Delimiter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final d in FieldDelimiter.values)
            _buildRadioRow(
              palette: palette,
              accent: accent,
              label: d.label,
              tag: d == FieldDelimiter.semicolon
                  ? ';'
                  : (d == FieldDelimiter.comma ? ',' : null),
              selected: _delimiter == d,
              onTap: () {
                setState(() {
                  _delimiter = d;
                  _invalidateGenerated();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEnclosureCard(AppThemePalette palette, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Field Enclosure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final e in FieldEnclosure.values)
            _buildRadioRow(
              palette: palette,
              accent: accent,
              label: e.label,
              tag: e == FieldEnclosure.doubleQuote
                  ? '"'
                  : (e == FieldEnclosure.singleQuote ? "'" : null),
              selected: _enclosure == e,
              onTap: () {
                setState(() {
                  _enclosure = e;
                  _invalidateGenerated();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRadioRow({
    required AppThemePalette palette,
    required Color accent,
    required String label,
    String? tag,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: palette.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: palette.textPrimary,
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: palette.cardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(AppThemePalette palette, Color accent) {
    final ext = _fileType == ExportFileType.csv ? '.csv' : '.txt';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                _includeHeaderRow = !_includeHeaderRow;
                _invalidateGenerated();
              });
            },
            child: Row(
              children: [
                SizedBox.square(
                    dimension: 16,
                    child: Checkbox(
                      fillColor: WidgetStatePropertyAll(palette.textPrimary),
                      checkColor: palette.panel,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      value: _includeHeaderRow,
                      onChanged: (val) {
                        setState(() {
                          _includeHeaderRow = val ?? true;
                          _invalidateGenerated();
                        });
                      },
                    )),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Include Field Names as First Row',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 16, color: palette.cardBorder),
          Text(
            'Filename',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: _filenameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: palette.panel,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                        borderSide: BorderSide(color: palette.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                        borderSide: BorderSide(color: palette.cardBorder),
                      ),
                    ),
                    onChanged: (_) => _invalidateGenerated(),
                  ),
                ),
              ),
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.cardBorder,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(4),
                  ),
                ),
                child: Text(
                  ext,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION: 4. PREVIEW PANE
  // ==========================================
  Widget _buildPreviewPane(AppThemePalette palette, Color accent) {
    final previewLines = _buildPreviewLines();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '4. Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0;
                        index < previewLines.length;
                        index++) ...[
                      if (index > 0)
                        const Divider(
                          height: 1,
                          color: Color(0xFF2D2D2D),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            alignment: Alignment.topRight,
                            color: const Color(0xFF252525),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontFamily: appFontFamily,
                                fontFamilyFallback: kAppFontFamilyFallback,
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 4,
                            ),
                            child: SelectableText(
                              previewLines[index],
                              style: TextStyle(
                                fontFamily: appFontFamily,
                                fontFamilyFallback: kAppFontFamilyFallback,
                                fontSize: 14,
                                fontWeight: (index == 0 && _includeHeaderRow)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: (index == 0 && _includeHeaderRow)
                                    ? const Color(0xFF888888)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION: BOTTOM ACTION BUTTONS
  // ==========================================
  Widget _buildBottomActions(AppThemePalette palette, Color accent) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBlockButton(
              key: const Key('export_csv.generate'),
              label: _isGenerating ? 'Generating file...' : 'Generate file',
              icon: _isGenerating ? AppBlockButtonIcon.spinner : null,
              color: accent,
              onPressed: _isGenerating ? null : _handleGenerate,
            ),
            if (_generatedContent != null) ...[
              const SizedBox(height: 20),
              AppBlockButton(
                key: const Key('export_csv.download'),
                label: 'Download file ($_generatedFileSize)',
                icon: AppBlockButtonIcon.download,
                color: kAppSuccessGreen,
                onPressed: _handleDownload,
              ),
              const SizedBox(height: 10),
              AppBlockButton(
                key: const Key('export_csv.copy'),
                label: 'Copy to clipboard',
                icon: AppBlockButtonIcon.copy,
                color: palette.field,
                onPressed: _handleCopyToClipboard,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MANAGE COLUMNS MODAL
  // ==========================================
  Future<void> _showManageColumnsDialog(BuildContext context) async {
    final child = _supportsChildList && _exportMode == ExportMode.childList;
    final result = await showLibraryReportColumns(context,
        fields: child
            ? [
                for (final c in _availableChildColumns)
                  (id: c.id, label: c.label)
              ]
            : [
                for (final c in _availableAlbumColumns)
                  (id: c.id, label: c.label)
              ],
        selected: child ? _selectedChildColumnIds : _selectedAlbumColumnIds);
    if (!mounted || result == null) return;
    setState(() {
      if (child) {
        _selectedChildColumnIds = result;
      } else {
        _selectedAlbumColumnIds = result;
      }
      _invalidateGenerated();
    });
  }

  Future<void> _showManageSortDialog(BuildContext context) async {
    final result = await showLibraryReportSorts(context,
        fields: [
          for (final column in _availableAlbumColumns
              .where((column) => column.metadata?.sortable != false))
            (id: column.id, label: column.label)
        ],
        selected: _sortFields);
    if (!mounted || result == null) return;
    setState(() {
      _sortFields = result;
      _invalidateGenerated();
    });
  }
}
