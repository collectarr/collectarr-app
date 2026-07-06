import 'package:flutter/material.dart';

class PickListMultiValueField extends StatelessWidget {
  const PickListMultiValueField({
    super.key,
    required this.label,
    required this.values,
    required this.selectedValues,
    required this.onChanged,
    this.onAddValue,
    this.onManageList,
    this.enabled = true,
  });

  final String label;
  final List<String> values;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback? onAddValue;
  final VoidCallback? onManageList;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final remaining = values.where((value) => !selectedValues.contains(value)).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final value in selectedValues)
                InputChip(
                  label: Text(value),
                  onDeleted: enabled
                      ? () {
                          final next = [...selectedValues]..remove(value);
                          onChanged(next);
                        }
                      : null,
                ),
              DropdownButton<String>(
                value: null,
                hint: Text(remaining.isEmpty ? 'No more values' : 'Add value'),
                items: [
                  for (final option in remaining)
                    DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                ],
                onChanged: !enabled
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        final next = [...selectedValues, value];
                        onChanged(next);
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: enabled ? onAddValue : null,
              icon: const Icon(Icons.add),
              label: const Text('Add value'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: enabled ? onManageList : null,
              icon: const Icon(Icons.tune),
              label: const Text('Manage list'),
            ),
          ],
        ),
      ],
    );
  }
}
