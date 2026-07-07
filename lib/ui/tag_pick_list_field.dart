import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:flutter/material.dart';

class MultiSelectPickListField extends StatelessWidget {
  const MultiSelectPickListField({
    super.key,
    required this.label,
    required this.values,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.emptyHint = 'Select values',
    this.pickerTitle,
    this.pickerSearchHint = 'Search values',
    this.allowCustomValues = true,
    this.customValueHint = 'Add value',
  });

  final String label;
  final List<String> values;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;
  final String emptyHint;
  final String? pickerTitle;
  final String pickerSearchHint;
  final bool allowCustomValues;
  final String customValueHint;

  @override
  Widget build(BuildContext context) {
    final selectedValues = mergePickListValues(
      builtInValues: values,
    );
    final selectableValues = mergePickListValues(
      builtInValues: options,
      selectedValues: selectedValues,
    );
    final hasValues = selectedValues.isNotEmpty;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: enabled && (selectableValues.isNotEmpty || allowCustomValues)
                ? () async {
                    final next = await _showSelector(
                      context,
                      initialValues: selectedValues,
                      selectableValues: selectableValues,
                      title: pickerTitle ?? label,
                      searchHint: pickerSearchHint,
                    );
                    if (next != null) {
                      onChanged(next);
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final value in selectedValues)
                    InputChip(
                      label: Text(value),
                    onPressed: enabled
                        ? () => _removeValue(selectedValues, value)
                        : null,
                    onDeleted: enabled
                        ? () => _removeValue(selectedValues, value)
                        : null,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (!hasValues)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        enabled ? emptyHint : '-',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (enabled && (selectableValues.isNotEmpty || allowCustomValues))
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeValue(List<String> currentValues, String value) {
    final next = [
      for (final current in currentValues)
        if (current.trim().toLowerCase() != value.trim().toLowerCase()) current,
    ];
    onChanged(next);
  }

  Future<List<String>?> _showSelector(
    BuildContext context, {
    required List<String> initialValues,
    required List<String> selectableValues,
    required String title,
    required String searchHint,
  }) {
    final selected = {...initialValues.map((value) => value.trim())};
    final customController = TextEditingController();
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredValues = selectableValues.where((value) {
              if (query.trim().isEmpty) {
                return true;
              }
              return value.toLowerCase().contains(query.trim().toLowerCase());
            }).toList(growable: false);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (allowCustomValues) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customController,
                              decoration: InputDecoration(
                                labelText: customValueHint,
                              ),
                              onSubmitted: (_) {
                                final value = customController.text.trim();
                                if (value.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  selected.add(value);
                                  customController.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              final value = customController.text.trim();
                              if (value.isEmpty) {
                                return;
                              }
                              setState(() {
                                selected.add(value);
                                customController.clear();
                              });
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      decoration: InputDecoration(
                        labelText: searchHint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => query = value),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final value in filteredValues)
                            CheckboxListTile(
                              value: selected.contains(value),
                              title: Text(value),
                              dense: true,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selected.add(value);
                                  } else {
                                    selected.remove(value);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(const <String>[]),
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(
                            mergePickListValues(
                              builtInValues: selected.toList(growable: false),
                            ),
                          ),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(customController.dispose);
  }
}

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
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final selected = splitPickListValues(value.text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultiSelectPickListField(
              label: label,
              values: selected,
              options: options,
              enabled: enabled,
              emptyHint: hint ?? 'Select values',
              pickerTitle: label,
              pickerSearchHint: hint ?? 'Search values',
              onChanged: (next) {
                final text = joinPickListValues(next) ?? '';
                controller.value = TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              },
            ),
            if (validator != null) ...[
              const SizedBox(height: 2),
              Builder(
                builder: (context) {
                  final validation = validator!(controller.text);
                  if (validation == null) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    validation,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
