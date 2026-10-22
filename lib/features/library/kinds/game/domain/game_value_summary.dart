import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';

/// Completeness tiers of the reference Value tab, keyed as stored.
const gameCompletenessOptions = [
  ('na', 'N/A'),
  ('loose', 'Loose'),
  ('cib', 'CIB'),
  ('new', 'New'),
  ('graded', 'Graded'),
];

/// "CIB | $ 17.58", as on the reference cards and details; null without a
/// completeness or value.
String? gameValueSummary(GamePersonalData personal) {
  final completeness = personal.details.completeness;
  final value = personal.marketValueCents;
  if (completeness == null && value == null) return null;
  final tier = gameCompletenessOptions
      .where((option) => option.$1 == completeness)
      .firstOrNull
      ?.$2;
  return [
    if (tier != null) tier,
    if (value != null)
      AppFormats.current
          .formatMoney(value, personal.currency ?? AppFormats.current.currency),
  ].join(' | ');
}
