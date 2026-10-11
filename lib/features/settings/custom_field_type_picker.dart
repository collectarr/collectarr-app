import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';

final customFieldTypeChoices =
    <CustomFieldValueType, (String, String, IconData)>{
  CustomFieldValueType.text: ('Text', 'Single-line text', Icons.text_fields),
  CustomFieldValueType.longText: (
    'Text Area',
    'Multi-line text field',
    Icons.notes
  ),
  CustomFieldValueType.boolean: (
    'Toggle',
    'Yes or No',
    Icons.toggle_on_outlined
  ),
  CustomFieldValueType.number: ('Number', 'Whole numbers only', Icons.numbers),
  CustomFieldValueType.decimal: (
    'Decimal',
    'Number with 2 decimals',
    Icons.calculate_outlined
  ),
  CustomFieldValueType.currency: (
    'Currency',
    'Monetary value',
    Icons.payments_outlined
  ),
  CustomFieldValueType.percentage: (
    'Percentage',
    'Whole number or 2 decimals',
    Icons.percent
  ),
  CustomFieldValueType.weight: (
    'Weight',
    'In pounds or kilograms',
    Icons.scale_outlined
  ),
  CustomFieldValueType.size: (
    'Size',
    'In inches or centimeters',
    Icons.straighten
  ),
  CustomFieldValueType.singleSelect: (
    'Pick List',
    'Pick a value from a manageable list',
    Icons.list_alt
  ),
  CustomFieldValueType.multiSelect: (
    'Multi-Value Pick List',
    'Pick multiple values from a manageable list',
    Icons.checklist
  ),
  CustomFieldValueType.fixedButtons: (
    'Fixed Button Bar',
    'Choose one from max. 4 fixed options',
    Icons.view_week_outlined
  ),
  CustomFieldValueType.fixedList: (
    'Fixed List',
    'Choose one from max. 20 fixed options',
    Icons.arrow_drop_down_circle_outlined
  ),
  CustomFieldValueType.date: (
    'Date',
    'Full or partial date, with date picker',
    Icons.calendar_month
  ),
  CustomFieldValueType.duration: (
    'Duration',
    'In hours and minutes',
    Icons.timer_outlined
  ),
  CustomFieldValueType.time: ('Time', 'Time of day', Icons.schedule),
  CustomFieldValueType.url: ('URL', 'Web address', Icons.link),
  CustomFieldValueType.person: (
    'Person / contact',
    'Contact name',
    Icons.person_outline
  ),
};

class CustomFieldTypePicker extends StatelessWidget {
  const CustomFieldTypePicker({super.key});

  @override
  Widget build(BuildContext context) => AccentAlertDialog(
        title: const Text('Add Custom Field'),
        content: SizedBox(
          width: 552,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Choose which type of field you want to add:'),
                const SizedBox(height: 12),
                for (final choice in customFieldTypeChoices.entries)
                  ListTile(
                    key: ValueKey('custom_field.type.${choice.key.name}'),
                    dense: true,
                    leading: Icon(choice.value.$3),
                    title: Text(choice.value.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(choice.value.$2),
                    onTap: () => Navigator.pop(context, choice.key),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      );
}
