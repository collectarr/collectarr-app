import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
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
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  testWidgets('comic details follow the reference layout', (tester) async {
    tester.view.physicalSize = const Size(1100, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await ComicEntryRepository(db).upsert(_entry);
    final summary = ComicLibraryEntryProjection.toSummary(_entry);
    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: EntryTargetRef(summary.ref),
        entrySummary: summary,
        libraryEntryDispatch: OpaqueLibraryEntryDispatch(
          ref: summary.ref,
          kind: CatalogMediaKind.comic,
          value: _entry,
        ),
        kindPresentationData: ComicWorkspaceData(comic: _entry.metadata),
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

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
}
