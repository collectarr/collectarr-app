import 'package:collectarr_app/core/localization/app_formats.dart';

String formatGameDate(DateTime? value) =>
    value == null ? '' : AppFormats.current.formatDate(value);

String formatGameCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
