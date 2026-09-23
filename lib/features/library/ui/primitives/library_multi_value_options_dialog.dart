import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:flutter/material.dart';

Future<Set<TValue>?> showLibraryMultiValueOptionsDialog<TValue>({
  required BuildContext context,
  required String label,
  required List<LibraryFieldOption<TValue>> options,
  required Set<TValue> selectedValues,
  bool allowCustomValues = true,
}) {
  return showDialog<Set<TValue>>(
    context: context,
    builder: (context) => _LibraryMultiValueOptionsDialog<TValue>(
      label: label,
      options: options,
      selectedValues: selectedValues,
      allowCustomValues: allowCustomValues,
    ),
  );
}

class _LibraryMultiValueOptionsDialog<TValue> extends StatefulWidget {
  const _LibraryMultiValueOptionsDialog({
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.allowCustomValues,
  });

  final String label;
  final List<LibraryFieldOption<TValue>> options;
  final Set<TValue> selectedValues;
  final bool allowCustomValues;

  @override
  State<_LibraryMultiValueOptionsDialog<TValue>> createState() =>
      _LibraryMultiValueOptionsDialogState<TValue>();
}

class _LibraryMultiValueOptionsDialogState<TValue>
    extends State<_LibraryMultiValueOptionsDialog<TValue>> {
  late final Set<TValue> _selected = {...widget.selectedValues};
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustomValue() {
    final text = _customController.text.trim();
    if (text.isEmpty || TValue != String) return;
    setState(() {
      _selected.add(text as TValue);
      _customController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleOptions = <LibraryFieldOption<TValue>>[
      ...widget.options,
      for (final value in _selected)
        if (!widget.options.any((option) => option.value == value))
          LibraryFieldOption<TValue>(value: value, label: value.toString()),
    ];
    return AccentAlertDialog(
      title: AccentDialogHeader(
        title: 'Select ${widget.label}',
        icon: Icons.list_alt_outlined,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in visibleOptions)
                CheckboxListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(option.label),
                  value: _selected.contains(option.value),
                  onChanged: option.enabled
                      ? (checked) => setState(() {
                            if (checked ?? false) {
                              _selected.add(option.value);
                            } else {
                              _selected.remove(option.value);
                            }
                          })
                      : null,
                ),
              if (widget.allowCustomValues && TValue == String) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customController,
                        decoration: const InputDecoration(
                          labelText: 'Add value',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addCustomValue(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Add value',
                      onPressed: _addCustomValue,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(Set.unmodifiable(_selected)),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
