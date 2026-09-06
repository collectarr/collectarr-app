import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';

const String seedCoverImageData =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+XbL0AAAAASUVORK5CYII=';

final Uint8List seedTinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Zx1EAAAAASUVORK5CYII=',
);

String seedOrdinal2(int value) => value.toString().padLeft(2, '0');

Iterable<String> seedIds(String kind, int count) sync* {
  for (var i = 1; i <= count; i++) {
    yield 'seed-$kind-${seedOrdinal2(i)}';
  }
}

CatalogEntityRef seedCatalogRef(String itemId) {
  final kind = itemId.startsWith('seed-') ? itemId.split('-')[1] : 'unknown';
  return CatalogEntityRef(
    kind: kind,
    entityType: CatalogEntityType.work,
    id: itemId,
  );
}

/// Rebuilds a transport fixture while preserving its common catalog fields.
/// Kind seeders use this only to add their own Core graph fields.
CatalogItem withSeedPayload(
  CatalogItem item,
  Map<String, dynamic> additions,
) {
  // Keep the additions in the raw kind payload. Reconstructing through the
  // envelope parser would classify `editions` as the generic common field
  // and drop kind-specific keys such as work_id, edition_title, or players.
  return CatalogItemDto.raw(
    id: item.id,
    mediaKind: item.mediaKind,
    common: item.common,
    payload: {
      ...item.payload,
      ...additions,
    },
  );
}

/// Returns the declared common editions, or one deterministic fallback edition
/// so every kind fixture exercises its edition/release mapping path.
List<Map<String, dynamic>> seedEditionPayloads(CatalogItem item) {
  if (item.editions.isNotEmpty) {
    return [for (final edition in item.editions) edition.toJson()];
  }
  return [
    {
      'id': '${item.id}-edition-01',
      'title': item.editionTitle ?? item.title,
      if (item.physicalFormat != null) 'format': item.physicalFormat,
      if (item.publisher != null) 'publisher': item.publisher,
      if (item.barcode != null) 'barcode': item.barcode,
      if (item.payload['country'] != null) 'region': item.payload['country'],
      if (item.payload['language'] != null)
        'language': item.payload['language'],
      if (item.releaseDate != null)
        'release_date': item.releaseDate!.toIso8601String(),
    },
  ];
}

