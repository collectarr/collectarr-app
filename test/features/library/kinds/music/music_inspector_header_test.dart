import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
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

MusicLibraryEntry _createFixture() => MusicLibraryEntry(
      id: const LibraryEntryId('test-entry-1'),
      sourceCatalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.music,
        id: 'catalog-1',
      ),
      updatedAt: DateTime.utc(2026, 10, 10),
      personal: const MusicPersonalData(indexNumber: 1),
      metadata: MusicAlbum(
        title: 'The Bleeding',
        artist: 'Cannibal Corpse',
        publisher: 'Metal Blade Records',
        catalogNumber: '3984-25039-1',
        barcode: '039842503912',
        countryCode: 'US',
        genres: const ['Death Metal', 'Brutal Death Metal'],
        releaseDateParts: const PartialDate(year: 2017),
        discs: [
          MusicDisc(
            id: const MusicDiscId('disc-1'),
            discNumber: 1,
            tracks: [
              MusicTrack(
                id: const MusicTrackId('track-1'),
                position: '1',
                title: 'Staring Through the Eyes of the Dead',
                durationMs: 210000,
              ),
            ],
          ),
        ],
      ),
    );

void main() {
  testWidgets(
      'renders CLZ-styled music inspector hero card with cover and metadata',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final entry = _createFixture();
    await MusicEntryRepository(db).upsert(entry);
    final summary = MusicLibraryEntryProjection.toSummary(entry);

    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: EntryTargetRef(summary.ref),
        entrySummary: summary,
        libraryEntryDispatch: OpaqueLibraryEntryDispatch(
          ref: summary.ref,
          kind: CatalogMediaKind.music,
          value: entry,
        ),
        kindPresentationData: MusicWorkspaceData.fromMusic(entry.metadata),
      ),
      personal: const PersonalOverlay(),
    );

    final item = LibraryProjectionItem.fromShelf(
      source,
      const MusicRegistration(),
    );
    final projection = LibraryProjection(
      allItems: [item],
      filteredItems: [item],
      buckets: const [],
      selectedItem: item,
      counts: const LibraryToolbarCounts(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 450,
              child: LibraryInspector(
                type: const MusicRegistration(),
                projection: projection,
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
      ),
    );
    await tester.pumpAndSettle();

    // 1. Artist (large, primary)
    expect(find.text('Cannibal Corpse'), findsOneWidget);

    // 2. Title (cyan #2A9FD6)
    final titleWidget = tester.widget<Text>(find.text('The Bleeding'));
    expect(titleWidget.style?.color, const Color(0xFF2A9FD6));

    // 3. Collection badge (cyan ✓)
    expect(find.byTooltip('In Collection'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsWidgets);

    // 4. Label & Year
    expect(find.text('Metal Blade Records'), findsOneWidget);
    expect(find.text('(2017)'), findsOneWidget);

    // 5. Pipe-separated Genres
    expect(find.text('Death Metal'), findsOneWidget);
    expect(find.text('Brutal Death Metal'), findsOneWidget);

    // 6. Barcode & Country
    expect(find.text('Barcode 039842503912'), findsOneWidget);
    expect(find.textContaining('United States'), findsOneWidget);

    // 7. Metric strip (1 Disc | 1 Tracks | 3:30)
    expect(find.text('1 Disc | 1 Tracks | 3:30'), findsOneWidget);

    // 8. Catalog Number & eBay link
    expect(find.text('cat no 3984-25039-1'), findsOneWidget);
    expect(find.text('eBay'), findsNWidgets(2));

    // 9. Cover carousel selector dots (Front & Back)
    expect(find.byTooltip('Front cover'), findsOneWidget);
  });
}
