import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active summary projection keeps only structural copy identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await OwnedItemsRepository(db).upsertTyped(
      CatalogMediaKind.comic,
      ComicOwnedItem(
        id: const ComicOwnedItemId('owned-comic-1'),
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-1',
        ),
        condition: 'Near Mint',
        grade: '9.8',
        ownerLabel: 'Alex',
        locationId: 'shelf-a',
        updatedAt: DateTime.utc(2026, 5, 1),
        details: const ComicOwnedDetails(),
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
