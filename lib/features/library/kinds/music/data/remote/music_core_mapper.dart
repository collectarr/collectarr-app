import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

typedef MusicReleaseDtoFetcher = Future<MusicReleaseDto> Function(String id);

/// Maps Core's canonical Music graph into the app's typed Music domain.
///
/// Core exposes release groups at the library boundary and concrete releases
/// for release-level screens. No physical medium is represented as a release.
final class MusicCoreMapper {
  const MusicCoreMapper._();

  static MusicReleaseGroup fromReleaseGroupDto(MusicReleaseGroupDto dto) {
    _validateKind(dto.kind, 'release group');
    return MusicReleaseGroup(
      id: MusicReleaseGroupId(dto.id),
      title: dto.title,
      sortTitle: dto.sortTitle,
      originalTitle: dto.originalTitle,
      artist: dto.artist,
      originalReleaseDate: _fullDate(
        dto.originalReleaseDateParts ?? dto.originalReleaseDateValue,
      ),
      originalReleaseDateParts:
          dto.originalReleaseDateParts ?? dto.originalReleaseDateValue,
      recordingDate: _fullDate(
        dto.recordingDateParts ?? dto.recordingDateValue,
      ),
      recordingDateParts: dto.recordingDateParts ?? dto.recordingDateValue,
      artistCredits: [
        for (final credit in dto.artistCredits) _artistCredit(credit),
      ],
      studio: dto.studio,
      isLive: dto.isLive,
      genres: dto.genres,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      externalLinks: _externalLinks(dto.externalLinks),
      releases: [
        for (final release in dto.releases) _fromReleaseSummary(release),
      ],
    );
  }

  static MusicRelease _fromReleaseSummary(MusicReleaseSummaryDto dto) {
    final date = dto.releaseDateParts ?? dto.releaseDateValue;
    return MusicRelease(
      id: MusicReleaseId(dto.id),
      releaseGroupId: MusicReleaseGroupId(dto.releaseGroupId),
      title: dto.title,
      releaseDate: _fullDate(date),
      releaseDateParts: date,
      releaseType: dto.releaseType,
      releaseStatus: dto.releaseStatus,
      publisher: dto.publisher,
      barcode: dto.barcodeValue,
      catalogNumber: dto.catalogNumber,
      coverImageUrl: dto.coverImageUrlValue,
      mediumTypesSummary: dto.mediumTypes,
    );
  }

  static MusicRelease fromReleaseDto(MusicReleaseDto dto) {
    _validateKind(dto.kind, 'release');
    final date = dto.releaseDateParts ?? dto.releaseDateValue;
    return MusicRelease(
      id: MusicReleaseId(dto.id),
      releaseGroupId: MusicReleaseGroupId(dto.releaseGroupId),
      title: dto.title,
      sortTitle: dto.sortTitle,
      subtitle: dto.subtitle,
      releaseType: dto.releaseType,
      releaseStatus: dto.releaseStatus,
      releaseDate: _fullDate(date),
      releaseDateParts: date,
      publisher: dto.publisher,
      countryCode: dto.countryCode,
      language: dto.language,
      barcode: dto.barcodeValue,
      upc: dto.upc,
      catalogNumber: dto.catalogNumber,
      packaging: dto.packaging,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      contributions: [
        for (var index = 0; index < dto.contributions.length; index++)
          _contribution(dto.id, dto.contributions[index], index),
      ],
      artistCredits: [
        for (final credit in dto.artistCredits) _artistCredit(credit),
      ],
      labels: [for (final label in dto.labels) _label(label)],
      identifiers: [
        for (final identifier in dto.identifiers)
          _identifier(dto.id, identifier),
      ],
      mediums: dto.mediums.map(fromMediumDto).toList(growable: false),
    );
  }

  static MusicReleaseGroup releaseGroupFromReleaseDto(MusicReleaseDto dto) {
    final release = fromReleaseDto(dto);
    final artist = _artistFromCredits(release.artistCredits) ??
        _artistFromContributions(release.contributions);
    return MusicReleaseGroup(
      id: release.releaseGroupId,
      title: release.title,
      artist: artist,
      originalReleaseDate: release.releaseDate,
      originalReleaseDateParts: release.releaseDateParts,
      artistCredits: release.artistCredits,
      coverImageUrl: release.coverImageUrl,
      coverImageKey: release.coverImageKey,
      releases: [release],
    );
  }

