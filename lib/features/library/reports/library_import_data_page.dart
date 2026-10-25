import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/app_management_page_scaffold.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'import/import_file_picker.dart';
import 'import/import_source_picker.dart';
import 'import/csv_import_panel.dart';
import 'import/guided_import_panel.dart';

class LibraryImportDataPage extends ConsumerStatefulWidget {
  const LibraryImportDataPage(
      {super.key,
      required this.type,
      this.initialSourceId,
      this.allShelfEntries,
      this.filePicker = pickLibraryImportFile});
  final LibraryKindRegistration type;
  final String? initialSourceId;
  final List<LibraryWorkspaceContext>? allShelfEntries;
  final ImportFilePicker filePicker;
  @override
  ConsumerState<LibraryImportDataPage> createState() =>
      _LibraryImportDataPageState();
}

class _LibraryImportDataPageState extends ConsumerState<LibraryImportDataPage> {
  String? _activeSourceId;
  bool _warningDismissed = false;
  int? _importedCount;
  int _importRun = 0;
  String get _pluralLabel =>
      libraryEntityVocabularyForKind(widget.type.kind).catalogItem.plural;
  int get _collectionCount =>
      widget.allShelfEntries
          ?.where((e) => e.mediaKind == widget.type.kind)
          .length ??
      0;
  @override
  void initState() {
    super.initState();
    _activeSourceId = widget.initialSourceId;
  }

  void _navigateBack() {
    if (_activeSourceId != null) {
      setState(() {
        _activeSourceId = null;
        _importedCount = null;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<int> _importRows(List<CollectionImportRow> rows) async {
    final count =
        await ref.read(collectionImportOrchestratorProvider).importRows(rows);
    if (mounted) ref.invalidate(shelfProvider);
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final capability = libraryImportForKind(widget.type.kind);
    final source = capability.findSourceById(_activeSourceId ?? '');
    final title = source == null
        ? 'Import Data'
        : source.sourceType == LibraryImportSourceType.csvTxt
            ? 'Import from CSV / TXT File'
            : 'Import from ${source.title}';
    return AppManagementPageScaffold(
        icon: AppIcons.importData,
        title: title,
        padding: EdgeInsets.zero,
        leading: AppPageBackButton(
            key: const Key('import_data.back'), onPressed: _navigateBack),
        child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 700 ? 12 : 0,
                vertical: source == null ? 20 : 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_importedCount != null) ...[
                    _buildSuccessBanner(_importedCount!),
                    const SizedBox(height: 16)
                  ],
                  if (source != null &&
                      !_warningDismissed &&
                      _collectionCount > 0) ...[
                    _buildAttentionBanner(appPalette(context)),
                    const SizedBox(height: 16)
                  ],
                  if (source == null)
                    ImportSourcePicker(
                        sources: capability.sources,
                        onSelect: (id) => setState(() => _activeSourceId = id))
                  else if (source.sourceType == LibraryImportSourceType.csvTxt)
                    CsvImportPanel(
                        key: ValueKey('${source.id}.$_importRun'),
                        capability: capability,
                        pluralLabel: _pluralLabel,
                        onImport: _importRows,
                        onComplete: _showSuccessBanner,
                        filePicker: widget.filePicker)
                  else
                    GuidedImportPanel(
                        pluralLabel: _pluralLabel,
                        key: ValueKey('${source.id}.$_importRun'),
                        source: source,
                        onImport: _importRows,
                        onComplete: _showSuccessBanner,
                        filePicker: widget.filePicker),
                ])));
  }

  Widget _buildAttentionBanner(AppThemePalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2DEDE),
        border: Border.all(color: const Color(0xFFEBCCD1)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA94442),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You currently have $_collectionCount $_pluralLabel in your collection. '
                  'Importing a list of $_pluralLabel could result in duplicates being added. '
                  'Review the parsed records before confirming the import.',
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
            icon: const Icon(AppIcons.close, size: 14),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFFA94442).withValues(alpha: 0.5),
              hoverColor: Colors.transparent,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Dismiss',
            onPressed: () => setState(() => _warningDismissed = true),
          ),
        ],
      ),
    );
  }

  void _showSuccessBanner(int count) {
    setState(() {
      _importedCount = count;
      _importRun++;
    });
  }

  Widget _buildSuccessBanner(int count) {
    const green = Color(0xFF3C763D);
    return Container(
      key: const Key('import_data.success'),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF0D8),
        border: Border.all(color: const Color(0xFFD6E9C6)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Import successful: $count $_pluralLabel added to your collection.',
              style: const TextStyle(fontSize: 14, height: 1.4, color: green),
            ),
          ),
          IconButton(
            key: const Key('import_data.dismiss_success'),
            icon: const Icon(AppIcons.close, size: 14),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: green.withValues(alpha: 0.5),
              hoverColor: Colors.transparent,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Dismiss',
            onPressed: () => setState(() => _importedCount = null),
          ),
        ],
      ),
    );
  }
}
