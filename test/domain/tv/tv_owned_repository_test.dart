import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late TvOwnedRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = TvOwnedRepository(db);
  });

  tearDown(() => db.close());

  test('round trips complete TV copies and filters deleted copies', () async {
    final item = TvOwnedItem(
      id: const TvOwnedItemId('owned-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: 'tv-1',
      ),
      condition: 'Very Good',
      grade: '8.5',
      personalNotes: 'Keep with the collector set',
      updatedAt: DateTime.utc(2026, 5, 1),
      details: const TvOwnedDetails(
        region: 'B',
        packaging: 'Amaray',
        distributor: 'BBC Studios',
      ),
    );

    await repository.upsert(item);

    final loaded = await repository.findById(item.id);
    expect(loaded?.id, item.id);
    expect(loaded?.itemId, 'tv-1');
    expect(loaded?.condition, 'Very Good');
    expect(loaded?.grade, '8.5');
    expect(loaded?.personalNotes, item.personalNotes);
    expect(loaded?.details, item.details);
    expect(await repository.listActive(), hasLength(1));

    final deletedAt = DateTime.utc(2026, 5, 2);
    await repository.markDeleted(item, deletedAt);

    final deleted = await repository.findById(item.id);
    expect(deleted?.deletedAt?.toUtc(), deletedAt);
    expect(await repository.listActive(), isEmpty);
  });
}
