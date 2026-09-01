import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:drift/drift.dart';

class CatalogCacheRepository {
  const CatalogCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<void> upsertMetadataItems(List<LibraryMetadataItem> items) =>
      upsertAll(items);

  Future<void> upsertAll(Iterable<dynamic> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    await _db.batch((batch) {
      batch.insertAll(
        _db.catalogCache,
        [
          for (final item in list)
            () {
              final payload = item is LibraryMetadataItem
                  ? item.payload
                  : (item as CatalogItem).payload;
              final editions = item is LibraryMetadataItem
                  ? item.editions
                  : (item as CatalogItem).editions;
              final trailerUrls = item is LibraryMetadataItem
                  ? item.trailerUrls
                  : (item as CatalogItem).trailerUrls;
              final seriesMap = _asMap(payload['series']);
              final publishingMap = _asMap(payload['publishing']);
              final videoMap = _asMap(payload['video']);
              final musicMap = _asMap(payload['music']);
              final gameMap = _asMap(payload['game']);
              final tracks = (musicMap?['tracks'] as List?)
                  ?.whereType<Map>()
                  .map((e) =>
                      CatalogTrackDto.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
              final discs = (musicMap?['discs'] as List?)
                  ?.whereType<Map>()
                  .map((e) =>
                      CatalogDiscDto.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
              final platforms = (gameMap?['platforms'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  (payload['platforms'] as List?)
                      ?.map((e) => e.toString())
                      .toList();
              final creators = (payload['creators'] as List?)
                  ?.whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
              final characters = (payload['characters'] as List?)
                  ?.map((e) => e.toString())
                  .toList();
              final characterDetails = (payload['character_details'] as List?)
                  ?.whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
              final storyArcs = (payload['story_arcs'] as List?)
                  ?.map((e) => e.toString())
                  .toList();
              final genres = (payload['genres'] as List?)
                  ?.map((e) => e.toString())
                  .toList();
              final volumeNumberStr = seriesMap?['volume_number']?.toString();
              final itemNumber =
                  (payload['item_number'] ?? payload['itemNumber'])?.toString();
              final editionTitle =
                  (payload['edition_title'] ?? payload['editionTitle'])
                      ?.toString();
              final physicalFormat =
                  (payload['physical_format'] ?? payload['physicalFormat'])
                      ?.toString();
              final physicalFormatLabel = (payload['physical_format_label'] ??
                      payload['physicalFormatLabel'])
                  ?.toString();
              final publisher = (payload['publisher'] ??
                      publishingMap?['original_publisher'] ??
                      publishingMap?['publisher'])
                  ?.toString();
              final barcode =
                  (payload['barcode'] ?? payload['upc'])?.toString();
              final variant = payload['variant']?.toString();
              final country = (payload['country'] ??
                      publishingMap?['original_country'] ??
                      publishingMap?['country'])
                  ?.toString();
              final language = (payload['language'] ??
                      publishingMap?['original_language'] ??
                      publishingMap?['language'])
                  ?.toString();
              final ageRating =
                  (payload['age_rating'] ?? publishingMap?['age_rating'])
                      ?.toString();
              final audienceRating =
                  (payload['audience_rating'] ?? videoMap?['audience_rating'])
                      ?.toString();
              final coverDate = payload['cover_date'] != null
                  ? DateTime.tryParse(payload['cover_date'].toString())
                  : null;
              final crossover = payload['crossover']?.toString();
              final plotSummary =
                  (payload['plot_summary'] ?? payload['plotSummary'])
                      ?.toString();
              final plotDescription =
                  (payload['plot_description'] ?? payload['plotDescription'])
                      ?.toString();
              final rawSeriesTags =
                  payload['series_tags'] ?? seriesMap?['tags'];
              final seriesTags = rawSeriesTags is List
                  ? rawSeriesTags.map((e) => e.toString()).toList()
                  : (rawSeriesTags is String
                      ? rawSeriesTags
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList()
                      : null);
              final id = item is LibraryMetadataItem
                  ? item.id
                  : (item as CatalogItem).id;
              final kind = item is LibraryMetadataItem
                  ? item.kind
                  : (item as CatalogItem).kind;
              final title = item is LibraryMetadataItem
                  ? item.title
                  : (item as CatalogItem).title;
              final displayTitle = item is LibraryMetadataItem
                  ? item.displayTitle
                  : (item as CatalogItem).displayTitle;
              final localizedTitle = item is LibraryMetadataItem
                  ? item.localizedTitle
                  : (item as CatalogItem).localizedTitle;
              final originalTitle = item is LibraryMetadataItem
                  ? item.originalTitle
                  : (item as CatalogItem).originalTitle;
              final titleExtension = item is LibraryMetadataItem
                  ? item.titleExtension
                  : (item as CatalogItem).titleExtension;
              final searchAliases = item is LibraryMetadataItem
                  ? item.searchAliases
                  : (item as CatalogItem).searchAliases;
              final sortKey = item is LibraryMetadataItem
                  ? item.sortKey
                  : (item as CatalogItem).sortKey;
              final synopsis = item is LibraryMetadataItem
                  ? item.synopsis
                  : (item as CatalogItem).synopsis;
              final coverImageUrl = item is LibraryMetadataItem
                  ? item.coverImageUrl
                  : (item as CatalogItem).coverImageUrl;
              final thumbnailImageUrl = item is LibraryMetadataItem
                  ? item.thumbnailImageUrl
                  : (item as CatalogItem).thumbnailImageUrl;
              final coverImageData = item is LibraryMetadataItem
                  ? item.coverImageData
                  : (item as CatalogItem).coverImageData;
              final releaseDate = item is LibraryMetadataItem
                  ? item.releaseDate
                  : (item as CatalogItem).releaseDate;
              final releaseYear = item is LibraryMetadataItem
                  ? item.releaseYear
                  : (item as CatalogItem).releaseYear;
              return CatalogCacheCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                displayTitle: Value(displayTitle),
                localizedTitle: Value(localizedTitle),
                originalTitle: Value(originalTitle),
                titleExtension: Value(titleExtension),
                searchAliasesJson: Value(
                  searchAliases != null && searchAliases.isNotEmpty
                      ? jsonEncode(searchAliases)
                      : null,
                ),
                sortKey: Value(sortKey),
                itemNumber: Value(itemNumber),
                synopsis: Value(synopsis),
                coverImageUrl: Value(coverImageUrl),
                thumbnailImageUrl: Value(thumbnailImageUrl),
                coverImageData: Value(coverImageData),
                editionTitle: Value(editionTitle),
                physicalFormat: Value(physicalFormat),
                physicalFormatLabel: Value(physicalFormatLabel),
                publisher: Value(publisher),
                coverDate: Value(coverDate),
                releaseDate: Value(releaseDate),
                releaseYear: Value(releaseYear),
                barcode: Value(barcode),
                variant: Value(variant),
                crossover: Value(crossover),
                plotSummary: Value(plotSummary),
                plotDescription: Value(plotDescription),
                seriesId: Value(seriesMap?['series_id'] as String?),
                seriesTitle: Value(seriesMap?['series_title'] as String?),
                volumeName: Value(seriesMap?['volume_name'] as String?),
                volumeNumber: Value(volumeNumberStr != null
                    ? double.tryParse(volumeNumberStr)
                    : null),
                volumeStartYear:
                    Value((seriesMap?['volume_start_year'] as num?)?.toInt()),
                seasonNumber:
                    Value((seriesMap?['season_number'] as num?)?.toInt()),
                episodeNumber:
                    Value((seriesMap?['episode_number'] as num?)?.toInt()),
                runtimeMinutes:
                    Value((videoMap?['runtime_minutes'] as num?)?.toInt()),
                trackCount: Value((musicMap?['track_count'] as num?)?.toInt()),
                tracksJson: Value(
                  tracks != null && tracks.isNotEmpty
                      ? jsonEncode(
                          tracks
                              .map((track) => track.toJson())
                              .toList(growable: false),
                        )
                      : null,
                ),
                discsJson: Value(
                  discs != null && discs.isNotEmpty
                      ? jsonEncode(
                          discs
                              .map((disc) => disc.toJson())
                              .toList(growable: false),
                        )
                      : null,
                ),
                editionsJson: Value(
                  editions.isNotEmpty
                      ? jsonEncode(
                          editions
                              .map((edition) => edition.toJson())
                              .toList(growable: false),
                        )
                      : null,
                ),
                creatorsJson: Value(
                  creators != null && creators.isNotEmpty
                      ? jsonEncode(creators)
                      : null,
                ),
                charactersJson: Value(
                  characters != null && characters.isNotEmpty
                      ? jsonEncode(characters)
                      : null,
                ),
                characterDetailsJson: Value(
                  characterDetails != null && characterDetails.isNotEmpty
                      ? jsonEncode(characterDetails)
                      : null,
                ),
                storyArcsJson: Value(
                  storyArcs != null && storyArcs.isNotEmpty
                      ? jsonEncode(storyArcs)
                      : null,
                ),
                seriesTagsJson: Value(
                  seriesTags != null && seriesTags.isNotEmpty
                      ? jsonEncode(seriesTags)
                      : null,
                ),
                platformsJson: Value(
                  platforms != null && platforms.isNotEmpty
                      ? jsonEncode(platforms)
                      : null,
                ),
                genresJson: Value(
                  genres != null && genres.isNotEmpty
                      ? jsonEncode(genres)
                      : null,
                ),
                country: Value(country),
                pageCount:
                    Value((publishingMap?['page_count'] as num?)?.toInt()),
                coverPriceCents: Value(
                    (publishingMap?['cover_price_cents'] as num?)?.toInt()),
                catalogCurrency: Value(publishingMap?['currency'] as String?),
                catalogNumber: Value(musicMap?['catalog_number'] as String?),
                releaseStatus: Value(musicMap?['release_status'] as String?),
                language: Value(language),
                ageRating: Value(ageRating),
                audienceRating: Value(audienceRating),
                imprint: Value(publishingMap?['imprint'] as String?),
                subtitle: Value(publishingMap?['subtitle'] as String?),
                seriesGroup: Value(publishingMap?['series_group'] as String?),
                trailerUrlsJson: Value(
                  trailerUrls.isNotEmpty
                      ? jsonEncode(
                          trailerUrls
                              .map((t) => t.toJson())
                              .toList(growable: false),
                        )
                      : null,
                ),
                color: Value(videoMap?['color'] as String?),
                nrDiscs: Value((videoMap?['nr_discs'] as num?)?.toInt()),
                screenRatio: Value(videoMap?['screen_ratio'] as String?),
                audioTracksJson: Value(videoMap?['audio_tracks'] as String?),
                subtitlesJson: Value(videoMap?['subtitles'] as String?),
                layers: Value(videoMap?['layers'] as String?),
                cachedAt: now,
              );
            }(),
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
    await _captureDerivedVocabulary(items);
  }

  Future<void> _captureDerivedVocabulary(Iterable<dynamic> items) async {
    final list = items.toList(growable: false);
    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    final byKind = <String, List<Map<String, dynamic>>>{};
    for (final item in list) {
      final kind =
          item is LibraryMetadataItem ? item.kind : (item as CatalogItem).kind;
      final payload = item is LibraryMetadataItem
          ? item.payload
          : (item as CatalogItem).payload;
      byKind
          .putIfAbsent(
              kind.trim().toLowerCase(), () => <Map<String, dynamic>>[])
          .add(payload);
    }

    await _db.transaction(() async {
      for (final entry in byKind.entries) {
        final mediaKind = entry.key;
        final scopedPayloads = entry.value;
        final kind = catalogMediaKindFromApiValue(mediaKind);
        final definitions =
            libraryKindRuntimeForKind(kind).edit.vocabularies?.definitions ??
                const [];
        for (final definition in definitions) {
          final reader = definition.catalogValueReader;
          if (reader == null) {
            continue;
          }
          final values = <String?>[];
          for (final payload in scopedPayloads) {
            values.addAll(reader(payload));
          }
          await pickLists.captureValuesWithoutTransaction(
            definition.key,
            values,
            mediaKind: mediaKind,
          );
        }
      }
      await serialAuthority.captureCatalogItemsWithoutTransaction(list);
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
      for (final row in rows) row.id: _itemFromRow(row),
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
    final payload = <String, dynamic>{
      if (row.itemNumber != null) 'item_number': row.itemNumber,
      if (row.variant != null) 'variant': row.variant,
      if (row.publisher != null) 'publisher': row.publisher,
      if (row.barcode != null) 'barcode': row.barcode,
      if (row.physicalFormat != null) 'physical_format': row.physicalFormat,
      if (row.physicalFormatLabel != null)
        'physical_format_label': row.physicalFormatLabel,
      if (row.editionTitle != null) 'edition_title': row.editionTitle,
      if (row.country != null) 'country': row.country,
      if (row.language != null) 'language': row.language,
      if (row.ageRating != null) 'age_rating': row.ageRating,
      if (row.audienceRating != null) 'audience_rating': row.audienceRating,
      if (row.crossover != null) 'crossover': row.crossover,
      if (row.plotSummary != null) 'plot_summary': row.plotSummary,
      if (row.plotDescription != null) 'plot_description': row.plotDescription,
      if (row.coverDate != null) 'cover_date': row.coverDate?.toIso8601String(),
      if (row.seriesId != null ||
          row.seriesTitle != null ||
          row.volumeName != null ||
          row.volumeNumber != null ||
          row.volumeStartYear != null ||
          row.seasonNumber != null ||
          row.episodeNumber != null ||
          row.seriesTagsJson != null)
        'series': {
          if (row.seriesId != null) 'series_id': row.seriesId,
          if (row.seriesTitle != null) 'series_title': row.seriesTitle,
          if (row.volumeName != null) 'volume_name': row.volumeName,
          if (row.volumeNumber != null)
            'volume_number': row.volumeNumber?.toString(),
          if (row.volumeStartYear != null)
            'volume_start_year': row.volumeStartYear,
          if (row.seasonNumber != null) 'season_number': row.seasonNumber,
          if (row.episodeNumber != null) 'episode_number': row.episodeNumber,
          if (row.seriesTagsJson != null)
            'tags': _decodeStringList(row.seriesTagsJson)?.join(', '),
        },
      if (row.pageCount != null ||
          row.coverPriceCents != null ||
          row.imprint != null ||
          row.subtitle != null ||
          row.seriesGroup != null)
        'publishing': {
          if (row.pageCount != null) 'page_count': row.pageCount,
          if (row.coverPriceCents != null)
            'cover_price_cents': row.coverPriceCents,
          if (row.catalogCurrency != null) 'currency': row.catalogCurrency,
          if (row.imprint != null) 'imprint': row.imprint,
          if (row.subtitle != null) 'subtitle': row.subtitle,
          if (row.seriesGroup != null) 'series_group': row.seriesGroup,
        },
      if (row.runtimeMinutes != null ||
          row.color != null ||
          row.nrDiscs != null ||
          row.screenRatio != null ||
          row.audioTracksJson != null ||
          row.subtitlesJson != null ||
          row.layers != null)
        'video': {
          if (row.runtimeMinutes != null) 'runtime_minutes': row.runtimeMinutes,
          if (row.color != null) 'color': row.color,
          if (row.nrDiscs != null) 'nr_discs': row.nrDiscs,
          if (row.screenRatio != null) 'screen_ratio': row.screenRatio,
          if (row.audioTracksJson != null) 'audio_tracks': row.audioTracksJson,
          if (row.subtitlesJson != null) 'subtitles': row.subtitlesJson,
          if (row.layers != null) 'layers': row.layers,
        },
      if (row.trackCount != null ||
          row.tracksJson != null ||
          row.discsJson != null ||
          row.catalogNumber != null ||
          row.releaseStatus != null)
        'music': {
          if (row.trackCount != null) 'track_count': row.trackCount,
          if (row.tracksJson != null)
            'tracks': _decodeListOfMaps(row.tracksJson),
          if (row.discsJson != null) 'discs': _decodeListOfMaps(row.discsJson),
          if (row.catalogNumber != null) 'catalog_number': row.catalogNumber,
          if (row.releaseStatus != null) 'release_status': row.releaseStatus,
        },
      if (row.platformsJson != null)
        'game': {
          'platforms': _decodeStringList(row.platformsJson) ?? const <String>[],
        },
      if (row.creatorsJson != null)
        'creators': _decodeListOfMaps(row.creatorsJson) ?? const [],
      if (row.charactersJson != null)
        'characters': _decodeStringList(row.charactersJson) ?? const [],
      if (row.characterDetailsJson != null)
        'character_details':
            _decodeListOfMaps(row.characterDetailsJson) ?? const [],
      if (row.storyArcsJson != null)
        'story_arcs': _decodeStringList(row.storyArcsJson) ?? const [],
      if (row.genresJson != null)
        'genres': _decodeStringList(row.genresJson) ?? const [],
    };

    final common = CatalogCommonDto(
      title: row.title,
      displayTitle: row.displayTitle,
      localizedTitle: row.localizedTitle,
      originalTitle: row.originalTitle,
      titleExtension: row.titleExtension,
      searchAliases: _decodeStringList(row.searchAliasesJson),
      sortKey: row.sortKey,
      synopsis: row.synopsis,
      coverImageUrl: row.coverImageUrl,
      thumbnailImageUrl: row.thumbnailImageUrl,
      coverImageData: row.coverImageData,
      releaseDate: row.releaseDate,
      releaseYear: row.releaseYear,
      editions:
          _decodeEditions(row.editionsJson) ?? const <CatalogEditionDto>[],
      trailerUrls:
          _decodeTrailerUrls(row.trailerUrlsJson) ?? const <TrailerLinkDto>[],
    );

    return CatalogItemDto.raw(
      id: row.id,
      mediaKind: catalogMediaKindFromValue(row.kind),
      common: common,
      payload: payload,
    );
  }

  static List<CatalogTrackDto>? _decodeTracks(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) {
      return null;
    }
    return decoded
        .map((track) => CatalogTrackDto.fromJson(track))
        .toList(growable: false);
  }

  static List<CatalogDiscDto>? _decodeDiscs(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) {
      return null;
    }
    return decoded
        .map((disc) => CatalogDiscDto.fromJson(disc))
        .toList(growable: false);
  }

  static List<CatalogEditionDto>? _decodeEditions(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) {
      return null;
    }
    return decoded
        .map((edition) => CatalogEditionDto.fromJson(edition))
        .toList(growable: false);
  }

  static List<TrailerLinkDto>? _decodeTrailerUrls(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) {
      return null;
    }
    return decoded
        .map((trailer) => TrailerLinkDto.fromJson(trailer))
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

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    try {
      final dynamic json = (value as dynamic).toJson();
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }
}
