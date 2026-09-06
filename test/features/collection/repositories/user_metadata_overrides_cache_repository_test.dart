import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips an opaque catalog target without semantic columns',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    const target = CatalogEntityRef(
      kind: 'book',
      entityType: CatalogEntityType.edition,
      id: 'edition-1',
    );
    final updatedAt = DateTime.utc(2026, 9, 7, 12);
    final override = UserMetadataOverride(
      id: 'override-1',
      targetRef: target,
      fieldPath: 'publisher',
      originalValue: 'Original',
      overrideValue: 'Corrected',
      updatedAt: updatedAt,
    );

    await repository.upsert(override);

    final row = await db.select(db.userMetadataOverridesCache).getSingle();
    expect(row.targetRefJson, contains('edition-1'));
    final restored = await repository.findByField(target, 'publisher');
    expect(restored?.targetRef.kind, 'book');
    expect(restored?.targetRef.entityType, CatalogEntityType.edition);
    expect(restored?.targetRef.id, 'edition-1');
    expect(restored?.overrideValue, 'Corrected');
    expect(
        restored?.toSyncPayload(), containsPair('target_ref', target.toJson()));
  });
}
