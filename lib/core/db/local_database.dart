import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';

part 'local_database.g.dart';

class CatalogCache extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get displayTitle => text().nullable()();
  TextColumn get localizedTitle => text().nullable()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get titleExtension => text().nullable()();
  TextColumn get searchAliasesJson => text().nullable()();
  TextColumn get sortKey => text().nullable()();
  TextColumn get itemNumber => text().nullable()();
  TextColumn get synopsis => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get thumbnailImageUrl => text().nullable()();
  TextColumn get coverImageData => text().nullable()();
  TextColumn get editionTitle => text().nullable()();
  TextColumn get physicalFormat => text().nullable()();
  TextColumn get physicalFormatLabel => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get coverDate => dateTime().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get variant => text().nullable()();
  TextColumn get crossover => text().nullable()();
  TextColumn get plotSummary => text().nullable()();
  TextColumn get plotDescription => text().nullable()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get seriesTitle => text().nullable()();
  TextColumn get volumeName => text().nullable()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get volumeStartYear => integer().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  IntColumn get trackCount => integer().nullable()();
  TextColumn get tracksJson => text().nullable()();
  TextColumn get discsJson => text().nullable()();
  TextColumn get editionsJson => text().nullable()();
  TextColumn get creatorsJson => text().nullable()();
  TextColumn get charactersJson => text().nullable()();
  TextColumn get characterDetailsJson => text().nullable()();
  TextColumn get storyArcsJson => text().nullable()();
  TextColumn get seriesTagsJson => text().nullable()();
  TextColumn get platformsJson => text().nullable()();
  TextColumn get genresJson => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get coverPriceCents => integer().nullable()();
  TextColumn get catalogCurrency => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get ageRating => text().nullable()();
  TextColumn get audienceRating => text().nullable()();
  TextColumn get imprint => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get seriesGroup => text().nullable()();
  TextColumn get trailerUrlsJson => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get nrDiscs => integer().nullable()();
  TextColumn get screenRatio => text().nullable()();
  TextColumn get audioTracksJson => text().nullable()();
  TextColumn get subtitlesJson => text().nullable()();
  TextColumn get layers => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OwnedItemsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isDigital => boolean().nullable()();
  TextColumn get anchorType => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get condition => text().nullable()();
  TextColumn get grade => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get pricePaidCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get personalNotes => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get indexNumber => integer().nullable()();
  IntColumn get coverPriceCents => integer().nullable()();
  TextColumn get rawOrSlabbed => text().nullable()();
  TextColumn get gradingCompany => text().nullable()();
  TextColumn get graderNotes => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  TextColumn get labelType => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  TextColumn get pageQuality => text().nullable()();
  TextColumn get certificationNumber => text().nullable()();
  BoolColumn get keyComic => boolean().withDefault(const Constant(false))();
  TextColumn get keyReason => text().nullable()();
  TextColumn get keyCategory => text().nullable()();
  TextColumn get keySeverity => text().nullable()();
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
  TextColumn get ownerUserId => text().nullable()();
  TextColumn get ownerLabel => text().nullable()();
  TextColumn get locationId => text().nullable()();
  TextColumn get features => text().nullable()();
  TextColumn get hdrFormatsJson => text().nullable()();
  TextColumn get purchaseStore => text().nullable()();
  TextColumn get boxSetId => text().nullable()();
  TextColumn get boxSetName => text().nullable()();
  TextColumn get storageDevice => text().nullable()();
  TextColumn get storageSlot => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get packaging => text().nullable()();
  TextColumn get distributor => text().nullable()();
  TextColumn get collectionStatus => text().nullable()();
  DateTimeColumn get lastBagBoardDate => dateTime().nullable()();
  IntColumn get marketValueCents => integer().nullable()();
  TextColumn get gameCompleteness => text().nullable()();
  BoolColumn get gameHasBox => boolean().nullable()();
  BoolColumn get gameHasManual => boolean().nullable()();
  TextColumn get gamePriceChartingId => text().nullable()();
  TextColumn get gameCoreRegion => text().nullable()();
  BoolColumn get gameValueIsLocked => boolean().nullable()();

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
  TextColumn get imageType => text().withDefault(
      const Constant('front_cover'))(); // front_cover, back_cover, auxiliary
  BlobColumn get imageData => blob()(); // raw image bytes
  TextColumn get caption => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WishlistItemsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get anchorType => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
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
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get ownedItemId => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get unitType => text()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get chapterNumber => integer().nullable()();
  TextColumn get issueNumber => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WatchSessionsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get trackingEntryId => text().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get seenWhere => text().nullable()();
  DateTimeColumn get watchedAt => dateTime()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
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
  TextColumn get itemId => text()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get fieldPath => text()();
  TextColumn get originalValue => text().nullable()();
  TextColumn get overrideValue => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomEpisodesCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text()();
  TextColumn get overview => text().nullable()();
  TextColumn get airDate => text().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
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

class PickListValuesCache extends Table {
  TextColumn get id => text()();
  TextColumn get listName => text()(); // e.g. 'condition', 'grade', 'tags'
  TextColumn get mediaKind => text().nullable()();
  TextColumn get value => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SeriesRegistryCache extends Table {
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

@DriftDatabase(tables: [
  CatalogCache,
  OwnedItemsCache,
  WishlistItemsCache,
  TrackingEntriesCache,
  TrackingUnitsCache,
  WatchSessionsCache,
  SyncQueue,
  UserMetadataOverridesCache,
  CustomEpisodesCache,
  CustomFieldDefinitionsCache,
  CustomFieldValuesCache,
  ItemImagesCache,
  LoansCache,
  LocationsCache,
  SmartListsCache,
  UserFoldersCache,
  UserFolderItemsCache,
  ReadingQueueCache,
  PickListValuesCache,
  SeriesRegistryCache,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      // All tables in this database are local caches that are rebuilt from
      // the server on next sync.  A destructive migration is intentional:
      // it avoids carrying forward every historical ALTER TABLE step while
      // remaining safe because no user-authored data lives here.
      onUpgrade: (m, from, to) async {
        for (final table in allTables) {
          await customStatement(
            'DROP TABLE IF EXISTS ${table.actualTableName}',
          );
        }
        await m.createAll();
      },
    );
  }
}
