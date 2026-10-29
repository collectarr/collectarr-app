import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/manual_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_integer_field.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Manual Add keeps eleven tabs and persists reading, quantity and plot',
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
        kindDraft: ComicAddManualDraft());
    addTearDown(manual.dispose);
    var personal = const ComicAddDraft();
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: StatefulBuilder(
        builder: (context, refresh) => ComicAddManualPane(
          request: LibraryAddManualPaneRequest(
            kind: CatalogMediaKind.comic,
            type: const ComicRegistration(),
            accent: Colors.red,
            commonDraft: const LibraryAddCommonDraft(),
            personalFields: comicKindPersonalFieldContributor.fields,
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
              personal = value as ComicAddDraft;
            }),
          ),
        ),
      ))),
    ));

    for (final label in [
      'Main',
      'Details',
      'Value',
      'Personal',
      'Custom Fields',
      'Covers',
      'My Images',
      'Creators',
      'Characters',
      'Plot',
      'Links'
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('Edition Details'), findsNothing);
    expect(find.text('Main'), findsOneWidget);
    Finder field(String label) => find.descendant(
        of: find.byWidgetPredicate(
            (widget) => widget is LibraryFormField && widget.label == label),
        matching: find.byType(TextFormField));
    await tester.enterText(field('Series'), 'QA Series');
    await tester.enterText(field('Issue No.'), '12.1');
    await tester.enterText(field('Variant'), 'A');
    await tester.enterText(field('Variant Description'), 'Standard cover');
    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();
    expect(find.text('Publication details'), findsNothing);
    expect(
        tester.widget<TextFormField>(field('Title')).controller!.text, isEmpty);
    await tester.enterText(field('Title'), 'Signal at Dawn');
    await tester.tap(find.text('Main').first);
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(field('Series')).controller!.text,
        'QA Series');
    expect(tester.widget<TextFormField>(field('Issue No.')).controller!.text,
        '12.1');
    expect(
        tester
            .widget<TextFormField>(field('Variant Description'))
            .controller!
            .text,
        'Standard cover');

    await tester.tap(find.text('Personal').first);
    await tester.pumpAndSettle();
    final read = find.descendant(
        of: find.byType(LibrarySegmentedChoiceField<bool>),
        matching: find.text('Yes'));
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(personal.personal.reading.status, 'Read');
    final quantity = find.byType(LibraryIntegerField).last;
    await tester.enterText(
        find.descendant(of: quantity, matching: find.byType(TextFormField)),
        '3');
    await tester.pumpAndSettle();
    expect(personal.personal.quantity, 3);
    final details = personal.toEntryDetailsDraft() as ComicEntryDetailsDraft;
    final candidate = buildComicManualCandidate(manual.kindDraft, title: '')!;
    final item = ComicLibraryEntryCreatePayload(
      details: details,
      quantity: personal.personal.quantity,
      reading: personal.personal.reading,
    ).toLibraryEntry(
        id: 'isolated-copy',
        sourceCatalogItem: candidate,
        createdAt: DateTime.utc(2026),
        existingIsDigital: null,
        ownerUserId: null,
        ownerLabel: null);
    expect(item.personal.quantity, 3);
    expect(item.personal.reading.status, 'Read');
    await tester.ensureVisible(find.text('Plot').first);
    await tester.tap(find.text('Plot').first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byWidgetPredicate(
            (widget) => widget is TextField && widget.maxLines == 18),
        'An original fictional plot.');
    await tester.pumpAndSettle();
    final edited = buildComicManualCandidate(manual.kindDraft, title: '')!;
    final metadata = edited.kindCapability
        .mapTransport((item) => ComicCatalogItem.fromJson(item.kindData));
    expect(metadata.description, 'An original fictional plot.');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
