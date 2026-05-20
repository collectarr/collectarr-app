import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/add/comics_barcode_add_workflow.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barcode workflow caches metadata and adds a local owned comic',
      () async {
    final api = _FakeBarcodeApiClient();
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final item = await addComicByBarcodeToCollection(
      api: api,
      catalog: CatalogCacheRepository(db),
      mutations: container.read(collectionMutationsProvider),
      barcode: '76194134192700811',
    );

    expect(api.lastBarcode, '76194134192700811');
    expect(api.lastKind, 'comic');
    expect(item.id, 'comic-8a');

    final catalogRow = await db.select(db.catalogCache).getSingle();
    final ownedRow = await db.select(db.ownedItemsCache).getSingle();
    final syncRows = await db.select(db.syncQueue).get();

    expect(catalogRow.title, 'Superman, Vol. 4');
    expect(ownedRow.itemId, 'comic-8a');
    expect(ownedRow.condition, 'Near Mint');
    expect(ownedRow.grade, 'Ungraded');
    expect(syncRows.map((row) => row.entityType), contains('owned_item'));
    expect(
      syncRows.map((row) => row.entityType),
      contains('library_item_snapshot'),
    );
  });
}

class _FakeBarcodeApiClient extends ApiClient {
  _FakeBarcodeApiClient() : super(baseUrl: 'http://unused');

  String? lastBarcode;
  String? lastKind;

  @override
  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
  }) async {
    lastBarcode = barcode;
    lastKind = kind;
    return {
      'id': 'comic-8a',
      'kind': 'comic',
      'title': 'Superman, Vol. 4',
      'item_number': '8A',
      'publisher': 'DC',
      'release_year': 2016,
      'barcode': barcode,
      'variant': 'Regular Cover',
    };
  }
}
