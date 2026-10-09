import 'package:collectarr_app/core/models/partial_date.dart';

PartialDate? musicGroupDateParts(DateTime? value) =>
    value == null ? null : PartialDate.fromDateTime(value);

bool musicGroupHasText(String? value) => value?.trim().isNotEmpty == true;

String musicGroupYesNo(bool value) => value ? 'Yes' : 'No';

Iterable<String> musicGroupSplit(String? value) =>
    value?.split(',') ?? const [];

String? musicGroupMonthLabel(PartialDate? value) {
  final month = value?.month;
  if (month == null) return null;
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${month.toString().padLeft(2, '0')} - ${names[month - 1]}';
}
