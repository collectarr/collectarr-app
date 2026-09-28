import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';
import 'package:collectarr_app/features/library/csv/catalog_item_v1_csv_importer.dart';
import 'package:collectarr_app/features/library/state/catalog_item_v1_providers.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/theme/theme_primitives.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportExportWizardDialog extends ConsumerStatefulWidget {
  const ImportExportWizardDialog({
    super.key,
    required this.entries,
    required this.profiles,
    this.initialIndex = 0,
    this.customFieldDefinitions = const [],
    this.customFieldValuesByItem = const {},
    this.additionalExports = const [],
  });

  final List<LibraryWorkspaceSource> entries;
  final Iterable<CollectionCsvKindProfile> profiles;
  final int initialIndex;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, List<CustomFieldValue>> customFieldValuesByItem;
  final List<ExportPreviewArtifact> additionalExports;

  @override
  ConsumerState<ImportExportWizardDialog> createState() =>
      _ImportExportWizardDialogState();
}

class _ImportExportWizardDialogState
    extends ConsumerState<ImportExportWizardDialog> {
  final _controller = TextEditingController();
  List<CatalogItemV1CsvImportRow>? _preview;
  CatalogItemV1CsvImportReport? _report;
  String? _error;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: AccentAlertDialog(
        title: const Text('Import or export'),
        content: SizedBox(
          width: 860,
          height: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    icon: Icon(Icons.download_outlined),
                    text: 'Export',
                  ),
                  Tab(
                    icon: Icon(Icons.upload_file_outlined),
                    text: 'Import',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _ExportWizardPane(
                      entries: widget.entries,
                      profiles: widget.profiles,
                      customFieldDefinitions: widget.customFieldDefinitions,
                      customFieldValuesByItem: widget.customFieldValuesByItem,
                      additionalExports: widget.additionalExports,
                    ),
                    _ImportWizardPane(
                      controller: _controller,
                      preview: _preview,
                      report: _report,
                      error: _error,
                      isWorking: _isWorking,
                      onPreview: _previewRows,
                      onImport: _importRows,
                      onChanged: _onImportTextChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _previewRows() async {
    setState(() {
      _isWorking = true;
      _error = null;
    });
    try {
      final preview =
          ref.read(catalogItemV1CsvImporterProvider).parse(_controller.text);
      if (mounted) {
        setState(() {
          _preview = preview;
          _report = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'CSV preview failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  void _onImportTextChanged(String _) {
    setState(() {
      _preview = null;
      _report = null;
      _error = null;
    });
  }

  Future<void> _importRows() async {
    var preview = _preview;
    if (preview == null) {
      await _previewRows();
      preview = _preview;
    }
    if (preview == null) {
      return;
    }
    if (preview.isEmpty) {
      setState(() => _error = 'The CSV has no rows to import.');
      return;
    }
    setState(() {
      _isWorking = true;
      _error = null;
    });
    try {
      final report = await ref
          .read(catalogItemV1CsvImporterProvider)
          .importContent(_controller.text);
      ref.invalidate(catalogItemV1AllWorkspacesProvider);
      ref.invalidate(shelfProvider);
      if (mounted && report.failures.isEmpty) {
        Navigator.of(context).pop(report.importedRows);
      } else if (mounted) {
        setState(() => _report = report);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'CSV import failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }
}

class _ExportWizardPane extends StatelessWidget {
  const _ExportWizardPane({
    required this.entries,
    required this.profiles,
    this.customFieldDefinitions = const [],
    this.customFieldValuesByItem = const {},
    this.additionalExports = const [],
  });

  final List<LibraryWorkspaceSource> entries;
  final Iterable<CollectionCsvKindProfile> profiles;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, List<CustomFieldValue>> customFieldValuesByItem;
  final List<ExportPreviewArtifact> additionalExports;

  @override
  Widget build(BuildContext context) {
    final csv = CollectionCsvCodec(profiles: profiles);
    final collectarr = csv.exportShelf(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
    );
    final clz = csv.exportClzFriendlyShelf(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
    );
    final exports = <ExportPreviewArtifact>[
      ExportPreviewArtifact(
        id: 'collection.collectarr_csv',
        label: 'Collectarr CSV',
        icon: Icons.copy_all_outlined,
        filename: 'collectarr.csv',
        mimeType: 'text/csv',
        content: collectarr,
      ),
      ExportPreviewArtifact(
        id: 'collection.clz_csv',
        label: 'CLZ-friendly CSV',
        icon: Icons.table_view_outlined,
        filename: 'collectarr-clz.csv',
        mimeType: 'text/csv',
        content: clz,
      ),
      ...additionalExports,
    ];
    final owned = entries.where((entry) => entry.isOwned).length;
    final wishlist = entries.where((entry) => entry.isWishlisted).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _WizardStat(
                icon: Icons.table_rows_outlined,
                label: '${entries.length} rows'),
            _WizardStat(
                icon: Icons.inventory_2_outlined, label: '$owned owned'),
            _WizardStat(
                icon: Icons.bookmark_border, label: '$wishlist wishlist'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: DefaultTabController(
            length: exports.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  tabs: [
                    for (final export in exports) Tab(text: export.label),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final export in exports)
                        _CsvPreview(text: export.content),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final export in exports)
              OutlinedButton.icon(
                onPressed: () => _copy(
                  context,
                  export.content,
                  '${export.label} copied',
                ),
                icon: Icon(export.icon),
                label: Text('Copy ${export.label}'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context, String value, String message) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ImportWizardPane extends StatelessWidget {
  const _ImportWizardPane({
    required this.controller,
    required this.preview,
    required this.report,
    required this.error,
    required this.isWorking,
    required this.onPreview,
    required this.onImport,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<CatalogItemV1CsvImportRow>? preview;
  final CatalogItemV1CsvImportReport? report;
  final String? error;
  final bool isWorking;
  final VoidCallback onPreview;
  final VoidCallback onImport;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final preview = this.preview;
    final importable = preview?.length ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const _WizardStat(
                    icon: Icons.content_paste,
                    label: 'Paste import CSV',
                  ),
                  _WizardStat(
                    icon: Icons.fact_check_outlined,
                    label: preview == null
                        ? 'Preview pending'
                        : '${preview.length} rows',
                  ),
                  _WizardStat(
                    icon: Icons.upload_file_outlined,
                    label: '$importable importable',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 7,
                maxLines: 9,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  labelText: 'Paste Catalog Item v1 CSV',
                  border: OutlineInputBorder(),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              if (preview != null)
                _ImportPreviewSummary(preview: preview, report: report),
              SizedBox(height: preview == null ? 0 : 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isWorking ? null : onPreview,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Preview import'),
                  ),
                  FilledButton.icon(
                    onPressed: isWorking || importable == 0 ? null : onImport,
                    icon: isWorking
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_outlined),
                    label: Text(
                      'Import $importable row${importable == 1 ? '' : 's'}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportPreviewSummary extends StatelessWidget {
  const _ImportPreviewSummary({required this.preview, this.report});

  final List<CatalogItemV1CsvImportRow> preview;
  final CatalogItemV1CsvImportReport? report;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WizardStat(
                  icon: Icons.inventory_2_outlined,
                  label: '${preview.length} copies',
                ),
                _WizardStat(
                  icon: Icons.add_box_outlined,
                  label:
                      '${preview.where((row) => row.catalogItemId == null).length} catalog items to create',
                ),
                for (final kind in preview.map((row) => row.kind).toSet())
                  _WizardStat(
                    icon: Icons.category_outlined,
                    label:
                        '${preview.where((row) => row.kind == kind).length} ${kind.apiValue}',
                  ),
              ],
            ),
            if (report?.failures.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              for (final failure in report!.failures.take(8))
                Text(
                  'Row ${failure.rowNumber}: ${failure.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CsvPreview extends StatelessWidget {
  const _CsvPreview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: SelectableText(
            text,
            style: const TextStyle(
              fontFamily: kClzMonospaceFontFamily,
              fontFamilyFallback: kClzMonospaceFontFallback,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _WizardStat extends StatelessWidget {
  const _WizardStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
