import 'package:drift/drift.dart';

class MusicReleaseRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get catalogNumber => text().nullable()();
  TextColumn get barcode => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  DateTimeColumn get recordingDate => dateTime().nullable()();
  TextColumn get releaseStatus => text().nullable()();
  TextColumn get releaseType => text().nullable()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get studio => text().nullable()();
  TextColumn get countryCode => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get contributionsJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isLive => boolean().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MusicMediaRows extends Table {
  TextColumn get releaseId => text()();
  TextColumn get id => text()();
  IntColumn get mediaNumber => integer()();
  TextColumn get mediaCondition => text().nullable()();
  TextColumn get mediaType => text().nullable()();
  TextColumn get packaging => text().nullable()();
  IntColumn get rpm => integer().nullable()();
  TextColumn get soundType => text().nullable()();
  TextColumn get spars => text().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get trackCount => integer().nullable()();
  TextColumn get vinylColor => text().nullable()();
  TextColumn get vinylWeight => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {releaseId, id};
}

class MusicTrackRows extends Table {
  TextColumn get mediaId => text()();
  TextColumn get id => text()();
  TextColumn get position => text()();
  TextColumn get title => text()();
  TextColumn get composition => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get instrument => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get rawPayloadJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {mediaId, id};
}

class MusicOwnedDetailsRows extends Table {
  TextColumn get ownedItemId => text()();
  TextColumn get storageDevice => text().nullable()();
  TextColumn get storageSlot => text().nullable()();
  TextColumn get signedBy => text().nullable()();
  DateTimeColumn get lastCleanedDate => dateTime().nullable()();
  TextColumn get matrixRunoutsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}
