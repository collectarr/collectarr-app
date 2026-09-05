import 'package:drift/drift.dart';

class MangaMediaRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get firstPublicationDate => dateTime().nullable()();
  TextColumn get originalLanguage => text().nullable()();
  DateTimeColumn get originalPublicationDate => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get chaptersJson => text().withDefault(const Constant('[]'))();
  TextColumn get characterAppearancesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get identifiersJson => text().withDefault(const Constant('[]'))();
  TextColumn get seriesJson => text().withDefault(const Constant('[]'))();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MangaOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get rawOrSlabbed => text().nullable()();
  TextColumn get gradingCompany => text().nullable()();
  TextColumn get graderNotes => text().nullable()();
  TextColumn get labelType => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  TextColumn get pageQuality => text().nullable()();
  TextColumn get certificationNumber => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  BoolColumn get obiStripPresent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get slipcoverPresent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get dustJacketPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dustJacketCondition => text().nullable()();
  TextColumn get boxSetOuterCondition => text().nullable()();
  BoolColumn get insertsPresent =>
      boolean().withDefault(const Constant(false))();
  TextColumn get printing => text().nullable()();
  TextColumn get localizedEdition => text().nullable()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

class MangaTrackingUnitRows extends Table {
  TextColumn get id => text()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get chapterNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
