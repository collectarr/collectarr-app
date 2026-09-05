import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/barcode/barcode_checksum.dart';

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
  return CatalogItem.fromJson({
    'id': item.id,
    ...item.toSyncPayload(),
    ...additions,
  });
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

  // Older seed payloads used a flat string for series. The typed catalog
  // contract stores series as an object, and serial-authority discovery reads
  // that object directly. Normalize the legacy shape while enriching data so
  // a forced re-seed cannot reintroduce an invalid payload.
  final rawSeries = payload['series'];
  if (rawSeries is String && rawSeries.trim().isNotEmpty) {
    payload['series'] = <String, dynamic>{'series_title': rawSeries.trim()};
  }
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
/// kind-specific migration work, not merely structurally valid JSON.
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
  }

  if (issues.isNotEmpty) {
    throw StateError(
      'Seed catalog quality validation failed:\n'
      '${issues.map((issue) => '- $issue').join('\n')}',
    );
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
  }
  _throwSeedQualityIssues('owned', issues);
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
  if (value is! num || value <= 0) {
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
