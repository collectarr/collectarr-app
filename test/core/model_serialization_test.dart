import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import '../helpers/json_test_helpers.dart';

void main() {
  test('media catalog parses provider defaults and physical formats', () {
    final mediaType = CatalogMediaType.fromJson({
      'kind': 'movie',
      'singular_label': 'Movie',
      'plural_label': 'Movies',
      'route_segments': ['movies', 'movie'],
      'default_provider': 'tmdb',
      'providers': ['tmdb'],
      'provider_search_policy': 'core_miss_then_configured_providers',
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
    expect(mediaType.defaultProvider, 'tmdb');
    expect(mediaType.providers, ['tmdb']);
    expect(
        mediaType.providerSearchPolicy, 'core_miss_then_configured_providers');
    expect(mediaType.routeSegments, ['movies', 'movie']);
    expect(mediaType.physicalFormats.single.id, 'blu-ray');
    expect(mediaType.physicalFormats.single.aliases, ['bluray', 'blu ray']);
  });

  test('catalog item parses search json', () {
    final item = CatalogItem.fromJson({
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
    expect(comic, isA<ComicMedia>());
    expect(comic.id, const ComicMediaId('id-1'));
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
    expect(payload.containsKey('id'), isFalse);
    expect(payload['title'], 'Absolute Batman');
    expect(payload['cover_image_url'], 'https://cdn.example/full.jpg');
    expect(payload['thumbnail_image_url'], 'https://cdn.example/thumb.jpg');
    expect(payload['release_date'], '2024-10-09T00:00:00.000Z');
  });

  test('catalog item preserves canonical metadata contract fields', () {
    final item = CatalogItem.fromJson({
      'id': 'music-1',
      'kind': 'music',
      'title': 'Discovery',
      'publisher': 'Daft Life',
      'catalog_number': 'DISC-2001',
      'track_count': 2,
      'tracks': [
        {
          'position': 1,
          'title': 'One More Time',
          'duration_seconds': 320,
        },
        {
          'position': 2,
          'title': 'Aerodynamic',
          'duration_seconds': 212,
        },
      ],
      'platforms': ['CD', 'Digital'],
      'release_status': 'Official',
      'release_date': '2001-03-12T00:00:00.000Z',
      'editions': [
        {
          'id': 'edition-1',
          'title': 'Deluxe CD',
          'format': 'CD',
          'publisher': 'Daft Life',
          'physical_format': 'cd',
          'physical_format_label': 'CD',
          'metadata_json': {
            'legacy_hint': 'keep-for-read-only',
          },
          'variants': [
            {
              'id': 'variant-1',
              'name': 'Limited Slipcase',
              'variant_type': 'physical',
              'barcode': '123456789012',
              'is_primary': true,
              'metadata_json': {
                'legacy_hint': 'keep-for-read-only',
              },
            }
          ],
        }
      ],
    });

    expect(MusicCatalogMapper.mapDtoToMusic(item), isA<MusicCatalogItem>());
    expect(item.payload['catalog_number'], 'DISC-2001');
    expect(item.payload['track_count'], 2);
    final tracks = jsonObjectList(item.payload['tracks']);
    expect(tracks, hasLength(2));
    expect(tracks.first['title'], 'One More Time');
    expect(item.payload['platforms'], ['CD', 'Digital']);
    expect(item.payload['release_status'], 'Official');
    expect(item.editions, hasLength(1));
    expect(item.editions.single.title, 'Deluxe CD');
    expect(item.editions.single.variants, hasLength(1));
    expect(item.editions.single.variants.single.name, 'Limited Slipcase');
    expect(item.editions.single.variants.single.isPrimary, isTrue);

    final payload = item.toSyncPayload();

    expect(payload['catalog_number'], 'DISC-2001');
    expect(payload['track_count'], 2);
    expect(
        ((payload['tracks'] as List).first as Map)['title'], 'One More Time');
    final editionPayload = (payload['editions'] as List).single as Map;
    expect(editionPayload['title'], 'Deluxe CD');
    expect(editionPayload.containsKey('metadata_json'), isFalse);
    final variantPayload = (editionPayload['variants'] as List).single as Map;
    expect(variantPayload.containsKey('metadata_json'), isFalse);
    expect(payload['platforms'], ['CD', 'Digital']);
    expect(payload['release_status'], 'Official');
    expect(payload['release_date'], '2001-03-12T00:00:00.000Z');
  });

  test('catalog item exposes typed detail views for non-music media', () {
    final item = CatalogItem.fromJson({
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
    expect(videoItem.videoDetails, isNotNull);
    expect(videoItem.videoDetails.runtimeMinutes, 164);
  });

  test('personal models preserve catalog entity refs in sync payloads', () {
    final ref = CatalogEntityRef(
      kind: 'book',
      entityType: CatalogEntityType.edition,
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
      targetId: owned.id,
      targetScope: CustomFieldTargetScope.ownedCopy,
      catalogRef: ref,
      fieldDefinitionId: 'field-1',
      value: 'Shelf A',
      updatedAt: DateTime.utc(2026, 7, 2),
    );

    expect(owned.toSyncPayload()['catalog_ref'], ref.toJson());
    expect(customValue.toSyncPayload()['catalog_ref'], ref.toJson());
    expect(
      OwnedItem.fromJson({
        'id': 'owned-1',
        'catalog_ref': ref.toJson(),
        'updated_at': '2026-07-02T00:00:00.000Z',
      },
          decodeDetails: (json) => libraryKindRuntimeForKind(ref.mediaKind)
              .decodeOwnedDetails(json)).catalogRef.id,
      'edition-1',
    );
  });

  test('provider preview parses music tracks', () {
    final preview = AdminProviderPreview.fromJson({
      'provider': 'musicbrainz',
      'provider_item_id': 'release-1',
      'kind': 'music',
      'title': 'Discovery',
      'track_count': 2,
      'tracks': [
        {
          'position': 1,
          'title': 'One More Time',
          'duration_seconds': 320,
          'artist': 'Daft Punk',
          'disc_number': 1,
        },
        {
          'position': 2,
          'title': 'Aerodynamic',
          'duration_seconds': 212,
          'artist': 'Daft Punk',
          'disc_number': 1,
        },
      ],
    });

    expect(preview.trackCount, 2);
    expect(preview.tracks, hasLength(2));
    expect(preview.tracks.first.title, 'One More Time');
    expect(preview.tracks.first.durationSeconds, 320);
    expect(preview.tracks.first.artist, 'Daft Punk');
  });

  test('admin duplicate candidate parses score and recommended target', () {
    final candidate = AdminDuplicateCandidate.fromJson({
      'kind': 'comic',
      'title': 'Absolute Batman',
      'item_number': '1',
      'count': 2,
      'item_ids': ['a', 'b'],
      'duplicate_score': 86,
      'recommended_target_item_id': 'b',
    });

    expect(candidate.duplicateScore, 86);
    expect(candidate.recommendedTargetItemId, 'b');
    expect(candidate.preferredTargetItemId, 'b');
    expect(candidate.displayTitle, 'Absolute Batman #1');
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
      'owned_item_id': 'owned-1',
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
        'owned_item_id': 'owned-2',
        'borrower_name': 'Jamie',
        'lent_date': 'invalid-date',
      }),
      throwsA(isA<StateError>()),
    );
  });

  test('smart list ignores unknown persisted enum values', () {
    final smartList = SmartList.fromRow(
      'smart-1',
      'Movies',
      '{"quick_view":"legacy_view","sort_column":"legacy_sort","filter":{"ownership":"legacy"}}',
    );

    expect(smartList.quickView, isNull);
    expect(smartList.sortColumn, isNull);
    expect(
        smartList.filterSelection.ownershipFilter, LibraryOwnershipFilter.all);
  });

  test('owned item builds sync payload', () {
    final item = testOwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      catalogRef: CatalogEntityRef(
        kind: 'comic',
        entityType: CatalogEntityType.work,
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

  test('catalog entity ref parses bundle release aliases', () {
    final ref = CatalogEntityRef.fromJson({
      'kind': 'book',
      'entity_type': 'bundle-release',
      'id': 'bundle-1',
    });

    expect(ref.entityType, CatalogEntityType.bundleRelease);
    expect(ref.isKnown, isTrue);
    expect(ref.toJson()['entity_type'], 'bundle_release');
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
      'scope': 'work',
      'write_target': 'core_canonical',
      'source_entity_type': 'book_work',
      'source_table': 'book_works',
    });

    expect(spec.scope, MetadataFieldScope.work);
    expect(spec.writeTarget, MetadataWriteTarget.coreCanonical);
    expect(spec.sourceEntityType, 'book_work');
    expect(spec.sourceTable, 'book_works');
  });
}
