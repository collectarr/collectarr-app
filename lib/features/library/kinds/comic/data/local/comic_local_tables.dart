import 'package:drift/drift.dart';

class ComicMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get seriesTitle => text().nullable()();
  TextColumn get issueNumber => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get imprint => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  DateTimeColumn get coverDate => dateTime().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get country => text().withDefault(const Constant('US'))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get ageRating => text().nullable()();
  TextColumn get crossover => text().nullable()();
  TextColumn get synopsis => text().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get searchAliasesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get writersJson => text().withDefault(const Constant('[]'))();
  TextColumn get artistsJson => text().withDefault(const Constant('[]'))();
  TextColumn get inkersJson => text().withDefault(const Constant('[]'))();
  TextColumn get coloristsJson => text().withDefault(const Constant('[]'))();
  TextColumn get letterersJson => text().withDefault(const Constant('[]'))();
  TextColumn get editorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get coverArtistsJson => text().withDefault(const Constant('[]'))();
  TextColumn get creatorCreditsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get charactersJson => text().withDefault(const Constant('[]'))();
  TextColumn get characterDetailsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get creatorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get storyArcsJson => text().withDefault(const Constant('[]'))();
  TextColumn get keyEventsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isKeyComic => boolean().withDefault(const Constant(false))();
  TextColumn get keyReason => text().nullable()();
  TextColumn get variant => text().nullable()();
  TextColumn get variantDescription => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get seriesJson => text().nullable()();
  TextColumn get publishingJson => text().nullable()();
  TextColumn get editionTitle => text().nullable()();
  TextColumn get titleExtension => text().nullable()();
  TextColumn get physicalFormat => text().nullable()();
  TextColumn get physicalFormatLabel => text().nullable()();
  TextColumn get linksJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ComicReleaseRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get publisher => text().nullable()();
  TextColumn get imprint => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get upc => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get variantsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}