CatalogItem enrichSeedItem(CatalogItem item) {
  final payload = Map<String, dynamic>.from(item.toSyncPayload());
  payload.putIfAbsent('id', () => item.id);

  _normalizeNestedPayload(payload, 'video', const <String>[
    'runtime_minutes',
    'color',
    'nr_discs',
    'screen_ratio',
    'audio_tracks',
    'subtitles',
    'layers',
  ]);
  _normalizeNestedPayload(payload, 'music', const <String>[
    'track_count',
    'catalog_number',
    'release_status',
    'original_release_date',
    'recording_date',
    'studio',
    'is_live',
    'tracks',
    'discs',
  ]);
  _normalizeNestedPayload(payload, 'game', const <String>['platforms']);

  payload.putIfAbsent('localized_title', () => item.displayTitle ?? item.title);
  payload.putIfAbsent('original_title', () => item.originalTitle ?? item.title);
  payload.putIfAbsent(
    'title_extension',
    () => item.releaseYear != null ? '${item.releaseYear}' : item.itemNumber,
  );
  final seriesMap = payload['series'] is Map ? payload['series'] as Map : null;
  final seriesTitle = seriesMap?['series_title'] as String?;
  final pubMap = item.payload['publishing'] as Map?;
  payload.putIfAbsent(
    'search_aliases',
    () => <String?>[
      item.title,
      item.displayTitle,
      item.originalTitle,
      seriesTitle,
    ].whereType<String>().toList(growable: false),
  );
  payload.putIfAbsent('cover_image_data', () => seedCoverImageData);
  final placeholderCoverUrl =
      'https://placehold.co/600x900/png?text=${Uri.encodeComponent(item.title)}';
  payload.putIfAbsent(
      'cover_image_url', () => item.coverImageUrl ?? placeholderCoverUrl);
  payload.putIfAbsent(
    'thumbnail_image_url',
    () => item.thumbnailImageUrl ?? payload['cover_image_url'],
  );
  payload.putIfAbsent(
    'trailer_urls',
    () => <TrailerLink>[
      TrailerLink(
        url: 'https://example.com/${item.kind}/${item.id}/trailer',
        title: '${item.title} trailer',
        source: 'seed',
      ),
    ].map((link) => link.toJson()).toList(growable: false),
  );

  if (pubMap != null || _shouldSeedPublishingDetails(item.kind)) {
    payload.putIfAbsent(
      'page_count',
      () => _seedPageCountForKind(item.kind),
    );
    payload.putIfAbsent(
      'cover_price_cents',
      () => _seedCoverPriceForKind(item.kind),
    );
    payload.putIfAbsent('currency', () => 'USD');
    payload.putIfAbsent('imprint', () => item.publisher);
    payload.putIfAbsent('subtitle', () => '${item.title} seed edition');
    payload.putIfAbsent('series_group', () => seriesTitle);
    payload.putIfAbsent('publication_place', () => 'US');
    payload.putIfAbsent('original_country', () => 'US');
    payload.putIfAbsent(
        'original_language', () => _seedOriginalLanguage(item.kind));
    payload.putIfAbsent(
      'original_publication_date',
      () => item.releaseDate?.toUtc().toIso8601String(),
    );
    payload.putIfAbsent('original_publication_place', () => 'US');
    payload.putIfAbsent('original_publisher', () => item.publisher);
    payload.putIfAbsent('paper_type', () => _seedPaperType(item.kind));
    payload.putIfAbsent('printed_by', () => 'Collectarr Seeds');
    payload.putIfAbsent(
      'subjects',
      () => <String>[
        item.kind,
        if (seriesTitle != null) seriesTitle,
      ],
    );
    payload.putIfAbsent(
      'dust_jacket_condition',
      () => item.kind == 'book' ? 'very good' : null,
    );
    payload.putIfAbsent('dust_jacket', () => item.kind == 'book');
    payload.putIfAbsent('audiobook_abridged', () => false);
    payload.putIfAbsent('first_edition', () => true);
  }

  if (_isVideoKind(item.kind)) {
    payload.putIfAbsent(
        'runtime_minutes', () => _seedRuntimeMinutes(item.kind));
    payload.putIfAbsent('color', () => 'Color');
    payload.putIfAbsent('nr_discs', () => 1);
    payload.putIfAbsent('screen_ratio', () => '16:9');
    payload.putIfAbsent('audio_tracks', () => 'English 5.1');
    payload.putIfAbsent('subtitles', () => 'English');
    payload.putIfAbsent('layers', () => 'single');
    payload.putIfAbsent('age_rating', () => _seedAgeRating(item.kind));
    payload.putIfAbsent(
        'audience_rating', () => _seedAudienceRating(item.kind));
  }

  if (item.kind == 'music') {
    final musicMap = payload['music'] is Map
        ? payload['music'] as Map
        : const <String, dynamic>{};
    final musicTracks = musicMap['tracks'];
    payload.putIfAbsent(
      'track_count',
      () =>
          musicMap['track_count'] ??
          (musicTracks is List && musicTracks.isNotEmpty
              ? musicTracks.length
              : 10),
    );
    payload.putIfAbsent('catalog_number', () => 'SEED-${item.id}');
    payload.putIfAbsent(
      'original_release_date',
      () => item.releaseDate?.toUtc().toIso8601String(),
    );
    payload.putIfAbsent(
      'recording_date',
      () => item.releaseDate?.toUtc().toIso8601String(),
    );
    payload.putIfAbsent('studio', () => item.publisher);
    payload.putIfAbsent('rpm', () => '33 1/3');
    payload.putIfAbsent('spars', () => 'none');
    payload.putIfAbsent('sound_type', () => 'stereo');
    payload.putIfAbsent('vinyl_color', () => 'black');
    payload.putIfAbsent('vinyl_weight', () => '180g');
    payload.putIfAbsent('media_condition', () => 'excellent');
    payload.putIfAbsent('instrument', () => 'ensemble');
    payload.putIfAbsent('is_live', () => false);
    payload.putIfAbsent('composition', () => item.title);
  }

  if (item.kind == 'game') {
    payload.putIfAbsent('platforms', () => <String>['PC', 'Console']);
    payload.putIfAbsent('toy_subtype', () => 'video game');
    payload.putIfAbsent('toy_type', () => 'software');
  }

  if (item.kind == 'boardgame') {
    payload.putIfAbsent('bgg_rank', () => 1);
    payload.putIfAbsent('bgg_rating', () => 7.5);
    payload.putIfAbsent('play_count', () => 5);
    payload.putIfAbsent(
        'last_played', () => item.releaseDate?.toUtc().toIso8601String());
    payload.putIfAbsent('favorite_player_count', () => 4);
    payload.putIfAbsent(
      'player_stats',
      () => <Map<String, dynamic>>[
        {'players': 2, 'rating': 7.0},
      ],
    );
  }

  return CatalogItem.fromJson(payload);
}

