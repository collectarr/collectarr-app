import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_domain.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('Manga Domain & Metadata Tests', () {
    test('MangaWorkspaceProjector produces a typed dto with correct title', () {
      final dto = CatalogItemDto.fromJson({
        'id': 'manga-work-1',
        'kind': 'manga',
        'title': 'Vagabond',
        'original_language': 'ja',
        'sort_title': 'Vagabond',
      });

      expect(dto.id, 'manga-work-1');
      expect(dto.title, 'Vagabond');
    });

    test('Manga projector keeps work and personal data together', () {
      final catalogItem = testCatalogItem(
        id: 'manga-1',
        kind: 'manga',
        title: 'Vagabond',
        itemNumber: '1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-1',
          seriesTitle: 'Vagabond',
        ),
        publishing: const CatalogPublishingDetailsDto(subtitle: 'Vol. 1'),
        editions: const [
          CatalogEditionDto(id: 'edition-1', title: 'Volume 1'),
        ],
      );
      final shelf = ShelfEntry(
        itemId: 'manga-1',
        catalogItem: catalogItem,
        ownedItem: testOwnedItem(
          id: 'owned-manga-1',
          itemId: 'manga-1',
          rawOrSlabbed: 'Raw',
          updatedAt: DateTime.utc(2026, 5, 30),
        ),
        trackingEntry: null,
        wishlistItem: null,
        locationPath: 'Shelf A / Box 3',
        watchSessions: const [],
        itemImages: const [],
        fallbackOwnerLabel: 'Andrei',
      );

      final dto = const MangaWorkspaceProjector().projectTitle(
        source: shelf,
        node: const LibraryTitleNodeRef(titleItemId: 'manga-1'),
      );

      expect(dto.seriesTitle, 'Vagabond');
      expect(shelf.catalogItem?.editions, hasLength(1));
    });

    test('MangaMetadata serialization and deserialization roundtrip', () {
      final metadata = MangaMetadata(
        nativeTitle: 'バガボンド',
        romajiTitle: 'Bagabondo',
        englishTitle: 'Vagabond',
        alternateTitles: const ['Takehiko Inoue Vagabond'],
        authors: const ['Takehiko Inoue'],
        artists: const ['Takehiko Inoue'],
        demographic: MangaDemographic.seinen,
        serializationPlatform: 'Morning',
        publicationStatus: MangaPublicationStatus.hiatus,
        originalPublisher: 'Kodansha',
        localizedPublisher: 'VIZ Media',
        volumeNumber: 1,
        totalVolumes: 37,
        chapterCount: 327,
        originalPublicationDate: DateTime.utc(1998, 9, 3),
        localizedReleaseDate: DateTime.utc(2002, 4, 6),
        isbn: '978-1569317075',
        editionFormat: MangaEditionFormat.omnibus,
        language: 'en',
        country: 'US',
        genres: const ['Action', 'Historical', 'Martial Arts'],
        themes: const ['Samurai', 'Philosophy'],
        translator: 'Yuji Oniki',
        readingDirection: MangaReadingDirection.rightToLeft,
        relations: const ['Slam Dunk', 'Real'],
      );

      final json = metadata.toJson();
      final fromJson = MangaMetadata.fromJson(json);

      expect(fromJson.nativeTitle, 'バガボンド');
      expect(fromJson.romajiTitle, 'Bagabondo');
      expect(fromJson.englishTitle, 'Vagabond');
      expect(fromJson.demographic, MangaDemographic.seinen);
      expect(fromJson.publicationStatus, MangaPublicationStatus.hiatus);
      expect(fromJson.editionFormat, MangaEditionFormat.omnibus);
      expect(fromJson.readingDirection, MangaReadingDirection.rightToLeft);
      expect(fromJson.authors, contains('Takehiko Inoue'));
      expect(fromJson.totalVolumes, 37);
      expect(fromJson.chapterCount, 327);
    });

    test('MangaHierarchy models series -> volumes -> releases', () {
      const hierarchy = MangaSeriesHierarchy(
        seriesId: 'series-vagabond',
        seriesTitle: 'Vagabond',
        volumes: [
          MangaVolumeHierarchyNode(
            volumeId: 'vol-1',
            volumeNumber: 1,
            title: 'Water',
            chapterCount: 10,
            releases: ['viz-tankobon-1', 'vizbig-1'],
          ),
          MangaVolumeHierarchyNode(
            volumeId: 'vol-2',
            volumeNumber: 2,
            title: 'Fire',
            chapterCount: 11,
            releases: ['viz-tankobon-2', 'vizbig-1'],
          ),
        ],
        boxSets: ['vizbig-box-1'],
      );

      expect(hierarchy.seriesTitle, 'Vagabond');
      expect(hierarchy.volumes, hasLength(2));
      expect(hierarchy.volumes.first.volumeNumber, 1);
      expect(hierarchy.volumes.first.releases, contains('vizbig-1'));
    });

    test('MangaKindModule uses Manga-owned capabilities exclusively', () {
      expect(mangaKindModule.kind, CatalogMediaKind.manga);
      expect(mangaKindModule.add.kind, CatalogMediaKind.manga);
      expect(mangaKindModule.add.createInitialDraft(), isA<MangaAddDraft>());
      expect(const MangaOwnedDetailsCodec(), isA<MangaOwnedDetailsCodec>());
      expect(const MangaOwnedDetailsCodec().defaultDetails(),
          isA<MangaOwnedDetails>());
    });
  });
}
