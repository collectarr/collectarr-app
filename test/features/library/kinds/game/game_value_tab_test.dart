import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/kinds/game/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/value_tab.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/market_links.dart';
import 'package:flutter_test/flutter_test.dart';

GameValuationSet _values() {
  ValuationSnapshot amount(int cents) => ValuationSnapshot(
      source: ValuationSource.values.first,
      amountCents: cents,
      currency: 'USD',
      capturedAt: DateTime.utc(2026));
  return GameValuationSet(
      loose: amount(800), cib: amount(1758), boxOnly: amount(703));
}

void main() {
  Finder tier(String label) => find.descendant(
      of: find.byType(LibrarySegmentedChoiceField<String>),
      matching: find.text(label));
  for (final locked in [false, true]) {
    testWidgets('Manual Add applies completeness once (locked: $locked)',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final manual = LibraryAddManualDraft(
          customFieldValues: [],
          itemImages: [],
          kindDraft: GameAddManualDraft());
      addTearDown(manual.dispose);
      var personal = GameAddDraft(
          marketValueCents: 999,
          details:
              GameEntryDetails(valuations: _values(), valueIsLocked: locked));
      var emissions = 0;
      await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: StatefulBuilder(
          builder: (context, refresh) => GameAddManualPane(
            request: LibraryAddManualPaneRequest(
              kind: CatalogMediaKind.game,
              type: const GameRegistration(),
              accent: Colors.red,
              commonDraft: const LibraryAddCommonDraft(),
              kindDraft: personal,
              manualDraft: manual.kindDraft,
              tags: manual.tags,
              personalNotesController: manual.personalNotesController,
              coverPriceController: manual.coverPriceController,
              priceController: manual.priceController,
              purchaseDateController: manual.purchaseDateController,
              purchaseStoreController: manual.purchaseStoreController,
              sellPriceController: manual.sellPriceController,
              soldDateController: manual.soldDateController,
              ownerLabelController: manual.ownerLabelController,
              isAdding: false,
              defaultCondition: '',
              defaultLocationLabel: null,
              defaultPurchaseDate: null,
              defaultTags: null,
              onAddEntry: () {},
              onAddWishlist: () {},
              onAddTrack: () {},
              onPropose: () {},
              onKindDraftChanged: (value) => refresh(() {
                emissions++;
                personal = value as GameAddDraft;
              }),
            ),
          ),
        ))),
      ));
      await tester.tap(find.text('Value').first);
      await tester.pumpAndSettle();
      await tester.tap(tier('CIB'));
      await tester.pumpAndSettle();
      expect(emissions, 1);
      expect(personal.details.completeness, 'cib');
      expect(personal.details.hasBox, isTrue);
      expect(personal.details.hasManual, isTrue);
      expect(personal.marketValueCents, locked ? 999 : 1758);
      final valueField = tester.widget<TextField>(find.descendant(
          of: find.byWidgetPredicate((widget) =>
              widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>)
                  .value
                  .startsWith('game-value-')),
          matching: find.byType(TextField)));
      expect(valueField.readOnly, locked);
      await tester.tap(tier('Loose'));
      await tester.pumpAndSettle();
      expect(emissions, 2);
      expect(personal.details.completeness, 'loose');
      expect(personal.details.hasBox, isFalse);
      expect(personal.details.hasManual, isFalse);
      expect(personal.marketValueCents, locked ? 999 : 800);
      await tester.tap(find.text('Box').first);
      await tester.pumpAndSettle();
      expect(emissions, 3);
      expect(personal.details.completeness, 'loose');
      expect(personal.details.hasBox, isTrue);
      expect(personal.marketValueCents, locked ? 999 : 1503);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('Edit applies the same packaging and valuation rules',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final original = GameEntryDetails(valuations: _values()).toJson();
    final record = LibraryEntryRecord(
        id: 'game-1',
        kind: CatalogMediaKind.game,
        catalogData: {'title': 'Starlight Courier'},
        personalData: original,
        updatedAt: DateTime.utc(2026));
    final draft = LibraryEntryEditDraft(record);
    addTearDown(draft.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: ListenableBuilder(
        listenable: draft,
        builder: (context, _) => GameValueTab(draft: draft),
      ))),
    ));
    await tester.pumpAndSettle();
    await tester.tap(tier('CIB'));
    await tester.pumpAndSettle();
    expect(draft.values['game_completeness'], 'cib');
    expect(draft.values['game_has_box'], isTrue);
    expect(draft.values['game_has_manual'], isTrue);
    expect(draft.values['market_value_cents'], 1758);
    await tester.tap(tier('Loose'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Box').first);
    await tester.pumpAndSettle();
    expect(draft.values['game_completeness'], 'loose');
    expect(draft.values['game_has_box'], isTrue);
    expect(draft.values['market_value_cents'], 1503);
    expect(record.personalData, original);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Edit links the PriceCharting page and eBay sold listings',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final draft = LibraryEntryEditDraft(LibraryEntryRecord(
        id: 'game-1',
        kind: CatalogMediaKind.game,
        catalogData: {
          'title': 'Starlight Courier',
          'platforms': ['PlayStation 4'],
        },
        personalData: GameEntryDetails(priceChartingId: '57416').toJson(),
        updatedAt: DateTime.utc(2026)));
    addTearDown(draft.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: Scaffold(body: GameValueTab(draft: draft))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Check historical values at PriceCharting.com'),
        findsOneWidget);
    expect(tester.widget<GameEbaySoldLink>(find.byType(GameEbaySoldLink)).query,
        'Starlight Courier PlayStation 4');
    draft.set('game_pricecharting_id', null);
    await tester.pumpAndSettle();
    expect(find.text('Check historical values at PriceCharting.com'),
        findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
