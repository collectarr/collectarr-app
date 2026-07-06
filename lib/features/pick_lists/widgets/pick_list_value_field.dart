import 'package:flutter/material.dart';

class PickListValueField extends StatelessWidget {
  const PickListValueField({
    super.key,
    required this.label,
    required this.values,
    required this.value,
    required this.onChanged,
    this.onAddValue,
    this.onManageList,
    this.enabled = true,
  });

  final String label;
  final List<String> values;
  final String? value;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onAddValue;
  final VoidCallback? onManageList;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            initialValue: value,
            isExpanded: true,
            decoration: InputDecoration(labelText: label),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(''),
              ),
              for (final option in values)
                DropdownMenuItem<String?>(
                  value: option,
                  child: Text(option),
                ),
            ],
            onChanged: enabled ? onChanged : null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Add value',
          onPressed: enabled ? onAddValue : null,
          icon: const Icon(Icons.add),
        ),
        IconButton(
          tooltip: 'Manage list',
          onPressed: enabled ? onManageList : null,
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }
}
