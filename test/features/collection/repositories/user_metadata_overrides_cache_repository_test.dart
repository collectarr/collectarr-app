import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
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
      kind: CatalogMediaKind.book,
      entityType: const CatalogEntityTypeId('edition'),
      id: 'edition-1',
    );
    final updatedAt = DateTime.utc(2026, 9, 7, 12);
    final override = UserMetadataOverride(
      id: 'override-1',
      targetRef: target,
      fieldId: const MetadataFieldId(
        kind: CatalogMediaKind.book,
        value: 'publisher',
      ),
      originalValue: 'Original',
      overrideValue: 'Corrected',
      updatedAt: updatedAt,
    );

    await repository.upsert(override);

    final row = await db.select(db.userMetadataOverridesCache).getSingle();
    expect(row.targetRefJson, contains('edition-1'));
    final restored = await repository.findByField(
      target,
      const MetadataFieldId(
        kind: CatalogMediaKind.book,
        value: 'publisher',
      ),
    );
    expect(restored?.targetRef.kind, CatalogMediaKind.book);
    expect(
        restored?.targetRef.entityType, const CatalogEntityTypeId('edition'));
    expect(restored?.targetRef.id, 'edition-1');
    expect(restored?.overrideValue, 'Corrected');
    expect(
        restored?.toSyncPayload(), containsPair('target_ref', target.toJson()));
  });

  test('filters active overrides by the complete structural target', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    const bookTarget = CatalogEntityRef(
      kind: CatalogMediaKind.book,
      entityType: const CatalogEntityTypeId('edition'),
      id: 'shared-id',
    );
    const comicTarget = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: const CatalogEntityTypeId('issue'),
      id: 'shared-id',
    );

    await repository.upsertAll([
      UserMetadataOverride(
        id: 'book-override',
        targetRef: bookTarget,
        fieldId: const MetadataFieldId(
          kind: CatalogMediaKind.book,
          value: 'publisher',
        ),
        overrideValue: 'Book publisher',
        updatedAt: DateTime.utc(2026, 9, 7),
      ),
      UserMetadataOverride(
        id: 'comic-override',
        targetRef: comicTarget,
        fieldId: const MetadataFieldId(
          kind: CatalogMediaKind.comic,
          value: 'publisher',
        ),
        overrideValue: 'Comic publisher',
        updatedAt: DateTime.utc(2026, 9, 7),
      ),
    ]);

    final matches = await repository.listActiveByTargets([bookTarget]);
    expect(matches.map((item) => item.id), ['book-override']);
  });
}
