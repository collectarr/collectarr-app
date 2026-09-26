import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';

/// Maps typed MusicBrainz provider candidates into MusicAlbum catalog values.
/// The remaining hierarchy conversion methods support the old local catalog
/// path while that persistence is moved to Catalog Item v1.
final class MusicMusicBrainzMapper {
  const MusicMusicBrainzMapper._();

  /// Maps one concrete provider release to the v1 catalog item shape.
  ///
  /// The release-group ID is provider provenance only; a collectible album
  /// remains addressable without a parent entity.
  static MusicAlbum albumFromCandidate(MusicReleaseCandidate candidate) {
    final albumId = MusicAlbumId(
      _providerScopedIdForProvider(
        candidate.identity.provider,
        candidate.identity.externalId,
      ),
    );
    final formats = candidate.mediums
        .map((medium) => _text(medium.format))
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    return MusicAlbum(
      id: albumId,
      title: candidate.title,
      artists: [
        if (_text(candidate.artist) case final artist?)
          MusicAlbumArtist(name: artist),
      ],
      releaseDate: candidate.releaseDate == null
          ? null
          : PartialDate.fromDateTime(candidate.releaseDate!),
      labels: [
        if (_text(candidate.publisher) case final label?)
          MusicAlbumLabel(
            name: label,
            catalogNumber: _text(candidate.catalogNumber),
          ),
      ],
      format: formats.isEmpty ? candidate.releaseType : formats.join(', '),
      barcode: _text(candidate.barcode),
      catalogNumber: _text(candidate.catalogNumber),
      genres: candidate.genres,
      packaging: _text(candidate.packaging),
      country: _text(candidate.country),
      coverImageUrl: candidate.primaryImageUrl?.toString(),
      discTitles: [
        for (final medium in candidate.mediums)
          if (_text(medium.title) case final title?)
            MusicAlbumDiscTitle(
              discNumber: medium.mediumNumber,
              title: title,
            ),
      ],
      tracks: _albumTracks(candidate, albumId),
    );
  }

  static List<MusicAlbumTrack> _albumTracks(
    MusicReleaseCandidate candidate,
    MusicAlbumId albumId,
  ) {
    final tracks = <MusicAlbumTrack>[];
    for (final medium in candidate.mediums) {
      var fallbackPosition = 0;
      for (final track in medium.tracks) {
        if (track.isHeader) continue;
        final title = _text(track.title);
        if (title == null) continue;
        fallbackPosition++;
        tracks.add(
          MusicAlbumTrack(
            albumId: albumId,
            discNumber: medium.mediumNumber,
            position: track.position > 0 ? track.position : fallbackPosition,
            title: title,
            artist: _text(track.artist),
            durationMs: track.durationMs,
          ),
        );
      }
    }
    return List<MusicAlbumTrack>.unmodifiable(tracks);
  }

