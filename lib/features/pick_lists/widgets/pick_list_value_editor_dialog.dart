import 'package:uuid/uuid.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<PickListValue?> showPickListValueEditorDialog({
  required BuildContext context,
  required String listName,
  required String label,
  String? mediaKind,
  PickListValue? existing,
  String? title,
  String valueFieldLabel = 'Name',
}) {
  return showDialog<PickListValue>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PickListValueEditorDialog(
      listName: listName,
      label: label,
      mediaKind: mediaKind,
      existing: existing,
      title: title,
      valueFieldLabel: valueFieldLabel,
    ),
  );
}

class _PickListValueEditorDialog extends StatefulWidget {
  const _PickListValueEditorDialog({
    required this.listName,
    required this.label,
    this.mediaKind,
    this.existing,
    this.title,
    required this.valueFieldLabel,
  });

  final String listName;
  final String label;
  final String? mediaKind;
  final PickListValue? existing;
  final String? title;
  final String valueFieldLabel;

  @override
  State<_PickListValueEditorDialog> createState() =>
      _PickListValueEditorDialogState();
}

class _PickListValueEditorDialogState
    extends State<_PickListValueEditorDialog> {
  late final TextEditingController _controller;
  late final TextEditingController _sortName;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.value ?? '');
    _sortName = TextEditingController(text: widget.existing?.sortName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _sortName.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _nameError = 'Enter a name.');
      return;
    }
    Navigator.of(context).pop(
      PickListValue(
        id: widget.existing?.id ?? const Uuid().v4(),
        listName: widget.listName,
        mediaKind: widget.mediaKind,
        value: value,
        sortName: _sortName.text.trim().isEmpty ? null : _sortName.text.trim(),
        displayLabel: widget.existing?.displayLabel,
        aliases: widget.existing?.aliases ?? const [],
        isSystem: widget.existing?.isSystem ?? false,
        sortOrder: widget.existing?.sortOrder ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      backgroundColor: appPalette(context).panel,
      headerOnClose: () => Navigator.of(context).pop(),
      title: Text(widget.title ??
          (widget.existing == null
              ? 'Add ${widget.label} value'
              : 'Edit ${widget.label} value')),
      content: SizedBox(
        width: 520,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: widget.valueFieldLabel,
              errorText: _nameError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: _sortName,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                  labelText: 'Sort Name',
                  hintText: 'Defaults to Name',
                  border: OutlineInputBorder())),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
