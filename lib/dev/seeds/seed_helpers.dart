import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/dev/seeds/dev_seed_kind_contributor.dart';
import 'package:collectarr_app/features/barcode/barcode_checksum.dart';
import 'package:collectarr_app/features/catalog/catalog_transport_summary_registry.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

const String seedCoverImageData =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+XbL0AAAAASUVORK5CYII=';

final Uint8List seedTinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Zx1EAAAAASUVORK5CYII=',
);

void seedNoopCatalogPayloadEnricher(
  CatalogItemDto item,
  Map<String, dynamic> payload,
) {}

/// Development fixtures use the same kind codec as the UI for display labels.
String seedTitle(CatalogItemDto item) =>
    summarizeCatalogTransportPayload(item).primaryLabel;

String? seedPublisher(CatalogItemDto item) =>
    _seedText(item.kindData['publisher'] ?? item.kindData['label']);

String? seedBarcode(CatalogItemDto item) => _seedText(
      item.kindData['barcode'] ??
          item.kindData['isbn'] ??
          item.kindData['upc'],
    );

DateTime? seedReleaseDate(CatalogItemDto item) =>
    PartialDate.tryParse(item.kindData['release_date'])?.asDateTime ??
    DateTime.tryParse(item.kindData['release_date']?.toString() ?? '');

String? seedPhysicalFormat(CatalogItemDto item) =>
    _seedText(item.kindData['physical_format'] ?? item.kindData['format']);

String? seedEditionTitle(CatalogItemDto item) =>
    _seedText(item.kindData['edition_title'] ?? item.kindData['title_extension']);

String? seedCoverImageUrl(CatalogItemDto item) =>
    summarizeCatalogTransportPayload(item).imageUrl;

String? _seedText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String seedOrdinal2(int value) => value.toString().padLeft(2, '0');

Iterable<String> seedIds(CatalogMediaKind kind, int count) sync* {
  for (var i = 1; i <= count; i++) {
    yield 'seed-${kind.apiValue}-${seedOrdinal2(i)}';
  }
}

CatalogItemRef seedCatalogRef(CatalogMediaKind kind, String itemId) {
  final expectedPrefix = 'seed-${kind.apiValue}-';
  if (!itemId.startsWith(expectedPrefix)) {
    throw ArgumentError.value(
      itemId,
      'itemId',
      'Seed catalog IDs for ${kind.apiValue} must start with $expectedPrefix',
    );
  }
  return CatalogItemRef(
    kind: kind,
    id: itemId,
  );
}

LibraryEntryRef seedLibraryEntryRef(CatalogMediaKind kind, String id) {
  return LibraryEntryRef(
    kind: kind,
    id: LibraryEntryId(id),
  );
}

/// Rebuilds a transport fixture while preserving its kind-entry fields.
/// Kind seeders use this only to add their own Core graph fields.
CatalogItemDto withSeedPayload(
  CatalogItemDto item,
  Map<String, dynamic> additions,
) {
  return CatalogItemDto.raw(
    id: item.id,
    mediaKind: item.mediaKind,
    kindData: {
      ...item.kindData,
      ...additions,
    },
  );
}

CatalogItemDto enrichSeedItem(
  CatalogItemDto item, {
  required DevSeedCatalogDefaults defaults,
}) {
  final payload = Map<String, dynamic>.from(item.toJson());
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

  final seriesMap = payload['series'] is Map ? payload['series'] as Map : null;
  final seriesTitle = seriesMap?['series_title'] as String?;
  final pubMap = item.payload['publishing'] as Map?;
  final title = seedTitle(item);
  final placeholderCoverUrl =
      'https://placehold.co/600x900/png?text=${Uri.encodeComponent(title)}';
  payload.putIfAbsent('cover_image_data', () => seedCoverImageData);
  payload.putIfAbsent('cover_image_url', () => seedCoverImageUrl(item) ?? placeholderCoverUrl);
  payload.putIfAbsent('thumbnail_image_url', () => payload['cover_image_url']);

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
    payload.putIfAbsent('imprint', () => seedPublisher(item));
    payload.putIfAbsent('subtitle', () => '$title seed edition');
    payload.putIfAbsent('series_group', () => seriesTitle);
    payload.putIfAbsent('publication_place', () => 'US');
    payload.putIfAbsent('original_country', () => 'US');
    payload.putIfAbsent('original_language', () => defaults.originalLanguage);
    payload.putIfAbsent(
      'original_publication_date',
      () => seedReleaseDate(item)?.toUtc().toIso8601String(),
    );
    payload.putIfAbsent('original_publication_place', () => 'US');
    payload.putIfAbsent('original_publisher', () => seedPublisher(item));
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
    final barcodeValidator = barcodeValidators[mediaKind];
    if (barcodeValidator == null) {
      seedValidateStandardBarcode(issues, prefix, seedBarcode(item));
    } else {
      barcodeValidator(issues, prefix, seedBarcode(item));
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

void validateSeedEntryQuality(Iterable<LibraryEntrySummary> items) {
  final issues = <String>[];
  for (final item in items) {
    final prefix = '${item.ref.kind.apiValue}/${item.ref.id.value}';
    final sourceCatalogRef = item.sourceCatalogRef;
    if (sourceCatalogRef != null && sourceCatalogRef.kind != item.ref.kind) {
      issues.add(
        '$prefix: source_catalog_ref kind ${sourceCatalogRef.kind.apiValue} does not match '
        'entry kind ${item.ref.kind}',
      );
    }
    if (!item.hasNotes || item.notes?.trim().isNotEmpty != true) {
      issues.add('$prefix: personal_notes is required');
    }
    if (item.purchaseDate == null) {
      issues.add('$prefix: purchase_date is required');
    }
    final pricePaidCents = item.pricePaidCents;
    if (pricePaidCents == null || pricePaidCents <= 0) {
      issues.add('$prefix: price_paid_cents must be positive');
    }
    if (item.currency?.trim().isNotEmpty != true) {
      issues.add('$prefix: currency is required when a purchase price exists');
    }
  }
  _throwSeedQualityIssues('entry', issues);
}

/// Adds the standard non-empty text issue used by kind-entry seed validators.
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

void validateSeedTrackingQuality(Iterable<TrackingStorageRecord> entries) {
  final issues = <String>[];
  for (final entry in entries) {
    final prefix = '${entry.libraryEntryRef.kind.apiValue}/${entry.id}';
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
    final current = entry.progress.current;
    final total = entry.progress.total;
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
  _requireText(issues, prefix, 'publisher', seedPublisher(item));
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

/// Primitive catalog-fixture checks exposed to kind-entry quality validators.
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
  if (value is Map<Object?, Object?>) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
