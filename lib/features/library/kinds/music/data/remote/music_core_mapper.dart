import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

typedef MusicReleaseDtoFetcher = Future<MusicReleaseDto> Function(String id);

/// Maps generated Core Music DTOs into Music-owned domain models.
final class MusicCoreMapper {
  const MusicCoreMapper._();

  static MusicRelease fromReleaseDto(MusicReleaseDto dto) {
    _validateKind(dto.kind, 'release', dto.raw);
    final media = dto.media.map(fromMediaDto).toList(growable: false);
    final tracks = media.expand((disc) => disc.tracks).toList(growable: false);
    return MusicRelease(
      id: MusicReleaseId(dto.id),
      title: dto.title,
      artist: _text(dto.raw['artist']) ?? dto.subtitle,
      publisher: dto.publisher,
      catalogNumber: dto.extras,
      barcode: dto.barcodeValue,
      releaseDate: dto.releaseDateValue,
      recordingDate: dto.recordingDate,
      releaseStatus: dto.releaseStatus,
      releaseType: dto.releaseType,
      sortTitle: dto.sortTitle,
      subtitle: dto.subtitle,
      studio: dto.studio,
      countryCode: dto.countryCode,
      language: dto.language,
      coverImageUrl: dto.coverImageUrlValue,
      genres: _strings(dto.raw['genres']),
      contributions: _maps(dto.contributions),
      media: media,
      tracks: tracks,
      rawPayload: dto.toJson(),
    );
  }

  static MusicMedia fromMediaDto(MusicMediaDto dto) {
    _validateKind(dto.kind, 'media', dto.raw);
    return MusicMedia(
      id: MusicMediaId(dto.id),
      releaseId: MusicReleaseId(dto.releaseId),
      mediaNumber: dto.mediaNumber,
      mediaCondition: dto.mediaCondition,
      mediaType: dto.mediaType,
      packaging: dto.packaging,
      rpm: dto.rpm,
      soundType: dto.soundType,
      spars: dto.spars,
      title: dto.titleValue,
      trackCount: dto.trackCount,
      tracks: dto.tracks.map(fromTrackDto).toList(growable: false),
      vinylColor: dto.vinylColor,
      vinylWeight: dto.vinylWeight,
      rawPayload: dto.toJson(),
    );
  }

  static MusicTrack fromTrackDto(MusicTrackDto dto) {
    _validateKind(dto.kind, 'track', dto.raw);
    return MusicTrack(
      id: MusicTrackId(dto.id),
      mediaId: MusicMediaId(dto.mediaId),
      position: dto.position,
      title: dto.title,
      composition: dto.composition,
      durationMs: dto.durationMs,
      instrument: dto.instrument,
      rawPayload: dto.toJson(),
    );
  }

  static void _validateKind(
    String? kind,
    String dtoType,
    Map<String, dynamic> raw,
  ) {
    final rawKind = _text(raw['kind']) ?? _text(kind);
    if (rawKind != null && rawKind.toLowerCase() != 'music') {
      throw StateError('Expected a music Core DTO for $dtoType, got $rawKind');
    }
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
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
        if (_text(entry) case final value?) value,
    ];
  }
}
