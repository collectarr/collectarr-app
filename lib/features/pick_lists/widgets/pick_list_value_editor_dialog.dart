import 'pick_list_chrome.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
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
                  // Reference layout: 16/700 labels over the fields, Name
                  // and Sort Name side by side.
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: _LabeledField(
                                        label: widget.valueFieldLabel,
                                        child: TextField(
                                          controller: _controller,
                                          autofocus: true,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (_) => _submit(),
                                          decoration:
                                              settingsSelectDecoration(context)
                                                  .copyWith(
                                                      errorText: _nameError),
                                        ))),
                                const SizedBox(width: 30),
                                Expanded(
                                    child: _LabeledField(
                                        label: 'Sort Name',
                                        child: TextField(
                                            controller: _sortName,
                                            textInputAction:
                                                TextInputAction.done,
                                            onSubmitted: (_) => _submit(),
                                            decoration: settingsSelectDecoration(
                                                    context)
                                                .copyWith(
                                                    hintText:
                                                        'Defaults to Name')))),
                              ]),
                          if (_isBorrower) ...[
                            _LabeledField(
                                label: 'Email',
                                child: TextField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(),
                                    decoration:
                                        settingsSelectDecoration(context))),
                            _LabeledField(
                                label: 'Address',
                                child: TextField(
                                    controller: _address,
                                    minLines: 3,
                                    maxLines: 5,
                                    decoration:
                                        settingsSelectDecoration(context))),
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ]),
      );
}
