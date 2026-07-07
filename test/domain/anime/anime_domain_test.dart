import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('AnimeSeries parses episodes and metadata', () {
    final dto = AnimeSeriesDto.fromJson({
      'id': 'anime-series-1',
      'title': 'Cowboy Bebop',
      'description': 'A bounty-hunting crew.',
      'original_air_date': '1998-04-03T00:00:00.000Z',
      'original_language': 'ja',
      'sort_title': 'Cowboy Bebop',
      'status': 'Finished',
      'episode_count': 26,
      'episodes': [
        {'id': 'ep-1', 'title': 'Asteroid Blues', 'episode_number': '1'},
        {'id': 'ep-2', 'title': 'Stray Dog Strut', 'episode_number': '2'},
      ],
      'kind': 'anime',
    });

    final series = AnimeSeries.fromDto(dto);

    expect(series.title, 'Cowboy Bebop');
    expect(series.episodes, hasLength(2));
    expect(series.displayEpisodeLabel, 'Asteroid Blues');
  });

  test('Anime shelf builder keeps series and overlay together', () {
    final catalogItem = CatalogItem(
      id: 'anime-1',
      kind: 'anime',
      title: 'Cowboy Bebop',
      series: const CatalogSeriesDetails(
        seriesId: 'series-1',
        seriesTitle: 'Cowboy Bebop',
      ),
      video: const VideoCatalogDetails(runtimeMinutes: 24),
      editions: const [
        CatalogEdition(id: 'edition-1', title: 'Episode 1'),
      ],
    );
    final shelf = ShelfEntry(
      itemId: 'anime-1',
      catalogItem: LibraryMetadataItem.fromCatalogItem(catalogItem),
      ownedItem: testOwnedItem(
        id: 'owned-anime-1',
        itemId: 'anime-1',
        updatedAt: DateTime.utc(2026, 5, 30),
      ),
      trackingEntry: null,
      wishlistItem: null,
      locationPath: 'Shelf B / Box 2',
      watchSessions: const [],
      itemImages: const [],
      fallbackOwnerLabel: 'Andrei',
    );

    final entry = buildAnimeLibraryWorkspaceEntryFromShelf(shelf);

    expect(entry.series?.seriesTitle, 'Cowboy Bebop');
    expect(entry.video?.runtimeMinutes, 24);
    expect(entry.editions, hasLength(1));
  });
}
