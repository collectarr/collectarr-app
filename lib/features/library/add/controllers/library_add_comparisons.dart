import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

bool sameStringList(List<String>? a, List<String>? b) {
  final left = normalizeStringList(a);
  final right = normalizeStringList(b);
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}

List<String> normalizeStringList(List<String>? values) {
  if (values == null) {
    return const <String>[];
  }
  final normalized = <String>[];
  for (final value in values) {
    final entry = value.trim();
    if (entry.isEmpty) {
      continue;
    }
    normalized.add(entry);
  }
  return normalized;
}

bool sameCreators(
  List<Map<String, dynamic>>? a,
  List<Map<String, dynamic>>? b,
) {
  final left = normalizeCreators(a);
  final right = normalizeCreators(b);
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    final l = left[i];
    final r = right[i];
    if (l['name'] != r['name'] || l['role'] != r['role']) {
      return false;
    }
  }
  return true;
}

List<Map<String, dynamic>> normalizeCreators(
  List<Map<String, dynamic>>? values,
) {
  if (values == null) {
    return const <Map<String, dynamic>>[];
  }
  final normalized = <Map<String, dynamic>>[];
  for (final raw in values) {
    final name = (raw['name']?.toString() ?? '').trim();
    if (name.isEmpty) {
      continue;
    }
    final role = raw['role']?.toString().trim();
    normalized.add({
      'name': name,
      if (role != null && role.isNotEmpty) 'role': role,
    });
  }
  return normalized;
}

bool sameTrailerLinks(List<TrailerLink>? a, List<TrailerLink>? b) {
  final left = normalizeTrailerLinks(a);
  final right = normalizeTrailerLinks(b);
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i].toString() != right[i].toString()) {
      return false;
    }
  }
  return true;
}

List<Map<String, dynamic>> normalizeTrailerLinks(List<TrailerLink>? links) {
  if (links == null) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final link in links)
      if (link.url.trim().isNotEmpty)
        {
          'url': link.url.trim(),
          if (link.source != null && link.source!.trim().isNotEmpty)
            'source': link.source!.trim(),
          if (link.title != null && link.title!.trim().isNotEmpty)
            'title': link.title!.trim(),
          if (link.kind.trim().isNotEmpty) 'kind': link.kind.trim(),
          if (link.description != null && link.description!.trim().isNotEmpty)
            'description': link.description!.trim(),
        },
  ];
}

bool sameTracks(List<CatalogTrack>? a, List<CatalogTrack>? b) {
  final left = normalizeTracks(a);
  final right = normalizeTracks(b);
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    final l = left[i];
    final r = right[i];
    if (l['title'] != r['title'] ||
        l['position'] != r['position'] ||
        l['duration_seconds'] != r['duration_seconds'] ||
        l['artist'] != r['artist'] ||
        l['disc_number'] != r['disc_number']) {
      return false;
    }
  }
  return true;
}

List<Map<String, dynamic>> normalizeTracks(List<CatalogTrack>? values) {
  if (values == null) {
    return const <Map<String, dynamic>>[];
  }
  final normalized = <Map<String, dynamic>>[];
  for (final track in values) {
    final title = (track.title ?? '').trim();
    if (title.isEmpty) {
      continue;
    }
    normalized.add({
      'title': title,
      if (track.position != null) 'position': track.position,
      if (track.durationSeconds != null)
        'duration_seconds': track.durationSeconds,
      if (track.artist != null && track.artist!.trim().isNotEmpty)
        'artist': track.artist!.trim(),
      if (track.discNumber != null) 'disc_number': track.discNumber,
    });
  }
  return normalized;
}

LibraryMetadataItem metadataItemFromIngestResult(AdminMetadataItem item) {
  final primaryEdition = item.primaryEdition;
  final primaryVariant = item.primaryVariant;
  final releaseDate = primaryEdition?.releaseDate;
  final mediaKind = catalogMediaKindFromApiValue(item.kind);
  return LibraryMetadataItem(
    identity: LibraryItemIdentity(
      id: item.id,
      mediaKind: mediaKind,
    ),
    kindMetadata: LibraryKindMetadataDecoders.decode(
      mediaKind,
      {
        'id': item.id,
        'kind': item.kind,
        'title': item.title,
        'item_number': item.itemNumber,
        'synopsis': item.synopsis,
        'cover_image_url':
            primaryVariant?.coverImageUrl ?? item.displayCoverUrl,
        'thumbnail_image_url':
            primaryVariant?.thumbnailImageUrl ?? item.displayCoverUrl,
        'publisher': primaryEdition?.publisher ?? item.publisher,
        'edition_title': primaryEdition?.title,
        'physical_format': primaryEdition?.physicalFormat,
        'physical_format_label': primaryEdition?.physicalFormatLabel,
        'release_date': releaseDate?.toUtc().toIso8601String(),
        'barcode': primaryVariant?.barcode ?? item.barcode,
        'variant': primaryVariant?.name,
        if (item.series != null) 'series_title': item.series!.seriesTitle,
      },
    ),
  );
}
