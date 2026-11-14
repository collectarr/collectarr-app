import 'package:collectarr_app/features/library/generic/folder_reorder_list.dart';
import 'package:collectarr_app/features/library/ui/primitives/field_selection.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

/// A field Pre-fill Settings can show, under its group in Pre-fill fields.
typedef PrefillFieldChoice = ({String id, String label, String group});

/// The reference's Pre-fill fields list: grouped fields with tick boxes on
/// the left and the chosen ones, in the order Pre-fill Settings shows them,
/// on the right. Returns the chosen ids, or null when cancelled.
Future<List<String>?> showPrefillFieldsDialog({
  required BuildContext context,
  required Color accent,
  required List<PrefillFieldChoice> choices,
  required List<String> selected,
}) =>
    showAppDialog<List<String>>(
      context: context,
      builder: (_) => _PrefillFieldsDialog(
          accent: accent, choices: choices, selected: selected),
    );

class _PrefillFieldsDialog extends StatefulWidget {
  const _PrefillFieldsDialog(
      {required this.accent, required this.choices, required this.selected});

  final Color accent;
  final List<PrefillFieldChoice> choices;
  final List<String> selected;

  @override
  State<_PrefillFieldsDialog> createState() => _PrefillFieldsDialogState();
}

class _PrefillFieldsDialogState extends State<_PrefillFieldsDialog> {
  late final List<String> _selected = [...widget.selected];
  final _search = TextEditingController();
  final _collapsed = <String>{};
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _label(String id) =>
      widget.choices.firstWhere((choice) => choice.id == id).label;

  /// A group's fields in alphabetical order, as the reference lists them.
  List<PrefillFieldChoice> _groupChoices(String group) => [
        for (final choice in widget.choices)
          if (choice.group == group &&
              choice.label.toLowerCase().contains(_query.toLowerCase()))
            choice,
      ]..sort((a, b) => a.label.compareTo(b.label));

  /// The reference's group order, then any other group as first listed.
  static const _groupOrder = ['Main', 'Value', 'Toy', 'Edition', 'Personal'];

  List<String> get _groups {
    final groups = {for (final choice in widget.choices) choice.group};
    return [
      for (final group in _groupOrder)
        if (groups.contains(group)) group,
      for (final group in groups)
        if (!_groupOrder.contains(group)) group,
    ];
  }

  void _toggle(String id) => setState(
      () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));

  void _toggleGroup(List<PrefillFieldChoice> choices) => setState(() {
        if (choices.every((choice) => _selected.contains(choice.id))) {
          _selected
              .removeWhere((id) => choices.any((choice) => choice.id == id));
        } else {
          for (final choice in choices) {
            if (!_selected.contains(choice.id)) _selected.add(choice.id);
          }
        }
      });

  LibraryFieldCheckState _groupCheck(List<PrefillFieldChoice> choices) {
    final count =
        choices.where((choice) => _selected.contains(choice.id)).length;
    return count == 0
        ? LibraryFieldCheckState.none
        : count == choices.length
            ? LibraryFieldCheckState.all
            : LibraryFieldCheckState.some;
  }

  @override
  Widget build(BuildContext context) => LibraryFieldSelectionDialog(
        title: 'Pre-fill fields',
        icon: AppIcons.settings,
        accent: widget.accent,
        confirmLabel: 'OK',
        onSave: () => Navigator.of(context).pop(_selected),
        child: LibraryFieldSelectionPanes(
          available: Column(children: [
            LibraryFieldSelectionSearch(
                controller: _search,
                onChanged: (value) => setState(() => _query = value)),
            const SizedBox(height: 10),
            Expanded(
                child: ListView(children: [
              for (final group in _groups)
                if (_groupChoices(group) case final choices
                    when choices.isNotEmpty)
                  LibraryFieldSelectionCategory(
                      title: group,
                      expanded:
                          _query.isNotEmpty || !_collapsed.contains(group),
                      onToggle: () => setState(() =>
                          _collapsed.remove(group) || _collapsed.add(group)),
                      check: _groupCheck(choices),
                      onToggleAll: () => _toggleGroup(choices),
                      children: [
                        for (final choice in choices)
                          LibraryFieldSelectionCheckbox(
                              key: ValueKey('prefill-field-${choice.id}'),
                              label: choice.label,
                              selected: _selected.contains(choice.id),
                              onTap: () => _toggle(choice.id)),
                      ]),
            ])),
          ]),
          selected: LibraryFolderReorderList(
              padding: const EdgeInsets.all(10),
              rowSpacing: 3,
              placeholderColor: const Color(0xff808080),
              itemCount: _selected.length,
              onReorder: (oldIndex, newIndex) => setState(() =>
                  _selected.insert(newIndex, _selected.removeAt(oldIndex))),
              itemBuilder: (context, index) {
                final id = _selected[index];
                return LibrarySelectedFieldRow(
                    key: ValueKey('prefill-selected-$id'),
                    handleKey: ValueKey('prefill-selected-$id-handle'),
                    label: _label(id),
                    removeTooltip: 'Remove field',
                    onRemove: () => setState(() => _selected.removeAt(index)));
              }),
        ),
      );
}
