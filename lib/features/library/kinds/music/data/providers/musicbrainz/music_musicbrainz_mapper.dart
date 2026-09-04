import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

/// Converts MusicBrainz-native and normalized payloads into Music's typed graph.
final class MusicMusicBrainzMapper {
  const MusicMusicBrainzMapper._();

  static MusicRelease fromNative(MusicBrainzRelease release) {
    final providerId = _requiredText(release.id, 'MusicBrainz release');
    final releaseId = MusicReleaseId('musicbrainz:$providerId');
    final artistNames = _artistNames(release.artistCredits);
    final media = _mediaFromNative(releaseId, release.media);
    final coverImageUrl = _coverUrl(providerId);

    return MusicRelease(
      id: releaseId,
      title: _text(release.title) ?? 'Unknown release',
      artist: _join(artistNames),
      publisher: _publisher(release),
      catalogNumber: _catalogNumber(release),
      barcode: _text(release.barcode),
      releaseDate: _parseDate(release.date),
      countryCode: _text(release.country),
      coverImageUrl: coverImageUrl,
      genres: release.genres.isNotEmpty ? release.genres : release.tags,
      contributions: _contributions(release.artistCredits),
      media: media,
      tracks: media.expand((medium) => medium.tracks).toList(growable: false),
      rawPayload: {
        ...release.toJson(),
        'id': releaseId.value,
        'kind': CatalogMediaKind.music.apiValue,
        'artist': _join(artistNames),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      },
    );
  }

  static MusicRelease fromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    _validateEnvelope(envelope);
    final normalized = Map<String, dynamic>.from(envelope.normalized);
    final providerId = _requiredText(
      envelope.providerItemId,
      'MusicBrainz envelope item',
    );
    final releaseId = MusicReleaseId('musicbrainz:$providerId');
    final normalizedCreators = _maps(normalized['creators']);
    final artist = _text(normalized['artist']) ??
        _join([
          for (final creator in normalizedCreators)
            if (_text(creator['name']) case final name?) name,
        ]);
    final coverImageUrl = _text(normalized['cover_image_url']) ??
        (envelope.images.isEmpty ? null : envelope.images.first.url);
    final media = _mediaFromNormalized(releaseId, normalized);

