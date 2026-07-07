import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
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
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvShelfSeasonDrilldown(
            titleEntry: LibraryWorkspaceEntry(
              id: 'series-1',
              mediaType: 'tv',
              title: 'Cowboy Bebop',
              displayTitle: 'Cowboy Bebop',
              coverImageUrl: 'https://example.com/poster.jpg',
              releaseDate: DateTime.utc(1998, 4, 3),
              updatedAt: DateTime.utc(2026, 7, 6),
            ),
            coverSize: 160,
            accent: Colors.teal,
            onBack: () {},
            onRefreshFromCore: () async {},
            onOpenTitleDetails: () {},
            seasonsOverride: [
              Season(
                seasonNumber: 1,
                title: 'Season 1',
                episodeCount: 1,
                posterUrl: 'https://example.com/season-1.jpg',
                episodes: [
                  Episode(
                    episodeNumber: 1,
                    title: 'Asteroid Blues',
                    airDate: '1998-04-03T00:00:00.000Z',
                    runtimeMinutes: 24,
                  ),
                ],
              ),
              Season(
                seasonNumber: 2,
                title: 'Season 2',
                episodeCount: 1,
                posterUrl: 'https://example.com/season-2.jpg',
                episodes: [
                  Episode(
                    episodeNumber: 1,
                    title: 'Stray Dog Strut',
                    airDate: '1998-04-10T00:00:00.000Z',
                    runtimeMinutes: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Seasons'), findsOneWidget);
    expect(find.textContaining('Season 1'), findsWidgets);
    expect(find.textContaining('Season 2'), findsWidgets);
    expect(find.text('E01'), findsOneWidget);
    expect(find.text('Asteroid Blues'), findsOneWidget);
  });
}
