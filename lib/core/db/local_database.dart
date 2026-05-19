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
  DateTimeColumn get soldAt => dateTime().nullable()();
  IntColumn get sellPriceCents => integer().nullable()();
  TextColumn get soldTo => text().nullable()();

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

@DriftDatabase(tables: [
  CatalogCache,
  OwnedItemsCache,
  WishlistItemsCache,
  SyncQueue,
  CustomFieldDefinitionsCache,
  CustomFieldValuesCache,
  ItemImagesCache,
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
          await m.createTable(customFieldDefinitionsCache);
          await m.createTable(customFieldValuesCache);
          await m.createTable(itemImagesCache);
          await _addColumnsIfMissing('owned_items_cache', {
            'sold_at': 'INTEGER',
            'sell_price_cents': 'INTEGER',
            'sold_to': 'TEXT',
          });
        }
      },
      beforeOpen: (_) async {
        await _ensureCatalogCacheColumns();
      },
    );
  }

  Future<void> _addColumnsIfMissing(
    String table,
    Map<String, String> columns,
  ) async {
    final existing =
        await customSelect('PRAGMA table_info($table)').get();
    final existingNames = {
      for (final row in existing) row.read<String>('name'),
    };
    for (final entry in columns.entries) {
      if (!existingNames.contains(entry.key)) {
        await customStatement(
          'ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
  }

  Future<void> _ensureCatalogCacheColumns() async {
    final columns =
        await customSelect('PRAGMA table_info(catalog_cache)').get();
    final columnNames = {
      for (final row in columns) row.read<String>('name'),
    };
    const optionalColumns = {
      'thumbnail_image_url': 'TEXT',
      'edition_title': 'TEXT',
      'physical_format': 'TEXT',
      'physical_format_label': 'TEXT',
    };
    for (final entry in optionalColumns.entries) {
      if (!columnNames.contains(entry.key)) {
        await customStatement(
          'ALTER TABLE catalog_cache ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
  }
}
