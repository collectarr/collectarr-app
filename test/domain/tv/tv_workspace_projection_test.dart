import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv workspace projections build series season episode and release nodes',
      () {
    final overlay = TvPersonalOverlay(updatedAt: DateTime.utc(2026, 7, 5));
    final series = TvSeries(
      id: 'series-1',
      title: 'Cowboy Bebop',
      originalTitle: 'Cowboy Bebop',
      overview: 'A space western.',
      firstAirDate: DateTime.utc(1998, 4, 3),
      runtimeMinutes: 24,
      contributions: const [
        {'name': 'Shinichiro Watanabe', 'role': 'Director'},
      ],
      releases: [
        TvRelease(
          id: 'release-1',
          seriesId: 'series-1',
          title: 'Blu-ray',
          releaseDate: DateTime.utc(2024, 1, 5),
          media: [
            TvReleaseMedia(
              id: 'media-1',
              releaseId: 'release-1',
              title: 'Disc 1',
              formatLabel: 'Blu-ray',
              discNumber: 1,
              sequenceNumber: 1,
              episodes: [
                TvEpisode(
                  id: 'episode-1',
                  seriesId: 'series-1',
                  seasonId: 'season-1',
                  seasonNumber: 1,
                  episodeNumber: 1,
                  title: 'Asteroid Blues',
                ),
              ],
            ),
          ],
          episodeMappings: [
            TvReleaseEpisodeMap(
              id: 'map-1',
              releaseId: 'release-1',
              mediaId: 'media-1',
              episodeId: 'episode-1',
              discNumber: 1,
              sequenceNumber: 1,
            ),
          ],
        ),
      ],
    );
    final season = TvSeason(
      id: 'season-1',
      seriesId: 'series-1',
      seasonNumber: 1,
      title: 'Season 1',
      airDate: DateTime.utc(1998, 4, 3),
      episodeCount: 1,
      episodes: [
        TvEpisode(
          id: 'episode-1',
          seriesId: 'series-1',
          seasonId: 'season-1',
          seasonNumber: 1,
          episodeNumber: 1,
          title: 'Asteroid Blues',
        ),
      ],
    );
    final episode = season.episodes.single;
    final release = series.releases.single;
    final media = release.media.single;

    final seriesEntry = buildTvSeriesWorkspaceEntry(series, overlay);
    final seasonEntry = buildTvSeasonWorkspaceEntry(
      series: series,
      season: season,
      overlay: overlay,
    );
    final episodeEntry = buildTvEpisodeWorkspaceEntry(
      series: series,
      season: season,
      episode: episode,
      overlay: overlay,
    );
    final releaseEntry = buildTvReleaseWorkspaceEntry(
      series: series,
      release: release,
      overlay: overlay,
    );
    final mediaEntry = buildTvReleaseMediaWorkspaceEntry(
      release: release,
      media: media,
    );
    final mapEntry = buildTvReleaseEpisodeMapWorkspaceEntry(
      release: release,
      media: media,
      episodeMap: release.episodeMappings.single,
    );

    expect(seriesEntry.browseScope, LibraryBrowserScope.title);
    expect(seriesEntry.id, 'series-1');
    expect(seasonEntry.releaseId, 'season-1');
    expect(seasonEntry.itemNumber, 'Season 1');
    expect(seasonEntry.referenceScopeLabel, 'Season');
    expect(seasonEntry.referenceEditionId, 'season-1');
    expect(episodeEntry.itemNumber, 'E01');
    expect(episodeEntry.referenceEditionId, isNull);
    expect(releaseEntry.browseScope, LibraryBrowserScope.release);
    expect(releaseEntry.releaseId, 'release-1');
    expect(releaseEntry.referenceVariantId, 'media-1');
    expect(mediaEntry.id, 'release-1:media:media-1');
    expect(mediaEntry.itemNumber, 'Disc 1');
    expect(mapEntry.id, 'release-1:media:media-1:map:map-1');
    expect(mapEntry.displayTitle, 'Episode map 1');
  });

  test('tv shelf entries map through the from-shelf adapter', () {
    final shelfEntry = ShelfEntry(
      itemId: 'series-2',
      catalogItem: LibraryMetadataItem(
        id: 'series-2',
        kind: 'tv',
        title: 'Samurai Champloo',
        displayTitle: 'Samurai Champloo',
        originalTitle: 'サムライチャンプルー',
        synopsis: 'A wanderer story.',
        coverImageUrl: 'https://example.com/tv.jpg',
        thumbnailImageUrl: 'https://example.com/tv-thumb.jpg',
        publisher: 'Fuji TV',
        releaseDate: DateTime.utc(2004, 5, 20),
        series: const CatalogSeriesDetails(
          seriesId: 'series-2',
          seriesTitle: 'Samurai Champloo',
        ),
        publishing: const CatalogPublishingDetails(
          subtitle: 'Broadcast',
          originalCountry: 'JP',
        ),
      ),
    );

    final entry = buildTvWorkspaceEntryFromShelf(shelfEntry);

    expect(entry.browseScope, LibraryBrowserScope.title);
    expect(entry.title, 'Samurai Champloo');
    expect(entry.series?.seriesTitle, 'Samurai Champloo');
    expect(entry.publishing?.subtitle, 'Broadcast');
  });
}
