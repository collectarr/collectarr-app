import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';

/// Converts MusicBrainz-native and normalized payloads into Music's typed
/// release-group -> release -> medium -> track graph.
final class MusicMusicBrainzMapper {
  const MusicMusicBrainzMapper._();

  static MusicRelease fromNative(MusicBrainzRelease release) {
    final releaseId = _releaseId(release.id, 'MusicBrainz release');
    final releaseGroupId = _releaseGroupId(release.releaseGroup?.id, releaseId);
    final artistNames = _artistNames(release.artistCredits);
    final coverImageUrl = _coverUrl(release.id!);
    return MusicRelease(
      id: releaseId,
      releaseGroupId: releaseGroupId,
      title: _text(release.title) ?? 'Unknown release',
      publisher: _publisher(release),
      catalogNumber: _catalogNumber(release),
      barcode: _text(release.barcode),
      releaseDate: _parseDate(release.date),
      countryCode: _text(release.country),
      coverImageUrl: coverImageUrl,
      contributions: _contributions(release.artistCredits, releaseId),
      mediums: _mediumsFromNative(releaseId, release.media),
      metadataJson: {
        ...release.toJson(),
        'id': releaseId.value,
        'release_group_id': releaseGroupId.value,
        'kind': CatalogMediaKind.music.apiValue,
        'artist': _join(artistNames),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      },
    );
  }

