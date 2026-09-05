import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

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
