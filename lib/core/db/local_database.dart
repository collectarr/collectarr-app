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
  TextColumn get thumbnailImageUrl => text().nullable()();
  TextColumn get editionTitle => text().nullable()();
  TextColumn get physicalFormat => text().nullable()();
  TextColumn get physicalFormatLabel => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get variant => text().nullable()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get seriesTitle => text().nullable()();
  TextColumn get volumeName => text().nullable()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get volumeStartYear => integer().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  IntColumn get trackCount => integer().nullable()();
  TextColumn get tracksJson => text().nullable()();
  TextColumn get creatorsJson => text().nullable()();
  TextColumn get charactersJson => text().nullable()();
  TextColumn get storyArcsJson => text().nullable()();
  TextColumn get genresJson => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get coverPriceCents => integer().nullable()();
  TextColumn get catalogCurrency => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get ageRating => text().nullable()();
  TextColumn get imprint => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get seriesGroup => text().nullable()();
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
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get soldAt => dateTime().nullable()();
  IntColumn get sellPriceCents => integer().nullable()();
  TextColumn get soldTo => text().nullable()();
  TextColumn get locationId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomFieldDefinitionsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fieldType => text()(); // text, number, date, bool, select
  TextColumn get mediaKind => text().nullable()(); // null = all media types
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get options => text().nullable()(); // JSON array for select type
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomFieldValuesCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownedItemId => text()();
  TextColumn get fieldDefinitionId => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemImagesCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownedItemId => text()();
  TextColumn get imageType =>
      text().withDefault(const Constant('front_cover'))(); // front_cover, back_cover, auxiliary
  TextColumn get imageData => text()(); // base64-encoded image data
  TextColumn get caption => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

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
  Set<Column> get primaryKey => {entityType, entityId};
}

class LoansCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownedItemId => text()();
  TextColumn get borrowerName => text()();
  DateTimeColumn get lentDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get returnedDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocationsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SmartListsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mediaKind => text().nullable()();
  TextColumn get criteriaJson => text()(); // serialized filter/sort/query
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserFoldersCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserFolderItemsCache extends Table {
  TextColumn get folderId => text()();
  TextColumn get ownedItemId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {folderId, ownedItemId};
}

class ReadingQueueCache extends Table {
  TextColumn get ownedItemId => text()();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

@DriftDatabase(tables: [
  CatalogCache,
  OwnedItemsCache,
  WishlistItemsCache,
  SyncQueue,
  CustomFieldDefinitionsCache,
  CustomFieldValuesCache,
  ItemImagesCache,
  LoansCache,
  LocationsCache,
  SmartListsCache,
  UserFoldersCache,
  UserFolderItemsCache,
  ReadingQueueCache,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        // Destructive: drop everything and recreate from scratch.
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      },
    );
  }
}
