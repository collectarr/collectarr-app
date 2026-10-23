import '../entries/game_entry_details.dart';
import 'game_value_summary.dart';

/// One completeness change, including its packaging and recorded valuation.
/// Applied together so immutable Add drafts never lose half of the change.
final class GameCompletenessSelection {
  const GameCompletenessSelection._(this.details, this.valueCents);

  factory GameCompletenessSelection({
    required GameEntryDetails current,
    required int? valueCents,
    required String? completeness,
  }) {
    final tier = completeness ?? 'na';
    if (!gameCompletenessOptions.any((option) => option.$1 == tier)) {
      throw ArgumentError.value(completeness, 'completeness');
    }
    final includesPackaging =
        tier == 'cib' || tier == 'new' || tier == 'graded';
    final amount = current.valuations?.amountForCompleteness(tier);
    return GameCompletenessSelection._(
      current.copyWith(
        completeness: tier == 'na' ? null : tier,
        hasBox: includesPackaging,
        hasManual: includesPackaging,
      ),
      current.valueIsLocked == true ? valueCents : amount ?? valueCents,
    );
  }

  final GameEntryDetails details;
  final int? valueCents;
}
