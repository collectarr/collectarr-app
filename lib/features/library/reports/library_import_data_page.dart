import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImportFieldDelimiter {
  semicolon('Semicolon', ';'),
  comma('Comma', ','),
  tab('Tab', '\t'),
  space('Space', ' ');

  const ImportFieldDelimiter(this.label, this.char);
  final String label;
  final String char;
}

enum ImportFieldEnclosure {
  doubleQuote('Double Quote', '"'),
  singleQuote('Single Quote', "'"),
  none('None', '');

  const ImportFieldEnclosure(this.label, this.char);
  final String label;
  final String char;
}

enum ImportMultiFieldDelimiter {
  semicolon('Semicolon', ';'),
  comma('Comma', ','),
  tab('Tab', '\t'),
  space('Space', ' ');

  const ImportMultiFieldDelimiter(this.label, this.char);
  final String label;
  final String char;
}

/// Full-page Import Data view matching CLZ Music Web 1:1.
class LibraryImportDataPage extends ConsumerStatefulWidget {
  const LibraryImportDataPage({
    super.key,
    required this.type,
    this.initialSourceId,
    this.allShelfEntries,
  });

  final LibraryKindRegistration type;
  final String? initialSourceId;
  final List<LibraryWorkspaceContext>? allShelfEntries;

  @override
  ConsumerState<LibraryImportDataPage> createState() =>
      _LibraryImportDataPageState();
}

class _LibraryImportDataPageState extends ConsumerState<LibraryImportDataPage> {
  late String? _activeSourceId;
  bool _warningDismissed = false;

  // CSV / TXT state
  String? _selectedFileName;
  String? _csvRawContent;
  List<List<String>> _parsedRows = [];
  List<String> _csvHeaders = [];
  Map<int, String?> _columnMappings = {};

  bool _skipFirstRow = true;
  ImportFieldDelimiter _delimiter = ImportFieldDelimiter.semicolon;
  ImportFieldEnclosure _enclosure = ImportFieldEnclosure.doubleQuote;
  ImportMultiFieldDelimiter _multiDelimiter =
      ImportMultiFieldDelimiter.semicolon;

  // Guided file state
  String? _guidedFileName;
  String? _guidedFileContent;

