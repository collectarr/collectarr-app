import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late PickListRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = PickListRepository(db);
  });

  tearDown(() => db.close());

  test('returns global and kind values with kind override', () async {
    await db.into(db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: 'g1',
            listName: 'condition',
            mediaKind: const Value(null),
            value: 'Near Mint',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: 'c1',
            listName: 'condition',
            mediaKind: const Value('comic'),
            value: 'Near Mint',
            sortOrder: const Value(0),
          ),
        );
    await db.into(db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: 'c2',
            listName: 'condition',
            mediaKind: const Value('comic'),
            value: 'Very Fine',
            sortOrder: const Value(2),
          ),
        );

    final values = await repo.valuesForList(
      listName: 'condition',
      mediaKind: 'comic',
    );

    expect(values.map((value) => value.value), ['Near Mint', 'Very Fine']);
    expect(values.first.mediaKind, 'comic');
  });

  test('delete and reorder values work', () async {
    await repo.addValue('condition', 'Near Mint');
    await repo.addValue('condition', 'Very Fine');
    final values = await repo.valuesForList(listName: 'condition');
    await repo.reorderValues(
      listName: 'condition',
      mediaKind: null,
      orderedIds: [values.last.id, values.first.id],
    );
    final reordered = await repo.valuesForList(listName: 'condition');
    expect(reordered.map((value) => value.value), ['Very Fine', 'Near Mint']);

    await repo.deleteValue(reordered.first.id);
    final remaining = await repo.valuesForList(listName: 'condition');
    expect(remaining.map((value) => value.value), ['Near Mint']);
  });

  test('list names and usage counts reflect stored values', () async {
    await db.into(db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: 'g1',
            listName: 'condition',
            mediaKind: const Value(null),
            value: 'Near Mint',
            sortOrder: const Value(0),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'item-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );

    expect(await repo.listNames(), ['condition']);
    final counts = await repo.usageCounts(listName: 'condition');
    expect(counts.values.first, 1);
  });

  test('addValue rejects same-scope duplicates only', () async {
    expect(await repo.addValue('condition', 'Near Mint'), isTrue);
    expect(await repo.addValue('condition', 'Near Mint'), isFalse);
    expect(await repo.addValue('condition', 'Near Mint', mediaKind: 'comic'),
        isTrue);
    expect(await repo.getValues('condition'), ['Near Mint']);
    expect(
      (await repo.valuesForList(listName: 'condition', mediaKind: 'comic'))
          .length,
      1,
    );
  });

  test('usage counts resolve canonical kind vocabulary IDs', () async {
    await db.into(db.pickListValuesCache).insert(
          PickListValuesCacheCompanion.insert(
            id: 'publisher-1',
            listName: 'comic.publisher',
            mediaKind: const Value('comic'),
            value: 'Image Comics',
            sortOrder: const Value(0),
          ),
        );
    await LibraryCatalogRepository(db).upsertAll([
      typedCatalogItemFromMap({
        'id': 'catalog-1',
        'kind': 'comic',
        'title': 'Saga',
        'publisher': 'Image Comics',
      }),
    ]);

    final counts = await repo.usageCounts(
      listName: 'comic.publisher',
      mediaKind: 'comic',
    );

    expect(counts['publisher-1'], 1);
  });
}
