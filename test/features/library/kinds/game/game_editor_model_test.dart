import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_item_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_item_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_adapters.dart';
import 'package:flutter_test/flutter_test.dart';

GameCatalogMetadata _metadata() => GameCatalogMetadata.fromJson({
      'id': 'game-1',
      'kind': 'game',
      'title': 'Starlight Courier',
      'platforms': ['PC', 'Xbox One'],
      'publisher': 'Northwind / Bluefield',
      'developers': ['Harbor Studio'],
      'release_date_parts': {'year': 2014, 'month': 11},
      'franchise': 'Courier',
      'genres': ['Action/Adventure'],
      'trailer_urls': [
        {'url': 'https://youtu.be/x', 'kind': 'trailer'},
      ],
    });

void main() {
  test('form values follow the reference Main tab', () {
    final values = gameCatalogFormValuesFromMetadata(_metadata());
    expect(values.platform, 'PC');
    expect(values.publishers, ['Northwind', 'Bluefield']);
    expect(values.releaseDateParts?.isoString, '2014-11');
    expect(gameEditHeaderTitle(_metadata()), 'Starlight Courier (PC)');
  });

  test('saving keeps Core fields without an editor and extra platforms', () {
    final metadata = _metadata();
    final values = gameCatalogFormValuesFromMetadata(metadata)
      ..sortTitle = 'Courier, Starlight';
    final saved = applyGameCatalogFormValues(
        current: metadata, values: values, title: values.title);
    expect(saved.platforms, ['PC', 'Xbox One']);
    expect(saved.franchise, 'Courier');
    expect(saved.sortKey, 'Courier, Starlight');
    expect(saved.publisher, 'Northwind / Bluefield');

    values.platform = 'Nintendo Switch';
    final moved = applyGameCatalogFormValues(
        current: metadata, values: values, title: values.title);
    expect(moved.platforms, ['Nintendo Switch']);
  });

  test('editor draft keeps links and trailers apart', () {
    final draft = GameItemEditDraft.fromMetadata(_metadata());
    expect(draft.links, isEmpty);
    expect(draft.trailers.single.url, 'https://youtu.be/x');
    final saved = draft.toMetadata();
    expect(saved.links.where((link) => link.isTrailerLink), hasLength(1));
  });

  test('entry details round-trip storage and completion', () {
    final details = GameEntryDetails(
      storageDevice: 'Switch OLED',
      storageSlot: 'SD 2',
      completed: true,
      completedDate: const PartialDate(year: 2026, month: 3),
    );
    final restored = GameEntryDetails.fromJson(details.toJson());
    expect(restored, details);

    final personal = GamePersonalData.fromJson({
      ...details.toJson(),
      'quantity': 2,
      'rating': 8,
      'purchase_date_parts': {'year': 2025},
    });
    expect(personal.quantity, 2);
    expect(personal.rating, 8);
    expect(personal.purchaseDateParts?.isoString, '2025');
    expect(personal.details.completed, isTrue);
  });

  test('valuation tiers feed the chart and completeness choice', () {
    ValuationSnapshot amount(int cents) => ValuationSnapshot(
          source: ValuationSource.values.first,
          amountCents: cents,
          currency: 'USD',
          capturedAt: DateTime.utc(2026),
        );
    final valuations = GameValuationSet(
      loose: amount(800),
      boxOnly: amount(700),
      cib: amount(1758),
      newSealed: amount(3600),
    );
    expect(valuations.amountForCompleteness('cib'), 1758);
    expect(valuations.amountForCompleteness('na'), isNull);
    expect(valuations.chartTiers.map((tier) => tier.$1),
        ['Loose', 'Loose + Box', 'CIB', 'New']);
    expect(valuations.chartTiers[1].$2, 1500);
  });

  test('value summary reads as the reference pill', () {
    expect(gameValueSummary(const GamePersonalData()), isNull);
    final summary = gameValueSummary(const GamePersonalData(
      marketValueCents: 1758,
      currency: 'USD',
      details: GameEntryDetails(completeness: 'cib'),
    ));
    expect(summary, startsWith('CIB | '));
    expect(summary, contains('17.58'));
  });
}