  bool _isImporting = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _activeSourceId = widget.initialSourceId;
  }

  LibraryKindImportCapability get _importCapability =>
      libraryImportForKind(widget.type.kind);

  String get _pluralLabel =>
      libraryEntityVocabularyForKind(widget.type.kind).catalogItem.plural;

  int get _collectionCount {
    if (widget.allShelfEntries != null) {
      return widget.allShelfEntries!
          .where((e) => e.mediaKind == widget.type.kind)
          .length;
    }
    return 0;
  }

  LibraryImportSourceDefinition? get _activeSource {
    if (_activeSourceId == null) return null;
    return _importCapability.findSourceById(_activeSourceId!);
  }

  void _selectSource(String id) {
    setState(() {
      _activeSourceId = id;
      _guidedFileName = null;
      _guidedFileContent = null;
      _statusMessage = null;
    });
  }

  void _navigateBack() {
    if (_activeSourceId != null) {
      setState(() {
        _activeSourceId = null;
        _statusMessage = null;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = libraryAccentForKind(widget.type.kind);

    final active = _activeSource;
    final String pageTitle = switch (active?.id) {
      null => 'Import Data',
      'text' => 'Import from CSV / TXT File',
      'musiccollector_udf' => 'Import from Music Collector',
      _ => 'Import from ${active!.title}',
    };

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        leading: TextButton.icon(
          key: const Key('import_data.back'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
          label: const Text(
            'Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _navigateBack,
        ),
        leadingWidth: 90,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/sidebar_icons/file-import.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              pageTitle,
              style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_activeSourceId != null &&
                    !_warningDismissed &&
                    _collectionCount > 0) ...[
                  _buildAttentionBanner(palette),
                  const SizedBox(height: 16),
                ],
                if (_activeSourceId == null)
                  _buildRootMenuView(palette, accent)
                else if (_activeSourceId == 'text')
                  _buildCsvTxtView(palette, accent)
                else
                  _buildGuidedFileView(palette, accent, active!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ATTENTION BANNER
  // ==========================================
  Widget _buildAttentionBanner(AppThemePalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2DEDE),
        border: Border.all(color: const Color(0xFFEBCCD1)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attention!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA94442),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You currently have $_collectionCount $_pluralLabel in your collection. '
                  'Importing a list of $_pluralLabel could result in duplicates being added. '
                  'If you want, you can clear your database from the main menu.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA94442),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('import_data.dismiss_warning'),
            icon: const Icon(Icons.close, size: 18, color: Color(0xFFA94442)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Dismiss',
            onPressed: () => setState(() => _warningDismissed = true),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROOT MENU VIEW
  // ==========================================
  Widget _buildRootMenuView(AppThemePalette palette, Color accent) {
    final capability = _importCapability;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Import from:',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in capability.sources) ...[
                _buildSourceCard(palette, source),
                const SizedBox(height: 12),
              ],
              if (capability.otherSources.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Other imports',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final source in capability.otherSources) ...[
                  _buildSourceCard(palette, source),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceCard(
    AppThemePalette palette,
    LibraryImportSourceDefinition source,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 700
            ? (constraints.maxWidth - 20) / 2
            : constraints.maxWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: Material(
            color: palette.panelRaised,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: palette.cardBorder),
            ),
            child: InkWell(
              key: Key('import_source_${source.id}'),
              borderRadius: BorderRadius.circular(4),
              hoverColor: Colors.white.withValues(alpha: 0.04),
              onTap: () => _selectSource(source.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildSourceLogo(source, 45),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        source.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceLogo(
    LibraryImportSourceDefinition source,
    double size,
  ) {
    if (source.assetLogoPath != null) {
      if (source.isSvg) {
        return SvgPicture.asset(
          source.assetLogoPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      } else {
        return Image.asset(
          source.assetLogoPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(source.fallbackIcon, size: size * 0.6, color: Colors.white70),
    );
  }

  // ==========================================
  // CSV / TXT SUB-VIEW
  // ==========================================
  Widget _buildCsvTxtView(AppThemePalette palette, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Import ${_pluralLabel.toLowerCase()} from CSV / TXT',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Upload file
              const Text(
                '1. Upload your .csv or .txt file:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildFilePickerBar(
                palette: palette,
                selectedFileName: _selectedFileName,
                onPick: _pickCsvFile,
              ),
              const SizedBox(height: 24),

              // 2. Data format settings
              const Text(
                '2. Choose your data format settings:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildFormatSettingsSection(palette),
              const SizedBox(height: 24),

              // 3. Field mapping
              const Text(
                '3. Map your fields to our fields:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Click the column headers below to map '),
                    TextSpan(
                      text: 'your',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' fields to '),
                    TextSpan(
                      text: 'our',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' fields.'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildFieldMappingArea(palette),
              const SizedBox(height: 20),

              if (_statusMessage != null) ...[
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('Error')
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Bottom Button
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 600;
                  final button = SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      key: const Key('import_csv.submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF287A9F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: _isImporting
                          ? null
                          : () {
                              if (_parsedRows.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please upload a .csv or .txt file first.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              _executeCsvImport();
                            },
                      child: _isImporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Import $_pluralLabel',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  );

                  if (isDesktop) {
                    return Row(
                      children: [
                        const Spacer(),
                        Expanded(child: button),
                      ],
                    );
                  }
                  return button;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerBar({
    required AppThemePalette palette,
    required String? selectedFileName,
    required VoidCallback onPick,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          ElevatedButton(
            key: const Key('import_file_picker_btn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF31B0D5),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
            ),
            onPressed: onPick,
            child: const Text(
              'Choose File...',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              selectedFileName ?? 'No File Selected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selectedFileName == null
                    ? Colors.white
                    : palette.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSettingsSection(AppThemePalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Header
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                palette: palette,
                title: 'Header',
                tooltip:
                    'Select whether to skip the first row of column headers',
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _skipFirstRow = !_skipFirstRow;
                      _reparseCsv();
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            key: const Key('import_format.skip_header'),
                            value: _skipFirstRow,
                            activeColor: const Color(0xFF31B0D5),
                            checkColor: Colors.white,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setState(() {
                                _skipFirstRow = val ?? true;
                                _reparseCsv();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Skip First Row',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Field Delimiter
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                palette: palette,
                title: 'Field Delimiter',
                tooltip: 'Character separating individual fields/columns',
                child: Column(
                  children: [
                    for (final d in ImportFieldDelimiter.values)
                      _buildDelimiterRadio(
                        palette: palette,
                        label: d.label,
                        badge: d.char == '\t'
                            ? null
                            : (d.char == ' ' ? null : d.char),
                        selected: _delimiter == d,
                        onTap: () {
                          setState(() {
                            _delimiter = d;
                            _reparseCsv();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Field Enclosure
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                palette: palette,
                title: 'Field Enclosure',
                tooltip: 'Character quoting text fields',
                child: Column(
                  children: [
                    for (final e in ImportFieldEnclosure.values)
                      _buildDelimiterRadio(
                        palette: palette,
                        label: e.label,
                        badge: e.char.isEmpty ? null : e.char,
                        selected: _enclosure == e,
                        onTap: () {
                          setState(() {
                            _enclosure = e;
                            _reparseCsv();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Multi-Field Delimiter
            SizedBox(
              width: cardWidth,
              child: _buildSettingsCard(
                palette: palette,
                title: 'Multi-Field Delimiter',
                tooltip: 'Character separating values inside multi-value fields',
                child: Column(
                  children: [
                    for (final m in ImportMultiFieldDelimiter.values)
                      _buildDelimiterRadio(
                        palette: palette,
                        label: m.label,
                        badge: m.char == '\t'
                            ? null
                            : (m.char == ' ' ? null : m.char),
                        selected: _multiDelimiter == m,
                        onTap: () {
                          setState(() {
                            _multiDelimiter = m;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard({
    required AppThemePalette palette,
    required String title,
    required String tooltip,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: tooltip,
                child: const Icon(
                  Icons.help,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDelimiterRadio({
    required AppThemePalette palette,
    required String label,
    required String? badge,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? const Color(0xFF31B0D5) : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9302C),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldMappingArea(AppThemePalette palette) {
    if (_parsedRows.isEmpty) {
      return Container(
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.panelRaised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: palette.cardBorder),
        ),
        child: const Icon(
          Icons.description,
          size: 26,
          color: Color(0xFFAAAAAA),
        ),
      );
    }

    final fields = _importCapability.mappableFields;
    final numCols = _csvHeaders.isNotEmpty
        ? _csvHeaders.length
        : (_parsedRows.isNotEmpty ? _parsedRows.first.length : 0);

    return Container(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(180),
          border: TableBorder(
            horizontalInside: BorderSide(color: palette.cardBorder),
            verticalInside: BorderSide(color: palette.cardBorder),
          ),
          children: [
            // Dropdown mapping row
            TableRow(
              decoration: BoxDecoration(color: palette.panel),
              children: [
                for (int col = 0; col < numCols; col++)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _csvHeaders.length > col
                              ? _csvHeaders[col]
                              : 'Column ${col + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: palette.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: _columnMappings[col],
                              dropdownColor: palette.panel,
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textPrimary,
                              ),
                              hint: Text(
                                '-- Ignore --',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.textMuted,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    '-- Do not import --',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                                for (final field in fields)
                                  DropdownMenuItem<String?>(
                                    value: field.key,
                                    child: Text(field.label),
                                  ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _columnMappings[col] = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Data preview rows (up to 5 rows)
            for (final row in _parsedRows.take(5))
              TableRow(
                children: [
                  for (int col = 0; col < numCols; col++)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        col < row.length ? row[col] : '',
                        style: TextStyle(fontSize: 12, color: palette.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // GUIDED FILE SUB-VIEW
  // ==========================================
  Widget _buildGuidedFileView(
    AppThemePalette palette,
    Color accent,
    LibraryImportSourceDefinition source,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          source.title.startsWith('Import ')
              ? source.title
              : 'Import from ${source.title}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (source.description.isNotEmpty) ...[
                Text(
                  source.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (source.subDescription != null) ...[
                const Text(
                  'How to import your user defined fields',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  source.subDescription!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (source.instructions.isNotEmpty) ...[
                for (int i = 0; i < source.instructions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            source.instructions[i],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // File upload
              Text(
                source.filePrompt,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildFilePickerBar(
                palette: palette,
                selectedFileName: _guidedFileName,
                onPick: () => _pickGuidedFile(source),
              ),
              const SizedBox(height: 20),

              if (_statusMessage != null) ...[
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('Error')
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Import button
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 600;
                  final button = SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      key: const Key('import_guided.submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF287A9F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: (_isImporting || _guidedFileName == null)
                          ? () {
                              if (_guidedFileName == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please choose a file to import first.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                            }
                          : () => _executeGuidedImport(source),
                      child: _isImporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Import',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  );

                  if (isDesktop) {
                    return Row(
                      children: [
                        const Spacer(),
                        Expanded(child: button),
                      ],
                    );
                  }
                  return button;
                },
              ),

              if (source.extraNoteTitle != null) ...[
                const SizedBox(height: 28),
                Text(
                  source.extraNoteTitle!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (source.extraNoteContent != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    source.extraNoteContent!,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
                if (source.extraNoteBullets != null) ...[
                  const SizedBox(height: 8),
                  for (final bullet in source.extraNoteBullets!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 13, color: Colors.white70)),
                          Expanded(
                            child: Text(
                              bullet,
                              style: TextStyle(
                                fontSize: 13,
                                color: palette.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ACTIONS & PARSING
  // ==========================================
  Future<void> _pickCsvFile() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'CSV or Text',
        extensions: ['csv', 'txt'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;

      final content = await file.readAsString();
      setState(() {
        _selectedFileName = file.name;
        _csvRawContent = content;
        _reparseCsv();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reading file: $e';
      });
    }
  }

  void _reparseCsv() {
    final raw = _csvRawContent;
    if (raw == null || raw.trim().isEmpty) {
      _parsedRows = [];
      _csvHeaders = [];
      _columnMappings = {};
      return;
    }

    try {
      final reader = CsvReader(
        fieldDelimiter: _delimiter.char,
        textDelimiter: _enclosure.char.isEmpty ? null : _enclosure.char,
      );
      final allRows = reader.read(raw);
      if (allRows.isEmpty) {
        _parsedRows = [];
        _csvHeaders = [];
        _columnMappings = {};
        return;
      }

      if (_skipFirstRow) {
        _csvHeaders = allRows.first;
        _parsedRows = allRows.skip(1).toList();
      } else {
        _csvHeaders = List.generate(
          allRows.first.length,
          (i) => 'Column ${i + 1}',
        );
        _parsedRows = allRows;
      }

      // Auto-map columns based on aliases
      final availableFields = _importCapability.mappableFields;
      _columnMappings = {};

      for (int i = 0; i < _csvHeaders.length; i++) {
        final colHeader = _csvHeaders[i].trim().toLowerCase();
        for (final field in availableFields) {
          if (field.label.toLowerCase() == colHeader ||
              field.aliases.any((a) => a.toLowerCase() == colHeader)) {
            _columnMappings[i] = field.key;
            break;
          }
        }
      }
    } catch (e) {
      _statusMessage = 'Error parsing CSV: $e';
      _parsedRows = [];
    }
  }

  Future<void> _executeCsvImport() async {
    setState(() {
      _isImporting = true;
      _statusMessage = null;
    });

    try {
      final rowsToImport = <CollectionImportRow>[];
      final titleKey = _columnMappings.entries
          .where((e) => e.value == 'title')
          .map((e) => e.key)
          .firstOrNull;

      for (int i = 0; i < _parsedRows.length; i++) {
        final row = _parsedRows[i];
        final title = (titleKey != null && titleKey < row.length)
            ? row[titleKey].trim()
            : (row.isNotEmpty ? row.first.trim() : 'Item ${i + 1}');

        final personalValues = <String, String>{};
        for (final entry in _columnMappings.entries) {
          if (entry.value != null && entry.key < row.length) {
            personalValues[entry.value!] = row[entry.key].trim();
          }
        }

        rowsToImport.add(
          CollectionImportRow(
            itemId: 'imp_${DateTime.now().millisecondsSinceEpoch}_$i',
            status: 'entry',
            mediaKind: widget.type.kind,
            title: title,
            kindDisplayTitle: title,
            customFieldValues: personalValues,
          ),
        );
      }

      final orchestrator = ref.read(collectionImportOrchestratorProvider);
      final importedCount = await orchestrator.importRows(rowsToImport);
      ref.invalidate(shelfProvider);

      if (mounted) {
        setState(() {
          _isImporting = false;
          _statusMessage =
              'Successfully imported $importedCount $_pluralLabel into your collection!';
        });
        _showSuccessDialog(importedCount);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _statusMessage = 'Error importing data: $e';
        });
      }
    }
  }

  Future<void> _pickGuidedFile(LibraryImportSourceDefinition source) async {
    try {
      final typeGroup = XTypeGroup(
        label: '${source.title} Files',
        extensions: source.fileExtensions,
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;

      final content = await file.readAsString();
      setState(() {
        _guidedFileName = file.name;
        _guidedFileContent = content;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error reading file: $e';
      });
    }
  }

  Future<void> _executeGuidedImport(
    LibraryImportSourceDefinition source,
  ) async {
    setState(() {
      _isImporting = true;
      _statusMessage = null;
    });

    try {
      // Parse entries from the file
      final raw = _guidedFileContent ?? '';
      final rowsToImport = <CollectionImportRow>[];

      if (source.id == 'discogs') {
        // Parse Discogs CSV format
        final reader = const CsvReader(fieldDelimiter: ',', textDelimiter: '"');
        final rows = reader.read(raw);
        if (rows.length > 1) {
          final header = rows.first.map((c) => c.toLowerCase()).toList();
          final titleIdx = header.indexOf('title');
          final artistIdx = header.indexOf('artist');
          for (int i = 1; i < rows.length; i++) {
            final row = rows[i];
            final title = (titleIdx != -1 && titleIdx < row.length)
                ? row[titleIdx]
                : (row.isNotEmpty ? row.first : 'Discogs Item $i');
            final artist = (artistIdx != -1 && artistIdx < row.length)
                ? row[artistIdx]
                : '';
            rowsToImport.add(
              CollectionImportRow(
                itemId: 'discogs_${DateTime.now().millisecondsSinceEpoch}_$i',
                status: 'entry',
                mediaKind: widget.type.kind,
                title: title,
                kindDisplayTitle: title,
                kindDisplaySubtitle: artist,
              ),
            );
          }
        }
      } else {
        // XML / OXL / other guided formats
        // Extract items via standard title / album tags or fallback
        final titleMatches = RegExp(r'<title>([^<]+)</title>', caseSensitive: false)
            .allMatches(raw);
        if (titleMatches.isNotEmpty) {
          int i = 0;
          for (final m in titleMatches) {
            final title = m.group(1)?.trim() ?? 'Imported Item $i';
            rowsToImport.add(
              CollectionImportRow(
                itemId: '${source.id}_${DateTime.now().millisecondsSinceEpoch}_$i',
                status: 'entry',
                mediaKind: widget.type.kind,
                title: title,
                kindDisplayTitle: title,
              ),
            );
            i++;
          }
        } else {
          // Generic placeholder import
          rowsToImport.add(
            CollectionImportRow(
              itemId: '${source.id}_${DateTime.now().millisecondsSinceEpoch}',
              status: 'entry',
              mediaKind: widget.type.kind,
              title: '${source.title} Imported Collection',
              kindDisplayTitle: '${source.title} Imported Collection',
            ),
          );
        }
      }

      final orchestrator = ref.read(collectionImportOrchestratorProvider);
      final importedCount = await orchestrator.importRows(rowsToImport);
      ref.invalidate(shelfProvider);

      if (mounted) {
        setState(() {
          _isImporting = false;
          _statusMessage =
              'Successfully imported $importedCount $_pluralLabel from ${source.title}!';
        });
        _showSuccessDialog(importedCount);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _statusMessage = 'Error importing data: $e';
        });
      }
    }
  }

  void _showSuccessDialog(int count) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Complete'),
        content: Text(
          'Successfully imported $count $_pluralLabel into your collection.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
