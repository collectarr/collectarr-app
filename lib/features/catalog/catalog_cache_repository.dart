import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
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
              final payload = item.payload;
              final seriesMap = payload['series'] as Map?;
              final publishingMap = payload['publishing'] as Map?;
              final videoMap = payload['video'] as Map?;
              final musicMap = payload['music'] as Map?;
              final gameMap = payload['game'] as Map?;
              final tracks = (musicMap?['tracks'] as List?)
                  ?.whereType<Map>()
                  .map((e) => CatalogTrackDto.fromJson(
                      Map<String, dynamic>.from(e)))
                  .toList();
              final discs = (musicMap?['discs'] as List?)
                  ?.whereType<Map>()
                  .map((e) => CatalogDiscDto.fromJson(
                      Map<String, dynamic>.from(e)))
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
              final country = payload['country'] as String?;
              final language = payload['language'] as String?;
              final ageRating = payload['age_rating'] as String?;
              final audienceRating = payload['audience_rating'] as String?;
              final coverDate = payload['cover_date'] != null
                  ? DateTime.tryParse(payload['cover_date'].toString())
                  : null;
              final crossover = payload['crossover'] as String?;
              final plotSummary = payload['plot_summary'] as String?;
              final plotDescription = payload['plot_description'] as String?;
              final seriesTags = seriesMap?['tags'] as String?;
              final volumeNumberStr = seriesMap?['volume_number']?.toString();
              return CatalogCacheCompanion.insert(
                id: item.id,
                kind: item.kind,
                title: item.title,
                displayTitle: Value(item.displayTitle),
                localizedTitle: Value(item.localizedTitle),
                originalTitle: Value(item.originalTitle),
                titleExtension: Value(item.titleExtension),
                searchAliasesJson: Value(
                  item.searchAliases != null && item.searchAliases!.isNotEmpty
                      ? jsonEncode(item.searchAliases)
                      : null,
                ),
                sortKey: Value(item.sortKey),
                itemNumber: Value(item.itemNumber),
                synopsis: Value(item.synopsis),
                coverImageUrl: Value(item.coverImageUrl),
                thumbnailImageUrl: Value(item.thumbnailImageUrl),
                coverImageData: Value(item.coverImageData),
                editionTitle: Value(item.editionTitle),
                physicalFormat: Value(item.physicalFormat),
                physicalFormatLabel: Value(item.physicalFormatLabel),
                publisher: Value(item.publisher),
                coverDate: Value(coverDate),
                releaseDate: Value(item.releaseDate),
                releaseYear: Value(item.releaseYear),
                barcode: Value(item.barcode),
                variant: Value(item.variant),
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
                trackCount:
                    Value((musicMap?['track_count'] as num?)?.toInt()),
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
                  item.editions.isNotEmpty
                      ? jsonEncode(
                          item.editions
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
                seriesTagsJson: Value(seriesTags),
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
                pageCount:
                    Value((publishingMap?['page_count'] as num?)?.toInt()),
                coverPriceCents: Value(
                    (publishingMap?['cover_price_cents'] as num?)?.toInt()),
                catalogCurrency:
                    Value(publishingMap?['currency'] as String?),
                catalogNumber:
                    Value(musicMap?['catalog_number'] as String?),
                country: Value(country),
                releaseStatus:
                    Value(musicMap?['release_status'] as String?),
                language: Value(language),
                ageRating: Value(ageRating),
                audienceRating: Value(audienceRating),
                imprint: Value(publishingMap?['imprint'] as String?),
                subtitle: Value(publishingMap?['subtitle'] as String?),
                seriesGroup:
                    Value(publishingMap?['series_group'] as String?),
                trailerUrlsJson: Value(
                  item.trailerUrls.isNotEmpty
                      ? jsonEncode(
                          item.trailerUrls
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

  Future<void> _captureDerivedVocabulary(List<CatalogItem> items) async {
    final pickLists = PickListRepository(_db);
    final seriesRegistry = SeriesRegistryRepository(_db);
    final byKind = <String, List<CatalogItem>>{};
    for (final item in items) {
      byKind
          .putIfAbsent(item.kind.trim().toLowerCase(), () => <CatalogItem>[])
          .add(item);
    }

    await _db.transaction(() async {
      for (final entry in byKind.entries) {
        final mediaKind = entry.key;
        final scopedItems = entry.value;
        await pickLists.captureValuesWithoutTransaction(
          kCountryPickListName,
          scopedItems.map((item) => item.payload['country'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kLanguagePickListName,
          scopedItems.map((item) => item.payload['language'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kAgeRatingPickListName,
          scopedItems.map((item) => item.payload['age_rating'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kAudienceRatingPickListName,
          scopedItems.map((item) => item.payload['audience_rating'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kScreenRatioPickListName,
          scopedItems.map((item) =>
              (item.payload['video'] as Map?)?['screen_ratio'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kLayersPickListName,
          scopedItems.map((item) =>
              (item.payload['video'] as Map?)?['layers'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kColorPickListName,
          scopedItems.map((item) =>
              (item.payload['video'] as Map?)?['color'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kAudioTrackPickListName,
          scopedItems.map((item) =>
              (item.payload['video'] as Map?)?['audio_tracks'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kSubtitlePickListName,
          scopedItems.map((item) =>
              (item.payload['video'] as Map?)?['subtitles'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kGamePlatformPickListName,
          scopedItems.expand((item) {
            final gameMap = item.payload['game'] as Map?;
            final platforms = (gameMap?['platforms'] as List?)
                ?.map((e) => e.toString())
                .toList();
            return platforms ?? const <String>[];
          }),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kMusicFormatPickListName,
          scopedItems
              .map((item) => item.physicalFormatLabel ?? item.physicalFormat),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kPublisherPickListName,
          scopedItems.map((item) => item.publisher),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kImprintPickListName,
          scopedItems.map((item) =>
              (item.payload['publishing'] as Map?)?['imprint'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kSeriesGroupPickListName,
          scopedItems.map((item) =>
              (item.payload['publishing'] as Map?)?['series_group'] as String?),
          mediaKind: mediaKind,
        );
        await pickLists.captureValuesWithoutTransaction(
          kPhysicalFormatPickListName,
          scopedItems.map(
            (item) => item.physicalFormatLabel ?? item.physicalFormat,
          ),
          mediaKind: mediaKind,
        );
      }
      await seriesRegistry.captureCatalogItemsWithoutTransaction(items);
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
      if (row.seriesId != null || row.seriesTitle != null)
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
          if (row.seriesTagsJson != null) 'tags': row.seriesTagsJson,
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
          if (row.discsJson != null)
            'discs': _decodeListOfMaps(row.discsJson),
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

    return CatalogItemDto.fromFields(
      id: row.id,
      mediaKind: catalogMediaKindFromValue(row.kind),
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
}