/// Verifies that the checked-in seed data is useful to the UI and to the
/// kind-specific behavior, not merely structurally valid JSON.
///
/// This runs after [enrichSeedItem], so defaults added at the serialization
/// boundary are tested as well. Keep the rules here intentionally limited to
/// fields that every fixture of a given kind should exercise.
void validateSeedCatalogQuality(Iterable<CatalogItem> items) {
  final issues = <String>[];
  for (final item in items) {
    final prefix = '${item.kind}/${item.id}';
    final payload = item.payload;

    _requireText(issues, prefix, 'localized_title', item.localizedTitle);
    _requireText(issues, prefix, 'original_title', item.originalTitle);
    _requireText(issues, prefix, 'synopsis', item.synopsis);
    _requireText(issues, prefix, 'cover_image_data', item.coverImageData);
    _requireText(issues, prefix, 'cover_image_url', item.coverImageUrl);
    _requireText(issues, prefix, 'thumbnail_image_url', item.thumbnailImageUrl);
    if (item.releaseYear == null || item.releaseYear! <= 0) {
      issues.add('$prefix: release_year must be a positive integer');
    }
    if (item.releaseDate == null) {
      issues.add('$prefix: release_date is required');
    }
    _requireSeedBarcode(issues, prefix, item.kind, item.barcode);
    _requireTextList(
        issues, prefix, 'search_aliases', payload['search_aliases']);
    _requireTextList(issues, prefix, 'genres', payload['genres']);

    if (item.trailerUrls.isEmpty) {
      issues.add('$prefix: trailer_urls must contain at least one link');
    } else {
      for (var index = 0; index < item.trailerUrls.length; index++) {
        if (item.trailerUrls[index].url.trim().isEmpty) {
          issues.add('$prefix: trailer_urls[$index].url is empty');
        }
      }
    }

    switch (item.kind) {
      case 'book':
        _requirePublishingQuality(issues, prefix, item);
        _requireCreatorList(issues, prefix, payload['creators']);
      case 'comic':
      case 'manga':
        _requirePublishingQuality(issues, prefix, item);
        _requireText(issues, prefix, 'publisher', item.publisher);
      case 'movie':
      case 'tv':
      case 'anime':
        _requirePositiveInt(
            issues, prefix, 'runtime_minutes', payload['runtime_minutes']);
        _requirePositiveInt(issues, prefix, 'nr_discs', payload['nr_discs']);
        _requireText(issues, prefix, 'audio_tracks', payload['audio_tracks']);
        _requireText(issues, prefix, 'subtitles', payload['subtitles']);
        _requireText(issues, prefix, 'age_rating', payload['age_rating']);
      case 'music':
        _requirePositiveInt(
            issues, prefix, 'track_count', payload['track_count']);
        _requireTrackList(issues, prefix, payload['tracks']);
        final tracks = payload['tracks'];
        final trackCount = payload['track_count'];
        if (tracks is List &&
            trackCount is int &&
            tracks.length != trackCount) {
          issues.add(
            '$prefix: track_count must equal the number of track objects',
          );
        }
        _requireText(
            issues, prefix, 'catalog_number', payload['catalog_number']);
      case 'game':
        _requireTextList(issues, prefix, 'platforms', payload['platforms']);
      case 'boardgame':
        _requirePositiveInt(issues, prefix, 'bgg_rank', payload['bgg_rank']);
        _requirePositiveNumber(
            issues, prefix, 'bgg_rating', payload['bgg_rating']);
        _requireCreatorList(issues, prefix, payload['creators']);
        _requirePlayerStats(issues, prefix, payload['player_stats']);
    }
    _validateTypedGraph(issues, prefix, item);
  }

  if (issues.isNotEmpty) {
    throw StateError(
      'Seed catalog quality validation failed:\n'
      '${issues.map((issue) => '- $issue').join('\n')}',
    );
  }
}

