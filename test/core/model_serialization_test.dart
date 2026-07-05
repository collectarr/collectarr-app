import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/smart_list.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

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
    expect(item.itemNumber, '1');
    expect(item.coverImageUrl, 'https://cdn.example/full.jpg');
    expect(item.thumbnailImageUrl, 'https://cdn.example/thumb.jpg');
    expect(item.displayCoverUrl, 'https://cdn.example/thumb.jpg');
    expect(item, isA<ComicCatalogItem>());
  });

  test('catalog item builds sync snapshot payload', () {
    final item = CatalogItem(
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

    expect(item.music, isNotNull);
    expect(item, isA<MusicCatalogItem>());
    expect(item.music!.catalogNumber, 'DISC-2001');
    expect(item.music!.trackCount, 2);
    expect(item.music!.tracks, hasLength(2));
    expect(item.music!.tracks.first.title, 'One More Time');
    expect(item.rawPlatforms, ['CD', 'Digital']);
    expect(item.music!.releaseStatus, 'Official');
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

    expect(item.series, isNotNull);
    expect(item.series!.seriesTitle, 'Blade Runner');
    expect(item.series!.hasSeason, isTrue);
    expect(item, isA<MovieCatalogItem>());
    expect(item.video, isNotNull);
    expect(item.video!.runtimeMinutes, 164);
    expect(item.publishing, isNotNull);
    expect(item.publishing!.pageCount, 220);
    expect(item.publishing!.imprint, 'Warner Archive');
    expect(item.game, isNull);
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
      }).catalogRef.id,
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

  test('season episode parses page count separately from runtime', () {
    final episode = Episode.fromJson({
      'episode_number': 1,
      'title': 'Romance Dawn',
      'runtime_minutes': null,
      'page_count': 53,
    });

    expect(episode.pageCount, 53);
    expect(episode.runtimeMinutes, isNull);
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

  test('comic detail parses editions and variants', () {
    final detail = ComicDetail.fromJson({
      'id': 'comic-1',
      'kind': 'comic',
      'title': 'Spider-Man',
      'item_number': '1',
      'sort_key': 'spider-man-000001',
      'synopsis': 'Seed',
      'series_title': 'Amazing Spider-Man',
      'volume_name': 'Amazing Spider-Man, Vol. 1',
      'volume_number': 1,
      'volume_start_year': 1963,
      'publisher': 'Marvel',
      'barcode': '75960604716100111',
      'cover_date': '1963-03-01',
      'store_date': '1963-02-10',
      'page_count': 32,
      'cover_price_cents': 399,
      'currency': 'USD',
      'creators': [
        {
          'name': 'Stan Lee',
          'role': 'Writer',
          'api_detail_url': 'https://comicvine.example/person',
          'site_detail_url': null,
        }
      ],
      'characters': [
        {'name': 'Spider-Man'}
      ],
      'story_arcs': [
        {'name': 'The Spider Strikes'}
      ],
      'provider_links': [
        {
          'provider': 'comicvine',
          'entity_type': 'item',
          'provider_item_id': '4000-1',
          'site_url': 'https://comicvine.example/issue',
          'api_url': 'https://comicvine.example/api/issue',
        }
      ],
      'editions': [
        {
          'id': 'edition-1',
          'title': 'Regular Edition',
          'format': 'Single Issue',
          'physical_format': 'blu-ray',
          'physical_format_label': 'Blu-ray',
          'publisher': 'Marvel',
          'isbn': null,
          'upc': '75960604716100111',
          'language': 'en',
          'region': 'US',
          'release_date': '2026-05-11',
          'variants': [
            {
              'id': 'variant-1',
              'name': 'Cover A',
              'sku': null,
              'barcode': '75960604716100111',
              'isbn': null,
              'variant_type': 'regular',
              'region': 'US',
              'cover_price_cents': 399,
              'currency': 'USD',
              'cover_image_url': 'https://cdn.example/full.jpg',
              'thumbnail_image_url': 'https://cdn.example/thumb.jpg',
              'description': 'Regular cover',
              'physical_format': 'blu-ray',
              'physical_format_label': 'Blu-ray',
              'is_primary': true,
            }
          ],
          'releases': [
            {
              'id': 'release-1',
              'region': 'US',
              'release_date': '2026-05-11',
              'publisher': 'Marvel',
              'provider_links': [
                {
                  'provider': 'comicvine',
                  'entity_type': 'bundle_release',
                  'provider_item_id': '4000-1',
                },
              ],
            }
          ],
        }
      ],
    });

    expect(detail.primaryEdition?.id, 'edition-1');
    expect(detail.primaryVariant?.id, 'variant-1');
    expect(detail.displayCoverUrl, 'https://cdn.example/thumb.jpg');
    expect(detail.seriesTitle, 'Amazing Spider-Man');
    expect(detail.volumeName, 'Amazing Spider-Man, Vol. 1');
    expect(detail.coverDate, DateTime.utc(1963, 3, 1));
    expect(detail.storeDate, DateTime.utc(1963, 2, 10));
    expect(detail.pageCount, 32);
    expect(detail.coverPriceCents, 399);
    expect(detail.creators.single.name, 'Stan Lee');
    expect(detail.creators.single.role, 'Writer');
    expect(detail.characters.single.name, 'Spider-Man');
    expect(detail.storyArcs.single.name, 'The Spider Strikes');
    expect(detail.providerLinks.single.providerItemId, '4000-1');
    expect(detail.primaryEdition?.releaseDate, DateTime.utc(2026, 5, 11));
    expect(detail.primaryEdition?.region, 'US');
    expect(detail.primaryEdition?.physicalFormat, 'blu-ray');
    expect(detail.primaryEdition?.physicalFormatLabel, 'Blu-ray');
    expect(detail.primaryVariant?.barcode, '75960604716100111');
    expect(detail.primaryVariant?.physicalFormatLabel, 'Blu-ray');
    expect(detail.primaryVariant?.coverPriceCents, 399);
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
      'is_legacy_projection': false,
    });

    expect(spec.scope, MetadataFieldScope.work);
    expect(spec.writeTarget, MetadataWriteTarget.coreCanonical);
    expect(spec.sourceEntityType, 'book_work');
    expect(spec.sourceTable, 'book_works');
    expect(spec.isLegacyProjection, isFalse);
  });
}
