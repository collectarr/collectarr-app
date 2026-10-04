import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late MovieEntryRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = MovieEntryRepository(db);
  });

  tearDown(() => db.close());

  test('round trips complete Movie copies and filters deleted copies',
      () async {
    final item = MovieLibraryEntry(
      id: const LibraryEntryId('entry-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'movie-1',
      ),
      condition: 'Very Good',
      grade: '8.5',
      personalNotes: 'Keep with the collector set',
      updatedAt: DateTime.utc(2026, 3, 1),
      details: const MovieEntryDetails(
        region: 'A',
        packaging: 'SteelBook',
        distributor: 'Warner Home Video',
      ),
    );

    await repository.upsert(item);

    final loaded = await repository.findById(item.id);
    expect(loaded?.id, item.id);
    expect(loaded?.itemId, 'movie-1');
    expect(loaded?.condition, 'Very Good');
    expect(loaded?.grade, '8.5');
    expect(loaded?.personalNotes, item.personalNotes);
    expect(loaded?.details, item.details);
    expect(await repository.listActive(), hasLength(1));

    final deletedAt = DateTime.utc(2026, 3, 2);
    await repository.markDeleted(item, deletedAt);

    final deleted = await repository.findById(item.id);
    expect(deleted?.deletedAt?.toUtc(), deletedAt);
    expect(await repository.listActive(), isEmpty);
  });
}
