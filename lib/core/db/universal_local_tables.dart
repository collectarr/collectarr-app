import 'package:drift/drift.dart';

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
  TextColumn get catalogRefJson => text().nullable()();
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

  /// The complete catalog target is transported opaquely by this universal
  /// table. Kind integrations decide whether it is a work, release, or
  /// another entity.
  TextColumn get catalogRefJson => text()();
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
  TextColumn get itemId => text()();

  /// Complete structural target reference. The owning kind interprets its
  /// entity type; this universal table only stores and indexes the reference.
  TextColumn get catalogRefJson => text()();
  TextColumn get anchorJson => text().nullable()();
  IntColumn get targetPriceCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackingEntriesCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get kind => text().withDefault(const Constant('unknown'))();
  TextColumn get ownedItemId => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get rating => integer().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get progressCurrent => integer().nullable()();
  IntColumn get progressTotal => integer().nullable()();
  IntColumn get timesCompleted => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  TextColumn get episodeRatings => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackingUnitsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get kind => text().withDefault(const Constant('unknown'))();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get ownedItemId => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get unitType => text()();
  DateTimeColumn get completedAt => dateTime()();
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
  TextColumn get targetRefJson => text()();
  TextColumn get fieldPath => text()();
  TextColumn get originalValue => text().nullable()();
  TextColumn get overrideValue => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoansCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownedItemId => text()();

  /// Serialized kind component of the structural OwnedItemRef.
  TextColumn get ownedKind => text().nullable()();
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

class ProviderAccountsCache extends Table {
  TextColumn get id => text()();
  TextColumn get provider => text()();
  TextColumn get displayName => text()();
  TextColumn get authType => text()();
  TextColumn get remoteAccountId => text().nullable()();
  TextColumn get remoteHandle => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get connectedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get enabledCapabilitiesJson => text()();
  TextColumn get syncPolicyJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProviderItemLinksCache extends Table {
  TextColumn get accountId => text()();
  TextColumn get provider => text()();
  TextColumn get remoteItemId => text()();
  TextColumn get remoteEntryId => text().nullable()();
  TextColumn get localEntityRefJson => text()();
  TextColumn get baseSnapshotJson => text().nullable()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();
  DateTimeColumn get lastPushedAt => dateTime().nullable()();
  TextColumn get remoteRevision => text().nullable()();
  TextColumn get metadataJson => text()();

  @override
  Set<Column> get primaryKey => {accountId, remoteItemId};
}
