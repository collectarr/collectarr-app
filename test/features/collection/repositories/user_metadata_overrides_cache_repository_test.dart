import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips an opaque LibraryEntryRef target without semantic columns',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    const target = LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId('edition-1'),
    );
    final updatedAt = DateTime.utc(2026, 9, 7, 12);
    final override = UserMetadataOverride(
      id: 'override-1',
      libraryEntryRef: target,
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
    expect(row.libraryEntryRefKey, contains('edition-1'));
    final restored = await repository.findByField(
      target,
      const MetadataFieldId(
        kind: CatalogMediaKind.book,
        value: 'publisher',
      ),
    );
    expect(restored?.libraryEntryRef.kind, CatalogMediaKind.book);
    expect(restored?.libraryEntryRef.id.value, 'edition-1');
    expect(restored?.overrideValue, 'Corrected');
    expect(restored?.toSyncPayload(),
        containsPair('library_entry_ref', target.toJson()));
  });

  test('filters active overrides by their kind and LibraryEntry ID', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = UserMetadataOverridesCacheRepository(db);
    const bookTarget = LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId('shared-id'),
    );
    const comicTarget = LibraryEntryRef(
      kind: CatalogMediaKind.comic,
      id: LibraryEntryId('shared-id'),
    );

    await repository.upsertAll([
      UserMetadataOverride(
        id: 'book-override',
        libraryEntryRef: bookTarget,
        fieldId: const MetadataFieldId(
          kind: CatalogMediaKind.book,
          value: 'publisher',
        ),
        overrideValue: 'Book publisher',
        updatedAt: DateTime.utc(2026, 9, 7),
      ),
      UserMetadataOverride(
        id: 'comic-override',
        libraryEntryRef: comicTarget,
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
      libraryEntryRef: const LibraryEntryRef(
        kind: CatalogMediaKind.unknown,
        id: LibraryEntryId(''),
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
      libraryEntryRef: const LibraryEntryRef(
        kind: CatalogMediaKind.book,
        id: LibraryEntryId('book-1'),
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
