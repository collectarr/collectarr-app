import 'package:collectarr_app/core/localization/app_formats.dart';
import 'game_hardware_personal_data.dart';

String? gameHardwareValueSummary(GameHardwarePersonalData personal) {
  final values = [
    if (personal.details.completeness?.label case final label?) label,
    if (personal.marketValueCents != null)
      AppFormats.current.formatMoney(personal.marketValueCents,
          personal.currency ?? AppFormats.current.currency)
  ];
  return values.isEmpty ? null : values.join(' | ');
}
