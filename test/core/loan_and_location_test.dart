import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Loan', () {
    test('isOverdueAt uses the provided clock', () {
      final loan = Loan(
        id: 'loan-1',
        ownedItemId: 'owned-1',
        borrowerName: 'Alex',
        lentDate: DateTime.utc(2026, 5, 1),
        dueDate: DateTime.utc(2026, 5, 10),
      );

      expect(loan.isOverdueAt(DateTime.utc(2026, 5, 9, 23, 59)), isFalse);
      expect(loan.isOverdueAt(DateTime.utc(2026, 5, 10)), isFalse);
      expect(loan.isOverdueAt(DateTime.utc(2026, 5, 11)), isTrue);
    });
  });

  group('StorageLocation', () {
    test('fullPath resolves parents without nullable firstWhere casts', () {
      final room = StorageLocation(id: 'room', name: 'Room');
      final shelf = StorageLocation(
        id: 'shelf',
        name: 'Shelf',
        parentId: 'room',
      );
      final box = StorageLocation(id: 'box', name: 'Box 3', parentId: 'shelf');

      expect(box.fullPath([box, shelf, room]), 'Room › Shelf › Box 3');
    });

    test('fullPath stops when parent chain becomes circular', () {
      final shelf = StorageLocation(
        id: 'shelf',
        name: 'Shelf',
        parentId: 'box',
      );
      final box = StorageLocation(id: 'box', name: 'Box 3', parentId: 'shelf');

      expect(box.fullPath([box, shelf]), 'Shelf › Box 3');
    });
  });

  group('LocationRepository', () {
    late LocalDatabase db;
    late LocationRepository repo;

    setUp(() {
      db = LocalDatabase(NativeDatabase.memory());
      repo = LocationRepository(db);
    });

    tearDown(() => db.close());

    test('create assigns increasing sortOrder values', () async {
      final first = await repo.create(name: 'Room');
      final second = await repo.create(name: 'Shelf');

      expect(first.sortOrder, 1);
      expect(second.sortOrder, 2);
    });
  });
}