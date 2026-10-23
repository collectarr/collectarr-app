import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ValuationSnapshot amount(int cents) => ValuationSnapshot(
        source: ValuationSource.values.first,
        amountCents: cents,
        currency: 'USD',
        capturedAt: DateTime.utc(2026),
      );

  final valuations = GameValuationSet(
    loose: amount(800),
    cib: amount(1758),
    newSealed: amount(3600),
    graded: amount(4000),
  );

  test('Manual Add keeps completeness, packaging and value in one change', () {
    final original = GameAddDraft(
      quantity: 2,
      rating: 8,
      details: GameEntryDetails(valuations: valuations, storageSlot: 'SD 2'),
    );
    final cib = original.selectCompleteness('cib');
    expect(cib.details.completeness, 'cib');
    expect(cib.details.hasBox, isTrue);
    expect(cib.details.hasManual, isTrue);
    expect(cib.marketValueCents, 1758);
    expect(cib.details.storageSlot, 'SD 2');
    expect(cib.quantity, 2);
    expect(cib.rating, 8);
    expect(original.details.completeness, isNull);
    expect(original.marketValueCents, isNull);

    final loose = cib.selectCompleteness('loose');
    expect(loose.details.completeness, 'loose');
    expect(loose.details.hasBox, isFalse);
    expect(loose.details.hasManual, isFalse);
    expect(loose.marketValueCents, 800);
    expect(loose.selectCompleteness('new').marketValueCents, 3600);
    final graded = loose.selectCompleteness('graded');
    expect(graded.details.hasBox, isTrue);
    expect(graded.details.hasManual, isTrue);
    expect(graded.marketValueCents, 4000);
  });

  test('a locked value survives completeness and packaging changes', () {
    final locked = GameAddDraft(
      marketValueCents: 999,
      details: GameEntryDetails(valueIsLocked: true, valuations: valuations),
    ).selectCompleteness('cib');
    expect(locked.details.completeness, 'cib');
    expect(locked.details.hasBox, isTrue);
    expect(locked.details.hasManual, isTrue);
    expect(locked.marketValueCents, 999);
    expect(locked.details.valueIsLocked, isTrue);
  });

  test('without a recorded valuation the manually entered value survives', () {
    final draft =
        const GameAddDraft(marketValueCents: 1234).selectCompleteness('cib');
    expect(draft.marketValueCents, 1234);
    final cleared = draft.selectCompleteness(null);
    expect(cleared.details.completeness, isNull);
    expect(cleared.details.hasBox, isFalse);
    expect(cleared.details.hasManual, isFalse);
    expect(cleared.marketValueCents, 1234);
    expect(
        GameEntryDetails.fromJson(cleared.details.toJson()), cleared.details);
  });
}
