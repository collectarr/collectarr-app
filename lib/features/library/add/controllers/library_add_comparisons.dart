part of '../library_add_dialog.dart';

extension _LibraryAddDialogComparisons on _LibraryAddDialogState {
  bool _sameStringList(List<String>? a, List<String>? b) {
    final left = _normalizeStringList(a);
    final right = _normalizeStringList(b);
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

  List<String> _normalizeStringList(List<String>? values) {
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

  bool _sameCreators(
    List<Map<String, dynamic>>? a,
    List<Map<String, dynamic>>? b,
  ) {
    final left = _normalizeCreators(a);
    final right = _normalizeCreators(b);
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

  List<Map<String, dynamic>> _normalizeCreators(
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

  bool _sameTrailerLinks(List<TrailerLink>? a, List<TrailerLink>? b) {
    final left = _normalizeTrailerLinks(a);
    final right = _normalizeTrailerLinks(b);
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

  List<Map<String, dynamic>> _normalizeTrailerLinks(List<TrailerLink>? links) {
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

  bool _sameTracks(List<CatalogTrack>? a, List<CatalogTrack>? b) {
    final left = _normalizeTracks(a);
    final right = _normalizeTracks(b);
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

  List<Map<String, dynamic>> _normalizeTracks(List<CatalogTrack>? values) {
    if (values == null) {
      return const <Map<String, dynamic>>[];
    }
    final normalized = <Map<String, dynamic>>[];
    for (final track in values) {
      final title = track.title.trim();
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
    return LibraryMetadataItem(
      id: item.id,
      kind: item.kind,
      title: item.title,
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: primaryVariant?.coverImageUrl ?? item.displayCoverUrl,
      thumbnailImageUrl:
          primaryVariant?.thumbnailImageUrl ?? item.displayCoverUrl,
      editionTitle: primaryEdition?.title,
      physicalFormat: primaryEdition?.physicalFormat,
      physicalFormatLabel: primaryEdition?.physicalFormatLabel,
      publisher: primaryEdition?.publisher ?? item.publisher,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year ?? item.series?.volumeStartYear,
      barcode: primaryVariant?.barcode ?? item.barcode,
      variant: primaryVariant?.name,
      series: item.series,
      publishing: item.publishing,
    );
  }
}
