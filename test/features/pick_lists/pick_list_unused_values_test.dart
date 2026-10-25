import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late PickListRepository repository;

  setUp(() async {
    db = LocalDatabase(NativeDatabase.memory());
    repository = PickListRepository(db,
        contributors: defaultPickListDefinitionContributors);
    await LibraryEntryStore(db).put(LibraryEntryRecord(
      id: 'game-copy',
      kind: CatalogMediaKind.game,
      catalogData: const {
        'title': 'Fictional Quest',
        'genres': ['Used Genre'],
      },
      personalData: const {},
      updatedAt: DateTime.utc(2026),
    ));
    for (final value in ['Used Genre', 'Unused Genre', 'Kept Genre']) {
      await repository.addValue('game.genre', value, mediaKind: 'game');
    }
  });
  tearDown(() => db.close());

  test('values no entry uses are deleted, as CLZ drops them', () async {
    await repository.deleteUnusedValues('game.genre',
        mediaKind: 'game', keep: const ['Kept Genre']);

    expect(await repository.getValues('game.genre', mediaKind: 'game'),
        unorderedEquals(['Used Genre', 'Kept Genre']));
  });

  test('nothing is deleted when no contributor can count usage', () async {
    await PickListRepository(db)
        .deleteUnusedValues('game.genre', mediaKind: 'game');

    expect(await repository.getValues('game.genre', mediaKind: 'game'),
        hasLength(3));
  });
}
