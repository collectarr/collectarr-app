import 'package:drift/drift.dart';

class LibraryCollections extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get name => text()();
  IntColumn get position => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

/// An entry belongs to exactly one collection in its own kind.
class LibraryCollectionMemberships extends Table {
  TextColumn get entryKind => text()();
  TextColumn get entryId => text()();
  TextColumn get collectionId => text().references(LibraryCollections, #id)();
  @override
  Set<Column> get primaryKey => {entryKind, entryId};
}