  static MusicReleaseGroup releaseGroupFromNative(MusicBrainzRelease release) {
    final mappedRelease = fromNative(release);
    final groupTitle =
        _text(release.releaseGroup?.title) ?? mappedRelease.title;
    return MusicReleaseGroup(
      id: mappedRelease.releaseGroupId,
      title: groupTitle,
      artist: _join(_artistNames(release.artistCredits)),
      originalReleaseDate: mappedRelease.releaseDate,
      genres: release.genres.isNotEmpty ? release.genres : release.tags,
      coverImageUrl: mappedRelease.coverImageUrl,
      releases: [mappedRelease],
      metadataJson: {
        ...release.toJson(),
        'id': mappedRelease.releaseGroupId.value,
        'title': groupTitle,
        'releases': [mappedRelease.toJson()],
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static MusicRelease fromEnvelope(ProviderMetadataEnvelope envelope) {
    _validateEnvelope(envelope);
    final normalized = envelope.payload.toJson();
    final providerId =
        _requiredText(envelope.providerItemId, 'MusicBrainz envelope item');
    final releaseId = MusicReleaseId('musicbrainz:$providerId');
    final releaseGroupId =
        _releaseGroupId(_text(normalized['release_group_id']), releaseId);
    final coverImageUrl = _text(normalized['cover_image_url']) ??
        (envelope.images.isEmpty ? null : envelope.images.first.url);
    return MusicRelease(
      id: releaseId,
      releaseGroupId: releaseGroupId,
      title: _text(normalized['title']) ?? 'Unknown release',
      publisher: _text(normalized['publisher']),
      catalogNumber: _text(normalized['catalog_number']),
      barcode: _text(normalized['barcode']),
      releaseDate: _parseDate(normalized['release_date']),
      releaseStatus: _text(normalized['release_status']),
      releaseType: _text(normalized['release_type']),
      countryCode: _text(normalized['country'] ?? normalized['country_code']),
      language: _text(normalized['language']),
      coverImageUrl: coverImageUrl,
      packaging: _text(normalized['packaging']),
      boxSetMembership: musicBoxSetMembershipFromJson(normalized),
      contributions: _contributionsFromMaps(
        normalized['creators'],
        releaseId,
      ),
      mediums: _mediumsFromNormalized(releaseId, normalized),
      metadataJson: {
        ...normalized,
        'id': releaseId.value,
        'release_group_id': releaseGroupId.value,
        'kind': CatalogMediaKind.music.apiValue,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      },
    );
  }

  static MusicReleaseGroup releaseGroupFromEnvelope(
      ProviderMetadataEnvelope envelope) {
    final release = fromEnvelope(envelope);
    final payload = envelope.payload.toJson();
    return MusicReleaseGroup(
      id: release.releaseGroupId,
      title: _text(payload['release_group_title']) ?? release.title,
      artist: _text(payload['artist']),
      originalReleaseDate:
          _parseDate(payload['original_release_date']) ?? release.releaseDate,
      genres: _strings(payload['genres']),
      coverImageUrl: release.coverImageUrl,
      releases: [release],
      metadataJson: {
        ...payload,
        'id': release.releaseGroupId.value,
        'title': _text(payload['release_group_title']) ?? release.title,
        'releases': [release.toJson()],
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static MusicReleaseId _releaseId(String? id, String label) =>
      MusicReleaseId(_providerScopedId(_requiredText(id, label)));

  static MusicReleaseGroupId _releaseGroupId(
      String? groupId, MusicReleaseId releaseId) {
    final value = _text(groupId);
    return MusicReleaseGroupId(
      value == null
          ? 'musicbrainz:release-group:${_providerIdPart(releaseId.value)}'
          : _providerScopedId(value),
    );
  }

  static String _providerScopedId(String value) =>
      value.startsWith('musicbrainz:') ? value : 'musicbrainz:$value';

  static String _providerIdPart(String value) =>
      value.startsWith('musicbrainz:')
          ? value.substring('musicbrainz:'.length)
          : value;

  static List<MusicMedium> _mediumsFromNative(
    MusicReleaseId releaseId,
    List<MusicBrainzMedium> source,
  ) =>
      [
        for (var index = 0; index < source.length; index++)
          _nativeMedium(releaseId, source[index], index + 1),
      ];

  static MusicMedium _nativeMedium(
    MusicReleaseId releaseId,
    MusicBrainzMedium source,
    int mediumNumber,
  ) {
    final mediumId = MusicMediumId('${releaseId.value}:medium:$mediumNumber');
    final tracks = [
      for (var index = 0; index < source.tracks.length; index++)
        _nativeTrack(mediumId, source.tracks[index], index + 1),
    ];
    return MusicMedium(
      id: mediumId,
      releaseId: releaseId,
      mediumNumber: mediumNumber,
      mediumType: source.format,
      trackCount: source.trackCount ?? (tracks.isEmpty ? null : tracks.length),
      tracks: tracks,
      metadataJson: {
        ...source.toJson(),
        'id': mediumId.value,
        'release_id': releaseId.value,
        'medium_number': mediumNumber,
        'medium_type': source.format,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static MusicTrack _nativeTrack(
    MusicMediumId mediumId,
    MusicBrainzTrack source,
    int fallbackPosition,
  ) {
    final position = (source.position ?? fallbackPosition).toString();
    final trackId = MusicTrackId('${mediumId.value}:track:$position');
    return MusicTrack(
      id: trackId,
      mediumId: mediumId,
      position: position,
      title: _text(source.title) ?? 'Track $position',
      artist: _join(_artistNames(source.artistCredits)),
      durationMs: source.length,
      metadataJson: {
        ...source.toJson(),
        'id': trackId.value,
        'medium_id': mediumId.value,
        'position': position,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static List<MusicMedium> _mediumsFromNormalized(
    MusicReleaseId releaseId,
    Map<String, dynamic> normalized,
  ) {
    final rawMediums = _maps(normalized['mediums']);
    if (rawMediums.isNotEmpty) {
      return [
        for (var index = 0; index < rawMediums.length; index++)
          _normalizedMedium(releaseId, rawMediums[index], index + 1),
      ];
    }
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final track in _maps(normalized['tracks'])) {
      final mediumNumber =
          _int(track['medium_number'] ?? track['disc_number']) ?? 1;
      grouped.putIfAbsent(mediumNumber, () => []).add(track);
    }
    final mediumType =
        _text(normalized['medium_type'] ?? normalized['physical_format']);
    final mediumNumbers = grouped.keys.toList()..sort();
    return [
      for (final mediumNumber in mediumNumbers)
        _normalizedMedium(
          releaseId,
          {
            'medium_number': mediumNumber,
            'medium_type': mediumType,
            'tracks': grouped[mediumNumber],
          },
          mediumNumber,
        ),
    ];
  }

  static MusicMedium _normalizedMedium(
    MusicReleaseId releaseId,
    Map<String, dynamic> source,
    int fallbackNumber,
  ) {
    final mediumNumber =
        _int(source['medium_number'] ?? source['disc_number']) ??
            fallbackNumber;
    final mediumId = MusicMediumId(
      _text(source['id']) ?? '${releaseId.value}:medium:$mediumNumber',
    );
    final rawTracks = _maps(source['tracks']);
    final tracks = [
      for (var index = 0; index < rawTracks.length; index++)
        _normalizedTrack(mediumId, rawTracks[index], index + 1),
    ];
    return MusicMedium(
      id: mediumId,
      releaseId: releaseId,
      mediumNumber: mediumNumber,
      mediumType: _text(
          source['medium_type'] ?? source['format'] ?? source['media_type']),
      mediaCondition: _text(source['media_condition']),
      rpm: _int(source['rpm']),
      soundType: _text(source['sound_type']),
      spars: _text(source['spars']),
      title: _text(source['title']),
      trackCount: _int(source['track_count']) ??
          (tracks.isEmpty ? null : tracks.length),
      expectedTrackCount: _int(source['expected_track_count']),
      missingTrackCount: _int(source['missing_track_count']),
      missingTrackPositions: _strings(source['missing_track_positions']),
      toc: _text(source['toc']),
      cddbId: _text(source['cddb_id']),
      leadoutOffset: _int(source['leadout_offset']),
      bpDiscId: _text(source['bp_disc_id']),
      tracks: tracks,
      vinylColor: _text(source['vinyl_color']),
      vinylWeight: _text(source['vinyl_weight']),
      metadataJson: {
        ...source,
        'id': mediumId.value,
        'release_id': releaseId.value,
        'medium_number': mediumNumber,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static MusicTrack _normalizedTrack(
    MusicMediumId mediumId,
    Map<String, dynamic> source,
    int fallbackPosition,
  ) {
    final position = _text(source['position'] ?? source['number']) ??
        fallbackPosition.toString();
    final trackId = MusicTrackId(
        _text(source['id']) ?? '${mediumId.value}:track:$position');
    final durationSeconds = _int(source['duration_seconds']);
    return MusicTrack(
      id: trackId,
      mediumId: mediumId,
      position: position,
      title: _text(source['title']) ?? 'Track $position',
      artist: _text(source['artist']),
      composition: _text(source['composition']),
      durationMs: _int(source['duration_ms']) ??
          (durationSeconds == null ? null : durationSeconds * 1000),
      offsetMs: _int(source['offset_ms']),
      bitrateKbps: _int(source['bitrate_kbps']),
      fileSizeBytes: _int(source['file_size_bytes']),
      trackHash: _text(source['track_hash']),
      instrument: _text(source['instrument']),
      metadataJson: {
        ...source,
        'id': trackId.value,
        'medium_id': mediumId.value,
        'position': position,
        'kind': CatalogMediaKind.music.apiValue,
      },
    );
  }

  static List<String> _artistNames(List<MusicBrainzArtistCredit> credits) => [
        for (final credit in credits)
          if (_text(credit.artist?.name ?? credit.name) case final name?) name,
      ];

  static List<MusicReleaseContribution> _contributions(
    List<MusicBrainzArtistCredit> credits,
    MusicReleaseId releaseId,
  ) =>
      [
        for (var index = 0; index < credits.length; index++)
          if (_text(credits[index].artist?.name ?? credits[index].name)
              case final name?)
            MusicReleaseContribution(
              id: MusicReleaseContributionId(
                _text(credits[index].artist?.id) ??
                    '${releaseId.value}:contribution:${index + 1}',
              ),
              releaseId: releaseId,
              personId: _text(credits[index].artist?.id) ?? name,
              role: 'Artist',
              sequence: index + 1,
              metadataJson: {
                'name': name,
                if (_text(credits[index].artist?.id) case final id?)
                  'person_id': id,
              },
            ),
      ];

  static List<MusicReleaseContribution> _contributionsFromMaps(
    Object? value,
    MusicReleaseId releaseId,
  ) =>
      [
        for (var index = 0; index < _maps(value).length; index++)
          MusicReleaseContribution.fromJson({
            ..._maps(value)[index],
            'id': _text(_maps(value)[index]['id']) ??
                '${releaseId.value}:contribution:${index + 1}',
            'release_id': releaseId.value,
            'person_id': _text(_maps(value)[index]['person_id']) ??
                _text(_maps(value)[index]['id']) ??
                _text(_maps(value)[index]['name']) ??
                'unknown',
          }),
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

  static void _validateEnvelope(ProviderMetadataEnvelope envelope) {
    if (envelope.provider.trim().toLowerCase() != 'musicbrainz') {
      throw StateError(
          'Music MusicBrainz integration received ${envelope.provider} data');
    }
    if (envelope.kind != CatalogMediaKind.music) {
      throw StateError(
          'Music MusicBrainz integration received ${envelope.kind.apiValue} data');
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

  static List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
      ? [
          for (final entry in value)
            if (entry is Map) Map<String, dynamic>.from(entry)
        ]
      : const <Map<String, dynamic>>[];

  static List<String> _strings(Object? value) => value is Iterable
      ? [
          for (final entry in value)
            if (_text(entry) case final text?) text
        ]
      : const <String>[];
}
