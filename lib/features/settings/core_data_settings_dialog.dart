import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/core_data/settings.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_metadata_contributors.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_page_tabs.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Which tab of the dialog opens first.
enum CoreDataSettingsTabChoice { add, update }

/// Opens Add/Update from Core Settings; returns whether it was saved.
Future<bool> showCoreDataSettingsDialog({
  required BuildContext context,
  required Color accent,
  required CatalogMediaKind kind,
  CoreDataSettingsTabChoice tab = CoreDataSettingsTabChoice.add,
}) async =>
    await showAppDialog<bool>(
      context: context,
      builder: (context) =>
          CoreDataSettingsDialog(accent: accent, kind: kind, initialTab: tab),
    ) ==
    true;

// The reference's colors for this dialog.
const _dialogColor = Color(0xff262626);
const _paneColor = Color(0xff383838);
const _headerColor = Color(0xff464950);
const _cellBorder = Color(0xff262626);
const _groupColor = Color(0xff404040);
const _selectAllColor = Color(0xff494949);
const _optionColor = Color(0xff444444);
const _optionBorder = Color(0xff666666);

/// Add/Update from Core settings: which non-personal fields Add downloads
/// and what Update does with each, as in the reference's two-tab dialog.
/// Rows are grouped by the kind's edit tabs: each tab has its own choice,
/// and a field set apart from its tab overrides it.
class CoreDataSettingsDialog extends StatefulWidget {
  const CoreDataSettingsDialog(
      {super.key,
      required this.accent,
      required this.kind,
      this.initialTab = CoreDataSettingsTabChoice.add});

  final Color accent;
  final CatalogMediaKind kind;
  final CoreDataSettingsTabChoice initialTab;

  @override
  State<CoreDataSettingsDialog> createState() => _CoreDataSettingsDialogState();
}

