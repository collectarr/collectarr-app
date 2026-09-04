import 'package:drift/drift.dart';

class MovieMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  TextColumn get ageRating => text().nullable()();
  TextColumn get audienceRating => text().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get characterAppearancesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get externalLinksJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get trailerUrlsJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MovieReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get workId => text().nullable()();
  TextColumn get coverImageKey => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get distributor => text().nullable()();
  TextColumn get externalLinksJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get format => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get mediaJson => text().withDefault(const Constant('[]'))();
  TextColumn get region => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get trailerUrlsJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

class MovieOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get features => text().nullable()();
  TextColumn get hdrFormatsJson => text().withDefault(const Constant('[]'))();
  TextColumn get boxSetId => text().nullable()();
  TextColumn get boxSetName => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get packaging => text().nullable()();
  TextColumn get distributor => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}
