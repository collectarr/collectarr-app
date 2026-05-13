import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
          'publisher': 'Marvel',
          'isbn': null,
          'upc': '75960604716100111',
          'language': 'en',
          'region': 'US',
          'release_date': '2026-05-11',
          'metadata_json': {
            'source': {
              'site_detail_url': 'https://comicvine.example/issue',
              'person_credits': [
                {'name': 'Stan Lee'}
              ],
            },
          },
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
              'is_primary': true,
            }
          ],
          'releases': [
            {
              'id': 'release-1',
              'region': 'US',
              'release_date': '2026-05-11',
              'publisher': 'Marvel',
              'external_ids': {'comicvine': '4000-1'},
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
    expect(detail.primaryEdition?.releases.single.region, 'US');
    expect(detail.primaryVariant?.barcode, '75960604716100111');
    expect(detail.primaryVariant?.coverPriceCents, 399);
    expect(
      detail.primaryEdition?.sourceMetadata?['site_detail_url'],
      'https://comicvine.example/issue',
    );
  });

  test('owned item builds sync payload', () {
    final item = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      condition: 'Near Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 5, 11),
      pricePaidCents: 1299,
      currency: 'USD',
      quantity: 2,
      storageBox: 'Box 6',
      keyComic: true,
      keyReason: 'First appearance',
      tags: 'signed,key',
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    final payload = item.toSyncPayload();

    expect(payload['item_id'], 'comic-1');
    expect(payload['grade'], '9.8');
    expect(payload['purchase_date'], '2026-05-11T00:00:00.000Z');
    expect(payload['quantity'], 2);
    expect(payload['storage_box'], 'Box 6');
    expect(payload['key_comic'], isTrue);
    expect(payload['key_reason'], 'First appearance');
    expect(payload['tags'], 'signed,key');
  });

  test('wishlist item builds sync payload', () {
    final item = WishlistItem(
      id: 'wish-1',
      itemId: 'comic-1',
      targetPriceCents: 999,
      currency: 'USD',
      createdAt: DateTime.utc(2026, 5, 11),
      updatedAt: DateTime.utc(2026, 5, 12),
    );

    final payload = item.toSyncPayload();

    expect(payload['item_id'], 'comic-1');
    expect(payload['target_price_cents'], 999);
    expect(payload['created_at'], '2026-05-11T00:00:00.000Z');
  });
}
