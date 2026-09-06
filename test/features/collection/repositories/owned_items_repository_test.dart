import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_data_factories.dart';

void main() {
  test('active summary projection keeps only structural copy identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await OwnedItemsRepository(db).upsert(
      testOwnedItem(
        id: 'owned-comic-1',
        itemId: 'comic-1',
        kind: 'comic',
        condition: 'Near Mint',
        grade: '9.8',
        ownerLabel: 'Alex',
        locationId: 'shelf-a',
        updatedAt: DateTime.utc(2026, 5, 1),
      ),
    );

    final summaries = await OwnedItemsRepository(db).listActiveSummaries();

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