/// Checks the kind-owned graph payload before it reaches the persistence
/// codecs. A non-empty catalog row is not enough for the dev fixture: every
/// kind must exercise its own child graph and keep parent references intact.
void _validateTypedGraph(
  List<String> issues,
  String prefix,
  CatalogItem item,
) {
  final payload = item.payload;
  switch (item.kind) {
    case 'comic':
      final issuesPayload = _requireObjectList(
        issues,
        prefix,
        'issues',
        payload['issues'],
      );
      _validateChildren(
        issues,
        prefix,
        'issues',
        issuesPayload,
        kind: 'comic',
        parentId: item.id,
        parentKey: 'work_id',
        titleKey: 'title',
      );
      for (var index = 0; index < issuesPayload.length; index++) {
        final issue = issuesPayload[index];
        _requireText(
          issues,
          prefix,
          'issues[$index].issue_number',
          issue['issue_number'] ?? item.itemNumber,
        );
      }
    case 'manga':
      final chapters = _requireObjectList(
        issues,
        prefix,
        'chapters',
        payload['chapters'],
      );
      _validateChildren(
        issues,
        prefix,
        'chapters',
        chapters,
        kind: 'manga',
        parentId: item.id,
        parentKey: 'series_id',
        titleKey: 'title',
      );
      for (var index = 0; index < chapters.length; index++) {
        _requirePositiveNumber(
          issues,
          prefix,
          'chapters[$index].chapter_number',
          chapters[index]['chapter_number'],
        );
      }
    case 'book':
      final editions = _requireObjectList(
        issues,
        prefix,
        'editions',
        payload['editions'],
      );
      _validateChildren(
        issues,
        prefix,
        'editions',
        editions,
        kind: 'book',
        parentId: item.id,
        parentKey: 'work_id',
        titleKey: 'display_title',
      );
      for (var index = 0; index < editions.length; index++) {
        _requireText(
            issues, prefix, 'editions[$index].isbn', editions[index]['isbn']);
        _requireText(issues, prefix, 'editions[$index].publisher',
            editions[index]['publisher']);
      }
    case 'game':
      final releases = _requireObjectList(
        issues,
        prefix,
        'releases',
        payload['releases'],
      );
      _validateChildren(
        issues,
        prefix,
        'releases',
        releases,
        kind: 'game',
        parentId: item.id,
        parentKey: 'work_id',
        titleKey: 'release_title',
      );
      for (var index = 0; index < releases.length; index++) {
        _requireText(issues, prefix, 'releases[$index].platform',
            releases[index]['platform']);
      }
    case 'boardgame':
      final editions = _requireObjectList(
        issues,
        prefix,
        'editions',
        payload['editions'],
      );
      _validateChildren(
        issues,
        prefix,
        'editions',
        editions,
        kind: 'boardgame',
        parentId: item.id,
        parentKey: 'work_id',
        titleKey: 'edition_title',
      );
      for (var index = 0; index < editions.length; index++) {
        final edition = editions[index];
        _requirePositiveInt(issues, prefix, 'editions[$index].min_players',
            edition['min_players']);
        _requirePositiveInt(issues, prefix, 'editions[$index].max_players',
            edition['max_players']);
        _requirePositiveInt(
            issues,
            prefix,
            'editions[$index].playing_time_minutes',
            edition['playing_time_minutes']);
      }
    case 'movie':
      _validateVideoReleases(issues, prefix, item, payload['releases']);
    case 'tv':
      final seasons = _requireObjectList(
        issues,
        prefix,
        'seasons',
        payload['seasons'],
      );
      _validateChildren(
        issues,
        prefix,
        'seasons',
        seasons,
        parentId: item.id,
        parentKey: 'series_id',
        titleKey: 'title',
      );
      for (var index = 0; index < seasons.length; index++) {
        final season = seasons[index];
        _requirePositiveInt(issues, prefix, 'seasons[$index].season_number',
            season['season_number']);
        final episodes = _requireObjectList(
          issues,
          prefix,
          'seasons[$index].episodes',
          season['episodes'],
        );
        for (var episodeIndex = 0;
            episodeIndex < episodes.length;
            episodeIndex++) {
          final episode = episodes[episodeIndex];
          _requireText(issues, prefix,
              'seasons[$index].episodes[$episodeIndex].id', episode['id']);
          _requireText(
              issues,
              prefix,
              'seasons[$index].episodes[$episodeIndex].season_id',
              episode['season_id']);
          if (episode['season_id']?.toString() != season['id']?.toString()) {
            issues.add(
                '$prefix: seasons[$index].episodes[$episodeIndex].season_id must reference the parent season');
          }
          _requireText(
              issues,
              prefix,
              'seasons[$index].episodes[$episodeIndex].episode_title',
              episode['episode_title']);
          _requirePositiveInt(
              issues,
              prefix,
              'seasons[$index].episodes[$episodeIndex].episode_number',
              episode['episode_number']);
        }
      }
      _validateVideoReleases(issues, prefix, item, payload['releases']);
    case 'anime':
      final episodes = _requireObjectList(
        issues,
        prefix,
        'episodes',
        payload['episodes'],
      );
      _validateChildren(
        issues,
        prefix,
        'episodes',
        episodes,
        kind: 'anime',
        parentId: item.id,
        parentKey: 'series_id',
        titleKey: 'title',
      );
      for (var index = 0; index < episodes.length; index++) {
        _requirePositiveInt(issues, prefix, 'episodes[$index].episode_number',
            episodes[index]['episode_number']);
      }
      final releases = _requireObjectList(
        issues,
        prefix,
        'releases',
        payload['releases'],
      );
      _validateChildren(
        issues,
        prefix,
        'releases',
        releases,
        kind: 'anime',
        parentId: item.id,
        parentKey: 'series_id',
        titleKey: 'release_title',
      );
    case 'music':
      final media = _requireObjectList(
        issues,
        prefix,
        'media',
        payload['media'],
      );
      _validateChildren(
        issues,
        prefix,
        'media',
        media,
        kind: 'music',
        parentId: item.id,
        parentKey: 'release_id',
        titleKey: 'title',
      );
      for (var index = 0; index < media.length; index++) {
        final tracks = _requireObjectList(
          issues,
          prefix,
          'media[$index].tracks',
          media[index]['tracks'],
        );
        for (var trackIndex = 0; trackIndex < tracks.length; trackIndex++) {
          final track = tracks[trackIndex];
          _requireText(issues, prefix, 'media[$index].tracks[$trackIndex].id',
              track['id']);
          _requireText(issues, prefix,
              'media[$index].tracks[$trackIndex].media_id', track['media_id']);
          if (track['media_id']?.toString() != media[index]['id']?.toString()) {
            issues.add(
                '$prefix: media[$index].tracks[$trackIndex].media_id must reference the parent media');
          }
          _requireText(issues, prefix,
              'media[$index].tracks[$trackIndex].title', track['title']);
          _requirePositiveNumber(issues, prefix,
              'media[$index].tracks[$trackIndex].position', track['position']);
          _requirePositiveNumber(
              issues,
              prefix,
              'media[$index].tracks[$trackIndex].duration_ms',
              track['duration_ms']);
        }
      }
  }
}

