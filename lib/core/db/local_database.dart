import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';

part 'local_database.g.dart';

class CatalogCache extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get itemNumber => text().nullable()();
  TextColumn get synopsis => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OwnedItemsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get condition => text().nullable()();
  TextColumn get grade => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get pricePaidCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get personalNotes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WishlistItemsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  IntColumn get targetPriceCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get clientChangedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  CatalogCache,
  OwnedItemsCache,
  WishlistItemsCache,
  SyncQueue,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
    );
  }
}
