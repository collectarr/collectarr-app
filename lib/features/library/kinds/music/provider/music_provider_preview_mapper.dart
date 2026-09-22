import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';

/// Projects typed Music provider data into the existing admin preview DTO.
///
/// The DTO is deliberately kept at this edge because the shared Add host
/// renders previews, while Music owns the candidate and its medium/track
/// semantics.
AdminProviderPreview providerPreviewFromMusicReleaseCandidate(
  MusicReleaseCandidate candidate,
) {
  final tracks = [
    for (final medium in candidate.mediums)
      for (final track in medium.tracks)
        CatalogTrackDto(
          title: track.title,
          position: track.position,
          artist: track.artist,
          durationSeconds:
              track.durationMs == null ? null : track.durationMs! ~/ 1000,
          discNumber: medium.mediumNumber,
        ),
  ];
  return AdminProviderPreview(
    provider: candidate.identity.provider,
    providerItemId: candidate.identity.externalId,
    kind: candidate.kind.apiValue,
    title: candidate.title,
    synopsis: candidate.summary,
    publisher: candidate.publisher,
    releaseDate: candidate.releaseDate,
    barcode: candidate.barcode,
    coverImageUrl: candidate.primaryImageUrl?.toString(),
    country: candidate.country,
    language: candidate.language,
    genres: candidate.genres,
    creators: [
      if (candidate.artist?.trim() case final artist? when artist.isNotEmpty)
        ProviderPreviewCredit(name: artist, role: 'Artist'),
    ],
    music: {
      'entity_type': 'music_release',
      if (candidate.artist != null) 'artist': candidate.artist,
      if (candidate.releaseGroupId != null)
        'release_group_id': candidate.releaseGroupId,
      if (candidate.releaseType != null) 'release_type': candidate.releaseType,
      if (candidate.releaseStatus != null)
        'release_status': candidate.releaseStatus,
      if (candidate.catalogNumber != null)
        'catalog_number': candidate.catalogNumber,
      'track_count': tracks.length,
      'tracks': tracks.map((track) => track.toJson()).toList(growable: false),
      'mediums': [
        for (final medium in candidate.mediums)
          {
            'medium_number': medium.mediumNumber,
            if (medium.format != null) 'medium_type': medium.format,
            if (medium.title != null) 'title': medium.title,
            if (medium.trackCount != null) 'track_count': medium.trackCount,
          },
      ],
    },
  );
}

/// Projects a typed Music release-group candidate into the admin preview
/// shape while retaining every concrete child release summary.
AdminProviderPreview providerPreviewFromMusicReleaseGroupCandidate(
  MusicReleaseGroupCandidate candidate,
) {
  final groupId = candidate.identity.externalId;
  final releaseSummaries = [
    for (final release in candidate.releases)
      {
        'id': release.providerItemId,
        'title': release.title,
        'release_group_id': groupId,
        if (release.releaseDate != null)
          'release_date': release.releaseDate!.toIso8601String(),
        if (release.country != null) 'country_code': release.country,
        if (release.status != null) 'release_status': release.status,
        if (release.packaging != null) 'packaging': release.packaging,
        if (release.format != null) 'format': release.format,
        if (release.publisher != null) 'publisher': release.publisher,
        if (release.catalogNumber != null)
          'catalog_number': release.catalogNumber,
        if (release.barcode != null) 'barcode': release.barcode,
        'cover_image_url': release.images.isNotEmpty
            ? release.images.first.url.toString()
            : 'https://coverartarchive.org/release/${release.providerItemId}/front',
      },
  ];
  return AdminProviderPreview(
    provider: candidate.identity.provider,
    providerItemId: candidate.providerItemId,
    kind: candidate.kind.apiValue,
    title: candidate.title,
    releaseDate: candidate.originalReleaseDate,
    coverImageUrl: candidate.primaryImageUrl?.toString(),
    genres: candidate.genres,
    creators: [
      if (candidate.artist?.trim() case final artist? when artist.isNotEmpty)
        ProviderPreviewCredit(name: artist, role: 'Artist'),
    ],
    music: {
      'entity_type': 'music_release_group',
      if (candidate.artist != null) 'artist': candidate.artist,
      'release_group_id': groupId,
      'release_group_title': candidate.title,
      'releases': releaseSummaries,
      'track_count': 0,
      'tracks': const <Map<String, Object?>>[],
    },
  );
}
