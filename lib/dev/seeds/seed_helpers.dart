import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

const String seedCoverImageData =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+XbL0AAAAASUVORK5CYII=';

final Uint8List seedTinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Zx1EAAAAASUVORK5CYII=',
);

void seedNoopCatalogPayloadEnricher(
  CatalogItemDto item,
  Map<String, dynamic> payload,
) {}

String seedOrdinal2(int value) => value.toString().padLeft(2, '0');

Iterable<String> seedIds(CatalogMediaKind kind, int count) sync* {
  for (var i = 1; i <= count; i++) {
    yield 'seed-${kind.apiValue}-${seedOrdinal2(i)}';
  }
}

CatalogEntityRef seedCatalogRef(String itemId) {
  final kind = itemId.startsWith('seed-') ? itemId.split('-')[1] : 'unknown';
  return CatalogEntityRef(
    kind: catalogMediaKindFromApiValue(kind),
    entityType: const CatalogEntityTypeId('work'),
    id: itemId,
  );
}

OwnedItemRef seedOwnedRef(CatalogMediaKind kind, String itemId) {
  return OwnedItemRef(kind: kind, id: OwnedItemId(itemId));
}

OwnedItemRef seedOwnedRefFromId(String itemId) {
  final parts = itemId.split('-');
  final kindValue = parts.length > 2 && parts[2] == 'seed'
      ? (parts.length > 3 ? parts[3] : null)
      : parts[2];
  final normalizedKind = kindValue == 'bg' ? 'boardgame' : kindValue;
  return seedOwnedRef(
    catalogMediaKindFromApiValue(normalizedKind),
    itemId,
  );
}

