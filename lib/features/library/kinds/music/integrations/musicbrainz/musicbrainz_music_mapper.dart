import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_candidate.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_envelope.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';

/// Maps MusicBrainz wire DTOs to typed Music provider candidates.
///
/// This is deliberately inside the Music integration. The shared provider
/// adapter only fetches MusicBrainz protocol data and never imports Music's
/// candidate or domain models.
final class MusicBrainzMusicMapper {
  const MusicBrainzMusicMapper._();

  static MusicReleaseCandidate releaseCandidate(
    MusicBrainzRelease release, {
    required String coverArtArchiveBaseUrl,
    required ProviderProvenance provenance,
    required ProviderAttribution attribution,
    bool isHydrated = false,
  }) {
    final id = _required(release.id, 'MusicBrainz release');
    final identity = _identity(id, LibraryEntityScope.release);
    final images = _releaseImages(
      id,
      coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
    );
    return MusicReleaseCandidate(
      identity: identity,
      title: _text(release.title) ?? 'Unknown release',
      releaseGroupId: _text(release.releaseGroup?.id),
      releaseGroupTitle: _text(release.releaseGroup?.title),
      artist: _join(_artistNames(release.artistCredits)),
      releaseDate: _parseDate(release.date),
      country: _text(release.country),
      barcode: _text(release.barcode),
      publisher: _publisher(release.labelInfo),
      catalogNumber: _catalogNumber(release.labelInfo),
      releaseStatus: _text(release.status),
      packaging: _text(release.packaging),
      mediums: [
        for (var index = 0; index < release.media.length; index++)
          _medium(release.media[index], index + 1),
      ],
      genres: release.genres,
      tags: release.tags,
      provenance: provenance,
      images: images,
      releaseGroupImages: [
        if (_text(release.releaseGroup?.id) case final groupId?)
          ..._groupImages(
            groupId,
            coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
          ),
      ],
      attribution: attribution,
      isHydrated: isHydrated,
    );
  }

  static MusicReleaseGroupCandidate releaseGroupCandidate(
    MusicBrainzReleaseGroupResponse group, {
    required String coverArtArchiveBaseUrl,
    required ProviderProvenance provenance,
    required ProviderAttribution attribution,
  }) {
    final id = _required(group.id, 'MusicBrainz release group');
    final identity = _identity(id, LibraryEntityScope.work);
    return MusicReleaseGroupCandidate(
      identity: identity,
      title: _text(group.title) ?? 'Unknown release group',
      artist: _join(_artistNames(group.artistCredits)),
      originalReleaseDate: _parseDate(group.firstReleaseDate),
      primaryType: _text(group.primaryType),
      releases: [
        for (final release in group.releases)
          if (_text(release.id) case final releaseId?)
            MusicReleaseSummaryCandidate(
              providerItemId: releaseId,
              title: _text(release.title) ?? 'Unknown release',
              releaseDate: _parseDate(release.date),
              country: _text(release.country),
              status: _text(release.status),
              packaging: _text(release.packaging),
              format: _firstFormat(release.media),
              publisher: _publisher(release.labelInfo),
              catalogNumber: _catalogNumber(release.labelInfo),
              barcode: _text(release.barcode),
              images: _releaseImages(
                releaseId,
                coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
              ),
            ),
      ],
      genres: group.tags,
      tags: group.tags,
      provenance: provenance,
      images: _groupImages(
        id,
        coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
      ),
      attribution: attribution,
    );
  }

  static ProviderEnvelope<MusicReleaseCandidate> releaseEnvelope(
    MusicBrainzRelease release, {
    required String coverArtArchiveBaseUrl,
    required ProviderProvenance provenance,
    required ProviderAttribution attribution,
  }) {
    final candidate = releaseCandidate(
      release,
      coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
      provenance: provenance,
      attribution: attribution,
      isHydrated: true,
    );
    return ProviderEnvelope(
      provider: candidate.identity.provider,
      providerItemId: candidate.identity.externalId,
      entityScope: candidate.entityScope,
      payload: candidate,
      provenance: provenance,
      images: candidate.images,
      attribution: attribution,
    );
  }

