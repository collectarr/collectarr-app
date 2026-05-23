import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:drift/drift.dart';

class CatalogCacheRepository {
  const CatalogCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<void> upsertAll(List<CatalogItem> items) async {
    if (items.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    await _db.batch((batch) {
      batch.insertAll(
        _db.catalogCache,
        [
          for (final item in items)
            () {
              final series = item.series;
              final publishing = item.publishing;
              final video = item.video;
              final music = item.music;
              final game = item.game;
              final tracks = music?.tracks;
              final platforms = game?.platforms ?? item.rawPlatforms;
              return CatalogCacheCompanion.insert(
                id: item.id,
                kind: item.kind,
                title: item.title,
                sortKey: Value(item.sortKey),
                itemNumber: Value(item.itemNumber),
                synopsis: Value(item.synopsis),
                coverImageUrl: Value(item.coverImageUrl),
                thumbnailImageUrl: Value(item.thumbnailImageUrl),
                editionTitle: Value(item.editionTitle),
                physicalFormat: Value(item.physicalFormat),
                physicalFormatLabel: Value(item.physicalFormatLabel),
                publisher: Value(item.publisher),
                releaseDate: Value(item.releaseDate),
                releaseYear: Value(item.releaseYear),
                barcode: Value(item.barcode),
                variant: Value(item.variant),
                seriesId: Value(series?.seriesId),
                seriesTitle: Value(series?.seriesTitle),
                volumeName: Value(series?.volumeName),
                volumeNumber: Value(series?.volumeNumber),
                volumeStartYear: Value(series?.volumeStartYear),
                seasonNumber: Value(series?.seasonNumber),
                episodeNumber: Value(series?.episodeNumber),
                runtimeMinutes: Value(video?.runtimeMinutes),
                trackCount: Value(music?.trackCount),
                tracksJson: Value(
                  tracks != null && tracks.isNotEmpty
                      ? jsonEncode(
                          tracks
                              .map((track) => track.toJson())
                              .toList(growable: false),
                        )
                      : null,
                ),
                creatorsJson: Value(
                  item.creators != null && item.creators!.isNotEmpty
                      ? jsonEncode(item.creators)
                      : null,
                ),
                charactersJson: Value(
                  item.characters != null && item.characters!.isNotEmpty
                      ? jsonEncode(item.characters)
                      : null,
                ),
                storyArcsJson: Value(
                  item.storyArcs != null && item.storyArcs!.isNotEmpty
                      ? jsonEncode(item.storyArcs)
                      : null,
                ),
                seriesTagsJson: Value(
                  series != null && series.tags.isNotEmpty
                      ? jsonEncode(series.tags)
                      : null,
                ),
                platformsJson: Value(
                  platforms != null && platforms.isNotEmpty
                      ? jsonEncode(platforms)
                      : null,
                ),
                genresJson: Value(
                  item.genres != null && item.genres!.isNotEmpty
                      ? jsonEncode(item.genres)
                      : null,
                ),
                pageCount: Value(publishing?.pageCount),
                coverPriceCents: Value(publishing?.coverPriceCents),
                catalogCurrency: Value(publishing?.currency),
                catalogNumber: Value(music?.catalogNumber),
                country: Value(item.country),
                releaseStatus: Value(music?.releaseStatus),
                language: Value(item.language),
                ageRating: Value(item.ageRating),
                imprint: Value(publishing?.imprint),
                subtitle: Value(publishing?.subtitle),
                seriesGroup: Value(publishing?.seriesGroup),
                cachedAt: now,
              );
            }()
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<Map<String, CatalogItem>> findByIds(Iterable<String> ids) async {
    final values = ids.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const {};
    }

    final rows = <CatalogCacheData>[];
    for (var index = 0; index < values.length; index += _lookupBatchSize) {
      final end = (index + _lookupBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      rows.addAll(
        await (_db.select(_db.catalogCache)..where((row) => row.id.isIn(batch)))
            .get(),
      );
    }

    return {
      for (final row in rows)
        row.id: _itemFromRow(row),
    };
  }

  Future<CatalogItem?> findByBarcode(String barcode, {String? kind}) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final query = _db.select(_db.catalogCache);
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind != null && normalizedKind.isNotEmpty) {
      query.where((row) => row.kind.equals(normalizedKind));
    }
    final compact = _compactBarcode(normalized);
    final rows = await query.get();
    final row = rows.cast<CatalogCacheData?>().firstWhere(
          (row) =>
              row != null &&
              row.barcode != null &&
              _compactBarcode(row.barcode!) == compact,
          orElse: () => null,
        );
    return row == null ? null : _itemFromRow(row);
  }

  Future<CatalogItem?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final row = await (_db.select(_db.catalogCache)
          ..where((row) => row.id.equals(normalized))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _itemFromRow(row);
  }

  Future<CatalogItem?> findByTitleAndIssue({
    required String title,
    required String? itemNumber,
    String? kind,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return null;
    }
    final query = _db.select(_db.catalogCache)
      ..where((row) => row.title.equals(normalizedTitle));
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind != null && normalizedKind.isNotEmpty) {
      query.where((row) => row.kind.equals(normalizedKind));
    }
    final normalizedIssue = itemNumber?.trim();
    if (normalizedIssue != null && normalizedIssue.isNotEmpty) {
      query.where((row) => row.itemNumber.equals(normalizedIssue));
    }
    query.limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _itemFromRow(row);
  }

  CatalogItem _itemFromRow(CatalogCacheData row) {
    final series = CatalogSeriesDetails(
      seriesId: row.seriesId,
      seriesTitle: row.seriesTitle,
      volumeName: row.volumeName,
      volumeNumber: row.volumeNumber,
      volumeStartYear: row.volumeStartYear,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      tags: _decodeStringList(row.seriesTagsJson) ?? const <String>[],
    );
    final video = VideoCatalogDetails(runtimeMinutes: row.runtimeMinutes);
    final tracks = _decodeTracks(row.tracksJson);
    final rawPlatforms = _decodeStringList(row.platformsJson);
    final music = MusicCatalogDetails(
      trackCount: row.trackCount,
      tracks: tracks ?? const <CatalogTrack>[],
      catalogNumber: row.catalogNumber,
      releaseStatus: row.releaseStatus,
    );
    final game = GameCatalogDetails(platforms: rawPlatforms ?? const <String>[]);
    final publishing = CatalogPublishingDetails(
      pageCount: row.pageCount,
      coverPriceCents: row.coverPriceCents,
      currency: row.catalogCurrency,
      imprint: row.imprint,
      subtitle: row.subtitle,
      seriesGroup: row.seriesGroup,
    );
    return CatalogItem(
      id: row.id,
      kind: row.kind,
      title: row.title,
      sortKey: row.sortKey,
      itemNumber: row.itemNumber,
      synopsis: row.synopsis,
      coverImageUrl: row.coverImageUrl,
      thumbnailImageUrl: row.thumbnailImageUrl,
      editionTitle: row.editionTitle,
      physicalFormat: row.physicalFormat,
      physicalFormatLabel: row.physicalFormatLabel,
      publisher: row.publisher,
      releaseDate: row.releaseDate,
      releaseYear: row.releaseYear,
      barcode: row.barcode,
      variant: row.variant,
      series: series.hasData ? series : null,
      video: video.hasData ? video : null,
      music: music.hasData ? music : null,
      game: game.hasData ? game : null,
      publishing: publishing.hasData ? publishing : null,
      creators: _decodeListOfMaps(row.creatorsJson),
      characters: _decodeStringList(row.charactersJson),
      storyArcs: _decodeStringList(row.storyArcsJson),
      rawPlatforms: rawPlatforms,
      genres: _decodeStringList(row.genresJson),
      country: row.country,
      language: row.language,
      ageRating: row.ageRating,
    );
  }

  static List<CatalogTrack>? _decodeTracks(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) {
      return null;
    }
    return decoded
        .map((track) => CatalogTrack.fromJson(track))
        .toList(growable: false);
  }

  static List<Map<String, dynamic>>? _decodeListOfMaps(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      return null;
    }
    return decoded.cast<Map<String, dynamic>>().toList(growable: false);
  }

  static List<String>? _decodeStringList(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      return null;
    }
    return decoded.cast<String>().toList(growable: false);
  }

  String _compactBarcode(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