/// Rebuilds a transport fixture while preserving its common catalog fields.
/// Kind seeders use this only to add their own Core graph fields.
CatalogItemDto withSeedPayload(
  CatalogItemDto item,
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
List<Map<String, dynamic>> seedEditionPayloads(CatalogItemDto item) {
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

CatalogItemDto enrichSeedItem(
  CatalogItemDto item, {
  required DevSeedCatalogDefaults defaults,
}) {
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
    () => <TrailerLinkDto>[
      TrailerLinkDto(
        url: 'https://example.com/${item.kind}/${item.id}/trailer',
        title: '${item.title} trailer',
        source: 'seed',
      ),
    ].map((link) => link.toJson()).toList(growable: false),
  );

  if (pubMap != null || defaults.includePublishingDetails) {
    payload.putIfAbsent(
      'page_count',
      () => defaults.pageCount,
    );
    payload.putIfAbsent(
      'cover_price_cents',
      () => defaults.coverPriceCents,
    );
    payload.putIfAbsent('currency', () => 'USD');
    payload.putIfAbsent('imprint', () => item.publisher);
    payload.putIfAbsent('subtitle', () => '${item.title} seed edition');
    payload.putIfAbsent('series_group', () => seriesTitle);
    payload.putIfAbsent('publication_place', () => 'US');
    payload.putIfAbsent('original_country', () => 'US');
    payload.putIfAbsent('original_language', () => defaults.originalLanguage);
    payload.putIfAbsent(
      'original_publication_date',
      () => item.releaseDate?.toUtc().toIso8601String(),
    );
    payload.putIfAbsent('original_publication_place', () => 'US');
    payload.putIfAbsent('original_publisher', () => item.publisher);
    payload.putIfAbsent('paper_type', () => defaults.paperType);
    payload.putIfAbsent('printed_by', () => 'Collectarr Seeds');
    payload.putIfAbsent(
      'subjects',
      () => <String>[
        item.kind,
        if (seriesTitle != null) seriesTitle,
      ],
    );
    payload.putIfAbsent('audiobook_abridged', () => false);
    payload.putIfAbsent('first_edition', () => true);
  }

  if (defaults.runtimeMinutes > 0) {
    payload.putIfAbsent('runtime_minutes', () => defaults.runtimeMinutes);
    payload.putIfAbsent('color', () => 'Color');
    payload.putIfAbsent('nr_discs', () => 1);
    payload.putIfAbsent('screen_ratio', () => '16:9');
    payload.putIfAbsent('audio_tracks', () => 'English 5.1');
    payload.putIfAbsent('subtitles', () => 'English');
    payload.putIfAbsent('layers', () => 'single');
    payload.putIfAbsent('age_rating', () => defaults.ageRating);
    payload.putIfAbsent('audience_rating', () => defaults.audienceRating);
  }

  defaults.enrichPayload(item, payload);

  return CatalogItemDto.fromJson(payload);
}

/// Verifies that the checked-in seed data is useful to the UI and to the
/// kind-specific behavior, not merely structurally valid JSON.
///
/// This runs after [enrichSeedItem], so defaults added at the serialization
/// boundary are tested as well. Keep the rules here intentionally limited to
/// fields that every fixture of a given kind should exercise.
void validateSeedCatalogQuality(
  Iterable<CatalogItemDto> items, {
  Map<CatalogMediaKind, DevSeedCatalogQualityValidator> validators = const {},
  Map<CatalogMediaKind, DevSeedCatalogGraphValidator> graphValidators =
      const {},
  Map<CatalogMediaKind, DevSeedCatalogBarcodeValidator> barcodeValidators =
      const {},
}) {
  final issues = <String>[];
  for (final item in items) {
    final prefix = '${item.kind}/${item.id}';
    final mediaKind = catalogMediaKindFromApiValue(item.kind);
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
    final barcodeValidator = barcodeValidators[mediaKind];
    if (barcodeValidator == null) {
      seedValidateStandardBarcode(issues, prefix, item.barcode);
    } else {
      barcodeValidator(issues, prefix, item.barcode);
    }
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

    final validator = validators[mediaKind];
    if (validator == null) {
      issues.add('$prefix: no typed catalog quality validator exists');
    } else {
      issues.addAll(validator(item));
    }
    final graphValidator = graphValidators[mediaKind];
    if (graphValidator == null) {
      issues.add('$prefix: no typed catalog graph validator exists');
    } else {
      issues.addAll(graphValidator(item));
    }
  }

  if (issues.isNotEmpty) {
    throw StateError(
      'Seed catalog quality validation failed:\n'
      '${issues.map((issue) => '- $issue').join('\n')}',
    );
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

List<Map<String, dynamic>> seedRequireObjectList(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  return _requireObjectList(issues, prefix, field, value);
}

void seedValidateChildren(
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

void seedValidateVideoReleases(
  List<String> issues,
  String prefix,
  CatalogItemDto item,
  Object? rawReleases, {
  required String kind,
  required String parentKey,
  required String titleKey,
}) {
  final releases = _requireObjectList(issues, prefix, 'releases', rawReleases);
  seedValidateChildren(
    issues,
    prefix,
    'releases',
    releases,
    kind: kind,
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

void seedValidateBarcode(
  List<String> issues,
  String prefix,
  String? barcode, {
  bool Function(String value)? additionalValid,
}) {
  if (barcode == null || barcode.trim().isEmpty) {
    issues.add('$prefix: barcode is required for the physical seed fixture');
    return;
  }
  final value = barcode.trim();
  if (!isValidRetailBarcode(value) &&
      !isValidIsbn(value) &&
      !(additionalValid?.call(value) ?? false)) {
    issues.add('$prefix: barcode has an invalid checksum or format');
  }
}

void seedValidateStandardBarcode(
  List<String> issues,
  String prefix,
  String? barcode,
) {
  seedValidateBarcode(issues, prefix, barcode);
}

void validateSeedOwnedQuality(
  Iterable<Object> items, {
  Map<CatalogMediaKind, DevSeedOwnedQualityValidator> validators = const {},
}) {
  final issues = <String>[];
  for (final item in items) {
    final ref = collectarrTypedOwnedItemRef(item);
    final json = collectarrTypedOwnedItemJson(item);
    final prefix = '${ref.kind.apiValue}/${ref.id.value}';
    _requireText(issues, prefix, 'condition', json['condition']);
    _requireText(issues, prefix, 'personal_notes', json['personal_notes']);
    _requireText(
      issues,
      prefix,
      'collection_status',
      json['collection_status'],
    );
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
    if (quantity < 1) {
      issues.add('$prefix: quantity must be at least 1');
    }
    if (json['purchase_date'] == null) {
      issues.add('$prefix: purchase_date is required');
    }
    final pricePaidCents = (json['price_paid_cents'] as num?)?.toInt();
    if (pricePaidCents == null || pricePaidCents <= 0) {
      issues.add('$prefix: price_paid_cents must be positive');
    }
    if ((json['currency'] as String?)?.trim().isEmpty != false) {
      issues.add('$prefix: currency is required when a purchase price exists');
    }
    final validator = validators[ref.kind];
    if (validator == null) {
      issues.add('$prefix: no typed owned details validator exists');
    } else {
      issues.addAll(validator(item));
    }
  }
  _throwSeedQualityIssues('owned', issues);
}

/// Adds the standard non-empty text issue used by kind-owned seed validators.
///
/// The validator itself stays with the owning kind; this helper only keeps the
/// error wording and primitive check consistent across fixtures.
void seedRequireText(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  _requireText(issues, prefix, field, value);
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
  CatalogItemDto item,
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

/// Primitive catalog-fixture checks exposed to kind-owned quality validators.
void seedRequirePublishingQuality(
  List<String> issues,
  String prefix,
  CatalogItemDto item,
) {
  _requirePublishingQuality(issues, prefix, item);
}

void seedRequireTextList(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  _requireTextList(issues, prefix, field, value);
}

void seedRequirePositiveInt(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  _requirePositiveInt(issues, prefix, field, value);
}

void seedRequirePositiveNumber(
  List<String> issues,
  String prefix,
  String field,
  Object? value,
) {
  _requirePositiveNumber(issues, prefix, field, value);
}

void seedRequireTrackList(
  List<String> issues,
  String prefix,
  Object? value,
) {
  _requireTrackList(issues, prefix, value);
}

void seedRequireCreatorList(
  List<String> issues,
  String prefix,
  Object? value,
) {
  _requireCreatorList(issues, prefix, value);
}

void seedRequirePlayerStats(
  List<String> issues,
  String prefix,
  Object? value,
) {
  _requirePlayerStats(issues, prefix, value);
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
