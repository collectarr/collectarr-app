import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:drift/drift.dart';

class TrackingUnitsCacheRepository {
  TrackingUnitsCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<TrackingUnit>> listActive() async {
    final rows = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.deletedAt.isNull()))
        .get();
    final coordinates = await _loadCoordinates();
    return _toModels(rows, coordinates);
  }

  Future<List<TrackingUnit>> findActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids = itemIds
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) {
      return const <TrackingUnit>[];
    }
    final rows = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.deletedAt.isNull() & tbl.itemId.isIn(ids)))
        .get();
    final coordinates = await _loadCoordinates(
      rows.map((row) => row.id),
    );
    return _toModels(rows, coordinates);
  }

  Future<TrackingUnit?> findById(String id) async {
    final row = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final coordinates = await _loadCoordinates([row.id]);
    return _toModel(row, coordinates[row.id]);
  }

  Future<void> upsert(TrackingUnit unit) async {
    await _db.transaction(() async {
      await _db.into(_db.trackingUnitsCache).insertOnConflictUpdate(
            _toBaseCompanion(unit),
          );
      await _replaceCoordinates(unit);
    });
  }

  Future<void> upsertAll(Iterable<TrackingUnit> units) async {
    final values = units.toList(growable: false);
    if (values.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.trackingUnitsCache,
          values.map(_toBaseCompanion).toList(growable: false),
        );
      });
      for (final unit in values) {
        await _replaceCoordinates(unit);
      }
    });
  }

  Future<void> markDeleted(TrackingUnit unit, DateTime deletedAt) async {
    await (_db.update(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.equals(unit.id)))
        .write(
      TrackingUnitsCacheCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  Future<void> markDeletedByIds(
    Iterable<String> ids,
    DateTime deletedAt,
  ) async {
    final normalizedIds = ids
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) {
      return;
    }
    await (_db.update(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.isIn(normalizedIds) & tbl.deletedAt.isNull()))
        .write(
      TrackingUnitsCacheCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  TrackingUnitsCacheCompanion _toBaseCompanion(TrackingUnit unit) {
    return TrackingUnitsCacheCompanion(
      id: Value(unit.id),
      itemId: Value(unit.itemId),
      kind: Value(unit.targetRef.kind),
      trackingEntryId: Value(unit.trackingEntryId),
      ownedItemId: Value(unit.ownedItemId),
      editionId: Value(unit.editionId),
      variantId: Value(unit.variantId),
      bundleReleaseId: Value(unit.bundleReleaseId),
      unitType: Value(unit.unitType.storageValue),
      completedAt: Value(unit.completedAt),
      updatedAt: Value(unit.updatedAt),
      deletedAt: Value(unit.deletedAt),
    );
  }

  Future<void> _replaceCoordinates(TrackingUnit unit) async {
    final id = unit.id;
    await (_db.delete(_db.tvTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();
    await (_db.delete(_db.animeTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();
    await (_db.delete(_db.bookTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();
    await (_db.delete(_db.mangaTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();
    await (_db.delete(_db.comicTrackingUnitRows)
          ..where((row) => row.id.equals(id)))
        .go();

    switch (unit.targetRef.kind) {
      case 'tv':
        if (unit case final VideoTrackingUnit video) {
          await _db.into(_db.tvTrackingUnitRows).insertOnConflictUpdate(
                TvTrackingUnitRowsCompanion.insert(
                  id: id,
                  seasonNumber: Value(video.seasonNumber),
                  episodeNumber: Value(video.episodeNumber),
                ),
              );
        }
      case 'anime':
        if (unit case final VideoTrackingUnit video) {
          await _db.into(_db.animeTrackingUnitRows).insertOnConflictUpdate(
                AnimeTrackingUnitRowsCompanion.insert(
                  id: id,
                  seasonNumber: Value(video.seasonNumber),
                  episodeNumber: Value(video.episodeNumber),
                ),
              );
        }
      case 'book':
        if (unit case final ReadingTrackingUnit reading) {
          await _db.into(_db.bookTrackingUnitRows).insertOnConflictUpdate(
                BookTrackingUnitRowsCompanion.insert(
                  id: id,
                  volumeNumber: Value(reading.volumeNumber),
                  chapterNumber: Value(reading.chapterNumber),
                ),
              );
        }
      case 'manga':
        if (unit case final ReadingTrackingUnit reading) {
          await _db.into(_db.mangaTrackingUnitRows).insertOnConflictUpdate(
                MangaTrackingUnitRowsCompanion.insert(
                  id: id,
                  volumeNumber: Value(reading.volumeNumber),
                  chapterNumber: Value(reading.chapterNumber),
                ),
              );
        }
      case 'comic':
        if (unit case final ComicTrackingUnit comic) {
          await _db.into(_db.comicTrackingUnitRows).insertOnConflictUpdate(
                ComicTrackingUnitRowsCompanion.insert(
                  id: id,
                  issueNumber: Value(comic.issueNumber),
                ),
              );
        }
      default:
        break;
    }
  }

  Future<Map<String, _TrackingUnitCoordinates>> _loadCoordinates([
    Iterable<String>? ids,
  ]) async {
    final normalizedIds = ids?.toSet().toList(growable: false);
    final coordinates = <String, _TrackingUnitCoordinates>{};

    final tvRows = normalizedIds == null
        ? await _db.select(_db.tvTrackingUnitRows).get()
        : await (_db.select(_db.tvTrackingUnitRows)
              ..where((row) => row.id.isIn(normalizedIds)))
            .get();
    for (final row in tvRows) {
      coordinates[row.id] = _TrackingUnitCoordinates(
        seasonNumber: row.seasonNumber,
        episodeNumber: row.episodeNumber,
      );
    }

    final animeRows = normalizedIds == null
        ? await _db.select(_db.animeTrackingUnitRows).get()
        : await (_db.select(_db.animeTrackingUnitRows)
              ..where((row) => row.id.isIn(normalizedIds)))
            .get();
    for (final row in animeRows) {
      coordinates[row.id] = _TrackingUnitCoordinates(
        seasonNumber: row.seasonNumber,
        episodeNumber: row.episodeNumber,
      );
    }

    final bookRows = normalizedIds == null
        ? await _db.select(_db.bookTrackingUnitRows).get()
        : await (_db.select(_db.bookTrackingUnitRows)
              ..where((row) => row.id.isIn(normalizedIds)))
            .get();
    for (final row in bookRows) {
      coordinates[row.id] = _TrackingUnitCoordinates(
        volumeNumber: row.volumeNumber,
        chapterNumber: row.chapterNumber,
      );
    }

    final mangaRows = normalizedIds == null
        ? await _db.select(_db.mangaTrackingUnitRows).get()
        : await (_db.select(_db.mangaTrackingUnitRows)
              ..where((row) => row.id.isIn(normalizedIds)))
            .get();
    for (final row in mangaRows) {
      coordinates[row.id] = _TrackingUnitCoordinates(
        volumeNumber: row.volumeNumber,
        chapterNumber: row.chapterNumber,
      );
    }

    final comicRows = normalizedIds == null
        ? await _db.select(_db.comicTrackingUnitRows).get()
        : await (_db.select(_db.comicTrackingUnitRows)
              ..where((row) => row.id.isIn(normalizedIds)))
            .get();
    for (final row in comicRows) {
      coordinates[row.id] = _TrackingUnitCoordinates(
        issueNumber: row.issueNumber,
      );
    }
    return coordinates;
  }

  List<TrackingUnit> _toModels(
    List<TrackingUnitsCacheData> rows,
    Map<String, _TrackingUnitCoordinates> coordinates,
  ) {
    final models = [
      for (final row in rows) _toModel(row, coordinates[row.id]),
    ];
    models.sort(_compareForDisplay);
    return models;
  }

  TrackingUnit _toModel(
    TrackingUnitsCacheData row,
    _TrackingUnitCoordinates? coordinates,
  ) {
    final unitType =
        trackingUnitTypeFromValue(row.unitType) ?? TrackingUnitType.episode;
    final targetRef = CatalogEntityRef(
      kind: row.kind,
      entityType: _entityTypeForUnit(unitType),
      id: row.itemId,
    );
    final common = _CommonTrackingUnitFields(
      id: row.id,
      targetRef: targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      unitType: unitType,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );

    return switch ((row.kind, coordinates)) {
      ('tv' || 'anime', final coordinates?) => VideoTrackingUnit(
          id: common.id,
          targetRef: common.targetRef,
          trackingEntryId: common.trackingEntryId,
          ownedItemId: common.ownedItemId,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
          unitType: common.unitType,
          seasonNumber: coordinates.seasonNumber,
          episodeNumber: coordinates.episodeNumber,
          completedAt: common.completedAt,
          updatedAt: common.updatedAt,
          deletedAt: common.deletedAt,
        ),
      ('book' || 'manga', final coordinates?) => ReadingTrackingUnit(
          id: common.id,
          targetRef: common.targetRef,
          trackingEntryId: common.trackingEntryId,
          ownedItemId: common.ownedItemId,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
          unitType: common.unitType,
          volumeNumber: coordinates.volumeNumber,
          chapterNumber: coordinates.chapterNumber,
          completedAt: common.completedAt,
          updatedAt: common.updatedAt,
          deletedAt: common.deletedAt,
        ),
      ('comic', final coordinates?) => ComicTrackingUnit(
          id: common.id,
          targetRef: common.targetRef,
          trackingEntryId: common.trackingEntryId,
          ownedItemId: common.ownedItemId,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
          unitType: common.unitType,
          issueNumber: coordinates.issueNumber,
          completedAt: common.completedAt,
          updatedAt: common.updatedAt,
          deletedAt: common.deletedAt,
        ),
      _ => TrackingUnit(
          id: common.id,
          targetRef: common.targetRef,
          trackingEntryId: common.trackingEntryId,
          ownedItemId: common.ownedItemId,
          editionId: common.editionId,
          variantId: common.variantId,
          bundleReleaseId: common.bundleReleaseId,
          unitType: common.unitType,
          completedAt: common.completedAt,
          updatedAt: common.updatedAt,
          deletedAt: common.deletedAt,
        ),
    };
  }

  static CatalogEntityType _entityTypeForUnit(TrackingUnitType unitType) {
    return switch (unitType) {
      TrackingUnitType.episode => CatalogEntityType.episode,
      TrackingUnitType.issue => CatalogEntityType.issue,
      _ => CatalogEntityType.work,
    };
  }

  static int _compareForDisplay(TrackingUnit a, TrackingUnit b) {
    final itemCompare = a.itemId.compareTo(b.itemId);
    if (itemCompare != 0) return itemCompare;
    final typeCompare = a.unitType.storageValue.compareTo(
      b.unitType.storageValue,
    );
    if (typeCompare != 0) return typeCompare;
    final coordinatesCompare = _compareCoordinates(a, b);
    if (coordinatesCompare != 0) return coordinatesCompare;
    return b.updatedAt.compareTo(a.updatedAt);
  }

  static int _compareCoordinates(TrackingUnit a, TrackingUnit b) {
    if (a is VideoTrackingUnit && b is VideoTrackingUnit) {
      final season = _compareNullableInt(a.seasonNumber, b.seasonNumber);
      if (season != 0) return season;
      return _compareNullableInt(a.episodeNumber, b.episodeNumber);
    }
    if (a is ReadingTrackingUnit && b is ReadingTrackingUnit) {
      final volume = _compareNullableInt(a.volumeNumber, b.volumeNumber);
      if (volume != 0) return volume;
      return _compareNullableInt(a.chapterNumber, b.chapterNumber);
    }
    if (a is ComicTrackingUnit && b is ComicTrackingUnit) {
      return (a.issueNumber ?? '').compareTo(b.issueNumber ?? '');
    }
    return 0;
  }

  static int _compareNullableInt(int? a, int? b) {
    return (a ?? 0).compareTo(b ?? 0);
  }
}

class _TrackingUnitCoordinates {
  const _TrackingUnitCoordinates({
    this.seasonNumber,
    this.episodeNumber,
    this.volumeNumber,
    this.chapterNumber,
    this.issueNumber,
  });

  final int? seasonNumber;
  final int? episodeNumber;
  final int? volumeNumber;
  final int? chapterNumber;
  final String? issueNumber;
}

class _CommonTrackingUnitFields {
  const _CommonTrackingUnitFields({
    required this.id,
    required this.targetRef,
    required this.trackingEntryId,
    required this.ownedItemId,
    required this.editionId,
    required this.variantId,
    required this.bundleReleaseId,
    required this.unitType,
    required this.completedAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final TrackingUnitType unitType;
  final DateTime completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
