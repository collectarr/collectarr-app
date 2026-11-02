import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/game/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:flutter_test/flutter_test.dart';

ValuationSnapshot _amount(int amount, {String currency = 'USD'}) =>
    ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: amount,
        currency: currency,
        capturedAt: DateTime.utc(2026));
void main() {
  test(
      'Loose packaging sums recorded components and preserves its tier atomically',
      () {
    final original = GameAddDraft(
        marketValueCents: 799,
        details: GameEntryDetails(
            completeness: 'loose',
            valuations: GameValuationSet(
                loose: _amount(799),
                boxOnly: _amount(703),
                manualOnly: _amount(200))));
    final boxed = original.selectPackaging(
        hasBox: true, hasManual: false, currency: 'USD');
    expect(boxed.marketValueCents, 1502);
    expect(boxed.details.completeness, 'loose');
    expect(boxed.details.hasBox, isTrue);
    expect(original.details.hasBox, isNull);
    final both =
        boxed.selectPackaging(hasBox: true, hasManual: true, currency: 'USD');
    expect(both.marketValueCents, 1702);
    final loose =
        both.selectPackaging(hasBox: false, hasManual: false, currency: 'USD');
    expect(loose.marketValueCents, 799);
  });
  test(
      'locked, non-Loose, unavailable or foreign-currency components preserve the amount',
      () {
    final cases = [
      GameEntryDetails(
          completeness: 'loose',
          valueIsLocked: true,
          valuations:
              GameValuationSet(loose: _amount(799), boxOnly: _amount(703))),
      GameEntryDetails(
          completeness: 'cib',
          valuations:
              GameValuationSet(loose: _amount(799), boxOnly: _amount(703))),
      GameEntryDetails(
          completeness: 'loose',
          valuations: GameValuationSet(loose: _amount(799))),
      GameEntryDetails(
          completeness: 'loose',
          valuations: GameValuationSet(
              loose: _amount(799), boxOnly: _amount(703, currency: 'EUR'))),
    ];
    for (final details in cases) {
      final updated = GameAddDraft(marketValueCents: 999, details: details)
          .selectPackaging(hasBox: true, hasManual: false, currency: 'USD');
      expect(updated.marketValueCents, 999);
      expect(updated.details.hasBox, isTrue);
      expect(updated.details.completeness, details.completeness);
    }
  });
}
