import 'package:collectarr_app/core/api/generated/catalog_item_v1_fields.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/core_data/core_data_settings.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_page_tabs.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Which tab of the dialog opens first.
enum CoreDataSettingsTab { add, update }

/// Opens Add/Update from Core Settings; returns whether it was saved.
Future<bool> showCoreDataSettingsDialog({
  required BuildContext context,
  required Color accent,
  required CatalogMediaKind kind,
  CoreDataSettingsTab tab = CoreDataSettingsTab.add,
}) async =>
    await showAppDialog<bool>(
      context: context,
      builder: (context) =>
          CoreDataSettingsDialog(accent: accent, kind: kind, initialTab: tab),
    ) ==
    true;

/// Add/Update from Core settings: which non-personal fields Add downloads
/// and what Update does with each, as in the reference's two-tab dialog.
class CoreDataSettingsDialog extends StatefulWidget {
  const CoreDataSettingsDialog(
      {super.key,
      required this.accent,
      required this.kind,
      this.initialTab = CoreDataSettingsTab.add});

  final Color accent;
  final CatalogMediaKind kind;
  final CoreDataSettingsTab initialTab;

  @override
  State<CoreDataSettingsDialog> createState() => _CoreDataSettingsDialogState();
}

/// One row of the dialog; a [nested] row is a list inside each element of the
/// row above it, keyed `parent.child`.
typedef _Field = ({String key, String label, bool nested});

class _CoreDataSettingsDialogState extends State<CoreDataSettingsDialog> {
  late CoreDataSettingsTab _tab = widget.initialTab;
  late final List<_Field> _fields = _fieldsFor(widget.kind);
  bool _loaded = false;
  Set<String> _skipped = {};
  Map<String, CoreUpdateMode> _modes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await CoreDataSettings.load(widget.kind);
    if (!mounted) return;
    setState(() {
      _skipped = {...settings.skippedDownloads};
      _modes = {...settings.updateModes};
      _loaded = true;
    });
  }

  /// The kind's fields in Core's Catalog Item contract, each list of objects
  /// followed by the lists its elements contain. Settings act on one nesting
  /// level, so lists deeper than that are not offered.
  static List<_Field> _fieldsFor(CatalogMediaKind kind) => [
        for (final field in catalogItemV1FieldsByKind[kind.apiValue] ??
            const <CatalogItemV1Field>[])
          if (!kCoreDataLockedFields.contains(field.key)) ...[
            (key: field.key, label: _label(field), nested: false),
            for (final child in field.children)
              (
                key: '${field.key}.${child.key}',
                label: _label(child),
                nested: true
              ),
          ],
      ];

  static String _label(CatalogItemV1Field field) {
    final title = field.title;
    if (title != null) return title;
    final words = field.key.replaceAll('_', ' ');
    return words[0].toUpperCase() + words.substring(1);
  }

  List<_Field> get _downloadFields => [
        for (final field in _fields)
          if (!kCoreDataAlwaysDownloaded.contains(field.key)) field,
      ];

  Future<void> _save() async {
    await CoreDataSettings(skippedDownloads: _skipped, updateModes: _modes)
        .save(widget.kind);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Dialog(
      backgroundColor: const Color(0xff262626),
      alignment: Alignment.topCenter,
      insetPadding: kAppDialogInsets,
      shape: appDialogShape,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AccentDialogHeader(
              title: 'Add/Update from Core Settings',
              accent: widget.accent,
              icon: Icons.cloud_download_outlined),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AppPageTabs(
              tabs: const [
                AppPageTab(label: 'Add from Core'),
                AppPageTab(label: 'Update from Core'),
              ],
              selectedIndex: _tab.index,
              onSelected: (index) =>
                  setState(() => _tab = CoreDataSettingsTab.values[index]),
            ),
          ),
          if (!_loaded)
            const Padding(
                padding: EdgeInsets.all(24), child: CircularProgressIndicator())
          else if (_fields.isEmpty)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Core has no catalog for this kind yet.'))
          else
            Flexible(
              child: Container(
                color: palette.panelRaised,
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: _tab == CoreDataSettingsTab.add
                      ? _addTable()
                      : _updateTable(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                height: 32,
                child: FilledButton(
                    key: const Key('core_data_settings.save'),
                    style: FilledButton.styleFrom(
                        backgroundColor: palette.utilityAction,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: _save,
                    child: const Text('Save')),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _addTable() => _SettingsTable(
        header: 'Download',
        selectAll: ('Select all', () => setState(() => _skipped = {})),
        rows: [
          for (final field in _downloadFields)
            _SettingsRow(
              label: field.label,
              nested: field.nested,
              options: const ['Yes', 'No'],
              selected: _skipped.contains(field.key) ? 1 : 0,
              onSelected: (index) => setState(() => index == 1
                  ? _skipped.add(field.key)
                  : _skipped.remove(field.key)),
            ),
        ],
      );

  Widget _updateTable() {
    final fields = _fields;
    return _SettingsTable(
      header: 'Leave as is / Update if empty / Replace data',
      selectAll: (
        'Select all',
        () => setState(() => _modes = {
              for (final field in fields) field.key: CoreUpdateMode.update
            })
      ),
      rows: [
        for (final field in fields)
          _SettingsRow(
            label: field.label,
            nested: field.nested,
            options: const ['Skip', 'Update', 'Replace'],
            selected: (_modes[field.key] ?? CoreUpdateMode.update).index,
            onSelected: (index) => setState(
                () => _modes[field.key] = CoreUpdateMode.values[index]),
          ),
      ],
    );
  }
}

class _SettingsRow {
  const _SettingsRow(
      {required this.label,
      this.nested = false,
      required this.options,
      required this.selected,
      required this.onSelected});
  final String label;
  final bool nested;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;
}

/// Bordered table: field names on the left, a justified button group per row.
class _SettingsTable extends StatelessWidget {
  const _SettingsTable(
      {required this.header, required this.selectAll, required this.rows});
  final String header;
  final (String, VoidCallback) selectAll;
  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Table(
      border: TableBorder.all(color: palette.divider),
      columnWidths: const {0: FixedColumnWidth(150)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(decoration: BoxDecoration(color: palette.field), children: [
          const SizedBox(height: 34),
          Center(
              child: Text(header,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
        ]),
        TableRow(children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(5),
            child: _GroupButton(
                label: selectAll.$1, selected: false, onTap: selectAll.$2),
          ),
        ]),
        for (final row in rows)
          TableRow(children: [
            Padding(
                padding: EdgeInsets.only(left: row.nested ? 24 : 8, right: 8),
                child: Text(row.label,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(children: [
                for (var i = 0; i < row.options.length; i++)
                  Expanded(
                      child: _GroupButton(
                          label: row.options[i],
                          selected: i == row.selected,
                          onTap: () => row.onSelected(i))),
              ]),
            ),
          ]),
      ],
    );
  }
}

class _GroupButton extends StatelessWidget {
  const _GroupButton(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return SizedBox(
      height: 30,
      child: Material(
        color: selected ? palette.utilityAction : const Color(0xff666666),
        child: InkWell(
          onTap: onTap,
          child: Center(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
        ),
      ),
    );
  }
}
