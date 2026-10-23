import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/stats/game_collection_stats.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/data/game_toy_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/stats/library_family_stats_page.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures/test_constants.dart';

GameLibraryEntry _game(String id, String platform,
        {String? completeness, int? value, bool? completed}) =>
    GameLibraryEntry(
      id: LibraryEntryId(id),
      metadata: GameCatalogMetadata(
          title: 'Fictional $id',
          platforms: [platform],
          genres: const ['Action'],
          releaseDateParts: const PartialDate(year: 2014, month: 11, day: 14)),
      personal: GamePersonalData(
          marketValueCents: value,
          currency: 'USD',
          details: GameEntryDetails(
              completeness: completeness, completed: completed)),
      updatedAt: DateTime.utc(2026),
    );

void main() {
  test('Games facts split platforms by completeness and total values', () {
    final facts = GameCollectionFacts.of([
      _game('a', 'PC', completeness: 'cib', value: 1758, completed: true),
      _game('b', 'PC', completeness: 'loose', value: 1249),
      _game('c', 'PlayStation 4'),
    ]);

    expect(facts.byPlatform, {
      'PC': {'CIB': 1, 'Loose': 1},
      'PlayStation 4': {'N/A': 1},
    });
    expect(facts.tiers, ['Loose', 'CIB', 'New', 'Graded', 'N/A']);
    expect(facts.valueByPlatform, {'PC': 3007});
    expect(facts.valueByTier, {'CIB': 1758, 'Loose': 1249});
    expect(facts.valueByCurrency, {'USD': 3007});
    expect(facts.valuedCount, 2);
    expect(facts.completed, 1);
    expect(facts.byYear, {'2014': 3});
    expect(facts.byGenre, {'Action': 3});
  });

  testWidgets('the Games family page has one tab per collection',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final game = _game('game', 'PC', completeness: 'cib', value: 1758);
    final toy = GameToyLibraryEntry(
      id: const LibraryEntryId('toy'),
      metadata: const GameToyCatalogMetadata(
          title: 'Fictional Figure', toyType: 'Fictional Type'),
      personal: const GameToyPersonalData(marketValueCents: 606),
      updatedAt: DateTime.utc(2026),
    );
    final gameSummary = GameLibraryEntryProjection.toSummary(game);
    final toySummary = GameToyLibraryEntryProjection.toSummary(toy);
    final state = ShelfState.from(entrySummaries: [
      gameSummary,
      toySummary
    ], wishlistItems: [], libraryEntryDispatchesByRef: {
      gameSummary.ref: OpaqueLibraryEntryDispatch(
          ref: gameSummary.ref, kind: CatalogMediaKind.game, value: game),
      toySummary.ref: OpaqueLibraryEntryDispatch(
          ref: toySummary.ref, kind: CatalogMediaKind.gameToy, value: toy),
    });
    final collections = LibraryCollectionRepository(db);
    await collections.create('game', 'Games');
    await collections.create('game_toy', 'Toys');
    for (final ref in [gameSummary.ref, toySummary.ref]) {
      await db.into(db.libraryEntries).insert(LibraryEntriesCompanion.insert(
          id: ref.id.value,
          kind: ref.kind.apiValue,
          payloadJson: '{}',
          updatedAt: DateTime.utc(2026)));
      await collections.assignNewEntry(ref);
    }
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: LibraryFamilyStatsPage(
                type: defaultLibraryKindRegistry.require(CatalogMediaKind.game),
                state: state))));
    await pumpUntilSettled(tester);

    expect(
        find.text('1 game in 1 platform', findRichText: true), findsOneWidget);
    expect(find.text('Games by Platform'), findsOneWidget);
    expect(find.text('Games Completed'), findsOneWidget);

    await tester.tap(find.text('Toys'));
    await pumpUntilSettled(tester);
    expect(find.text('1 toy in 1 type', findRichText: true), findsOneWidget);
    expect(find.text('Toys by Type'), findsNWidgets(2));

    await tester.tap(find.text('Hardware'));
    await pumpUntilSettled(tester);
    expect(find.text('0 hardware in 0 platforms', findRichText: true),
        findsOneWidget);

    for (final width in [700.0, 380.0]) {
      await tester.binding.setSurfaceSize(Size(width, 850));
      await pumpUntilSettled(tester);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
