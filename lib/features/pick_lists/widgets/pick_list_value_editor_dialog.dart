import 'pick_list_chrome.dart';
import 'package:uuid/uuid.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
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
  return showAppDialog<PickListValue>(
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
  late final TextEditingController _email;
  late final TextEditingController _address;
  String? _nameError;

  // Borrowers carry contact details, as CLZ loaners do.
  bool get _isBorrower => widget.listName == 'borrower';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.value ?? '');
    _sortName = TextEditingController(text: widget.existing?.sortName ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
    _address = TextEditingController(text: widget.existing?.address ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _sortName.dispose();
    _email.dispose();
    _address.dispose();
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
        email: _isBorrower && _email.text.trim().isNotEmpty
            ? _email.text.trim()
            : null,
        address: _isBorrower && _address.text.trim().isNotEmpty
            ? _address.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickListDialog(
        child: Material(
            color: pickListSurface(context),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PickListHeader(
                      onClose: () => Navigator.of(context).pop(),
                      title: widget.title ??
                          (widget.existing == null
                              ? 'Add ${widget.label} value'
                              : 'Edit ${widget.label} value')),
                  Padding(
                    padding: const EdgeInsets.all(15),
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
                      if (_isBorrower) ...[
                        const SizedBox(height: 12),
                        TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(
                            controller: _address,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                                labelText: 'Address',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder())),
                      ],
                    ]),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FilledButton(
                              style: pickListButtonStyle(context,
                                  primary: false, footer: true),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 5),
                            FilledButton(
                              style: pickListButtonStyle(context, footer: true),
                              onPressed: _submit,
                              child: const Text('Save'),
                            ),
                          ])),
                ])));
  }
}
