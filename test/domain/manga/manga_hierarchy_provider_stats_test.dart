import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/stats/manga_stats_capability.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Manga hierarchy groups Catalog Items into ordered volumes', () {
    final volumeOne = CatalogItemDto.raw(
      id: 'volume-1',
      mediaKind: CatalogMediaKind.manga,
      common: const CatalogCommonDto(title: 'Nausicaa 1'),
      payload: const {
        'series': {'series_id': 'series-1', 'series_title': 'Nausicaa'},
        'volume_number': 1,
        'chapters': [
          {'id': 'chapter-1', 'chapter_number': 1, 'title': 'The Wind'},
        ],
      },
    );
    final volumeTwo = CatalogItemDto.raw(
      id: 'volume-2',
      mediaKind: CatalogMediaKind.manga,
      common: const CatalogCommonDto(title: 'Nausicaa 2'),
      payload: const {
        'series': {'series_id': 'series-1', 'series_title': 'Nausicaa'},
        'volume_number': 2,
        'chapters': [
          {
            'id': 'chapter-2',
            'chapter_number': 2,
            'title': 'The Valley',
            'page_count': 40,
          },
          {'id': 'chapter-3', 'chapter_number': 3, 'title': 'The Forest'},
        ],
      },
    );
    final hierarchy = MangaHierarchyMapper.fromCatalogItems(
      selected: volumeOne,
      items: [volumeTwo, volumeOne],
    );

    expect(hierarchy.seriesTitle, 'Nausicaa');
    expect(hierarchy.volumes.map((volume) => volume.volumeNumber), [1, 2]);
    expect(hierarchy.volumes[1].chapters, hasLength(2));
    expect(hierarchy.volumes.first.chapters.single.chapterId, 'chapter-1');
    expect(hierarchy.volumes[1].chapters.first.chapterId, 'chapter-2');
    expect(hierarchy.volumes[1].chapters.last.chapterNumber, 3);

    final nodes = MangaHierarchyMapper.toLibraryNodes(hierarchy);
    expect(nodes, hasLength(2));
    expect(nodes.first.level, LibraryHierarchyLevel.container);
    expect(nodes[1].children, hasLength(2));
    expect(nodes[1].children.first.level, LibraryHierarchyLevel.leaf);
    expect(nodes[1].children.first.secondaryLabel, '40 pages');
  });

  test('Manga catalog transport decodes the active typed media model', () {
    final media = const MangaCatalogTransportCodec().decode(
      CatalogItemDto.raw(
        id: 'manga-1',
        mediaKind: CatalogMediaKind.manga,
        common: const CatalogCommonDto(title: 'Nausicaa'),
        payload: const {
          'series_title': 'Nausicaa',
          'volume_number': 1,
          'genres': ['Adventure'],
        },
      ),
    );

    expect(media, isA<MangaMedia>());
    expect(media.id, 'manga-1');
    expect(media.title, 'Nausicaa');
    expect(media.rawPayload['series_title'], 'Nausicaa');
    expect(media.rawPayload['volume_number'], 1);
    expect(media.rawPayload['genres'], ['Adventure']);
  });

  test('Manga stats derive missing volumes from typed metadata', () {
    final entries = [
      _mangaEntry('manga-1', 1),
      _mangaEntry('manga-3', 3),
      _mangaEntry('manga-4', 4),
      _mangaEntry('other', 2, owned: false),
    ];

    expect(
      MangaStatsCapability.missingVolumeNumbers(entries),
      {
        'Nausicaa': [2]
      },
    );
  });
}

LibraryWorkspaceSource _mangaEntry(String id, int volume, {bool owned = true}) {
  return LibraryWorkspaceSource(
    itemId: id,
    catalogData: testWorkspaceCatalogData(CatalogItemDto(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.manga),
      kindMetadata: MangaMetadata(
        title: 'Volume $volume',
        seriesTitle: 'Nausicaa',
        volumeNumber: volume,
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Nausicaa'),
      ),
    ).asShelfCatalogItem),
    ownedSummary: owned
        ? testOwnedSummary(testOwnedItem(
            id: 'owned-$id',
            catalogRef: CatalogEntityRef(
              id: id,
              kind: CatalogMediaKind.manga,
              entityType: const CatalogEntityTypeId('work'),
            ),
            updatedAt: DateTime.utc(2026, 1, 1),
          ))
        : null,
  );
}