  static ProviderEnvelope<MusicReleaseGroupCandidate> releaseGroupEnvelope(
    MusicBrainzReleaseGroupResponse group, {
    required String providerItemId,
    required String coverArtArchiveBaseUrl,
    required ProviderProvenance provenance,
    required ProviderAttribution attribution,
  }) {
    final candidate = releaseGroupCandidate(
      group,
      coverArtArchiveBaseUrl: coverArtArchiveBaseUrl,
      provenance: provenance,
      attribution: attribution,
    );
    return ProviderEnvelope(
      provider: candidate.identity.provider,
      providerItemId: providerItemId,
      entityScope: candidate.entityScope,
      payload: candidate,
      provenance: provenance,
      images: candidate.images,
      attribution: attribution,
    );
  }

  static MusicMediumCandidate _medium(
    MusicBrainzMedium medium,
    int mediumNumber,
  ) {
    final tracks = [
      for (var index = 0; index < medium.tracks.length; index++)
        _track(medium.tracks[index], index + 1),
    ];
    return MusicMediumCandidate(
      mediumNumber: mediumNumber,
      format: _text(medium.format),
      title: _text(medium.title),
      trackCount: medium.trackCount ?? (tracks.isEmpty ? null : tracks.length),
      tracks: tracks,
    );
  }

  static MusicTrackCandidate _track(
    MusicBrainzTrack track,
    int fallbackPosition,
  ) {
    return MusicTrackCandidate(
      position: track.position ?? fallbackPosition,
      title: _text(track.title) ?? 'Untitled track',
      durationMs: track.length,
      artist: _join(_artistNames(track.artistCredits)),
      recordingId: _text(track.recordingId),
    );
  }

  static ProviderEntityIdentity _identity(
    String id,
    LibraryEntityScope scope,
  ) =>
      ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: id,
        scope: scope,
      );

  static List<ProviderImageCandidate> _releaseImages(
    String id, {
    required String coverArtArchiveBaseUrl,
  }) {
    final source = _identity(id, LibraryEntityScope.release);
    return [
      ProviderImageCandidate(
        url: Uri.parse('$coverArtArchiveBaseUrl/release/$id/front'),
        source: source,
        role: 'cover',
      ),
    ];
  }

  static List<ProviderImageCandidate> _groupImages(
    String id, {
    required String coverArtArchiveBaseUrl,
  }) {
    final source = _identity(id, LibraryEntityScope.work);
    return [
      ProviderImageCandidate(
        url: Uri.parse('$coverArtArchiveBaseUrl/release-group/$id/front'),
        source: source,
        role: 'cover',
      ),
    ];
  }

  static List<String> _artistNames(List<MusicBrainzArtistCredit> credits) => [
        for (final credit in credits)
          if (_text(credit.artist?.name ?? credit.name) case final name?) name,
      ];

  static String? _publisher(List<MusicBrainzLabelInfo> values) {
    for (final value in values) {
      if (_text(value.label?.name) case final name?) return name;
    }
    return null;
  }

  static String? _catalogNumber(List<MusicBrainzLabelInfo> values) {
    for (final value in values) {
      if (_text(value.catalogNumber) case final number?) return number;
    }
    return null;
  }

  static String? _firstFormat(List<MusicBrainzMedium> values) {
    for (final value in values) {
      if (_text(value.format) case final format?) return format;
    }
    return null;
  }

  static String? _join(Iterable<String> values) {
    final distinct = <String>[];
    for (final value in values) {
      if (!distinct.contains(value)) distinct.add(value);
    }
    return distinct.isEmpty ? null : distinct.join(', ');
  }

  static String _required(String? value, String label) {
    final text = _text(value);
    if (text == null) throw FormatException('$label is missing an id');
    return text;
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(Object? value) =>
      DateTime.tryParse(_text(value) ?? '');
}