  static MusicRelease fromNative(MusicBrainzRelease release) {
    final releaseId = _releaseId(release.id, 'MusicBrainz release');
    final releaseGroupExternalId = _text(release.releaseGroup?.id);
    if (releaseGroupExternalId == null) {
      throw StateError(
        'Cannot import Music release ${releaseId.value} without its '
        'canonical release-group identity.',
      );
    }
    final releaseGroupId = MusicReleaseGroupId(
      _providerScopedId(releaseGroupExternalId),
    );
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
    );
  }

  /// Accepts the typed provider proposition directly.  This is the canonical
  /// provider-boundary handoff used by Music Add; it does not serialize the
  /// candidate and does not reparse a CatalogItemDto.
  static MusicRelease fromCandidate(MusicReleaseCandidate candidate) {
    final provider = candidate.identity.provider;
    final releaseId = MusicReleaseId(
      _providerScopedIdForProvider(provider, candidate.identity.externalId),
    );
    final releaseGroupExternalId = candidate.releaseGroupId?.trim();
    if (releaseGroupExternalId == null || releaseGroupExternalId.isEmpty) {
      throw StateError(
        'Cannot import Music release ${candidate.identity.externalId} '
        'without its canonical release-group identity.',
      );
    }
    final groupId = MusicReleaseGroupId(
      _providerScopedIdForProvider(provider, releaseGroupExternalId),
    );
    return MusicRelease(
      id: releaseId,
      releaseGroupId: groupId,
      title: candidate.title,
      publisher: candidate.publisher,
      catalogNumber: candidate.catalogNumber,
      barcode: candidate.barcode,
      releaseDate: candidate.releaseDate,
      releaseStatus: candidate.releaseStatus,
      releaseType: candidate.releaseType,
      countryCode: candidate.country,
      language: candidate.language,
      packaging: candidate.packaging,
      coverImageUrl: candidate.primaryImageUrl?.toString(),
      contributions: _contributionsFromArtist(
        candidate.artist,
        releaseId,
      ),
      mediums: [
        for (final medium in candidate.mediums)
          _mediumFromCandidate(releaseId, medium),
      ],
    );
  }

  static MusicReleaseGroup releaseGroupFromCandidate(
    MusicReleaseGroupCandidate candidate,
  ) {
    final provider = candidate.identity.provider;
    final groupId = MusicReleaseGroupId(
      _providerScopedIdForProvider(provider, candidate.identity.externalId),
    );
    return MusicReleaseGroup(
      id: groupId,
      title: candidate.title,
      artist: candidate.artist,
      originalReleaseDate: candidate.originalReleaseDate,
      genres: candidate.genres,
      coverImageUrl: candidate.primaryImageUrl?.toString(),
      releases: [
        for (final summary in candidate.releases)
          MusicRelease(
            id: MusicReleaseId(
              _providerScopedIdForProvider(provider, summary.providerItemId),
            ),
            releaseGroupId: groupId,
            title: summary.title,
            releaseDate: summary.releaseDate,
            releaseStatus: summary.status,
            publisher: summary.publisher,
            catalogNumber: summary.catalogNumber,
            barcode: summary.barcode,
            packaging: summary.packaging,
            countryCode: summary.country,
            mediumTypesSummary:
                summary.format == null ? const [] : [summary.format!],
            coverImageUrl: summary.images.isEmpty
                ? null
                : summary.images.first.url.toString(),
          ),
      ],
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
      coverImageUrl: _coverGroupUrl(
        _text(release.releaseGroup?.id) ?? '',
      ),
      releases: [mappedRelease],
    );
  }

  static MusicReleaseId _releaseId(String? id, String label) =>
      MusicReleaseId(_providerScopedId(_requiredText(id, label)));

  static String _providerScopedId(String value) =>
      value.startsWith('musicbrainz:') ? value : 'musicbrainz:$value';

  static String _providerScopedIdForProvider(String provider, String value) {
    final normalizedProvider = provider.trim().toLowerCase();
    return value.startsWith('$normalizedProvider:')
        ? value
        : '$normalizedProvider:$value';
  }

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
    );
  }

  static MusicMedium _mediumFromCandidate(
    MusicReleaseId releaseId,
    MusicMediumCandidate source,
  ) {
    final mediumId = MusicMediumId(
      '${releaseId.value}:medium:${source.mediumNumber}',
    );
    final tracks = [
      for (final track in source.tracks)
        MusicTrack(
          id: MusicTrackId('${mediumId.value}:track:${track.position}'),
          mediumId: mediumId,
          position: track.position.toString(),
          title: track.title,
          artist: track.artist,
          durationMs: track.durationMs,
          recordingId: track.recordingId,
          isHeader: track.isHeader,
          indentLevel: track.indentLevel,
          parentHeaderId: track.parentHeaderId,
        ),
    ];
    return MusicMedium(
      id: mediumId,
      releaseId: releaseId,
      mediumNumber: source.mediumNumber,
      mediumType: source.format,
      title: source.title,
      trackCount: source.trackCount ?? (tracks.isEmpty ? null : tracks.length),
      tracks: tracks,
    );
  }

  static List<MusicReleaseContribution> _contributionsFromArtist(
    String? artist,
    MusicReleaseId releaseId,
  ) {
    final name = _text(artist);
    if (name == null) return const <MusicReleaseContribution>[];
    return [
      MusicReleaseContribution(
        id: MusicReleaseContributionId('${releaseId.value}:contribution:1'),
        releaseId: releaseId,
        personId: name,
        role: 'Artist',
        sequence: 1,
        displayName: name,
      ),
    ];
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
      recordingId: source.recordingId,
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
              displayName: name,
            ),
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
      'https://coverartarchive.org/release/$providerId/front';

  static String _coverGroupUrl(String providerId) =>
      'https://coverartarchive.org/release-group/$providerId/front';

  static String _requiredText(String? value, String label) {
    final text = _text(value);
    if (text == null) throw FormatException('$label is missing an id');
    return text;
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
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
}
