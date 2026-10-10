import 'dart:convert';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/library_entry_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MusicLibraryEntry fixture() => MusicLibraryEntry(
      id: const LibraryEntryId('music-entry'),
      sourceCatalogRef:
          const CatalogItemRef(kind: CatalogMediaKind.music, id: 'core-album'),
      updatedAt: DateTime.utc(2026, 10, 10),
      personal: const MusicPersonalData(
          indexNumber: 4, personalNotes: 'Keep this note'),
      metadata: MusicAlbum(title: 'Deluxe Edition', genres: const [
        'Rock'
      ], discs: [
        MusicDisc(
            id: const MusicDiscId('disc-1'),
            discNumber: 1,
            format: 'CD',
            formatFamily: MusicDiscFormatFamily.opticalDisc,
            recordingDate: const PartialDate(year: 2025),
            recordingLocations: const ['Abbey Road'],
            sparsCode: 'DDD',
            isLive: false,
            credits: [
              MusicCredit(
                  id: const MusicCreditId('credit-1'),
                  name: 'John',
                  role: 'Producer',
                  instruments: const ['Piano'],
                  sequence: 1)
            ],
            tracks: [
              MusicTrack(
                  id: const MusicTrackId('track-1'),
                  position: '1',
                  title: 'First Song',
                  durationMs: 90000)
            ]),
      ]),
    );

void main() {
  test('unlink preserves complete Music data and emits a durable sync update',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    final events = CollectionEventBus();
    addTearDown(events.dispose);
    addTearDown(db.close);
    final entry = fixture();
    final repository = MusicEntryRepository(db);
    await repository.upsert(entry);
    final ref = MusicLibraryEntryProjection.toSummary(entry).ref;
    final queue = SyncQueueRepository(db);
    final emitted = <CollectionEvent>[];
    final subscription = events.stream.listen(emitted.add);
    addTearDown(subscription.cancel);
    final mutations = LibraryEntryMutations(
      libraryEntries: LibraryEntriesRepository(db),
      wishlist: WishlistItemsCacheRepository(db),
      catalogSummaries: CatalogDisplaySummaryRepository(db),
      syncQueue: queue,
      mutationRunner: CollectionMutationRunner(database: db, events: events),
    );
    await mutations.unlinkFromCore(ref);
    final detached = (await repository.findById(entry.id))!;
    expect(detached.sourceCatalogRef, isNull);
    expect(detached.metadata.toJson(), entry.metadata.toJson());
    expect(detached.personal.toJson(), entry.personal.toJson());
    await Future<void>.delayed(Duration.zero);
    expect(emitted, [LibraryEntryUpdated(ref)]);
    final pending = await queue.readPending();
    expect(pending.changes, hasLength(1));
    final payload =
        jsonDecode(pending.changes.single.payloadJson) as Map<String, dynamic>;
    expect(payload['source_catalog_ref'], isNull);
  });

  testWidgets(
      'entry inspector resolves summary, offers actions and renders Music v2 at 350px',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final entry = fixture();
    await MusicEntryRepository(db).upsert(entry);
    final summary = MusicLibraryEntryProjection.toSummary(entry);
    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
          target: EntryTargetRef(summary.ref),
          entrySummary: summary,
          libraryEntryDispatch: OpaqueLibraryEntryDispatch(
              ref: summary.ref, kind: CatalogMediaKind.music, value: entry),
          kindPresentationData: MusicWorkspaceData.fromMusic(entry.metadata)),
      personal: const PersonalOverlay(),
    );
    final item =
        LibraryProjectionItem.fromShelf(source, const MusicRegistration());
    final projection = LibraryProjection(
        allItems: [item],
        filteredItems: [item],
        buckets: const [],
        selectedItem: item,
        counts: const LibraryToolbarCounts());
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
            home: Scaffold(
                body: SizedBox(
                    width: 350,
                    child: LibraryInspector(
                      type: const MusicRegistration(),
                      projection: projection,
                      item: item,
                      libraryEntry: null,
                      accent: Colors.orange,
                      db: db,
                      onAddEntry: null,
                      onRemoveEntry: () {},
                      onAddWishlist: null,
                      onRemoveWishlist: null,
                      onEdit: (_) {},
                    ))))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Credits'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Producer / Disc 1'), findsOneWidget);
    expect(find.text('John - Piano'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Share'), findsOneWidget);
    await tester.tap(find.byTooltip('More inspector actions'));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Loan'), findsOneWidget);
    expect(find.text('Unlink from Core'), findsOneWidget);
    expect(find.text('Move to other collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Loan'));
    await tester.pumpAndSettle();
    expect(find.text('Loans'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
