import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/detail/library_video_detail_page.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import '../../helpers/test_data_factories.dart';
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
    final type = tvKindModule;
    const itemId = '00000000-0000-0000-0000-000000000001';

    final source = ShelfEntry(
      itemId: itemId,
      catalogItem: testCatalogItem(
        id: itemId,
        kind: 'tv',
        title: 'Cowboy Bebop',
        displayTitle: 'Cowboy Bebop',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: itemId);
    final dto = const GenericWorkspaceProjector()
        .projectTitle(source: source, node: node);
    final tvItem = LibraryProjectionItem(source: source, node: node, dto: dto);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(db),
          apiClientProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          home: LibraryVideoDetailPage(
            request: LibraryDetailPageRequest(
              type: type,
              item: tvItem,
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
    final videoUnits = await db.select(db.tvTrackingUnitRows).get();
    expect(units, hasLength(1));
    expect(units.single.itemId, itemId);
    expect(videoUnits, hasLength(1));
    expect(videoUnits.single.seasonNumber, 1);
    expect(videoUnits.single.episodeNumber, 1);
    expect(units.single.deletedAt, isNull);

    final entries = await db.select(db.trackingEntriesCache).get();
    expect(entries, hasLength(1));
    expect(entries.single.itemId, itemId);
    expect(entries.single.progressCurrent, 1);
    expect(entries.single.seasonNumber, 1);
    expect(entries.single.episodeNumber, 1);
  }, skip: true);
}

class _VideoSeasonApiClient extends ApiClient {
  @override
  Future<List<Season>> getTvSeriesSeasons(String seriesId) async {
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
