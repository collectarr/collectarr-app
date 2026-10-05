import 'package:drift/drift.dart';

/// One independently editable local library record. Catalog and personal
/// fields share the same row and lifecycle; Core is an optional source only.
class LibraryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {kind, id};
}

/// Cached source-neutral Catalog Item payload and local storage provenance.
///
/// Catalog Items are keyed by their owning kind and concrete item ID. Kind
/// details remain inside the pinned kind payload rather than being split into
/// a generic Work/Release graph.
/// Offline cache for canonical Core items.
///
/// `payloadJson` contains the Core Catalog Item envelope and one kind-owned
/// `kind_data` object; catalog values are never split into shared title,
/// cover, or date columns.
class CatalogItemsCache extends Table {
  TextColumn get catalogKind => text()();
  TextColumn get itemId => text()();
  TextColumn get origin => text().withDefault(const Constant('core'))();
  TextColumn get payloadJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {catalogKind, itemId};
}

/// Drift tables shared by multiple library kinds or by app-wide services.
///
/// Kind-specific table semantics live beside their owning kind. This file is
/// intentionally limited to truly universal cache and coordination tables.
class CustomFieldDefinitionsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fieldType => text()();
  TextColumn get mediaKind => text().nullable()();
  TextColumn get editScope => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get options => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomFieldValuesCache extends Table {
  TextColumn get id => text()();
  TextColumn get targetId => text()();
  TextColumn get targetScope => text()();
  TextColumn get fieldDefinitionId => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemImagesCache extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
  TextColumn get imageType =>
      text().withDefault(const Constant('front_cover'))();
  BlobColumn get imageData => blob()();
  TextColumn get caption => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserExternalLinksCache extends Table {
  TextColumn get id => text()();

  /// Personal links belong to one local entry, not the shared Core catalog.
  TextColumn get libraryEntryRefKey =>
      text().withDefault(const Constant(''))();
  TextColumn get label => text()();
  TextColumn get url => text()();
  TextColumn get kind => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WishlistItemsCache extends Table {
  TextColumn get id => text()();

  /// Concrete Catalog Item reference. This table stores and indexes the
  /// reference without copying catalog data into wishlist state.
  TextColumn get catalogRefJson => text()();
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

class UserMetadataOverridesCache extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
  TextColumn get fieldKey => text()();
  TextColumn get originalValue => text().nullable()();
  TextColumn get overrideValue => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoansCache extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
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
  TextColumn get criteriaJson => text()();
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
  TextColumn get libraryEntryRefKey => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {folderId, libraryEntryRefKey};
}

class ReadingQueueCache extends Table {
  TextColumn get libraryEntryRefKey => text()();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {libraryEntryRefKey};
}

class PickListValuesCache extends Table {
  TextColumn get id => text()();
  TextColumn get listName => text()();
  TextColumn get mediaKind => text().nullable()();
  TextColumn get value => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SerialAuthorityCache extends Table {
  TextColumn get id => text()();
  TextColumn get mediaKind => text()();
  TextColumn get title => text()();
  TextColumn get normalizedTitle => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get normalizedSortTitle => text().nullable()();
  TextColumn get coreSeriesId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
