import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
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
}