import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class SeriesRegistryEntry {
  const SeriesRegistryEntry({
    required this.id,
    required this.mediaKind,
    required this.title,
    required this.sortTitle,
    required this.coreSeriesId,
    required this.itemCount,
  });

  final String id;
  final String mediaKind;
  final String title;
  final String? sortTitle;
  final String? coreSeriesId;
  final int itemCount;
}

class SeriesRegistryRepository {
  SeriesRegistryRepository(this._db);

  final LocalDatabase _db;

  Future<List<SeriesRegistryEntry>> searchEntries({
    required String mediaKind,
    String? query,
    String? selectedTitle,
    String? selectedSeriesId,
  }) async {
    final normalizedKind = mediaKind.trim().toLowerCase();
    final normalizedQuery = _normalize(query);
    final rows = await (_db.select(_db.seriesRegistryCache)
          ..where((table) => table.mediaKind.equals(normalizedKind))
          ..orderBy([
            (table) => OrderingTerm.asc(table.normalizedSortTitle),
            (table) => OrderingTerm.asc(table.normalizedTitle),
          ]))
        .get();
    final counts = await _countsBySeriesKey(normalizedKind);
    final entries = <SeriesRegistryEntry>[
      for (final row in rows)
        if (normalizedQuery == null ||
            row.normalizedTitle.contains(normalizedQuery) ||
            (row.normalizedSortTitle?.contains(normalizedQuery) ?? false))
          _entryFromRow(
            row,
            itemCount: counts[_seriesKey(
                  coreSeriesId: row.coreSeriesId,
                  normalizedTitle: row.normalizedTitle,
                )] ??
                0,
          ),
    ];

    final selectedNormalizedTitle = _normalize(selectedTitle);
    final hasSelected = entries.any(
      (entry) =>
          (selectedSeriesId != null && entry.coreSeriesId == selectedSeriesId) ||
          _normalize(entry.title) == selectedNormalizedTitle,
    );
    if (!hasSelected && selectedNormalizedTitle != null) {
      entries.insert(
        0,
        SeriesRegistryEntry(
          id: 'selected:$normalizedKind:$selectedNormalizedTitle',
          mediaKind: normalizedKind,
          title: selectedTitle!.trim(),
          sortTitle: null,
          coreSeriesId: selectedSeriesId,
          itemCount: counts[_seriesKey(
                coreSeriesId: selectedSeriesId,
                normalizedTitle: selectedNormalizedTitle,
              )] ??
              0,
        ),
      );
    }

    return entries;
  }

  Future<SeriesRegistryEntry?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final row = await (_db.select(_db.seriesRegistryCache)
          ..where((table) => table.id.equals(normalized))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final counts = await _countsBySeriesKey(row.mediaKind);
    return _entryFromRow(
      row,
      itemCount: counts[_seriesKey(
            coreSeriesId: row.coreSeriesId,
            normalizedTitle: row.normalizedTitle,
          )] ??
          0,
    );
  }

