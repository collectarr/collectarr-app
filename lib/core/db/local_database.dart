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
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get storageBox => text().nullable()();
  IntColumn get indexNumber => integer().nullable()();
  IntColumn get coverPriceCents => integer().nullable()();
  TextColumn get rawOrSlabbed => text().nullable()();
  TextColumn get gradingCompany => text().nullable()();
  TextColumn get graderNotes => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  BoolColumn get keyComic => boolean().withDefault(const Constant(false))();
  TextColumn get keyReason => text().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get readStatus => text().nullable()();
  TextColumn get tags => text().nullable()();
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(ownedItemsCache, ownedItemsCache.quantity);
          await m.addColumn(ownedItemsCache, ownedItemsCache.storageBox);
          await m.addColumn(ownedItemsCache, ownedItemsCache.indexNumber);
          await m.addColumn(ownedItemsCache, ownedItemsCache.coverPriceCents);
          await m.addColumn(ownedItemsCache, ownedItemsCache.rawOrSlabbed);
          await m.addColumn(ownedItemsCache, ownedItemsCache.gradingCompany);
          await m.addColumn(ownedItemsCache, ownedItemsCache.graderNotes);
          await m.addColumn(ownedItemsCache, ownedItemsCache.signedBy);
          await m.addColumn(ownedItemsCache, ownedItemsCache.keyComic);
          await m.addColumn(ownedItemsCache, ownedItemsCache.keyReason);
          await m.addColumn(ownedItemsCache, ownedItemsCache.rating);
          await m.addColumn(ownedItemsCache, ownedItemsCache.readStatus);
          await m.addColumn(ownedItemsCache, ownedItemsCache.tags);
        }
      },
    );
  }
}