class _CoreDataSettingsDialogState extends State<CoreDataSettingsDialog> {
  late CoreDataSettingsTabChoice _tab = widget.initialTab;
  late final List<CoreDataSettingsTab> _tabs =
      libraryCoreDataTabsForKind(widget.kind) ?? const [];
  CoreDataSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await CoreDataSettings.load(widget.kind);
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _save() async {
    await _settings?.save(widget.kind);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _update(CoreDataSettings Function(CoreDataSettings) change) =>
      setState(() => _settings = change(_settings!));

  /// Tabs with the fields Add from Core may leave empty.
  List<CoreDataSettingsTab> get _downloadTabs => [
        for (final tab in _tabs)
          if (tab.fields.where((field) => !_alwaysDownloaded(field)).toList()
              case final fields when fields.isNotEmpty)
            (id: tab.id, label: tab.label, fields: fields),
      ];

  static bool _alwaysDownloaded(CoreDataSettingsField field) =>
      field.keys.every(kCoreDataAlwaysDownloaded.contains);

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return Dialog(
      backgroundColor: _dialogColor,
      alignment: Alignment.topCenter,
      insetPadding: kAppDialogInsets,
      shape: appDialogShape,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AccentDialogHeader(
            title: 'Add/Update from Core Settings',
            accent: widget.accent,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppPageTabs(
                selectedColor: _paneColor,
                tabs: const [
                  AppPageTab(label: 'Add from Core'),
                  AppPageTab(label: 'Update from Core'),
                ],
                selectedIndex: _tab.index,
                onSelected: (index) => setState(
                    () => _tab = CoreDataSettingsTabChoice.values[index]),
              ),
            ),
          ),
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: _paneColor, borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (settings == null)
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator())
                  else if (_tabs.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Core has no catalog for this kind yet.'))
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: _tab == CoreDataSettingsTabChoice.add
                            ? _addTable(settings)
                            : _updateTable(settings),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 122.5,
                      height: 32,
                      child: FilledButton(
                          key: const Key('core_data_settings.save'),
                          style: FilledButton.styleFrom(
                              backgroundColor:
                                  appPalette(context).utilityAction,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                          onPressed: settings == null ? null : _save,
                          child: const Text('Save')),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _addTable(CoreDataSettings settings) {
    const options = ['Yes', 'No'];
    int tabChoice(String tab) => settings.tabDownloads(tab) ? 0 : 1;
    return _SettingsTable(
      nameFlex: 1,
      optionsFlex: 1,
      headers: const ['Download'],
      selectAll: [
        _SelectAll(
            key: const Key('core_data_settings.select_all.0'),
            onTap: () => _update((s) => s.copyWith(
                skippedTabs: {}, skippedDownloads: {}, keptDownloads: {}))),
        _SelectAll(
            key: const Key('core_data_settings.select_all.1'),
            onTap: () => _update((s) => s.copyWith(
                skippedTabs: {for (final tab in _tabs) tab.id},
                skippedDownloads: {},
                keptDownloads: {}))),
      ],
      groups: [
        for (final tab in _downloadTabs)
          _SettingsGroup(
            label: tab.label,
            options: options,
            selected: tabChoice(tab.id),
            onSelected: (index) => _update((s) {
              final downloads = index == 0;
              final keys = {
                for (final field in tab.fields) ...field.keys,
              };
              return s.copyWith(
                skippedTabs: downloads
                    ? ({...s.skippedTabs}..remove(tab.id))
                    : {...s.skippedTabs, tab.id},
                // A field that now agrees with its tab is no longer apart.
                skippedDownloads: downloads
                    ? s.skippedDownloads
                    : ({...s.skippedDownloads}..removeAll(keys)),
                keptDownloads: downloads
                    ? ({...s.keptDownloads}..removeAll(keys))
                    : s.keptDownloads,
              );
            }),
            rows: [
              for (final field in tab.fields)
                _SettingsRow(
                  label: field.label,
                  options: options,
                  selected: settings.downloads(field.keys.first) ? 0 : 1,
                  overridden: field.keys.any((key) =>
                      settings.skippedDownloads.contains(key) ||
                      settings.keptDownloads.contains(key)),
                  onSelected: (index) => _update((s) {
                    final downloads = index == 0;
                    final apart = downloads != s.tabDownloads(tab.id);
                    final skipped = {...s.skippedDownloads}
                      ..removeAll(field.keys);
                    final kept = {...s.keptDownloads}..removeAll(field.keys);
                    if (apart) (downloads ? kept : skipped).addAll(field.keys);
                    return s.copyWith(
                        skippedDownloads: skipped, keptDownloads: kept);
                  }),
                ),
            ],
          ),
      ],
    );
  }

  Widget _updateTable(CoreDataSettings settings) {
    const options = ['Skip', 'Update', 'Replace'];
    return _SettingsTable(
      nameFlex: 1,
      optionsFlex: 3,
      headers: const ['Leave as is', 'Update if empty', 'Replace data'],
      selectAll: [
        for (final mode in CoreUpdateMode.values)
          _SelectAll(
              key: Key('core_data_settings.select_all.${mode.index}'),
              onTap: () => _update((s) => s.copyWith(
                  tabUpdateModes: {for (final tab in _tabs) tab.id: mode},
                  updateModes: {}))),
      ],
      groups: [
        for (final tab in _tabs)
          _SettingsGroup(
            label: tab.label,
            options: options,
            selected: settings.tabModeFor(tab.id).index,
            onSelected: (index) => _update((s) {
              final mode = CoreUpdateMode.values[index];
              final keys = {for (final field in tab.fields) ...field.keys};
              return s.copyWith(
                tabUpdateModes: {...s.tabUpdateModes, tab.id: mode},
                updateModes: {
                  for (final entry in s.updateModes.entries)
                    if (!keys.contains(entry.key) || entry.value != mode)
                      entry.key: entry.value,
                },
              );
            }),
            rows: [
              for (final field in tab.fields)
                _SettingsRow(
                  label: field.label,
                  options: options,
                  selected: settings.modeFor(field.keys.first).index,
                  overridden: field.keys.any(settings.updateModes.containsKey),
                  onSelected: (index) => _update((s) {
                    final mode = CoreUpdateMode.values[index];
                    final modes = {...s.updateModes}
                      ..removeWhere((key, _) => field.keys.contains(key));
                    if (mode != s.tabModeFor(tab.id)) {
                      for (final key in field.keys) {
                        modes[key] = mode;
                      }
                    }
                    return s.copyWith(updateModes: modes);
                  }),
                ),
            ],
          ),
      ],
    );
  }
}

class _SettingsRow {
  const _SettingsRow(
      {required this.label,
      required this.options,
      required this.selected,
      required this.onSelected,
      this.overridden = false});
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  /// Whether the field is set apart from its tab's choice.
  final bool overridden;
}

/// One edit tab: its own choice, then the fields it shows.
class _SettingsGroup {
  const _SettingsGroup(
      {required this.label,
      required this.options,
      required this.selected,
      required this.onSelected,
      required this.rows});
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<_SettingsRow> rows;
}

class _SelectAll {
  const _SelectAll({required this.key, required this.onTap});
  final Key key;
  final VoidCallback onTap;
}

/// The reference's bordered table: a grey header row, a row of Select all
/// buttons, then one row per setting with a joined button group. Each edit
/// tab adds a shaded row of its own before its fields.
class _SettingsTable extends StatelessWidget {
  const _SettingsTable({
    required this.nameFlex,
    required this.optionsFlex,
    required this.headers,
    required this.selectAll,
    required this.groups,
  });

  final int nameFlex;
  final int optionsFlex;
  final List<String> headers;
  final List<_SelectAll> selectAll;
  final List<_SettingsGroup> groups;

  static const _bold =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white);
  static const _side = BorderSide(color: _cellBorder);

  Widget _row(
          {required Widget name,
          required Widget options,
          Color? color,
          bool header = false}) =>
      Container(
        color: color,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                flex: nameFlex,
                child: header
                    ? name
                    : DecoratedBox(
                        decoration: const BoxDecoration(
                            border: Border(right: _side, bottom: _side)),
                        child: name)),
            Expanded(
                flex: optionsFlex,
                child: header
                    ? options
                    : DecoratedBox(
                        decoration:
                            const BoxDecoration(border: Border(bottom: _side)),
                        child: options)),
          ]),
        ),
      );

  Widget _label(String text, {double indent = 0, bool overridden = false}) =>
      Padding(
        padding: EdgeInsets.fromLTRB(5 + indent, 5, 5, 5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(text: text, style: _bold, children: [
              if (overridden)
                const TextSpan(
                    text: '  •', style: TextStyle(color: Color(0xff5eb1de))),
            ]),
            semanticsLabel: overridden ? '$text, set apart from its tab' : text,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final optionCount = groups.firstOrNull?.options.length ?? headers.length;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: _paneColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _row(
          header: true,
          color: _headerColor,
          name: const SizedBox(height: 37),
          options: Row(children: [
            for (final header in headers)
              Expanded(
                child: Center(
                  child:
                      Text(header, textAlign: TextAlign.center, style: _bold),
                ),
              ),
          ]),
        ),
        _row(
          name: const SizedBox(height: 48),
          options: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              for (var i = 0; i < selectAll.length; i++) ...[
                if (i > 0) SizedBox(width: optionCount == 2 ? 3 : 16),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: Material(
                      key: selectAll[i].key,
                      color: _selectAllColor,
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: selectAll[i].onTap,
                        child: const Center(
                            child: Text('Select all',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white))),
                      ),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ),
        for (final group in groups) ...[
          _row(
            color: _groupColor,
            name: _label(group.label),
            options: _ButtonGroup(
                options: group.options,
                selected: group.selected,
                onSelected: group.onSelected),
          ),
          for (final row in group.rows)
            _row(
              name: _label(row.label, indent: 16, overridden: row.overridden),
              options: _ButtonGroup(
                  options: row.options,
                  selected: row.selected,
                  onSelected: row.onSelected),
            ),
        ],
      ]),
    );
  }
}

/// The reference's justified radio group: joined 34 px buttons with a grey
/// outline, rounded only at the ends.
class _ButtonGroup extends StatelessWidget {
  const _ButtonGroup(
      {required this.options,
      required this.selected,
      required this.onSelected});
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = appPalette(context).utilityAction;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        height: 34,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            border: Border.all(color: _optionBorder),
            borderRadius: BorderRadius.circular(4)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0)
              const ColoredBox(color: _optionBorder, child: SizedBox(width: 1)),
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                child: Material(
                  color: i == selected ? selectedColor : _optionColor,
                  child: InkWell(
                    onTap: () => onSelected(i),
                    child: Center(
                      child: Text(options[i],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
