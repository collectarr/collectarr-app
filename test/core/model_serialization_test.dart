import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('media catalog parses route labels and physical formats', () {
    final mediaType = CatalogMediaType.fromJson({
      'kind': 'movie',
      'singular_label': 'Movie',
      'plural_label': 'Movies',
      'route_segments': ['movies', 'movie'],
      'is_top_level': true,
      'physical_formats': [
        {
          'id': 'blu-ray',
          'label': 'Blu-ray',
          'media_family': 'video',
          'variant_type': 'physical',
          'aliases': ['bluray', 'blu ray'],
        }
      ],
    });

    expect(mediaType.kind, 'movie');
    expect(mediaType.routeSegments, ['movies', 'movie']);
    expect(mediaType.physicalFormats.single.id, 'blu-ray');
    expect(mediaType.physicalFormats.single.aliases, ['bluray', 'blu ray']);
  });

  test('catalog item parses search json', () {
    final item = CatalogItemDto.fromJson({
      'id': 'id-1',
      'kind': 'comic',
      'title': 'Spider-Man',
      'item_number': '1',
      'synopsis': 'Seed',
      'cover_image_url': 'https://cdn.example/full.jpg',
      'thumbnail_image_url': 'https://cdn.example/thumb.jpg',
    });

    expect(item.title, 'Spider-Man');
    expect(item.payload['item_number'], '1');
    expect(item.coverImageUrl, 'https://cdn.example/full.jpg');
    expect(item.thumbnailImageUrl, 'https://cdn.example/thumb.jpg');
    expect(item.displayCoverUrl, 'https://cdn.example/thumb.jpg');
    final comic = ComicCoreMapper.fromCatalogItem(item);
    expect(comic, isA<ComicCatalogItem>());
    expect(comic.id, const ComicCatalogItemId('id-1'));
  });

  test('catalog item builds sync snapshot payload', () {
    final item = testCatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Absolute Batman',
      itemNumber: '1',
      synopsis: 'Absolute universe launch',
      coverImageUrl: 'https://cdn.example/full.jpg',
      thumbnailImageUrl: 'https://cdn.example/thumb.jpg',
      publisher: 'DC',
      releaseDate: DateTime.utc(2024, 10, 9),
      releaseYear: 2024,
      barcode: '76194138584600111',
      variant: 'Cover A',
    );

    final payload = item.toSyncPayload();

    expect(payload['snapshot_version'], 1);
    expect(payload['id'], 'comic-1');
    expect(payload['kind'], 'comic');
    expect(payload['title'], 'Absolute Batman');
    expect(payload['cover_image_url'], 'https://cdn.example/full.jpg');
    expect(payload['thumbnail_image_url'], 'https://cdn.example/thumb.jpg');
    expect(payload['release_date'], '2024-10-09T00:00:00.000Z');
  });

  test('Music Catalog Item DTO preserves its flat album and disc contract', () {
    final musicDto = CatalogMusicItemDto.fromJson({
      'id': 'music-1',
      'kind': 'music',
      'title': 'Discovery',
      'artist': 'Daft Punk',
      'label': 'Daft Life',
      'format': 'CD',
      'catalog_number': 'DISC-2001',
      'release_date': '2001-03-12',
      'discs': [
        {
          'id': 'disc-1',
          'disc_number': 1,
          'tracks': [
            {
              'id': 'track-1',
              'position': '1',
              'title': 'One More Time',
              'duration_ms': 320000,
            },
            {
              'id': 'track-2',
              'position': '2',
              'title': 'Aerodynamic',
              'duration_ms': 212000,
            },
          ],
        },
      ],
    });
    final item = testCatalogItem(
      id: musicDto.id,
      kind: 'music',
      title: musicDto.title,
      payload: {'music': musicDto.toProposalData()},
    );

    final music = MusicCatalogMapper.mapDtoToMusic(item);
    expect(music.id.value, 'music-1');
    expect(music.title, 'Discovery');
    expect(music.artist, 'Daft Punk');
    expect(music.publisher, 'Daft Life');
    expect(music.catalogNumber, 'DISC-2001');
    expect(music.trackCount, 2);
    expect(music.mediums.single.tracks.first.title, 'One More Time');
    expect(music.mediums.single.tracks.first.durationMs, 320000);
    expect(music.releaseDateParts?.isoString, '2001-03-12');
  });

  test('catalog item exposes typed detail views for non-music media', () {
    final item = CatalogItemDto.fromJson({
      'id': 'movie-1',
      'kind': 'movie',
      'title': 'Blade Runner 2049',
      'series_id': 'franchise-1',
      'series_title': 'Blade Runner',
      'season_number': 1,
      'episode_number': 2,
      'runtime_minutes': 164,
      'platforms': ['Blu-ray'],
      'page_count': 220,
      'cover_price_cents': 2599,
      'currency': 'USD',
      'imprint': 'Warner Archive',
      'subtitle': 'Collector Edition',
      'series_group': 'Sci-Fi Classics',
    });

    final videoItem = MovieCatalogMapper.mapDtoToMovie(item);
    expect(videoItem, isA<MovieCatalogItem>());
    expect(videoItem.runtimeMinutes, 164);
  });

  test('personal models preserve catalog entity refs in sync payloads', () {
    final ref = CatalogEntityRef(
      kind: CatalogMediaKind.book,
      entityType: const CatalogEntityTypeId('edition'),
      id: 'edition-1',
    );
    final owned = testOwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      catalogRef: ref,
      updatedAt: DateTime.utc(2026, 7, 2),
    );
    final customValue = CustomFieldValue(
      id: 'cf-1',
      targetId: owned.ref.key,
      targetScope: CustomFieldTargetScope.ownedCopy,
      catalogRef: ref,
      fieldDefinitionId: 'field-1',
      value: 'Shelf A',
      updatedAt: DateTime.utc(2026, 7, 2),
    );

    expect(owned.toSyncPayload()['catalog_ref'], ref.toJson());
    expect(customValue.toSyncPayload()['catalog_ref'], ref.toJson());
    expect(
      BookOwnedItem.fromJson({
        'id': 'owned-1',
        'catalog_ref': ref.toJson(),
        'updated_at': '2026-07-02T00:00:00.000Z',
      }).catalogRef.id,
      'edition-1',
    );
  });

  test('typed TV episode parses runtime and air date', () {
    final episode = TvEpisode.fromJson({
      'id': 'episode-1',
      'series_id': 'series-1',
      'season_id': 'season-1',
      'season_number': 1,
      'episode_number': 1,
      'title': 'Romance Dawn',
      'description': 'A new adventure begins.',
      'air_date': '2026-01-01T00:00:00Z',
      'runtime_minutes': 24,
    });

    expect(episode.title, 'Romance Dawn');
    expect(episode.description, 'A new adventure begins.');
    expect(episode.runtimeMinutes, 24);
    expect(episode.airDate, DateTime.utc(2026, 1, 1));
  });

  test('loan parses optional invalid dates as null and guards required fields',
      () {
    final loan = Loan.fromJson({
      'id': 'loan-1',
      'owned_ref': {'kind': 'book', 'id': 'owned-1'},
      'borrower_name': 'Alex',
      'lent_date': '2026-05-01',
      'due_date': 'not-a-date',
      'returned_date': '',
    });

    expect(loan.lentDate, DateTime.parse('2026-05-01'));
    expect(loan.dueDate, isNull);
    expect(loan.returnedDate, isNull);
    expect(
      () => Loan.fromJson({
        'id': 'loan-2',
        'owned_ref': {'kind': 'book', 'id': 'owned-2'},
        'borrower_name': 'Jamie',
        'lent_date': 'invalid-date',
      }),
      throwsA(isA<StateError>()),
    );
  });

  test('smart list preserves unknown persisted field tokens', () {
    final smartList = SmartList.fromRow(
      'smart-1',
      'Movies',
      '{"schema_version":1,"entity_type":"catalog_item","quick_view":"unknown_view","sort_column":"unknown_sort","filter":{"ownership":"unknown"}}',
    );

    expect(smartList.quickView, isNull);
    expect(smartList.sortColumn, 'unknown_sort');
    expect(smartList.degradedSortTokens, contains('unknown_sort'));
    expect(
        smartList.filterSelection.ownershipFilter, LibraryOwnershipFilter.all);
  });

  test('owned item builds sync payload', () {
    final item = testOwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      catalogRef: CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: const CatalogEntityTypeId('work'),
        id: 'comic-1',
      ),
      createdAt: DateTime.utc(2026, 5, 10),
      isDigital: true,
      condition: 'Near Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 5, 11),
      pricePaidCents: 1299,
      coverPriceCents: 1599,
      currency: 'USD',
      quantity: 2,
      keyComic: true,
      keyReason: 'First appearance',
      tags: 'signed,key',
      soldAt: DateTime.utc(2026, 5, 20),
      sellPriceCents: 1899,
      soldTo: 'Local shop',
      ownerUserId: 'user-1',
      ownerLabel: 'user@example.com',
      locationId: 'loc-short-box-6',
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    final payload = item.toSyncPayload();

    expect(payload['catalog_ref'], {
      'kind': 'comic',
      'entity_type': 'work',
      'id': 'comic-1',
    });
    expect(payload['created_at'], '2026-05-10T00:00:00.000Z');
    expect(payload['is_digital'], isTrue);
    expect(payload['grade'], '9.8');
    expect(payload['purchase_date'], '2026-05-11T00:00:00.000Z');
    expect(payload['price_paid_cents'], 1299);
    expect(payload['cover_price_cents'], 1599);
    expect(payload['quantity'], 2);
    expect(payload.containsKey('storage_box'), isFalse);
    expect(payload['key_comic'], isTrue);
    expect(payload['key_reason'], 'First appearance');
    expect(payload['tags'], 'signed,key');
    expect(payload['sold_at'], '2026-05-20T00:00:00.000Z');
    expect(payload['sell_price_cents'], 1899);
    expect(payload['sold_to'], 'Local shop');
    expect(payload['owner_user_id'], 'user-1');
    expect(payload['owner_label'], 'user@example.com');
    expect(payload['location_id'], 'loc-short-box-6');
  });

  test('wishlist item builds sync payload', () {
    final item = WishlistItem(
      id: 'wish-1',
      catalogRef: testCatalogRef('comic-1', kind: 'comic'),
      targetPriceCents: 999,
      currency: 'USD',
      createdAt: DateTime.utc(2026, 5, 11),
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    final payload = item.toSyncPayload();

    expect(payload['catalog_ref'], {
      'kind': 'comic',
      'entity_type': 'work',
      'id': 'comic-1',
    });
    expect(payload['target_price_cents'], 999);
    expect(payload['created_at'], '2026-05-11T00:00:00.000Z');
  });

  test('catalog entity ref preserves opaque entity type identifiers', () {
    final ref = CatalogEntityRef.fromJson({
      'kind': 'book',
      'entity_type': 'bundle-release',
      'id': 'bundle-1',
    });

    expect(ref.entityType, const CatalogEntityTypeId('bundle-release'));
    expect(ref.isKnown, isTrue);
    expect(ref.toJson()['entity_type'], 'bundle-release');
  });

  test('metadata field spec captures routing metadata', () {
    final spec = MetadataFieldSpec.fromJson({
      'key': 'title',
      'value_type': 'string',
      'label': 'Title',
      'common': true,
      'typed': false,
      'normalized': true,
      'editable': true,
      'section': 'item',
      'input': 'text',
      'kinds': ['book'],
      'ownership_by_kind': {
        'book': {
          'scope': 'catalog_item',
          'write_target': 'core_canonical',
          'source_entity_type': 'catalog_book_item',
          'source_table': 'book_items',
        },
      },
    });

    final ownership = spec.ownershipForKind('book');
    expect(ownership.scope, MetadataFieldScope.catalogItem);
    expect(ownership.writeTarget, MetadataWriteTarget.coreCanonical);
    expect(ownership.sourceEntityType, 'catalog_book_item');
    expect(ownership.sourceTable, 'book_items');
  });
}
