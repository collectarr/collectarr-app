import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/stats/manga_stats_capability.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Manga hierarchy groups typed chapters into ordered volumes', () {
    final hierarchy = MangaHierarchyMapper.fromChapterRows(
      seriesId: 'series-1',
      rows: [
        {
          'id': 'chapter-2',
          'series_title': 'Nausicaa',
          'volume_number': 2,
          'chapter_number': 2,
          'chapter_title': 'The Valley',
          'page_count': 40,
        },
        {
          'id': 'chapter-1',
          'series_title': 'Nausicaa',
          'volume_number': 1,
          'chapter_number': 1,
          'chapter_title': 'The Wind',
        },
        {
          'id': 'chapter-3',
          'series_title': 'Nausicaa',
          'volume_number': 2,
          'chapter_title': 'The Forest',
        },
      ],
    );

    expect(hierarchy.seriesTitle, 'Nausicaa');
    expect(hierarchy.volumes.map((volume) => volume.volumeNumber), [1, 2]);
    expect(hierarchy.volumes[1].chapters, hasLength(2));
    expect(hierarchy.volumes[1].chapters.first.chapterId, 'chapter-2');
    expect(hierarchy.volumes[1].chapters.last.chapterNumber, 3);

    final nodes = MangaHierarchyMapper.toLibraryNodes(hierarchy);
    expect(nodes, hasLength(2));
    expect(nodes.first.level, LibraryHierarchyLevel.container);
    expect(nodes[1].children, hasLength(2));
    expect(nodes[1].children.first.level, LibraryHierarchyLevel.leaf);
    expect(nodes[1].children.first.secondaryLabel, '40 pages');
  });

  test('Manga provider mapper decodes only Manga envelopes', () {
    const mapper = MangaLibraryKindProviderMapper();
    final envelope = _envelope(
      kind: 'manga',
      normalized: {
        'title': 'Nausicaa',
        'series_title': 'Nausicaa',
        'volume_number': 1,
        'genres': ['Adventure'],
      },
    );

    final metadata = mapper.metadataFromEnvelope(envelope);
    expect(metadata, isA<MangaMetadata>());
    expect(metadata.title, 'Nausicaa');
    expect(metadata.volumeNumber, 1);
    expect(
        mapper.catalogFromEnvelope(envelope).mediaKind, CatalogMediaKind.manga);
    expect(
      () => mapper.metadataFromEnvelope(_envelope(kind: 'anime')),
      throwsA(isA<StateError>()),
    );
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

NormalizedProviderEnvelopeV1 _envelope({
  required String kind,
  Map<String, dynamic> normalized = const {},
}) {
  return NormalizedProviderEnvelopeV1(
    provider: 'anilist',
    providerItemId: '123',
    kind: kind,
    normalized: normalized,
    provenance: const ProviderProvenance(fetchedAt: '2026-01-01T00:00:00Z'),
    images: const [],
    attribution: const ProviderAttribution(required: false),
  );
}

ShelfEntry _mangaEntry(String id, int volume, {bool owned = true}) {
  return ShelfEntry(
    itemId: id,
    catalogItem: CatalogItem(
      identity: LibraryItemIdentity(id: id, mediaKind: CatalogMediaKind.manga),
      kindMetadata: MangaMetadata(
        title: 'Volume $volume',
        seriesTitle: 'Nausicaa',
        volumeNumber: volume,
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Nausicaa'),
      ),
    ),
    ownedItem: owned
        ? OwnedItem(
            id: 'owned-$id',
            catalogRef: CatalogEntityRef(
              id: id,
              kind: CatalogMediaKind.manga.apiValue,
              entityType: CatalogEntityType.work,
            ),
            details: const GenericOwnedDetails(),
            updatedAt: DateTime.utc(2026, 1, 1),
          )
        : null,
  );
}
