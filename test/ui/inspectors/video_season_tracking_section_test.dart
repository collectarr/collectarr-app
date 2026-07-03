import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/video/video_detail_page.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('video detail stores granular episode tracking locally', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final api = _VideoSeasonApiClient();
    final type = collectarrLibraryTypes.byKind('tv')!;
    const itemId = '00000000-0000-0000-0000-000000000001';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(db),
          apiClientProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          home: VideoLibraryDetailPage(
            request: LibraryDetailPageRequest(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: itemId,
                mediaType: 'tv',
                title: 'Cowboy Bebop',
                displayTitle: 'Cowboy Bebop',
                editions: const [
                  CatalogEdition(
                    id: 'edition-bluray',
                    title: 'Blu-ray',
                    publisher: 'Crunchyroll',
                  ),
                ],
                updatedAt: DateTime.utc(2026, 5, 25),
              ),
              ownedItem: null,
              accent: Colors.orange,
              onAddOwned: () {},
              onRemoveOwned: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (_) {},
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('Seasons & episodes'), findsOneWidget);
    expect(find.text('E1 • Asteroid Blues'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('E1 • Asteroid Blues'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUntilSettled(tester);
    await tester.tap(find.text('E1 • Asteroid Blues'));
    await pumpUntilSettled(tester);

    final units = await db.select(db.trackingUnitsCache).get();
    expect(units, hasLength(1));
    expect(units.single.itemId, itemId);
    expect(units.single.seasonNumber, 1);
    expect(units.single.episodeNumber, 1);
    expect(units.single.deletedAt, isNull);

    final entries = await db.select(db.trackingEntriesCache).get();
    expect(entries, hasLength(1));
    expect(entries.single.itemId, itemId);
    expect(entries.single.progressCurrent, 1);
    expect(entries.single.seasonNumber, 1);
    expect(entries.single.episodeNumber, 1);
  });
}

class _VideoSeasonApiClient extends ApiClient {
  @override
  Future<List<Season>> getItemSeasons(
    String itemId, {
    String? kind,
  }) async {
    return [
      Season(
        seasonNumber: 1,
        title: 'Season 1',
        episodeCount: 2,
        episodes: [
          Episode(
            episodeNumber: 1,
            title: 'Asteroid Blues',
            runtimeMinutes: 24,
          ),
          Episode(
            episodeNumber: 2,
            title: 'Stray Dog Strut',
            runtimeMinutes: 24,
          ),
        ],
      ),
    ];
  }
}