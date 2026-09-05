import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Converts the current catalog projection into the Music-owned workspace
/// release graph.
///
/// Catalog payloads can still contain legacy release/track shapes. This
/// boundary gives those values stable Music IDs and parent references before
/// they reach Music workspace fields.
final class MusicWorkspaceMapper {
  const MusicWorkspaceMapper._();

  static MusicRelease fromCatalogItem(
    CatalogItem item, {
    String? releaseId,
    CatalogEdition? edition,
  }) {
    final payload = item.toSyncPayload();
    final selectedLegacyRelease = _selectRelease(
      payload['releases'],
      releaseId,
    );
    final selectedEdition = edition ?? item.editions.firstOrNull;
    final source = <String, dynamic>{
      ...payload,
      if (selectedLegacyRelease != null) ...selectedLegacyRelease,
    };
    final resolvedId = releaseId ??
        selectedEdition?.id ??
        _text(selectedLegacyRelease?['id']) ??
        item.id;
    final resolvedMedia = _resolveMedia(
      releaseId: resolvedId,
      source: source,
      edition: selectedEdition,
    );

    return MusicRelease.fromJson({
      ...source,
      'id': resolvedId,
      'kind': 'music',
      'title': selectedEdition?.title ?? _text(source['title']) ?? item.title,
      if (_text(source['artist'] ?? source['series_title']) case final artist?)
        'artist': artist,
      if (_text(source['publisher'] ?? source['record_label'])
          case final publisher?)
        'publisher': publisher,
      if (_text(source['catalog_number']) case final catalogNumber?)
        'catalog_number': catalogNumber,
      if (_text(source['barcode'] ?? source['upc']) case final barcode?)
        'barcode': barcode,
      if (source['release_date'] == null &&
          source['original_release_date'] != null)
        'release_date': source['original_release_date'],
      if (_text(source['country'] ?? source['country_code'])
          case final country?)
        'country_code': country,
      if (_text(source['cover_image_url']) ?? item.coverImageUrl
          case final cover?)
        'cover_image_url': cover,
      'genres': _strings(source['genres']),
      'contributions': _maps(source['contributions'] ?? source['creators']),
      'media': resolvedMedia,
      'tracks': [
        for (final media in resolvedMedia) ..._maps(media['tracks']),
      ],
    });
  }

  static List<Map<String, dynamic>> _resolveMedia({
    required String releaseId,
    required Map<String, dynamic> source,
    required CatalogEdition? edition,
  }) {
    final rawMedia = _maps(source['media']).isNotEmpty
        ? _maps(source['media'])
        : _maps(source['discs']);
    if (rawMedia.isNotEmpty) {
      return [
        for (var index = 0; index < rawMedia.length; index++)
          _mediaPayload(
            releaseId,
            rawMedia[index],
            index + 1,
          ),
      ];
    }

    if (edition != null && edition.discs.isNotEmpty) {
      return [
        for (var index = 0; index < edition.discs.length; index++)
          _editionMediaPayload(releaseId, edition, edition.discs[index], index),
      ];
    }

    final rawTracks = _maps(source['tracks']);
    if (rawTracks.isEmpty) return const <Map<String, dynamic>>[];
    final byDisc = <int, List<Map<String, dynamic>>>{};
    for (final track in rawTracks) {
      final discNumber = _int(
            track['disc_number'] ?? track['disc'] ?? track['media_number'],
          ) ??
          1;
      byDisc.putIfAbsent(discNumber, () => []).add(track);
    }
    return [
      for (final entry in byDisc.entries)
        _mediaPayload(
          releaseId,
          {
            'media_number': entry.key,
            if (_text(source['format'] ?? source['physical_format'])
                case final format?)
              'media_type': format,
            if (_text(source['packaging']) case final packaging?)
              'packaging': packaging,
            'tracks': entry.value,
          },
          entry.key,
        ),
    ];
  }

  static Map<String, dynamic> _editionMediaPayload(
    String releaseId,
    CatalogEdition edition,
    CatalogDisc disc,
    int index,
  ) {
    final mediaNumber = disc.discNumber ?? index + 1;
    return _mediaPayload(
      releaseId,
      {
        'id': '$releaseId:media:$mediaNumber',
        'media_number': mediaNumber,
        if (disc.name != null) 'title': disc.name,
        if (edition.physicalFormat != null)
          'media_type': edition.physicalFormat,
        if (edition.physicalFormatLabel != null)
          'media_type_label': edition.physicalFormatLabel,
        'tracks': [
          for (final track in disc.tracks) track.toJson(),
        ],
      },
      mediaNumber,
    );
  }

  static Map<String, dynamic> _mediaPayload(
    String releaseId,
    Map<String, dynamic> source,
    int fallbackNumber,
  ) {
    final mediaNumber =
        _int(source['media_number'] ?? source['disc_number']) ?? fallbackNumber;
    final id = _text(source['id']) ?? '$releaseId:media:$mediaNumber';
    final tracks = _maps(source['tracks']);
    return {
      ...source,
      'id': id,
      'kind': 'music',
      'release_id': releaseId,
      'media_number': mediaNumber,
      'tracks': [
        for (var index = 0; index < tracks.length; index++)
          _trackPayload(id, tracks[index], index + 1),
      ],
    };
  }

  static Map<String, dynamic> _trackPayload(
    String mediaId,
    Map<String, dynamic> source,
    int fallbackPosition,
  ) {
    final position = _text(
          source['position'] ?? source['track_number'] ?? source['number'],
        ) ??
        '$fallbackPosition';
    final id = _text(source['id']) ?? '$mediaId:track:$position';
    final durationSeconds =
        _int(source['duration_seconds'] ?? source['length_seconds']);
    final durationMs = _int(source['duration_ms']) ??
        (durationSeconds == null || durationSeconds < 0
            ? null
            : durationSeconds * 1000);
    return {
      ...source,
      'id': id,
      'kind': 'music',
      'media_id': mediaId,
      'position': position,
      'title': _text(source['title']) ?? 'Track',
      if (durationMs != null) 'duration_ms': durationMs,
    };
  }

  static Map<String, dynamic>? _selectRelease(
    Object? value,
    String? releaseId,
  ) {
    final releases = _maps(value);
    if (releases.isEmpty) return null;
    if (releaseId == null) return releases.first;
    for (final release in releases) {
      if (_text(release['id']) == releaseId) return release;
    }
    return releases.first;
  }

  static List<String> _strings(Object? value) {
    if (value is! Iterable) return const <String>[];
    return [
      for (final entry in value)
        if (_text(entry) case final text?) text,
    ];
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    if (value is! Iterable) return const <Map<String, dynamic>>[];
    return [
      for (final entry in value)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }
}
