import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class SerialAuthorityEntry {
  const SerialAuthorityEntry({
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

class SerialAuthorityRepository {
  SerialAuthorityRepository(this._db);

  final LocalDatabase _db;

  Future<List<SerialAuthorityEntry>> searchEntries({
    required String mediaKind,
    String? query,
    String? selectedTitle,
    String? selectedSeriesId,
  }) async {
    final normalizedKind = mediaKind.trim().toLowerCase();
    final normalizedQuery = _normalize(query);
    final rows = await (_db.select(_db.serialAuthorityCache)
          ..where((table) => table.mediaKind.equals(normalizedKind))
          ..orderBy([
            (table) => OrderingTerm.asc(table.normalizedSortTitle),
            (table) => OrderingTerm.asc(table.normalizedTitle),
          ]))
        .get();
    final counts = await _countsBySeriesKey(normalizedKind);
    final entries = <SerialAuthorityEntry>[
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
          (selectedSeriesId != null &&
              entry.coreSeriesId == selectedSeriesId) ||
          _normalize(entry.title) == selectedNormalizedTitle,
    );
    if (!hasSelected && selectedNormalizedTitle != null) {
      entries.insert(
        0,
        SerialAuthorityEntry(
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

  Future<SerialAuthorityEntry?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final row = await (_db.select(_db.serialAuthorityCache)
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

  Future<SerialAuthorityEntry> upsertManualEntry({
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
      await _db.into(_db.serialAuthorityCache).insert(
            SerialAuthorityCacheCompanion.insert(
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
      return SerialAuthorityEntry(
        id: id,
        mediaKind: normalizedKind,
        title: title.trim(),
        sortTitle: _emptyToNull(sortTitle),
        coreSeriesId: null,
        itemCount: 0,
      );
    }
    await (_db.update(_db.serialAuthorityCache)
          ..where((table) => table.id.equals(existing.id)))
        .write(
      SerialAuthorityCacheCompanion(
        title: Value(title.trim()),
        normalizedTitle: Value(normalizedTitle),
        sortTitle: Value(_emptyToNull(sortTitle)),
        normalizedSortTitle: Value(normalizedSortTitle),
        updatedAt: Value(now),
      ),
    );
    final updated = await findById(existing.id);
    return updated ??
        SerialAuthorityEntry(
          id: existing.id,
          mediaKind: normalizedKind,
          title: title.trim(),
          sortTitle: _emptyToNull(sortTitle),
          coreSeriesId: existing.coreSeriesId,
          itemCount: 0,
        );
  }

  Future<void> captureCatalogItems(Iterable<Object?> items) async {
    await _db.transaction(() async {
      await captureCatalogItemsWithoutTransaction(items);
    });
  }

  Future<void> captureCatalogItemsWithoutTransaction(
      Iterable<Object?> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    final candidates = <String, _SeriesCandidate>{};
    for (final item in list) {
      final metadataItem = typedCatalogItemFromUnknown(item);
      if (metadataItem == null) {
        continue;
      }
      final kind = metadataItem.kind;
      final payload = metadataItem.payload;
      final rawSeriesPayload = payload['series'];
      final seriesPayload = rawSeriesPayload is Map
          ? Map<String, dynamic>.from(rawSeriesPayload)
          : payload;
      final seriesTitle =
          (seriesPayload['series_title'] ?? seriesPayload['seriesTitle'])
              ?.toString();
      final seriesId =
          (seriesPayload['series_id'] ?? seriesPayload['seriesId'])?.toString();
      final title = _emptyToNull(
        seriesTitle ??
            ((kind == 'comic' || kind == 'manga')
                ? payload['title']?.toString()
                : null),
      );
      final normalizedTitle = _normalize(title);
      if (normalizedTitle == null) {
        continue;
      }
      final mediaKind = kind.trim().toLowerCase();
      final coreSeriesId = _emptyToNull(seriesId);
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
        await _db.into(_db.serialAuthorityCache).insert(
              SerialAuthorityCacheCompanion.insert(
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
      await (_db.update(_db.serialAuthorityCache)
            ..where((table) => table.id.equals(existing.id)))
          .write(
        SerialAuthorityCacheCompanion(
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
    final row = await (_db.select(_db.serialAuthorityCache)
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
    await (_db.update(_db.serialAuthorityCache)
          ..where((table) => table.id.equals(entryId)))
        .write(
      SerialAuthorityCacheCompanion(
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
    final catalogItems =
        await LibraryCatalogRepository(_db).findAll(kind: row.mediaKind);
    for (final catalogItem in catalogItems) {
      if (!_catalogMatchesSeries(catalogItem, row)) {
        continue;
      }
      await LibraryCatalogRepository(_db).upsertAll(
        [
          typedCatalogItemFromMap(
            _catalogPayloadWithSeries(
              catalogItem,
              seriesId: row.coreSeriesId,
              seriesTitle: title.trim(),
            ),
          ),
        ],
        captureDerivedData: false,
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
    final target = await (_db.select(_db.serialAuthorityCache)
          ..where((table) => table.id.equals(targetEntryId))
          ..limit(1))
        .getSingleOrNull();
    if (target == null) {
      return;
    }
    final uniqueSourceIds = sourceEntryIds
        .toSet()
        .where((id) => id != target.id)
        .toList(growable: false);
    if (uniqueSourceIds.isEmpty) {
      return;
    }
    final sources = await (_db.select(_db.serialAuthorityCache)
          ..where((table) => table.id.isIn(uniqueSourceIds)))
        .get();
    if (sources.isEmpty) {
      return;
    }
    final catalogItems =
        await LibraryCatalogRepository(_db).findAll(kind: target.mediaKind);
    for (final catalogItem in catalogItems) {
      final matchesSource = sources.any(
        (source) => _catalogMatchesSeries(catalogItem, source),
      );
      if (!matchesSource) {
        continue;
      }
      await LibraryCatalogRepository(_db).upsertAll(
        [
          typedCatalogItemFromMap(
            _catalogPayloadWithSeries(
              catalogItem,
              seriesId: target.coreSeriesId,
              seriesTitle: target.title,
            ),
          ),
        ],
        captureDerivedData: false,
      );
    }
    await (_db.delete(_db.serialAuthorityCache)
          ..where((table) => table.id.isIn(uniqueSourceIds)))
        .go();
  }

  Future<Map<String, int>> _countsBySeriesKey(String mediaKind) async {
    final counts = <String, int>{};
    final catalogItems =
        await LibraryCatalogRepository(_db).findAll(kind: mediaKind);
    for (final catalogItem in catalogItems) {
      final series = _seriesPayload(catalogItem);
      final normalizedTitle = _normalize(
        (series['series_title'] ?? series['seriesTitle'])?.toString(),
      );
      if (normalizedTitle == null) {
        continue;
      }
      final key = _seriesKey(
        coreSeriesId: _emptyToNull(
          (series['series_id'] ?? series['seriesId'])?.toString(),
        ),
        normalizedTitle: normalizedTitle,
      );
      counts.update(key, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Future<SerialAuthorityCacheData?> _findMatchingRow({
    required String mediaKind,
    required String? coreSeriesId,
    required String normalizedTitle,
  }) async {
    if (coreSeriesId != null) {
      final byCoreId = await (_db.select(_db.serialAuthorityCache)
            ..where((table) =>
                table.mediaKind.equals(mediaKind) &
                table.coreSeriesId.equals(coreSeriesId))
            ..limit(1))
          .getSingleOrNull();
      if (byCoreId != null) {
        return byCoreId;
      }
    }
    return (_db.select(_db.serialAuthorityCache)
          ..where((table) =>
              table.mediaKind.equals(mediaKind) &
              table.normalizedTitle.equals(normalizedTitle))
          ..limit(1))
        .getSingleOrNull();
  }

  SerialAuthorityEntry _entryFromRow(
    SerialAuthorityCacheData row, {
    required int itemCount,
  }) {
    return SerialAuthorityEntry(
      id: row.id,
      mediaKind: row.mediaKind,
      title: row.title,
      sortTitle: row.sortTitle,
      coreSeriesId: row.coreSeriesId,
      itemCount: itemCount,
    );
  }

  bool _catalogMatchesSeries(
    CatalogItem catalogItem,
    SerialAuthorityCacheData registryRow,
  ) {
    final registryCoreSeriesId = _emptyToNull(registryRow.coreSeriesId);
    final series = _seriesPayload(catalogItem);
    final catalogCoreSeriesId = _emptyToNull(
      (series['series_id'] ?? series['seriesId'])?.toString(),
    );
    if (registryCoreSeriesId != null &&
        catalogCoreSeriesId == registryCoreSeriesId) {
      return true;
    }
    return _normalize(
          (series['series_title'] ?? series['seriesTitle'])?.toString(),
        ) ==
        registryRow.normalizedTitle;
  }

  static Map<String, dynamic> _seriesPayload(CatalogItem item) {
    final rawSeries = item.payload['series'];
    return rawSeries is Map ? Map<String, dynamic>.from(rawSeries) : const {};
  }

  static Map<String, dynamic> _catalogPayloadWithSeries(
    CatalogItem item, {
    required String? seriesId,
    required String seriesTitle,
  }) {
    final payload = Map<String, dynamic>.from(item.payload);
    final series = _seriesPayload(item);
    if (seriesId == null || seriesId.isEmpty) {
      series.remove('series_id');
      series.remove('seriesId');
    } else {
      series['series_id'] = seriesId;
    }
    series['series_title'] = seriesTitle;
    payload['series'] = series;
    return {
      'id': item.id,
      ...item.toSyncPayload(),
      ...payload,
    };
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
    return coreSeriesId == null
        ? 'title:$normalizedTitle'
        : 'core:$coreSeriesId';
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
