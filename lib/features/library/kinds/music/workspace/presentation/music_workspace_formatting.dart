import 'package:collectarr_app/core/models/partial_date.dart';

String formatMusicCell(Object? value) => switch (value) {
      null => '',
      bool v => v ? 'Yes' : 'No',
      Iterable<Object?> v => v.map(formatMusicCell).join(' | '),
      PartialDate v => formatMusicPartialDate(v),
      DateTime v => formatMusicDate(v),
      _ => value.toString(),
    };

String formatMusicPartialDate(PartialDate? value) {
  if (value?.year == null) return '';
  if (value!.month == null) return '${value.year}';
  final date = value.asDateTime!;
  return value.day == null
      ? '${_months[date.month - 1]} ${date.year}'
      : formatMusicDate(date);
}

String formatMusicDate(DateTime? value) {
  if (value == null) return '';
  return '${_months[value.month - 1]} ${value.day.toString().padLeft(2, '0')}, ${value.year}';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

String formatMusicCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
