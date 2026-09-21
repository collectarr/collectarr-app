import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/release/anime_release_detail_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('resolves only canonical Core releases from the workspace graph', () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'anime-1',
      'kind': 'anime',
      'title': 'Blade Runner',
      'editions': [
        {
          'id': 'edition-core',
          'title': 'Final Cut 4K release',
          'release_date': DateTime.utc(1982, 6, 25).toIso8601String(),
          'variants': [
            {
              'id': 'variant-core',
              'name': '4K UHD',
              'is_primary': true,
            },
          ],
        },
      ],
    });

    final editions = const AnimeReleaseDetailSource().resolveCatalogData(
      AnimeWorkspaceCatalogData.fromTransport(catalogItem),
    );

    expect(editions, hasLength(1));
    expect(editions.single.id, 'edition-core');
    expect(editions.single.title, 'Final Cut 4K release');
    expect(animeReleaseSourceLabel(editions.single), 'Core release');
  });

  test('does not fabricate a release for a work without Core releases', () {
    final catalogItem = testCatalogItemFromJson({
      'id': 'anime-without-release',
      'kind': 'anime',
      'title': 'Dune',
    });

    final editions = const AnimeReleaseDetailSource().resolveCatalogData(
      AnimeWorkspaceCatalogData.fromTransport(catalogItem),
    );

    expect(editions, isEmpty);
  });

  test('matches canonical release anchors by exact edition identity', () {
    const edition = CatalogEditionDto(
      id: 'edition-core',
      title: 'Collector Edition',
      metadata: {
        'release_source': 'core_release',
      },
    );

    expect(
      matchesAnimeReleaseAnchor(
        edition,
        editionId: 'edition-core',
      ),
      isTrue,
    );
    expect(
      matchesAnimeReleaseAnchor(
        edition,
        editionId: 'stale-edition',
      ),
      isFalse,
    );
  });
}