  static MusicMedium fromMediumDto(MusicMediumDto dto) {
    _validateKind(dto.kind, 'medium');
    return MusicMedium(
      id: MusicMediumId(dto.id),
      releaseId: MusicReleaseId(dto.releaseId),
      mediumNumber: dto.mediumNumber,
      mediumType: dto.mediumType,
      title: dto.titleValue,
      trackCount: dto.trackCount,
      expectedTrackCount: dto.expectedTrackCount,
      missingTrackCount: dto.missingTrackCount,
      missingTrackPositions: dto.missingTrackPositions,
      toc: dto.toc,
      cddbId: dto.cddbId,
      leadoutOffset: dto.leadoutOffset,
      bpDiscId: dto.bpDiscId,
      soundType: dto.soundType,
      vinylColor: dto.vinylColor,
      vinylWeight: dto.vinylWeight,
      rpm: dto.rpm,
      spars: dto.spars,
      tracks: dto.tracks.map(fromTrackDto).toList(growable: false),
    );
  }

  static MusicTrack fromTrackDto(MusicTrackDto dto) {
    _validateKind(dto.kind, 'track');
    return MusicTrack(
      id: MusicTrackId(dto.id),
      mediumId: MusicMediumId(dto.mediumId),
      position: dto.position,
      title: dto.title,
      artist: dto.artist,
      composition: dto.composition,
      durationMs: dto.durationMs,
      offsetMs: dto.offsetMs,
      bitrateKbps: dto.bitrateKbps,
      fileSizeBytes: dto.fileSizeBytes,
      trackHash: dto.trackHash,
      instrument: dto.instrument,
      isHeader: dto.isHeader,
      indentLevel: dto.indentLevel,
      parentHeaderId: dto.parentHeaderId,
      recordingId: dto.recordingId,
    );
  }

  static MusicArtistCredit _artistCredit(MusicArtistCreditDto dto) =>
      MusicArtistCredit(
        id: dto.id,
        creditedName: dto.creditedName,
        artistId: dto.artistId,
        joinPhrase: dto.joinPhrase,
        sequence: dto.sequence,
        source: dto.source,
      );

  static MusicReleaseLabel _label(MusicReleaseLabelDto dto) =>
      MusicReleaseLabel(
        id: dto.id,
        labelId: dto.labelId,
        labelName: dto.labelName,
        catalogNumber: dto.catalogNumber,
        sequence: dto.sequence,
        source: dto.source,
      );

  static MusicReleaseContribution _contribution(
    String releaseId,
    MusicContributorDto dto,
    int index,
  ) =>
      MusicReleaseContribution(
        id: MusicReleaseContributionId(
          '$releaseId:contribution:${dto.sequence ?? index}:${dto.personId}',
        ),
        releaseId: MusicReleaseId(releaseId),
        personId: dto.personId,
        role: dto.role,
        roleId: dto.roleId,
        sequence: dto.sequence,
        displayName: dto.name,
        imageUrl: dto.imageUrl,
      );

  static MusicReleaseIdentifier _identifier(
    String releaseId,
    MusicIdentifierDto dto,
  ) =>
      MusicReleaseIdentifier(
        id: MusicReleaseIdentifierId(dto.id),
        releaseId: MusicReleaseId(releaseId),
        identifierType: dto.identifierType,
        value: dto.value,
        normalizedValue: dto.normalizedValue,
        isPrimary: dto.isPrimary,
        sourceProvider: dto.sourceProvider,
      );

  static DateTime? _fullDate(PartialDate? value) => value?.asDateTime;

  static void _validateKind(String? kind, String entity) {
    if (kind != null && kind != 'music') {
      throw StateError('Expected Music $entity DTO, received $kind');
    }
  }

  static List<MusicExternalLink> _externalLinks(
    Iterable<Map<String, dynamic>> source,
  ) {
    final values = <MusicExternalLink>[];
    final seen = <String>{};
    for (final entry in source) {
      final url = entry['url']?.toString().trim() ?? '';
      if (url.isEmpty || !seen.add(url)) continue;
      values.add(MusicExternalLink.fromJson(entry));
    }
    return values;
  }

  static String? _artistFromCredits(Iterable<MusicArtistCredit> credits) {
    for (final credit in credits) {
      if (credit.creditedName.trim().isNotEmpty) return credit.creditedName;
    }
    return null;
  }

  static String? _artistFromContributions(
    Iterable<MusicReleaseContribution> contributions,
  ) {
    for (final contribution in contributions) {
      final role = contribution.role.toLowerCase();
      if (role.contains('artist') || role.contains('performer')) {
        final name = contribution.displayName;
        if (name != null) return name;
      }
    }
    return null;
  }
}