    return MusicRelease(
      id: releaseId,
      title: _text(normalized['title']) ?? 'Unknown release',
      artist: artist,
      publisher: _text(normalized['publisher']),
      catalogNumber: _text(normalized['catalog_number']),
      barcode: _text(normalized['barcode']),
      releaseDate: _parseDate(normalized['release_date']),
      recordingDate: _parseDate(normalized['recording_date']),
      releaseStatus: _text(normalized['release_status']),
      releaseType: _text(normalized['release_type']),
      countryCode: _text(normalized['country'] ?? normalized['country_code']),
      language: _text(normalized['language']),
      coverImageUrl: coverImageUrl,
      genres: _strings(normalized['genres']),
      contributions: normalizedCreators,
      media: media,
      tracks: media.expand((medium) => medium.tracks).toList(growable: false),
      isLive: normalized['is_live'] as bool?,
      rawPayload: {
        ...normalized,
        'id': releaseId.value,
        'kind': CatalogMediaKind.music.apiValue,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      },
    );
  }

  static List<MusicMedia> _mediaFromNative(
    MusicReleaseId releaseId,
    List<MusicBrainzMedium> source,
  ) {
    return [
      for (var index = 0; index < source.length; index++)
        _nativeMedium(releaseId, source[index], index + 1),
    ];
  }

  static MusicMedia _nativeMedium(
    MusicReleaseId releaseId,
    MusicBrainzMedium source,
    int mediaNumber,
  ) {
    final mediaId = MusicMediaId('${releaseId.value}:media:$mediaNumber');
    final tracks = [
      for (var index = 0; index < source.tracks.length; index++)
        _nativeTrack(mediaId, source.tracks[index], index + 1),
    ];
    return MusicMedia(
      id: mediaId,
      releaseId: releaseId,
      mediaNumber: mediaNumber,
      mediaType: source.format,
      trackCount: source.trackCount ?? (tracks.isEmpty ? null : tracks.length),
      tracks: tracks,
      rawPayload: {
        ...source.toJson(),
        'id': mediaId.value,
        'release_id': releaseId.value,
        'media_number': mediaNumber,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static MusicTrack _nativeTrack(
    MusicMediaId mediaId,
    MusicBrainzTrack source,
    int fallbackPosition,
  ) {
    final position = (source.position ?? fallbackPosition).toString();
    final trackId = MusicTrackId('${mediaId.value}:track:$position');
    final artist = _join(_artistNames(source.artistCredits));
    return MusicTrack(
      id: trackId,
      mediaId: mediaId,
      position: position,
      title: _text(source.title) ?? 'Track $position',
      durationMs: source.length,
      artist: artist,
      rawPayload: {
        ...source.toJson(),
        'id': trackId.value,
        'media_id': mediaId.value,
        'position': position,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static List<MusicMedia> _mediaFromNormalized(
    MusicReleaseId releaseId,
    Map<String, dynamic> normalized,
  ) {
    final rawMedia = _maps(normalized['media'] ?? normalized['discs']);
    if (rawMedia.isNotEmpty) {
      return [
        for (var index = 0; index < rawMedia.length; index++)
          _normalizedMedium(releaseId, rawMedia[index], index + 1),
      ];
    }

    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final track in _maps(normalized['tracks'])) {
      final mediaNumber = _int(
            track['disc_number'] ?? track['media_number'],
          ) ??
          1;
      grouped.putIfAbsent(mediaNumber, () => []).add(track);
    }
    final format = _text(normalized['format']) ??
        _strings(normalized['formats']).firstOrNull;
    final mediaNumbers = grouped.keys.toList()..sort();
    if (mediaNumbers.isEmpty) return const <MusicMedia>[];
    return [
      for (final mediaNumber in mediaNumbers)
        _normalizedMedium(
          releaseId,
          {
            'media_number': mediaNumber,
            'media_type': format,
            'tracks': grouped[mediaNumber],
          },
          mediaNumber,
        ),
    ];
  }

  static MusicMedia _normalizedMedium(
    MusicReleaseId releaseId,
    Map<String, dynamic> source,
    int fallbackNumber,
  ) {
    final mediaNumber =
        _int(source['media_number'] ?? source['disc_number']) ?? fallbackNumber;
    final mediaId = MusicMediaId(
      _text(source['id']) ?? '${releaseId.value}:media:$mediaNumber',
    );
    final rawTracks = _maps(source['tracks']);
    final tracks = [
      for (var index = 0; index < rawTracks.length; index++)
        _normalizedTrack(mediaId, rawTracks[index], index + 1),
    ];
    return MusicMedia(
      id: mediaId,
      releaseId: releaseId,
      mediaNumber: mediaNumber,
      mediaCondition: _text(source['media_condition']),
      mediaType: _text(source['media_type'] ?? source['format']),
      packaging: _text(source['packaging']),
      rpm: _int(source['rpm']),
      soundType: _text(source['sound_type']),
      spars: _text(source['spars']),
      title: _text(source['title']),
      trackCount: _int(source['track_count']) ??
          (tracks.isEmpty ? null : tracks.length),
      tracks: tracks,
      vinylColor: _text(source['vinyl_color']),
      vinylWeight: _text(source['vinyl_weight']),
      rawPayload: {
        ...source,
        'id': mediaId.value,
        'release_id': releaseId.value,
        'media_number': mediaNumber,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static MusicTrack _normalizedTrack(
    MusicMediaId mediaId,
    Map<String, dynamic> source,
    int fallbackPosition,
  ) {
    final position = _text(source['position'] ?? source['number']) ??
        fallbackPosition.toString();
    final trackId = MusicTrackId(
      _text(source['id']) ?? '${mediaId.value}:track:$position',
    );
    final durationSeconds = _int(source['duration_seconds']);
    final durationMs = _int(source['duration_ms']) ??
        (durationSeconds == null ? null : durationSeconds * 1000);
    return MusicTrack(
      id: trackId,
      mediaId: mediaId,
      position: position,
      title: _text(source['title']) ?? 'Track $position',
      composition: _text(source['composition']),
      durationMs: durationMs,
      instrument: _text(source['instrument']),
      artist: _text(source['artist']),
      rawPayload: {
        ...source,
        'id': trackId.value,
        'media_id': mediaId.value,
        'position': position,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static List<String> _artistNames(List<MusicBrainzArtistCredit> credits) => [
        for (final credit in credits)
          if (_text(credit.artist?.name ?? credit.name) case final name?) name,
      ];

  static List<Map<String, dynamic>> _contributions(
    List<MusicBrainzArtistCredit> credits,
  ) =>
      [
        for (final credit in credits)
          if (_text(credit.artist?.name ?? credit.name) case final name?)
            {
              'id': _text(credit.artist?.id),
              'person_id': _text(credit.artist?.id),
              'name': name,
              'role': 'Artist',
            },
      ];

  static String? _publisher(MusicBrainzRelease release) {
    for (final entry in release.labelInfo) {
      final value = _text(entry.label?.name);
      if (value != null) return value;
    }
    return null;
  }

  static String? _catalogNumber(MusicBrainzRelease release) {
    for (final entry in release.labelInfo) {
      final value = _text(entry.catalogNumber);
      if (value != null) return value;
    }
    return null;
  }

  static String? _coverUrl(String providerId) =>
      'https://coverartarchive.org/release/$providerId/front.jpg';

  static void _validateEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    if (envelope.provider.trim().toLowerCase() != 'musicbrainz') {
      throw StateError(
        'Music MusicBrainz integration received ${envelope.provider} data',
      );
    }
    if (envelope.kind.trim().toLowerCase() != CatalogMediaKind.music.apiValue) {
      throw StateError(
        'Music MusicBrainz integration received ${envelope.kind} data',
      );
    }
  }

  static String _requiredText(String? value, String label) {
    final text = _text(value);
    if (text == null) throw FormatException('$label is missing an id');
    return text;
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

  static DateTime? _parseDate(Object? value) =>
      DateTime.tryParse(value?.toString().trim() ?? '');

  static String? _join(Iterable<String> values) {
    final distinct = <String>[];
    for (final value in values) {
      if (!distinct.contains(value)) distinct.add(value);
    }
    return distinct.isEmpty ? null : distinct.join(', ');
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    if (value is! Iterable) return const <Map<String, dynamic>>[];
    return [
      for (final entry in value)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }

  static List<String> _strings(Object? value) {
    if (value is! Iterable) return const <String>[];
    return [
      for (final entry in value)
        if (_text(entry) case final text?) text,
    ];
  }
}
