import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/settings/custom_field_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

final customFieldTypeChoices =
    <CustomFieldValueType, (String, String, IconData)>{
  CustomFieldValueType.text: (
    'Text',
    'Single-line text (max. 250 characters)',
    AppIcons.customFieldText
  ),
  CustomFieldValueType.longText: (
    'Text Area',
    'Multi-line text field',
    AppIcons.customFieldTextArea
  ),
  CustomFieldValueType.boolean: (
    'Toggle',
    'Yes or No',
    AppIcons.customFieldToggle
  ),
  CustomFieldValueType.number: (
    'Number',
    'Whole numbers only',
    AppIcons.customFieldText
  ),
  CustomFieldValueType.decimal: (
    'Decimal',
    'Number with 2 decimals',
    AppIcons.customFieldText
  ),
  CustomFieldValueType.currency: (
    'Currency',
    'Monetary value',
    AppIcons.customFieldCurrency
  ),
  CustomFieldValueType.percentage: (
    'Percentage',
    'As a whole number or with 2 decimals',
    AppIcons.customFieldPercentage
  ),
  CustomFieldValueType.weight: (
    'Weight',
    'In pounds or kilograms',
    AppIcons.customFieldWeight
  ),
  CustomFieldValueType.size: (
    'Size',
    'In inches or centimeters',
    AppIcons.customFieldSize
  ),
  CustomFieldValueType.singleSelect: (
    'Pick List',
    'Pick a single value from a manageable pick list',
    AppIcons.customFieldPickList
  ),
  CustomFieldValueType.multiSelect: (
    'Multi-Value Pick List',
    'Pick multiple values from a manageable pick list',
    AppIcons.customFieldMultiPickList
  ),
  CustomFieldValueType.fixedButtons: (
    'Fixed Button Bar',
    'Choose one from max. 4 fixed options',
    AppIcons.customFieldPickList
  ),
  CustomFieldValueType.fixedList: (
    'Fixed List',
    'Choose one from a list of max. 20 fixed options',
    AppIcons.customFieldFixedList
  ),
  CustomFieldValueType.date: (
    'Date',
    'Full or partial date, with date picker',
    AppIcons.customFieldDate
  ),
  CustomFieldValueType.duration: (
    'Duration',
    'In hours and minutes',
    AppIcons.customFieldDuration
  ),
  CustomFieldValueType.time: (
    'Time',
    'Time of day',
    AppIcons.customFieldDuration
  ),
  CustomFieldValueType.url: ('URL', 'Web address', AppIcons.link),
  CustomFieldValueType.person: (
    'Person / contact',
    'Contact name',
    AppIcons.customFieldPerson
  ),
};

class CustomFieldTypePicker extends StatefulWidget {
  const CustomFieldTypePicker({super.key});

  @override
  State<CustomFieldTypePicker> createState() => _CustomFieldTypePickerState();
}

class _CustomFieldTypePickerState extends State<CustomFieldTypePicker> {
  bool _showAdditional = false;
  @override
  Widget build(BuildContext context) => CustomFieldDialog(
        title: 'Add Custom Field',
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'))
        ],
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Choose which type of field you want to add:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 15),
                  LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 520
                        ? 3
                        : constraints.maxWidth >= 330
                            ? 2
                            : 1;
                    final choices = customFieldTypeChoices.entries
                        .take(_showAdditional ? 18 : 15)
                        .toList();
                    final width =
                        (constraints.maxWidth - (columns - 1) * 15) / columns;
                    return Column(children: [
                      for (var start = 0;
                          start < choices.length;
                          start += columns) ...[
                        if (start > 0) const SizedBox(height: 15),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = start;
                                  i < start + columns && i < choices.length;
                                  i++) ...[
                                if (i > start) const SizedBox(width: 15),
                                SizedBox(
                                    width: width,
                                    height:
                                        start == 3 && columns == 3 ? 104 : 121,
                                    child: _TypeCard(
                                        type: choices[i].key,
                                        choice: choices[i].value)),
                              ],
                            ]),
                      ],
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                              onPressed: () => setState(
                                  () => _showAdditional = !_showAdditional),
                              icon: Icon(
                                  _showAdditional
                                      ? AppIcons.chevronUp
                                      : AppIcons.chevronDown,
                                  size: 12),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 20)),
                              label: const Text('More field types'))),
                    ]);
                  }),
                ])),
      );
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.choice});
  final CustomFieldValueType type;
  final (String, String, IconData) choice;
  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(
              color: palette.isDark
                  ? palette.textPrimary.withValues(alpha: .8)
                  : palette.textMuted)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          key: ValueKey('custom_field.type.${type.name}'),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: Theme.of(context).colorScheme.primary,
          onTap: () => Navigator.pop(context, type),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child: Column(children: [
                SizedBox(
                    height: 26,
                    child: CustomFieldTypeIcon(type: type, size: 26)),
                const SizedBox(height: 10),
                Text(choice.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary)),
                const SizedBox(height: 5),
                Expanded(
                    child: Text(choice.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: palette.textPrimary.withValues(alpha: .5)))),
              ]))),
    );
  }
}

class CustomFieldTypeIcon extends StatelessWidget {
  const CustomFieldTypeIcon({super.key, required this.type, this.size = 24});
  final CustomFieldValueType type;
  final double size;
  @override
  Widget build(BuildContext context) {
    if (type == CustomFieldValueType.text) {
      return SvgPicture.asset(AppIcons.customFieldTextSvg,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(
              appPalette(context).textPrimary, BlendMode.srcIn));
    }
    if (type == CustomFieldValueType.number ||
        type == CustomFieldValueType.decimal) {
      return Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: appPalette(context).textPrimary, width: 2),
                  borderRadius: BorderRadius.circular(2)),
              child: Text(type == CustomFieldValueType.number ? '42' : '1.50',
                  style: TextStyle(
                      fontSize: size * .5,
                      height: 1,
                      fontWeight: FontWeight.w700))));
    }
    if (type == CustomFieldValueType.fixedButtons) {
      return Center(
          child: Container(
              width: size * 2,
              height: size * .7,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: appPalette(context).textPrimary, width: 2),
                  borderRadius: BorderRadius.circular(2)),
              child: Row(children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              border: i < 2
                                  ? Border(
                                      right: BorderSide(
                                          color:
                                              appPalette(context).textPrimary))
                                  : null)))
              ])));
    }
    return Icon(customFieldTypeChoices[type]!.$3, size: size);
  }
}