List<Map<String, dynamic>> _requireObjectList(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  if (value is! List || value.isEmpty) {
    issues.add('$prefix: $field must contain at least one object');
    return const <Map<String, dynamic>>[];
  }
  final result = <Map<String, dynamic>>[];
  for (var index = 0; index < value.length; index++) {
    final entry = value[index];
    if (entry is! Map) {
      issues.add('$prefix: $field[$index] must be an object');
      continue;
    }
    result.add(Map<String, dynamic>.from(entry));
  }
  return result;
}

void _validateChildren(
  List<String> issues,
  String prefix,
  String field,
  List<Map<String, dynamic>> children, {
  String? kind,
  required String parentId,
  required String parentKey,
  required String titleKey,
}) {
  final ids = <String>{};
  for (var index = 0; index < children.length; index++) {
    final child = children[index];
    final childPrefix = '$field[$index]';
    final id = child['id']?.toString().trim() ?? '';
    _requireText(issues, prefix, '$childPrefix.id', child['id']);
    if (id.isNotEmpty && !ids.add(id)) {
      issues.add('$prefix: duplicate $field id $id');
    }
    if (kind != null && child['kind']?.toString() != kind) {
      issues.add('$prefix: $childPrefix.kind must be $kind');
    }
    if (child[parentKey]?.toString() != parentId) {
      issues.add('$prefix: $childPrefix.$parentKey must reference $parentId');
    }
    _requireText(issues, prefix, '$childPrefix.$titleKey', child[titleKey]);
  }
}

