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
}) {
  return showDialog<PickListValue>(
    context: context,
    builder: (context) => _PickListValueEditorDialog(
      listName: listName,
      label: label,
      mediaKind: mediaKind,
      existing: existing,
    ),
  );
}

class _PickListValueEditorDialog extends StatefulWidget {
  const _PickListValueEditorDialog({
    required this.listName,
    required this.label,
    this.mediaKind,
    this.existing,
  });

  final String listName;
  final String label;
  final String? mediaKind;
  final PickListValue? existing;

  @override
  State<_PickListValueEditorDialog> createState() =>
      _PickListValueEditorDialogState();
}

class _PickListValueEditorDialogState extends State<_PickListValueEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.value ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      PickListValue(
        id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        listName: widget.listName,
        mediaKind: widget.mediaKind,
        value: value,
        sortOrder: widget.existing?.sortOrder ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      backgroundColor: appPalette(context).panel,
      title: Text(widget.existing == null ? 'Add ${widget.label} value' : 'Edit ${widget.label} value'),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
          ),
        ),
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