  Future<SeriesRegistryEntry> upsertManualEntry({
    required String mediaKind,
    required String title,
    String? sortTitle,
  }) async {
    final normalizedKind = mediaKind.trim().toLowerCase();
    final normalizedTitle = _normalize(title);
    if (normalizedTitle == null) {
      throw ArgumentError.value(title, 'title', 'Series title cannot be empty');
    }
    final normalizedSortTitle = _normalize(sortTitle);
    final now = DateTime.now().toUtc();
    final existing = await _findMatchingRow(
      mediaKind: normalizedKind,
      coreSeriesId: null,
      normalizedTitle: normalizedTitle,
    );
    if (existing == null) {
      final id = const Uuid().v4();
      await _db.into(_db.seriesRegistryCache).insert(
            SeriesRegistryCacheCompanion.insert(
              id: id,
              mediaKind: normalizedKind,
              title: title.trim(),
              normalizedTitle: normalizedTitle,
              sortTitle: Value(_emptyToNull(sortTitle)),
              normalizedSortTitle: Value(normalizedSortTitle),
              coreSeriesId: const Value.absent(),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return SeriesRegistryEntry(
        id: id,
        mediaKind: normalizedKind,
        title: title.trim(),
        sortTitle: _emptyToNull(sortTitle),
        coreSeriesId: null,
        itemCount: 0,
      );
    }
    await (_db.update(_db.seriesRegistryCache)
          ..where((table) => table.id.equals(existing.id)))
        .write(
      SeriesRegistryCacheCompanion(
        title: Value(title.trim()),
        normalizedTitle: Value(normalizedTitle),
        sortTitle: Value(_emptyToNull(sortTitle)),
        normalizedSortTitle: Value(normalizedSortTitle),
        updatedAt: Value(now),
      ),
    );
    final updated = await findById(existing.id);
    return updated ??
        SeriesRegistryEntry(
          id: existing.id,
          mediaKind: normalizedKind,
          title: title.trim(),
          sortTitle: _emptyToNull(sortTitle),
          coreSeriesId: existing.coreSeriesId,
          itemCount: 0,
        );
  }

  Future<void> captureCatalogItems(List<CatalogItem> items) async {
    await _db.transaction(() async {
      await captureCatalogItemsWithoutTransaction(items);
    });
  }

  Future<void> captureCatalogItemsWithoutTransaction(List<CatalogItem> items) async {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    final candidates = <String, _SeriesCandidate>{};
    for (final item in items) {
      final type = collectarrLibraryTypes.byKind(item.kind);
      final title = _emptyToNull(
        item.series?.seriesTitle ??
            (type?.usesTitleAsSeriesFallback ?? false ? item.title : null),
      );
      final normalizedTitle = _normalize(title);
      if (normalizedTitle == null) {
        continue;
      }
      final mediaKind = item.kind.trim().toLowerCase();
      final coreSeriesId = _emptyToNull(item.series?.seriesId);
      final key = _seriesKey(
        coreSeriesId: coreSeriesId,
        normalizedTitle: normalizedTitle,
      );
      candidates[key] = _SeriesCandidate(
        mediaKind: mediaKind,
        title: title!,
        normalizedTitle: normalizedTitle,
        sortTitle: title,
        normalizedSortTitle: normalizedTitle,
        coreSeriesId: coreSeriesId,
      );
    }
    if (candidates.isEmpty) {
      return;
    }

    for (final candidate in candidates.values) {
      final existing = await _findMatchingRow(
        mediaKind: candidate.mediaKind,
        coreSeriesId: candidate.coreSeriesId,
        normalizedTitle: candidate.normalizedTitle,
      );
      if (existing == null) {
        await _db.into(_db.seriesRegistryCache).insert(
              SeriesRegistryCacheCompanion.insert(
                id: const Uuid().v4(),
                mediaKind: candidate.mediaKind,
                title: candidate.title,
                normalizedTitle: candidate.normalizedTitle,
                sortTitle: Value(candidate.sortTitle),
                normalizedSortTitle: Value(candidate.normalizedSortTitle),
                coreSeriesId: Value(candidate.coreSeriesId),
                createdAt: now,
                updatedAt: now,
              ),
            );
        continue;
      }
      await (_db.update(_db.seriesRegistryCache)
            ..where((table) => table.id.equals(existing.id)))
          .write(
        SeriesRegistryCacheCompanion(
          title: Value(candidate.title),
          normalizedTitle: Value(candidate.normalizedTitle),
          sortTitle: Value(candidate.sortTitle),
          normalizedSortTitle: Value(candidate.normalizedSortTitle),
          coreSeriesId: Value(candidate.coreSeriesId ?? existing.coreSeriesId),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> renameEntry({
    required String entryId,
    required String title,
    String? sortTitle,
    bool applyToCatalog = true,
  }) async {
    final row = await (_db.select(_db.seriesRegistryCache)
          ..where((table) => table.id.equals(entryId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return;
    }
    final normalizedTitle = _normalize(title);
    if (normalizedTitle == null) {
      return;
    }
    final normalizedSortTitle = _normalize(sortTitle);
    final now = DateTime.now().toUtc();
    await (_db.update(_db.seriesRegistryCache)
          ..where((table) => table.id.equals(entryId)))
        .write(
      SeriesRegistryCacheCompanion(
        title: Value(title.trim()),
        normalizedTitle: Value(normalizedTitle),
        sortTitle: Value(_emptyToNull(sortTitle)),
        normalizedSortTitle: Value(normalizedSortTitle),
        updatedAt: Value(now),
      ),
    );
    if (!applyToCatalog) {
      return;
    }
    final catalogRows = await (_db.select(_db.catalogCache)
          ..where((table) => table.kind.equals(row.mediaKind)))
        .get();
    for (final catalogRow in catalogRows) {
      if (!_catalogMatchesSeries(catalogRow, row)) {
        continue;
      }
      await (_db.update(_db.catalogCache)
            ..where((table) => table.id.equals(catalogRow.id)))
          .write(
        CatalogCacheCompanion(
          seriesId: Value(row.coreSeriesId),
          seriesTitle: Value(title.trim()),
        ),
      );
    }
  }

  Future<void> mergeEntries({
    required String targetEntryId,
    required List<String> sourceEntryIds,
  }) async {
    if (sourceEntryIds.isEmpty) {
      return;
    }
    final target = await (_db.select(_db.seriesRegistryCache)
          ..where((table) => table.id.equals(targetEntryId))
          ..limit(1))
        .getSingleOrNull();
    if (target == null) {
      return;
    }
    final uniqueSourceIds = sourceEntryIds.toSet().where((id) => id != target.id).toList(growable: false);
    if (uniqueSourceIds.isEmpty) {
      return;
    }
    final sources = await (_db.select(_db.seriesRegistryCache)
          ..where((table) => table.id.isIn(uniqueSourceIds)))
        .get();
    if (sources.isEmpty) {
      return;
    }
    final catalogRows = await (_db.select(_db.catalogCache)
          ..where((table) => table.kind.equals(target.mediaKind)))
        .get();
    for (final catalogRow in catalogRows) {
      final matchesSource = sources.any(
        (source) => _catalogMatchesSeries(catalogRow, source),
      );
      if (!matchesSource) {
        continue;
      }
      await (_db.update(_db.catalogCache)
            ..where((table) => table.id.equals(catalogRow.id)))
          .write(
        CatalogCacheCompanion(
          seriesId: Value(target.coreSeriesId),
          seriesTitle: Value(target.title),
        ),
      );
    }
    await (_db.delete(_db.seriesRegistryCache)
          ..where((table) => table.id.isIn(uniqueSourceIds)))
        .go();
  }

  Future<Map<String, int>> _countsBySeriesKey(String mediaKind) async {
    final rows = await (_db.select(_db.catalogCache)
          ..where((table) => table.kind.equals(mediaKind)))
        .get();
    final counts = <String, int>{};
    for (final row in rows) {
      final normalizedTitle = _normalize(row.seriesTitle);
      if (normalizedTitle == null) {
        continue;
      }
      final key = _seriesKey(
        coreSeriesId: _emptyToNull(row.seriesId),
        normalizedTitle: normalizedTitle,
      );
      counts.update(key, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Future<SeriesRegistryCacheData?> _findMatchingRow({
    required String mediaKind,
    required String? coreSeriesId,
    required String normalizedTitle,
  }) async {
    if (coreSeriesId != null) {
      final byCoreId = await (_db.select(_db.seriesRegistryCache)
            ..where((table) =>
                table.mediaKind.equals(mediaKind) &
                table.coreSeriesId.equals(coreSeriesId))
            ..limit(1))
          .getSingleOrNull();
      if (byCoreId != null) {
        return byCoreId;
      }
    }
    return (_db.select(_db.seriesRegistryCache)
          ..where((table) =>
              table.mediaKind.equals(mediaKind) &
              table.normalizedTitle.equals(normalizedTitle))
          ..limit(1))
        .getSingleOrNull();
  }

  SeriesRegistryEntry _entryFromRow(
    SeriesRegistryCacheData row, {
    required int itemCount,
  }) {
    return SeriesRegistryEntry(
      id: row.id,
      mediaKind: row.mediaKind,
      title: row.title,
      sortTitle: row.sortTitle,
      coreSeriesId: row.coreSeriesId,
      itemCount: itemCount,
    );
  }

  bool _catalogMatchesSeries(
    CatalogCacheData catalogRow,
    SeriesRegistryCacheData registryRow,
  ) {
    final registryCoreSeriesId = _emptyToNull(registryRow.coreSeriesId);
    final catalogCoreSeriesId = _emptyToNull(catalogRow.seriesId);
    if (registryCoreSeriesId != null && catalogCoreSeriesId == registryCoreSeriesId) {
      return true;
    }
    return _normalize(catalogRow.seriesTitle) == registryRow.normalizedTitle;
  }

  static String? _normalize(String? value) {
    final trimmed = _emptyToNull(value);
    if (trimmed == null) {
      return null;
    }
    return trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _seriesKey({
    required String? coreSeriesId,
    required String normalizedTitle,
  }) {
    return coreSeriesId == null ? 'title:$normalizedTitle' : 'core:$coreSeriesId';
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class _SeriesCandidate {
  const _SeriesCandidate({
    required this.mediaKind,
    required this.title,
    required this.normalizedTitle,
    required this.sortTitle,
    required this.normalizedSortTitle,
    required this.coreSeriesId,
  });

  final String mediaKind;
  final String title;
  final String normalizedTitle;
  final String? sortTitle;
  final String? normalizedSortTitle;
  final String? coreSeriesId;
}