void _validateVideoReleases(
  List<String> issues,
  String prefix,
  CatalogItem item,
  Object? rawReleases,
) {
  final releases = _requireObjectList(issues, prefix, 'releases', rawReleases);
  final parentKey =
      item.kind == 'tv' || item.kind == 'anime' ? 'series_id' : 'work_id';
  final titleKey = item.kind == 'tv' ? 'title' : 'release_title';
  _validateChildren(
    issues,
    prefix,
    'releases',
    releases,
    kind: item.kind,
    parentId: item.id,
    parentKey: parentKey,
    titleKey: titleKey,
  );
  for (var index = 0; index < releases.length; index++) {
    final media = _requireObjectList(
      issues,
      prefix,
      'releases[$index].media',
      releases[index]['media'],
    );
    for (var mediaIndex = 0; mediaIndex < media.length; mediaIndex++) {
      final child = media[mediaIndex];
      _requireText(issues, prefix, 'releases[$index].media[$mediaIndex].id',
          child['id']);
      if (child['release_id']?.toString() !=
          releases[index]['id']?.toString()) {
        issues.add(
            '$prefix: releases[$index].media[$mediaIndex].release_id must reference the parent release');
      }
      _requirePositiveInt(
          issues,
          prefix,
          'releases[$index].media[$mediaIndex].media_number',
          child['media_number']);
      _requireText(
          issues,
          prefix,
          'releases[$index].media[$mediaIndex].media_type',
          child['media_type']);
    }
  }
}

void _requireSeedBarcode(
  List<String> issues,
  String prefix,
  String kind,
  String? barcode,
) {
  if (barcode == null || barcode.trim().isEmpty) {
    issues.add('$prefix: barcode is required for the physical seed fixture');
    return;
  }
  final value = barcode.trim();
  final isComicSupplement = kind == 'comic' &&
      value.length == 17 &&
      isValidRetailBarcode(value.substring(0, 12)) &&
      RegExp(r'^\d{5}$').hasMatch(value.substring(12));
  if (!isValidRetailBarcode(value) &&
      !isValidIsbn(value) &&
      !isComicSupplement) {
    issues.add('$prefix: barcode has an invalid checksum or format');
  }
}

void validateSeedOwnedQuality(Iterable<OwnedItem> items) {
  final issues = <String>[];
  for (final item in items) {
    final prefix = '${item.catalogRef.kind}/${item.id}';
    _requireText(issues, prefix, 'condition', item.condition);
    _requireText(issues, prefix, 'personal_notes', item.personalNotes);
    _requireText(issues, prefix, 'collection_status', item.collectionStatus);
    if (item.quantity < 1) {
      issues.add('$prefix: quantity must be at least 1');
    }
    if (item.purchaseDate == null) {
      issues.add('$prefix: purchase_date is required');
    }
    if (item.pricePaidCents == null || item.pricePaidCents! <= 0) {
      issues.add('$prefix: price_paid_cents must be positive');
    }
    if (item.currency?.trim().isEmpty != false) {
      issues.add('$prefix: currency is required when a purchase price exists');
    }
    _validateSeedOwnedDetails(issues, prefix, item);
  }
  _throwSeedQualityIssues('owned', issues);
}

