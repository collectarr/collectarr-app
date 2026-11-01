import 'package:drift/drift.dart';

/// Complete Comic-collection item state. Generic entry storage is retained only
/// as the kind-entry local persistence surface.

class ComicReadingRows extends Table {
  TextColumn get libraryEntryRefKey => text()();
  IntColumn get rating => integer().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {libraryEntryRefKey};
}

class ComicTrackingUnitRows extends Table {
  TextColumn get id => text()();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get libraryEntryRefKey => text()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get issueNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ComicTrackingRows extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryRefKey => text()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get rating => integer().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get progressCurrent => integer().nullable()();
  IntColumn get progressTotal => integer().nullable()();
  IntColumn get timesCompleted => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The image a user loaded for a Custom Label, by the label's name. Images
/// come only from the user's own files; the app ships none.
class ComicCustomLabelImageRows extends Table {
  /// The label's trimmed, lower-case name.
  TextColumn get labelKey => text()();
  TextColumn get label => text()();
  BlobColumn get imageData => blob()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {labelKey};
}
