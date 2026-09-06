import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active summary projection keeps only structural copy identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-comic-1',
            itemId: 'comic-1',
            kind: const Value('comic'),
            condition: const Value('Near Mint'),
            grade: const Value('9.8'),
            ownerLabel: const Value('Alex'),
            locationId: const Value('shelf-a'),
            updatedAt: DateTime.utc(2026, 5, 1),
          ),
        );

    final summaries = await OwnedItemsCacheRepository(db).listActiveSummaries();

    expect(summaries, hasLength(1));
    final summary = summaries.single;
    expect(summary.ref.kind, CatalogMediaKind.comic);
    expect(summary.ref.id.value, 'owned-comic-1');
    expect(summary.catalogRef?.id, 'comic-1');
    expect(summary.title, 'comic-1');
    expect(summary.ownerLabel, 'Alex');
    expect(summary.locationLabel, 'shelf-a');
  });
}
