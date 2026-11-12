import 'package:collectarr_app/features/pick_lists/widgets/pick_list_chrome.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _dialogWidth = 400.0;
const _dialogHeight = 500.0;
const _rowHeight = 34.0;
const _actionWidth = 28.0;

typedef TitleCaseExceptionsChanged = Future<void> Function(
    List<String> words, List<String> disabled);

/// Row changes save immediately, as in the reference exception manager.
Future<void> showTitleCaseExceptionsDialog(
  BuildContext context, {
  required List<String> exceptions,
  required List<String> disabledExceptions,
  required Color accent,
  required TitleCaseExceptionsChanged onChanged,
}) =>
    showAppDialog<void>(
        context: context,
        builder: (_) => _ExceptionsDialog(
              exceptions: exceptions,
              disabledExceptions: disabledExceptions,
              accent: accent,
              onChanged: onChanged,
            ));

class _Exception {
  _Exception(this.word, this.enabled);
  String word;
  bool enabled;
}

class _ExceptionsDialog extends StatefulWidget {
  const _ExceptionsDialog(
      {required this.exceptions,
      required this.disabledExceptions,
      required this.accent,
      required this.onChanged});
  final List<String> exceptions;
  final List<String> disabledExceptions;
  final Color accent;
  final TitleCaseExceptionsChanged onChanged;
  @override
  State<_ExceptionsDialog> createState() => _ExceptionsDialogState();
}

class _ExceptionsDialogState extends State<_ExceptionsDialog> {
  late final _disabled = widget.disabledExceptions
      .map((word) => word.trim().toLowerCase())
      .toSet();
  late final _entries = [
    for (final word in widget.exceptions
        .map((word) => word.trim().toLowerCase())
        .where((word) => word.isNotEmpty)
        .toSet())
      _Exception(word, !_disabled.contains(word))
  ];
  final _word = TextEditingController();
  final _focus = FocusNode();
  int? _editing;
  bool _adding = false;
  String? _error;

  @override
  void dispose() {
    _word.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _beginEdit([int? index]) {
    setState(() {
      _adding = index == null;
      _editing = index;
      _error = null;
      _word.text = index == null ? '' : _entries[index].word;
      _word.selection =
          TextSelection(baseOffset: 0, extentOffset: _word.text.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _clearEdit() {
    _adding = false;
    _editing = null;
    _error = null;
    _word.clear();
  }

  Future<void> _publish() => widget.onChanged(
        [for (final entry in _entries) entry.word],
        [
          for (final entry in _entries)
            if (!entry.enabled) entry.word
        ],
      );

  Future<void> _apply() async {
    final word = _word.text.trim().toLowerCase();
    if (word.isEmpty || RegExp(r'[\s,]').hasMatch(word)) {
      setState(() => _error = 'Enter one word.');
      return;
    }
    if (_entries
        .asMap()
        .entries
        .any((entry) => entry.key != _editing && entry.value.word == word)) {
      setState(() => _error = 'This exception already exists.');
      return;
    }
    setState(() {
      if (_adding) {
        _entries.add(_Exception(word, true));
      } else {
        _entries[_editing!].word = word;
      }
      _clearEdit();
    });
    await _publish();
  }

  Future<void> _toggle(int index) async {
    setState(() => _entries[index].enabled = !_entries[index].enabled);
    await _publish();
  }

  Future<void> _delete(int index) async {
    setState(() {
      _entries.removeAt(index);
      if (_editing == index) {
        _clearEdit();
      } else if (_editing != null && _editing! > index) {
        _editing = _editing! - 1;
      }
    });
    await _publish();
  }

  Widget _editor() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: TextField(
                  key: const Key('exception-word'),
                  controller: _word,
                  focusNode: _focus,
                  onSubmitted: (_) => _apply(),
                  decoration: InputDecoration(
                      hintText: 'Exception',
                      errorText: _error,
                      isDense: true))),
          const SizedBox(width: 6),
          DialogActionButton(
              label: _adding ? 'Add' : 'Save',
              width: 60,
              primary: true,
              onPressed: _apply),
          IconButton(
              tooltip: 'Cancel edit',
              icon: const Icon(AppIcons.close),
              onPressed: () => setState(_clearEdit)),
        ]),
      );

  Widget _action(IconData icon, String label, VoidCallback onPressed) =>
      IconButton(
        tooltip: label,
        icon: Icon(icon, size: 16, color: appPalette(context).utilityAction),
        constraints: const BoxConstraints.tightFor(
            width: _actionWidth, height: _rowHeight),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      );

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return PickListDialog(
        child: SizedBox(
      width: _dialogWidth,
      height: _dialogHeight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AccentDialogHeader(title: 'Auto Cap Exceptions', accent: widget.accent),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      _adding ? setState(_clearEdit) : _beginEdit(),
                  icon: Icon(
                      _adding ? AppIcons.chevronDown : AppIcons.chevronRight,
                      size: 14),
                  label: const Text('Add new exception'),
                  style: TextButton.styleFrom(
                      foregroundColor: palette.utilityAction,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, _rowHeight)),
                )),
            if (_adding) _editor(),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No exceptions yet.'))
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        if (_editing == index) return _editor();
                        return Semantics(
                          checked: entry.enabled,
                          label: entry.word,
                          child: Material(
                            color: index.isEven
                                ? palette.tableOddRow
                                : palette.tableEvenRow,
                            child: InkWell(
                                onTap: () => _toggle(index),
                                child: SizedBox(
                                  height: _rowHeight,
                                  child: Row(children: [
                                    SizedBox(
                                        width: _actionWidth,
                                        child: Center(
                                            child: PickListCheckbox(
                                                selected: entry.enabled))),
                                    Expanded(
                                        child: Text(entry.word,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: kAppBodyFontSize,
                                                fontWeight:
                                                    kAppBoldFontWeight))),
                                    _action(
                                        AppIcons.inlineEdit,
                                        'Edit ${entry.word}',
                                        () => _beginEdit(index)),
                                    _action(
                                        AppIcons.delete,
                                        'Delete ${entry.word}',
                                        () => _delete(index)),
                                  ]),
                                )),
                          ),
                        );
                      }),
            ),
          ]),
        )),
      ]),
    ));
  }
}
