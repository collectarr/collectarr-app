import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/settings/custom_field_dialog.dart';
import 'package:flutter/material.dart';

/// Disposable sample values rendered by the real custom-field controls.
/// Preview values are never included in a definition or persisted.
class CustomFieldPreview extends StatelessWidget {
  const CustomFieldPreview(
      {super.key,
      required this.name,
      required this.type,
      required this.options,
      required this.unit,
      required this.display,
      required this.revision});
  final String name;
  final CustomFieldValueType type;
  final List<String> options;
  final String unit;
  final CustomFieldDisplaySettings display;
  final int revision;
  @override
  Widget build(BuildContext context) {
    final palette = customFieldPalette(context);
    final choices = options.where((e) => e.trim().isNotEmpty).toList();
    final demoOptions = choices.isNotEmpty
        ? choices
        : type.isFixedChoice
            ? ['Value 1', 'Value 2', 'Value 3']
            : display.multiValueControl ==
                    CustomFieldMultiValueControl.personList
                ? ['Jane Doe', 'Joe Public', 'John Doe']
                : [
                    'Option 1',
                    'Option 10',
                    'Option 100',
                    'Option 2',
                    'Option 3'
                  ];
    final sample = switch (type) {
      CustomFieldValueType.number => '13',
      CustomFieldValueType.text => 'Lorem ipsum dolor sit amet.',
      CustomFieldValueType.longText =>
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vitae nibh ac nisi rhoncus cursus. Nam posuere, nisi at convallis consequat, sapien mi facilisis nulla, vitae rutrum augue sem sed est.',
      CustomFieldValueType.date =>
        DateTime.now().toIso8601String().split('T').first,
      CustomFieldValueType.fixedButtons => demoOptions.first,
      CustomFieldValueType.duration => '2:17',
      CustomFieldValueType.decimal ||
      CustomFieldValueType.currency ||
      CustomFieldValueType.percentage ||
      CustomFieldValueType.weight ||
      CustomFieldValueType.size =>
        display.numericStorage == CustomFieldNumericStorage.number
            ? '42'
            : '13.37',
      CustomFieldValueType.singleSelect ||
      CustomFieldValueType.fixedList =>
        demoOptions.first,
      CustomFieldValueType.multiSelect =>
        encodeCustomFieldMultiValues(demoOptions.take(3)),
      _ => null,
    };
    final encodedOptions = type.hasUnit
        ? encodeCustomFieldOptions([unit])
        : type.supportsOptions
            ? encodeCustomFieldOptions(demoOptions)
            : null;
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        color: palette.divider,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Preview',
              style: TextStyle(
                  fontSize: 18,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary.withValues(alpha: .7))),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 7),
              decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(3)),
              child: ExcludeFocus(
                  child: IgnorePointer(
                      child: CustomFieldsEditSection(
                          key: ValueKey(
                              'preview:$revision:${options.join('|')}:${type.name}:$name'),
                          preview: true,
                          displaySettings: {'preview': display},
                          definitions: [
                            CustomFieldDefinition(
                                id: 'preview',
                                name: name.trim().isEmpty
                                    ? 'Field Name'
                                    : name.trim(),
                                fieldType: type.apiValue,
                                options: encodedOptions,
                                createdAt: DateTime.utc(2026))
                          ],
                          values: {'preview': sample},
                          accent: Theme.of(context).colorScheme.primary,
                          onChanged: (_) {})))),
        ]));
  }
}
