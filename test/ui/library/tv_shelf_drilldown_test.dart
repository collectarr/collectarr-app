import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tv shelf drilldown shows seasons and episode details', (
    tester,
  ) async {
    final source = ShelfEntry(
      itemId: 'series-1',
      catalogItem: testCatalogItem(
        id: 'series-1',
        kind: 'tv',
        title: 'Cowboy Bebop',
        displayTitle: 'Cowboy Bebop',
        coverImageUrl: null,
        releaseDate: DateTime.utc(1998, 4, 3),
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'series-1');
    final dto = const GenericWorkspaceProjector()
        .projectTitle(source: source, node: node);
    final tvItem = LibraryProjectionItem(source: source, node: node, dto: dto);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvShelfSeasonDrilldown(
            titleItem: tvItem,
            coverSize: 160,
            accent: Colors.teal,
            onBack: () {},
            onRefreshFromCore: () async {},
            onOpenTitleDetails: () {},
            seasonsOverride: [
              TvSeason(
                id: 'series-1:season:1',
                seriesId: 'series-1',
                seasonNumber: 1,
                title: 'Season 1',
                episodeCount: 1,
                coverImageUrl: null,
                episodes: [
                  TvEpisode(
                    id: 'series-1:season:1:episode:1',
                    seriesId: 'series-1',
                    seasonId: 'series-1:season:1',
                    episodeNumber: 1,
                    title: 'Asteroid Blues',
                    airDate: DateTime.utc(1998, 4, 3),
                    runtimeMinutes: 24,
                  ),
                ],
              ),
              TvSeason(
                id: 'series-1:season:2',
                seriesId: 'series-1',
                seasonNumber: 2,
                title: 'Season 2',
                episodeCount: 1,
                coverImageUrl: null,
                episodes: [
                  TvEpisode(
                    id: 'series-1:season:2:episode:1',
                    seriesId: 'series-1',
                    seasonId: 'series-1:season:2',
                    episodeNumber: 1,
                    title: 'Stray Dog Strut',
                    airDate: DateTime.utc(1998, 4, 10),
                    runtimeMinutes: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Seasons'), findsOneWidget);
    expect(find.textContaining('Season 1'), findsWidgets);
    expect(find.textContaining('Season 2'), findsWidgets);
    expect(find.text('E01'), findsWidgets);
    expect(find.text('Asteroid Blues'), findsOneWidget);
  });
}
