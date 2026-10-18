import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late PickListRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = PickListRepository(db);
  });

  tearDown(() => db.close());

  test('addValue stores new values in ascending sort order', () async {
    expect(await repo.addValue('condition', 'Near Mint'), isTrue);
    expect(await repo.addValue('condition', 'Very Fine'), isTrue);

    expect(await repo.getValues('condition'), ['Near Mint', 'Very Fine']);
  });

  test('addValue rejects duplicates without creating extra rows', () async {
    expect(await repo.addValue('grade', '9.8'), isTrue);
    expect(await repo.addValue('grade', '9.8'), isFalse);

    expect(await repo.getValues('grade'), ['9.8']);
  });

  test('watchSortNames prefers a kind Sort Name over a shared one', () async {
    Future<void> put(String id, String list, String? kind, String value,
            String? sortName) =>
        repo.upsertValue(PickListValue(
            id: id,
            listName: list,
            mediaKind: kind,
            value: value,
            sortName: sortName));
    await put('a', 'locations', null, 'Shelf 2', 'Shelf 02');
    await put('b', 'locations', 'music', 'Shelf 2', 'Music shelf 2');
    await put('c', 'music.record_label', 'music', 'The End Records',
        'End Records, The');
    await put('d', 'music.genre', 'music', 'Metal', null);
    await put('e', 'book.publisher', 'book', 'The Folio Society', 'Folio');

    expect(await repo.watchSortNames('music').first, {
      'locations': {'shelf 2': 'Music shelf 2'},
      'music.record_label': {'the end records': 'End Records, The'},
    });
  });
}
