import 'package:drift/drift.dart';

class BookMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get firstPublicationDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  DateTimeColumn get originalPublicationDate => dateTime().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get searchAliasesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get contributorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get seriesJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class BookReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get workId => text().nullable()();
  TextColumn get titleValue => text().nullable()();
  TextColumn get displayTitle => text().nullable()();
  TextColumn get ageRating => text().nullable()();
  IntColumn get audioLengthMinutes => integer().nullable()();
  TextColumn get binding => text().nullable()();
  TextColumn get contributorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get distributor => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get editionStatement => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get imprint => text().nullable()();
  TextColumn get upc => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get region => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get physicalFormat => text().nullable()();
  TextColumn get physicalFormatLabel => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get thumbnailImageUrl => text().nullable()();
  TextColumn get dimensions => text().nullable()();
  BoolColumn get firstEdition => boolean().nullable()();
  TextColumn get variantsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

class BookOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get signedBy => text().nullable()();
  BoolColumn get dustJacketPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dustJacketCondition => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

class BookTrackingUnitRows extends Table {
  TextColumn get id => text()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get chapterNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
