import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
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
    _validateKind(dto.kind, 'release group', dto.raw);
    final rawReleases = _maps(dto.raw['releases']);
    return MusicReleaseGroup(
      id: MusicReleaseGroupId(dto.id),
      title: dto.title,
      sortTitle: dto.sortTitle,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      artist: dto.artist,
      originalReleaseDate: dto.originalReleaseDate,
      recordingDate: dto.recordingDate,
      studio: dto.studio,
      isLive: dto.isLive,
      genres: dto.genres,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      externalLinks: _externalLinks(dto.raw),
      releases: [
        for (final release in dto.releases)
          MusicRelease(
            id: MusicReleaseId(release.id),
            releaseGroupId: MusicReleaseGroupId(release.releaseGroupId),
            title: release.title,
            releaseDate: release.releaseDate,
            releaseType: release.releaseType,
            releaseStatus: release.releaseStatus,
            publisher: release.publisher,
            barcode: release.barcode,
            catalogNumber: release.catalogNumber,
            coverImageUrl: release.coverImageUrl,
            boxSetMembership: musicBoxSetMembershipFromJson(
              rawReleases.firstWhere(
                (raw) => raw['id']?.toString() == release.id,
                orElse: () => const <String, dynamic>{},
              ),
            ),
          ),
      ],
      metadataJson: dto.raw,
    );
  }

  static MusicRelease fromReleaseDto(MusicReleaseDto dto) {
    _validateKind(dto.kind, 'release', dto.raw);
    return MusicRelease(
      id: MusicReleaseId(dto.id),
      releaseGroupId: MusicReleaseGroupId(dto.releaseGroupId),
      title: dto.title,
      sortTitle: dto.sortTitle,
      subtitle: dto.subtitle,
      releaseType: dto.releaseType,
      releaseStatus: dto.releaseStatus,
      releaseDate: dto.releaseDateValue,
      publisher: dto.publisher,
      countryCode: dto.countryCode,
      language: dto.language,
      barcode: dto.barcodeValue,
      upc: dto.upc,
      catalogNumber: dto.catalogNumber,
      packaging: dto.packaging,
      coverImageUrl: dto.coverImageUrlValue,
      coverImageKey: dto.coverImageKey,
      boxSetMembership: musicBoxSetMembershipFromJson(dto.raw),
      contributions: _contributions(dto.contributions),
      identifiers: _identifiers(dto.identifiers),
      mediums: dto.mediums.map(fromMediumDto).toList(growable: false),
      metadataJson: dto.raw,
    );
  }

  static MusicReleaseGroup releaseGroupFromReleaseDto(MusicReleaseDto dto) {
    final release = fromReleaseDto(dto);
    final group = MusicReleaseGroup(
      id: release.releaseGroupId,
      title: _text(dto.raw['release_group_title']) ?? release.title,
      artist: _text(dto.raw['artist']) ??
          _artistFromContributions(release.contributions),
      originalTitle: _text(dto.raw['original_title']),
      synopsis: _text(dto.raw['synopsis']),
      originalReleaseDate:
          _date(dto.raw['original_release_date']) ?? release.releaseDate,
      recordingDate: _date(dto.raw['recording_date']),
      studio: _text(dto.raw['studio']),
      isLive: dto.raw['is_live'] is bool ? dto.raw['is_live'] as bool : null,
      genres: _strings(dto.raw['genres']),
      coverImageUrl: release.coverImageUrl,
      coverImageKey: release.coverImageKey,
      releases: [release],
      metadataJson: dto.raw,
    );
    return group;
  }

  static MusicMedium fromMediumDto(MusicMediumDto dto) {
    _validateKind(dto.kind, 'medium', dto.raw);
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
      mediaCondition: dto.mediaCondition,
      soundType: dto.soundType,
      vinylColor: dto.vinylColor,
      vinylWeight: dto.vinylWeight,
      rpm: dto.rpm,
      spars: dto.spars,
      tracks: dto.tracks.map(fromTrackDto).toList(growable: false),
      metadataJson: dto.raw,
    );
  }

  static MusicTrack fromTrackDto(MusicTrackDto dto) {
    _validateKind(dto.kind, 'track', dto.raw);
    return MusicTrack(
      id: MusicTrackId(dto.id),
      mediumId: MusicMediumId(dto.mediumId),
      position: dto.position,
      title: dto.titleValue,
      artist: dto.artist,
      composition: dto.composition,
      durationMs: dto.durationMs,
      offsetMs: dto.offsetMs,
      bitrateKbps: dto.bitrateKbps,
      fileSizeBytes: dto.fileSizeBytes,
      trackHash: dto.trackHash,
      instrument: dto.instrument,
      isHeader: dto.isHeader || dto.raw['entry_type']?.toString() == 'header',
      indentLevel: dto.indentLevel,
      parentHeaderId: dto.parentHeaderId,
      metadataJson: dto.raw,
    );
  }

  static void _validateKind(
      String? kind, String entity, Map<String, dynamic> raw) {
    final value = raw['kind']?.toString() ?? kind;
    if (value != null && value != 'music') {
      throw StateError('Expected Music $entity DTO, received $value');
    }
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _date(Object? value) =>
      DateTime.tryParse(value?.toString().trim() ?? '');

  static List<String> _strings(Object? value) => value is Iterable
      ? [
          for (final entry in value)
            if (_text(entry) case final text?) text
        ]
      : const <String>[];

  static List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
      ? [
          for (final entry in value)
            if (entry is Map) Map<String, dynamic>.from(entry),
        ]
      : const <Map<String, dynamic>>[];

  static List<MusicExternalLink> _externalLinks(Map<String, dynamic> raw) {
    final values = <MusicExternalLink>[];
    final seen = <String>{};
    for (final source in [raw['external_links'], raw['trailer_urls']]) {
      if (source is! Iterable) continue;
      for (final entry in source) {
        if (entry is! Map) continue;
        final value = Map<String, dynamic>.from(entry);
        final url = value['url']?.toString().trim() ?? '';
        if (url.isEmpty || !seen.add(url)) {
          continue;
        }
        values.add(MusicExternalLink.fromJson(value));
      }
    }
    return values;
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

  static List<MusicReleaseContribution> _contributions(Object? value) => [
        for (final entry in _maps(value))
          MusicReleaseContribution.fromJson(entry),
      ];

  static List<MusicReleaseIdentifier> _identifiers(Object? value) => [
        for (final entry in _maps(value))
          MusicReleaseIdentifier.fromJson(entry),
      ];
}
