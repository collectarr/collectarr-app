import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bulk edit applies structured location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-a',
            name: 'Shelf A',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-b',
            name: 'Shelf B',
            sortOrder: const Value(2),
          ),
        );

    final mutations = container.read(collectionMutationsProvider);
    await mutations.addItem(
      'movie-1',
      storageBox: 'Legacy shelf',
      locationId: 'loc-a',
    );

    final row = await db.select(db.ownedItemsCache).getSingle();
    final owned = OwnedItem(
      id: row.id,
      itemId: row.itemId,
      storageBox: row.storageBox,
      locationId: row.locationId,
      updatedAt: row.updatedAt,
    );
    final actions = LibraryBulkActions(mutations);

    await actions.editSelected(
      entries: [ShelfEntry(itemId: 'movie-1', ownedItem: owned)],
      selection: const LibraryBulkEditSelection(
        applyLocation: true,
        locationId: 'loc-b',
      ),
    );

    final updated = await db.select(db.ownedItemsCache).getSingle();
    expect(updated.locationId, 'loc-b');
    expect(updated.storageBox, isNull);
  });
}