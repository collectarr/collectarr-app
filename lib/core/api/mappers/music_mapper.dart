import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';

List<String>? tryGetList(dynamic Function() fn) {
  try {
    final res = fn();
    if (res is List) return res.whereType<String>().toList();
  } catch (_) {}
  return null;
}

MusicRelease musicReleaseFromDto(MusicReleaseDto dto) {
  final discs = dto.media
      .map((m) => musicMediaFromDto(m))
      .toList(growable: false);

  // Flatten all tracks for the top-level tracks list.
  final allTracks = discs.expand((d) => d.tracks).toList(growable: false);

  return MusicRelease(
    id: dto.id,
    title: dto.title,
    artist: dto.subtitle,
    publisher: dto.publisher,
    catalogNumber: dto.extras,
    upc: dto.barcode,
    releaseDate: dto.releaseDate,
    releaseStatus: dto.releaseStatus,
    releaseType: dto.releaseType,
    coverImageUrl: dto.coverImageUrl,
    genres: (tryGetList(() => (dto as dynamic).genres) ??
            tryGetList(() => (dto as dynamic).toJson()['genres']) ??
            (dto is Map ? tryGetList(() => (dto as Map)['genres']) : null)) ??
        const <String>[],
    discs: discs,
    tracks: allTracks,
  );
}

MusicDiscRef musicMediaFromDto(MusicMediaDto dto) {
  final tracks = dto.tracks
      .map((t) => musicTrackFromDto(t))
      .toList(growable: false);
  return MusicDiscRef(
    discNumber: dto.mediaNumber,
    discName: dto.titleValue,
    discFormat: dto.mediaType,
    trackCount: dto.trackCount,
    mediaCondition: dto.mediaCondition,
    tracks: tracks,
  );
}

MusicTrackRef musicTrackFromDto(MusicTrackDto dto) {
  return MusicTrackRef(
    title: dto.title,
    position: int.tryParse(dto.position),
    durationSeconds:
        dto.durationMs != null ? (dto.durationMs! / 1000).round() : null,
  );
}
