import 'package:drift/drift.dart';

class GameMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get platformsJson => text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get companyRolesJson => text().withDefault(const Constant('[]'))();
  TextColumn get ageRatingsJson => text().withDefault(const Constant('[]'))();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get searchAliasesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class GameReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get workId => text().nullable()();
  TextColumn get platform => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get regionCode => text().nullable()();
  TextColumn get format => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

class GameOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get completeness => text().nullable()();
  BoolColumn get hasBox => boolean().nullable()();
  BoolColumn get hasManual => boolean().nullable()();
  TextColumn get priceChartingId => text().nullable()();
  TextColumn get coreRegion => text().nullable()();
  BoolColumn get valueIsLocked => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}
