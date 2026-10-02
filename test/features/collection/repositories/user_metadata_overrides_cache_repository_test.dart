import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips an opaque Catalog Item target without semantic columns',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    const target = CatalogItemRef(
      kind: CatalogMediaKind.book,
      id: 'edition-1',
    );
    final updatedAt = DateTime.utc(2026, 9, 7, 12);
    final override = UserMetadataOverride(
      id: 'override-1',
      catalogRef: target,
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
    expect(row.catalogRefJson, contains('edition-1'));
    final restored = await repository.findByField(
      target,
      const MetadataFieldId(
        kind: CatalogMediaKind.book,
        value: 'publisher',
      ),
    );
    expect(restored?.catalogRef.kind, CatalogMediaKind.book);
    expect(restored?.catalogRef.id, 'edition-1');
    expect(restored?.overrideValue, 'Corrected');
    expect(restored?.toSyncPayload(),
        containsPair('catalog_ref', target.toJson()));
  });

  test('filters active overrides by their kind and Catalog Item ID', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    const bookTarget = CatalogItemRef(
      kind: CatalogMediaKind.book,
      id: 'shared-id',
    );
    const comicTarget = CatalogItemRef(
      kind: CatalogMediaKind.comic,
      id: 'shared-id',
    );

    await repository.upsertAll([
      UserMetadataOverride(
        id: 'book-override',
        catalogRef: bookTarget,
        fieldId: const MetadataFieldId(
          kind: CatalogMediaKind.book,
          value: 'publisher',
        ),
        overrideValue: 'Book publisher',
        updatedAt: DateTime.utc(2026, 9, 7),
      ),
      UserMetadataOverride(
        id: 'comic-override',
        catalogRef: comicTarget,
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

  test('rejects unknown targets and empty override values', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    final unknownTarget = UserMetadataOverride(
      id: 'invalid-target',
      catalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.unknown,
        id: '',
      ),
      fieldId: const MetadataFieldId(
        kind: CatalogMediaKind.unknown,
        value: 'title',
      ),
      overrideValue: 'value',
      updatedAt: DateTime.utc(2026, 9, 7),
    );
    await expectLater(repository.upsert(unknownTarget), throwsArgumentError);

    final emptyValue = UserMetadataOverride(
      id: 'empty-value',
      catalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.book,
        id: 'book-1',
      ),
      fieldId: const MetadataFieldId(
        kind: CatalogMediaKind.book,
        value: 'title',
      ),
      overrideValue: ' ',
      updatedAt: DateTime.utc(2026, 9, 7),
    );
    await expectLater(repository.upsert(emptyValue), throwsArgumentError);
  });
}
