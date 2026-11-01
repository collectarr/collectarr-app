import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/inspector/inspector.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_story_arc.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/slab.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_icon.dart';
import 'package:collectarr_app/features/library/workspace/entry/context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _entry = ComicLibraryEntry(
  id: const LibraryEntryId('comic-entry-1'),
  updatedAt: DateTime.utc(2026, 10, 10),
  personal: const ComicPersonalData(
    indexNumber: 5,
    collectionStatus: 'wishlist',
    reading: ComicReadingState(status: 'Read'),
    details: ComicEntryDetails(
      keySeverity: 'Trivia',
      keyReason: 'First appearance of Example Hero',
      keyCategory: '1st full appearance;Debut of item/vehicle/location',
      coverPriceCents: 499,
    ),
  ),
  metadata: const ComicCatalogItem(
    title: 'Part 2',
    seriesTitle: 'Example Series',
    issueNumber: '2',
    variant: 'A',
    variantDescription: 'Regular Cover',
    publisher: 'Example Comics',
    physicalFormat: 'Comic',
    publicationAge: 'Modern Age',
    pageCount: 32,
    releaseDateParts: PartialDate(year: 2024, month: 11, day: 13),
    coverDateParts: PartialDate(year: 2025, month: 1),
    storyArcs: [ComicStoryArc(name: 'The Zoo')],
    description: 'An example plot.',
    creators: [
      ComicCreator(name: 'Example Artist', role: 'Artist'),
      ComicCreator(name: 'Example Writer', role: 'Writer'),
    ],
    characters: [ComicCharacter(name: 'Example Hero', realName: 'Jane Doe')],
  ),
);

/// Shows [entry]'s details panel; it starts on the loading spinner.
Future<void> _pumpInspector(
    WidgetTester tester, ComicLibraryEntry entry) async {
  tester.view.physicalSize = const Size(1100, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = LocalDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  await ComicEntryRepository(db).upsert(entry);
  final summary = ComicLibraryEntryProjection.toSummary(entry);
  final source = LibraryWorkspaceContext(
    item: WorkspaceItem(
      target: EntryTargetRef(summary.ref),
      entrySummary: summary,
      libraryEntryDispatch: OpaqueLibraryEntryDispatch(
        ref: summary.ref,
        kind: CatalogMediaKind.comic,
        value: entry,
      ),
      kindPresentationData: ComicWorkspaceData(comic: entry.metadata),
    ),
    personal: const PersonalOverlay(),
  );
  final item =
      LibraryProjectionItem.fromShelf(source, const ComicRegistration());

  await tester.pumpWidget(ProviderScope(
    overrides: [localDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1000,
          child: LibraryInspector(
            type: const ComicRegistration(),
            projection: LibraryProjection(
              allItems: [item],
              filteredItems: [item],
              buckets: const [],
              selectedItem: item,
              counts: const LibraryToolbarCounts(),
            ),
            item: item,
            libraryEntry: null,
            accent: const Color(0xFF2A9FD6),
            db: db,
            onAddEntry: null,
            onRemoveEntry: () {},
            onAddWishlist: null,
            onRemoveWishlist: null,
            onEdit: (_) {},
          ),
        ),
      ),
    ),
  ));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('comic details follow the reference layout', (tester) async {
    await _pumpInspector(tester, _entry);
    // The reference's spinner covers the panel until the entry has loaded.
    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('Example Series'), findsNothing);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Loading...'), findsNothing);
    expect(find.text('Example Series'), findsOneWidget);
    expect(find.text('#2A'), findsOneWidget);
    expect(find.text('The Zoo - Part 2'), findsOneWidget);
    expect(find.text('First appearance of Example Hero'), findsOneWidget);
    expect(find.text('Regular Cover'), findsOneWidget);
    expect(find.text('Nov 13, 2024'), findsOneWidget);
    expect(find.text('An example plot.'), findsOneWidget);
    for (final heading in [
      'Creators',
      'Characters',
      'Details',
      'Personal',
      'Value'
    ]) {
      expect(find.text(heading), findsWidgets, reason: heading);
    }
    // Writer comes before Artist, as in the reference role order.
    expect(tester.getTopLeft(find.text('Example Writer')).dy,
        lessThan(tester.getTopLeft(find.text('Example Artist')).dy));
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(
        find.text('Trivia: First appearance of Example Hero'), findsOneWidget);
    expect(find.text('1st full appearance | Debut of item/vehicle/location'),
        findsOneWidget);
    // Beside the plot sits the Collection Status, not the Read state.
    final status = find.byType(LibraryCollectionStatusIcon);
    expect(status, findsOneWidget);
    expect(tester.widget<LibraryCollectionStatusIcon>(status).collectionStatus,
        LibraryCollectionStatusScope.wishList);
    expect(find.byTooltip('Not read'), findsNothing);
    expect(find.text('Quick actions'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a slabbed comic shows its slab and grading as the reference',
      (tester) async {
    await _pumpInspector(
        tester,
        ComicLibraryEntry(
          id: const LibraryEntryId('comic-entry-2'),
          updatedAt: DateTime.utc(2026, 10, 10),
          personal: ComicPersonalData(
            grade: '10.0 Gem Mint',
            marketValueCents: 150000,
            currency: 'USD',
            purchaseDate: DateTime(2024, 3, 15),
            pricePaidCents: 80000,
            purchaseStore: 'Example Store',
            details: const ComicEntryDetails(
              rawOrSlabbed: 'Slabbed',
              gradingCompany: 'CGC',
              labelType: 'Signature Series',
              certificationNumber: '4123456001',
              customLabel: 'Example Label',
            ),
          ),
          metadata: _entry.metadata,
        ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // The slab label prints a perfect grade as a gold 10 beside the company.
    expect(find.byType(ComicSlab), findsOneWidget);
    expect(find.text('CGC'), findsOneWidget);
    expect(tester.widget<Text>(find.text('10')).style?.color,
        const Color(0xffd3a63d));
    // The ribbon carries the grade's code and My Value.
    final pill = find.byType(LibraryOutlinedPill);
    expect(pill, findsOneWidget);
    expect(
        find.descendant(of: pill, matching: find.text('10.0')), findsOneWidget);
    final value = AppFormats.current.formatMoney(150000, 'USD');
    for (final (label, text) in [
      ('Grade and value', '10.0 Gem Mint ($value)'),
      ('Grade status', 'Slabbed and graded by CGC'),
      ('Slab Certification Number', '4123456001'),
      ('Label Type', 'Signature Series'),
      ('Custom Label', 'Example Label'),
      (
        'Purchased',
        '${AppFormats.current.formatDate(DateTime(2024, 3, 15))} for '
            '${AppFormats.current.formatMoney(80000, 'USD')} at Example Store'
      ),
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
      expect(find.text(text), findsOneWidget, reason: text);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
