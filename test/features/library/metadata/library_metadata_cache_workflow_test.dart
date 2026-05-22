import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search workflow caches metadata results', () async {
    final api = _FakeMetadataWorkflowApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final items = await searchAndCacheLibraryMetadata(
      api: api,
      type: comicsLibraryConfig,
      catalog: CatalogCacheRepository(db),
      input: const LibraryMetadataSearchInput(
        query: 'Batman',
        issueNumber: '1',
        limit: 25,
      ),
    );
    final rows = await db.select(db.catalogCache).get();

    expect(api.lastSearchQuery?.kind, 'comic');
    expect(api.lastSearchQuery?.query, 'Batman');
    expect(api.lastSearchQuery?.issueNumber, '1');
    expect(api.lastSearchQuery?.limit, 25);
    expect(items.single.id, 'comic-search-1');
    expect(rows.single.id, 'comic-search-1');
  });

  test('barcode workflow caches matches and reports misses', () async {
    final api = _FakeMetadataWorkflowApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final seen = <LibraryBarcodeLookupResult>[];

    final results = await lookupAndCacheLibraryBarcodes(
      api: api,
      type: comicsLibraryConfig,
      catalog: CatalogCacheRepository(db),
      barcodes: const ['good-code', 'missing-code'],
      onResult: seen.add,
    );
    final rows = await db.select(db.catalogCache).get();

    expect(results.length, 2);
    expect(results.first.found, isTrue);
    expect(results.last.found, isFalse);
    expect(seen.map((result) => result.barcode), [
      'good-code',
      'missing-code',
    ]);
    expect(rows.single.id, 'comic-good-code');
  });

  test('search input detects blank requests', () {
    expect(const LibraryMetadataSearchInput().isEmpty, isTrue);
    expect(
      const LibraryMetadataSearchInput(query: '   ', barcode: '').isEmpty,
      isTrue,
    );
    expect(const LibraryMetadataSearchInput(series: 'Batman').isEmpty, isFalse);
    expect(const LibraryMetadataSearchInput(year: 2024).isEmpty, isFalse);
  });
}

class _FakeMetadataWorkflowApiClient extends ApiClient {
  _FakeMetadataWorkflowApiClient() : super(baseUrl: 'http://unused');

  MetadataSearchQuery? lastSearchQuery;

  @override
  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query,
  ) async {
    lastSearchQuery = query;
    return const [
      {
        'id': 'comic-search-1',
        'kind': 'comic',
        'title': 'Batman',
        'item_number': '1',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
  }) async {
    if (barcode.contains('missing')) {
      throw Exception('missing barcode');
    }
    return {
      'id': 'comic-$barcode',
      'kind': kind ?? 'comic',
      'title': 'Batman',
      'barcode': barcode,
    };
  }
}
