import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:flutter/material.dart';

class TagPickListField extends StatelessWidget {
  const TagPickListField({
    super.key,
    required this.controller,
    required this.options,
    required this.label,
    this.hint,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final List<String> options;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
        if (options.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Quick tags',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final selectedTags = splitPickListValues(value.text);
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in options)
                    FilterChip(
                      label: Text(option),
                      selected: _containsTag(selectedTags, option),
                      onSelected: enabled
                          ? (selected) =>
                              _toggleTag(option, selectedTags, selected)
                          : null,
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  bool _containsTag(List<String> selectedTags, String candidate) {
    return selectedTags.any(
      (tag) => tag.trim().toLowerCase() == candidate.trim().toLowerCase(),
    );
  }

  void _toggleTag(String option, List<String> selectedTags, bool selected) {
    final next = [...selectedTags];
    if (selected) {
      next.add(option);
    } else {
      next.removeWhere(
        (tag) => tag.trim().toLowerCase() == option.trim().toLowerCase(),
      );
    }
    final text = joinPickListValues(next) ?? '';
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}