/// Ensures every development copy exercises the complete typed details
/// boundary for its owning kind. A common Owned row with an arbitrary details
/// payload would make the fixture look populated while leaving the kind-owned
/// table empty or incorrectly decoded.
void _validateSeedOwnedDetails(
  List<String> issues,
  String prefix,
  OwnedItem item,
) {
  switch (item.catalogRef.kind) {
    case 'comic':
      final details = item.details;
      if (details is! ComicOwnedDetails) {
        issues.add('$prefix: expected ComicOwnedDetails');
        return;
      }
      _requireText(
          issues, prefix, 'comic.raw_or_slabbed', details.rawOrSlabbed);
      _requireText(issues, prefix, 'comic.page_quality', details.pageQuality);
      if (details.lastBagBoardDate == null) {
        issues.add('$prefix: comic.last_bag_board_date is required');
      }
    case 'manga':
      final details = item.details;
      if (details is! MangaOwnedDetails) {
        issues.add('$prefix: expected MangaOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'manga.printing', details.printing);
      _requireText(
          issues, prefix, 'manga.localized_edition', details.localizedEdition);
      if (!details.dustJacketPresent) {
        issues.add('$prefix: manga.dust_jacket_present must be true');
      }
    case 'book':
      final details = item.details;
      if (details is! BookOwnedDetails) {
        issues.add('$prefix: expected BookOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'book.signed_by', details.signedBy);
      if (!details.dustJacketPresent) {
        issues.add('$prefix: book.dust_jacket_present must be true');
      }
    case 'game':
      final details = item.details;
      if (details is! GameOwnedDetails) {
        issues.add('$prefix: expected GameOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'game.completeness', details.completeness);
      _requireText(issues, prefix, 'game.core_region', details.coreRegion);
      _requireText(
          issues, prefix, 'game.pricecharting_id', details.priceChartingId);
      if (details.hasBox != true || details.hasManual != true) {
        issues.add('$prefix: game copy must include box and manual');
      }
    case 'boardgame':
      final details = item.details;
      if (details is! BoardgameOwnedDetails) {
        issues.add('$prefix: expected BoardgameOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'boardgame.edition_language',
          details.editionLanguage);
      _requireText(
          issues, prefix, 'boardgame.edition_region', details.editionRegion);
      _requireText(issues, prefix, 'boardgame.component_condition',
          details.componentCondition);
      _requireText(issues, prefix, 'boardgame.component_completeness',
          details.componentCompleteness);
    case 'movie':
      final details = item.details;
      if (details is! MovieOwnedDetails) {
        issues.add('$prefix: expected MovieOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'movie.region', details.region);
      _requireText(issues, prefix, 'movie.packaging', details.packaging);
      _requireText(issues, prefix, 'movie.distributor', details.distributor);
    case 'tv':
      final details = item.details;
      if (details is! TvOwnedDetails) {
        issues.add('$prefix: expected TvOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'tv.region', details.region);
      _requireText(issues, prefix, 'tv.packaging', details.packaging);
      _requireText(issues, prefix, 'tv.distributor', details.distributor);
    case 'anime':
      final details = item.details;
      if (details is! AnimeOwnedDetails) {
        issues.add('$prefix: expected AnimeOwnedDetails');
        return;
      }
      _requireText(issues, prefix, 'anime.region', details.region);
      _requireText(issues, prefix, 'anime.packaging', details.packaging);
      _requireText(issues, prefix, 'anime.distributor', details.distributor);
    case 'music':
      final details = item.details;
      if (details is! MusicOwnedDetails) {
        issues.add('$prefix: expected MusicOwnedDetails');
        return;
      }
      _requireText(
          issues, prefix, 'music.storage_device', details.storageDevice);
      _requireText(issues, prefix, 'music.storage_slot', details.storageSlot);
      if (details.matrixRunouts.isEmpty) {
        issues.add('$prefix: music.matrix_runouts must not be empty');
      }
      for (var index = 0; index < details.matrixRunouts.length; index++) {
        final runout = details.matrixRunouts[index];
        _requireText(
            issues, prefix, 'music.matrix_runouts[$index].side', runout.side);
        _requireText(issues, prefix, 'music.matrix_runouts[$index].runout_text',
            runout.runoutText);
        if (runout.mediumIndex < 1) {
          issues.add(
              '$prefix: music.matrix_runouts[$index].medium_index must be positive');
        }
      }
    default:
      issues.add('$prefix: no typed owned details validator exists');
  }
}

void validateSeedTrackingQuality(Iterable<TrackingEntry> entries) {
  final issues = <String>[];
  for (final entry in entries) {
    final prefix = '${entry.catalogRef.kind}/${entry.id}';
    if (entry.status == null) {
      issues.add('$prefix: status is required');
    }
    if (entry.sourceType == null) {
      issues.add('$prefix: source_type is required');
    }
    if (entry.rating != null && (entry.rating! < 0 || entry.rating! > 10)) {
      issues.add('$prefix: rating must be between 0 and 10');
    }
    if (entry.status == MediaTrackingStatus.completed &&
        entry.finishedAt == null) {
      issues.add('$prefix: completed tracking must have finished_at');
    }
    final current = entry.progressCurrent;
    final total = entry.progressTotal;
    if (current != null && current < 0) {
      issues.add('$prefix: progress_current cannot be negative');
    }
    if (total != null && total <= 0) {
      issues.add('$prefix: progress_total must be positive');
    }
    if (current != null && total != null && current > total) {
      issues.add('$prefix: progress_current cannot exceed progress_total');
    }
  }
  _throwSeedQualityIssues('tracking', issues);
}

void _requirePublishingQuality(
  List<String> issues,
  String prefix,
  CatalogItem item,
) {
  _requireText(issues, prefix, 'publisher', item.publisher);
  _requirePositiveInt(issues, prefix, 'page_count', item.payload['page_count']);
  _requirePositiveInt(
      issues, prefix, 'cover_price_cents', item.payload['cover_price_cents']);
  _requireText(issues, prefix, 'currency', item.payload['currency']);
}

void _requireText(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  if (value is! String || value.trim().isEmpty) {
    issues.add('$prefix: $field must be a non-empty string');
  }
}

void _requireTextList(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  if (value is! List ||
      value.isEmpty ||
      value.any((item) => item is! String || item.trim().isEmpty)) {
    issues.add('$prefix: $field must contain non-empty strings');
  }
}

void _requirePositiveInt(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  if (value is! int || value <= 0) {
    issues.add('$prefix: $field must be a positive integer');
  }
}

void _requirePositiveNumber(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  final number = value is num ? value : num.tryParse(value?.toString() ?? '');
  if (number == null || number <= 0) {
    issues.add('$prefix: $field must be a positive number');
  }
}

void _requireTrackList(List<String> issues, String prefix, Object? value) {
  if (value is! List || value.isEmpty) {
    issues.add('$prefix: tracks must contain at least one track');
    return;
  }
  for (var index = 0; index < value.length; index++) {
    final track = value[index];
    if (track is! Map) {
      issues.add('$prefix: tracks[$index] must be an object');
      continue;
    }
    _requireText(issues, prefix, 'tracks[$index].title', track['title']);
    _requireText(
        issues, prefix, 'tracks[$index].track_number', track['track_number']);
    final duration = track['duration_seconds'] ?? track['duration'];
    if (duration == null || (duration is String && duration.trim().isEmpty)) {
      issues.add('$prefix: tracks[$index].duration is required');
    }
  }
}

void _requireCreatorList(List<String> issues, String prefix, Object? value) {
  if (value is! List || value.isEmpty) {
    issues.add('$prefix: creators must contain at least one creator');
    return;
  }
  for (var index = 0; index < value.length; index++) {
    final creator = value[index];
    final name = creator is Map ? creator['name'] : null;
    if (name is! String || name.trim().isEmpty) {
      issues.add('$prefix: creators[$index].name is required');
    }
  }
}

void _requirePlayerStats(List<String> issues, String prefix, Object? value) {
  if (value is! List || value.isEmpty) {
    issues.add('$prefix: player_stats must contain at least one entry');
    return;
  }
  for (var index = 0; index < value.length; index++) {
    final stats = value[index];
    final players = stats is Map ? stats['players'] : null;
    if (players is! int || players <= 0) {
      issues.add('$prefix: player_stats[$index] must define positive players');
    }
  }
}

void _throwSeedQualityIssues(String domain, List<String> issues) {
  if (issues.isEmpty) return;
  throw StateError(
    'Seed $domain quality validation failed:\n'
    '${issues.map((issue) => '- $issue').join('\n')}',
  );
}

void _normalizeNestedPayload(
  Map<String, dynamic> payload,
  String key,
  List<String> mirroredKeys,
) {
  final normalized = _asPayloadMap(payload[key]);
  if (normalized == null) return;
  payload[key] = normalized;
  for (final field in mirroredKeys) {
    payload.putIfAbsent(field, () => normalized[field]);
  }
}

Map<String, dynamic>? _asPayloadMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value == null) return null;
  try {
    final dynamic encoded = (value as dynamic).toJson();
    if (encoded is Map) return Map<String, dynamic>.from(encoded);
  } on Object {
    // A provider-shaped value that cannot be encoded is left untouched.
  }
  return null;
}

bool _isVideoKind(String kind) =>
    kind == 'movie' || kind == 'tv' || kind == 'anime';

bool _shouldSeedPublishingDetails(String kind) =>
    kind == 'book' || kind == 'comic' || kind == 'manga' || _isVideoKind(kind);

String? _seedPaperType(String kind) {
  if (kind == 'book' || kind == 'comic' || kind == 'manga') {
    return 'paperback';
  }
  return null;
}

String? _seedOriginalLanguage(String kind) {
  return switch (kind) {
    'music' => 'en',
    'game' => 'en',
    'boardgame' => 'en',
    _ => 'en',
  };
}

int _seedPageCountForKind(String kind) {
  return switch (kind) {
    'book' => 560,
    'comic' => 32,
    'manga' => 192,
    _ => 1,
  };
}

int _seedCoverPriceForKind(String kind) {
  return switch (kind) {
    'book' => 2499,
    'comic' => 499,
    'manga' => 799,
    'music' => 1999,
    'game' => 5999,
    'boardgame' => 4499,
    _ => 1999,
  };
}

int _seedRuntimeMinutes(String kind) {
  return switch (kind) {
    'movie' => 120,
    'tv' => 42,
    'anime' => 24,
    _ => 0,
  };
}

String _seedAgeRating(String kind) {
  return switch (kind) {
    'tv' => 'TV-MA',
    'anime' => 'TV-14',
    'movie' => 'PG-13',
    _ => 'PG',
  };
}

String _seedAudienceRating(String kind) {
  return switch (kind) {
    'movie' => 'PG-13',
    'tv' => 'TV-MA',
    'anime' => 'TV-14',
    'boardgame' => '10+',
    _ => 'All',
  };
}
