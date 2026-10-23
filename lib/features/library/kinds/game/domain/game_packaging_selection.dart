import '../entries/game_entry_details.dart';

/// Packaging changes keep the chosen completeness tier and update an unlocked
/// Loose amount only when every needed recorded component uses its currency.
final class GamePackagingSelection {
  const GamePackagingSelection._(this.details, this.valueCents);
  factory GamePackagingSelection(
      {required GameEntryDetails current,
      required int? valueCents,
      required String currency,
      required bool hasBox,
      required bool hasManual}) {
    final next = current.copyWith(hasBox: hasBox, hasManual: hasManual);
    final values = current.valuations;
    final loose = values?.loose;
    if (current.completeness != 'loose' ||
        current.valueIsLocked == true ||
        loose == null) {
      return GamePackagingSelection._(next, valueCents);
    }
    final components = [
      loose,
      if (hasBox) values?.boxOnly,
      if (hasManual) values?.manualOnly
    ];
    if (components.any((amount) =>
        amount == null ||
        amount.currency.toUpperCase() != currency.toUpperCase())) {
      return GamePackagingSelection._(next, valueCents);
    }
    return GamePackagingSelection._(
        next,
        components.fold<int>(
            0, (total, amount) => total + amount!.amountCents));
  }
  final GameEntryDetails details;
  final int? valueCents;
}
