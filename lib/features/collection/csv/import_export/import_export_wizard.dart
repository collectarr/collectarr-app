import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/cbz/comic_info_xml.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/xml/collection_xml.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportExportWizardDialog extends ConsumerStatefulWidget {
  const ImportExportWizardDialog({
    super.key,
    required this.entries,
    this.initialIndex = 0,
    this.customFieldDefinitions = const [],
    this.customFieldValuesByItem = const {},
  });

  final List<ShelfEntry> entries;
  final int initialIndex;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, List<CustomFieldValue>> customFieldValuesByItem;

  @override
  ConsumerState<ImportExportWizardDialog> createState() =>
      _ImportExportWizardDialogState();
}

class _ImportExportWizardDialogState
    extends ConsumerState<ImportExportWizardDialog> {
  final _controller = TextEditingController();
  final _csv = CollectionCsv();
  CollectionImportPreview? _preview;
  String? _error;
  bool _isWorking = false;

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
        title: const Text('Import or export collection'),
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
                    text: 'Export collection',
                  ),
                  Tab(
                    icon: Icon(Icons.upload_file_outlined),
                    text: 'Import collection',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _ExportWizardPane(
                      entries: widget.entries,
                      customFieldDefinitions: widget.customFieldDefinitions,
                      customFieldValuesByItem:
                          widget.customFieldValuesByItem,
                    ),
                    _ImportWizardPane(
                      controller: _controller,
                      preview: _preview,
                      error: _error,
                      isWorking: _isWorking,
                      onPreview: _previewRows,
                      onImport: _importRows,
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
      final rows = _csv.parse(_controller.text);
      final preview =
          await ref.read(collectionMutationsProvider).previewImportRows(rows);
      if (mounted) {
        setState(() => _preview = preview);
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

  Future<void> _importRows() async {
    var preview = _preview;
    if (preview == null) {
      await _previewRows();
      preview = _preview;
    }
    if (preview == null) {
      return;
    }
    final rows = [...preview.resolvedRows, ...preview.conflictRows];
    if (rows.isEmpty) {
      setState(() => _error = 'No matched rows are ready to import.');
      return;
    }
    setState(() {
      _isWorking = true;
      _error = null;
    });
    try {
      final imported =
          await ref.read(collectionMutationsProvider).importRows(rows);
      ref.invalidate(shelfProvider);
      if (mounted) {
        Navigator.of(context).pop(imported);
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
    this.customFieldDefinitions = const [],
    this.customFieldValuesByItem = const {},
  });

  final List<ShelfEntry> entries;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final Map<String, List<CustomFieldValue>> customFieldValuesByItem;

  @override
  Widget build(BuildContext context) {
    final csv = CollectionCsv();
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
    final owned = entries.where((entry) => entry.isOwned).length;
    final wishlist = entries.where((entry) => entry.isWishlisted).length;
    final comicEntries = entries
        .where((e) => e.catalogItem?.kind == 'comic' && e.catalogItem != null)
        .toList();
    final comicInfoXml = comicEntries.isEmpty
        ? '<!-- No comics to export -->'
        : _buildComicInfoBatch(comicEntries);
    final collectionXml = const CollectionXml().serialize(
      entries,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
    );
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
            _WizardStat(
                icon: Icons.style_outlined,
                label: '${comicEntries.length} comics'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: DefaultTabController(
            length: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Collectarr CSV'),
                    Tab(text: 'CLZ-friendly CSV'),
                    Tab(text: 'ComicInfo.xml'),
                    Tab(text: 'Collectarr XML'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CsvPreview(text: collectarr),
                      _CsvPreview(text: clz),
                      _CsvPreview(text: comicInfoXml),
                      _CsvPreview(text: collectionXml),
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
            OutlinedButton.icon(
              onPressed: () =>
                  _copy(context, collectarr, 'Collectarr CSV copied'),
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy Collectarr CSV'),
            ),
            OutlinedButton.icon(
              onPressed: () => _copy(context, clz, 'CLZ-friendly CSV copied'),
              icon: const Icon(Icons.table_view_outlined),
              label: const Text('Copy CLZ-friendly CSV'),
            ),
            if (comicEntries.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () =>
                    _copy(context, comicInfoXml, 'ComicInfo.xml copied'),
                icon: const Icon(Icons.code_outlined),
                label: const Text('Copy ComicInfo.xml'),
              ),
            OutlinedButton.icon(
              onPressed: () =>
                  _copy(context, collectionXml, 'Collectarr XML copied'),
              icon: const Icon(Icons.code_outlined),
              label: const Text('Copy Collectarr XML'),
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

  String _buildComicInfoBatch(List<ShelfEntry> comics) {
    const xml = ComicInfoXml();
    final buffer = StringBuffer();
    for (var i = 0; i < comics.length; i++) {
      final entry = comics[i];
      final catalog = entry.catalogItem;
      if (catalog == null) continue;
      final owned = entry.ownedItem;
      if (i > 0) {
        buffer.writeln();
        buffer.writeln('<!-- ─── next issue ─── -->');
        buffer.writeln();
      }
      buffer.write(xml.serialize(catalog, owned));
    }
    return buffer.toString();
  }
}

class _ImportWizardPane extends StatelessWidget {
  const _ImportWizardPane({
    required this.controller,
    required this.preview,
    required this.error,
    required this.isWorking,
    required this.onPreview,
    required this.onImport,
  });

  final TextEditingController controller;
  final CollectionImportPreview? preview;
  final String? error;
  final bool isWorking;
  final VoidCallback onPreview;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final preview = this.preview;
    final importable = preview == null
        ? 0
        : preview.resolvedRows.length + preview.conflictRows.length;
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
                        : '${preview.totalRows} rows',
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
                decoration: const InputDecoration(
                  labelText: 'Paste Collectarr CSV or CLZ-friendly CSV',
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
              if (preview != null) _ImportPreviewSummary(preview: preview),
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
  const _ImportPreviewSummary({required this.preview});

  final CollectionImportPreview preview;

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
                    icon: Icons.check_circle_outline,
                    label: '${preview.resolvedCount} matched'),
                _WizardStat(
                    icon: Icons.update_outlined,
                    label: '${preview.conflictCount} updates'),
                _WizardStat(
                    icon: Icons.search_off_outlined,
                    label: '${preview.unresolvedCount} unresolved'),
                _WizardStat(
                    icon: Icons.content_copy_outlined,
                    label: '${preview.duplicateCount} duplicates'),
                _WizardStat(
                    icon: Icons.block_outlined,
                    label: '${preview.skippedCount} skipped'),
              ],
            ),
            if (preview.unresolvedRows.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Unresolved rows stay out of this import until you match them in a later pass.',
                style: Theme.of(context).textTheme.bodySmall,
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
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
