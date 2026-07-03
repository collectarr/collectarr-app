import 'package:collectarr_app/core/api/generated/catalog_typed_dtos.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

final class MusicTrack {
  const MusicTrack({
    required this.title,
    this.position,
    this.durationSeconds,
    this.artist,
    this.discNumber,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final String? artist;
  final int? discNumber;

  factory MusicTrack.fromDto(MusicTrackDto dto) {
    return MusicTrack(
      title: dto.title,
      position: _parseInt(dto.position),
      durationSeconds: dto.durationMs == null ? null : (dto.durationMs! ~/ 1000),
    );
  }
}

final class MusicMedia {
  const MusicMedia({
    required this.id,
    required this.title,
    required this.mediaNumber,
    this.mediaCondition,
    this.mediaType,
    this.packaging,
    this.rpm,
    this.soundType,
    this.spars,
    this.trackCount,
    this.vinylColor,
    this.vinylWeight,
    this.tracks = const <MusicTrack>[],
  });

  final String id;
  final String title;
  final int mediaNumber;
  final String? mediaCondition;
  final String? mediaType;
  final String? packaging;
  final int? rpm;
  final String? soundType;
  final String? spars;
  final int? trackCount;
  final String? vinylColor;
  final String? vinylWeight;
  final List<MusicTrack> tracks;

  factory MusicMedia.fromDto(MusicMediaDto dto) {
    return MusicMedia(
      id: dto.id,
      title: dto.title,
      mediaNumber: dto.mediaNumber,
      mediaCondition: dto.mediaCondition,
      mediaType: dto.mediaType,
      packaging: dto.packaging,
      rpm: dto.rpm,
      soundType: dto.soundType,
      spars: dto.spars,
      trackCount: dto.trackCount,
      vinylColor: dto.vinylColor,
      vinylWeight: dto.vinylWeight,
      tracks: [
        for (final track in dto.tracks) MusicTrack.fromDto(track),
      ],
    );
  }

  CatalogDisc toCatalogDisc() {
    return CatalogDisc(
      discNumber: mediaNumber,
      discName: title,
    );
  }

  List<CatalogTrack> toCatalogTracks() {
    return [
      for (final track in tracks)
        CatalogTrack(
          title: track.title,
          position: track.position,
          durationSeconds: track.durationSeconds,
          artist: track.artist,
          discNumber: track.discNumber ?? mediaNumber,
        ),
    ];
  }
}

final class MusicRelease {
  const MusicRelease({
    required this.id,
    required this.title,
    this.artist,
    this.subtitle,
    this.publisher,
    this.catalogNumber,
    this.recordingDate,
    this.originalReleaseDate,
    this.releaseDate,
    this.releaseStatus,
    this.releaseType,
    this.sortTitle,
    this.studio,
    this.trackCount,
    this.barcode,
    this.coverImageUrl,
    this.language,
    this.countryCode,
    this.extras,
    this.mediaCondition,
    this.instrument,
    this.composition,
    this.rpm,
    this.spars,
    this.soundType,
    this.vinylColor,
    this.vinylWeight,
    this.genres = const <String>[],
    this.creators = const <Map<String, dynamic>>[],
    this.identifiers = const <dynamic>[],
    this.media = const <MusicMedia>[],
  });

  final String id;
  final String title;
  final String? artist;
  final String? subtitle;
  final String? publisher;
  final String? catalogNumber;
  final DateTime? recordingDate;
  final DateTime? originalReleaseDate;
  final DateTime? releaseDate;
  final String? releaseStatus;
  final String? releaseType;
  final String? sortTitle;
  final String? studio;
  final int? trackCount;
  final String? barcode;
  final String? coverImageUrl;
  final String? language;
  final String? countryCode;
  final String? extras;
  final String? mediaCondition;
  final String? instrument;
  final String? composition;
  final String? rpm;
  final String? spars;
  final String? soundType;
  final String? vinylColor;
  final String? vinylWeight;
  final List<String> genres;
  final List<Map<String, dynamic>> creators;
  final List<dynamic> identifiers;
  final List<MusicMedia> media;

  List<CatalogDisc> get discs =>
      [for (final media in this.media) media.toCatalogDisc()];

  List<CatalogTrack> get tracks =>
      [for (final media in this.media) ...media.toCatalogTracks()];

  bool get isLive => extras?.toLowerCase().contains('live') ?? false;

  factory MusicRelease.fromDto(MusicReleaseDto dto) {
    final contributors = [
      for (final entry in dto.contributions)
        if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
    ];
    return MusicRelease(
      id: dto.id,
      title: dto.title,
      artist: _artistFromContributions(contributors),
      subtitle: dto.subtitle,
      publisher: dto.publisher,
      catalogNumber: dto.extras,
      recordingDate: dto.recordingDate,
      originalReleaseDate: dto.releaseDate,
      releaseDate: dto.releaseDate,
      releaseStatus: dto.releaseStatus,
      releaseType: dto.releaseType,
      sortTitle: dto.sortTitle,
      studio: dto.studio,
      trackCount: dto.trackCount,
      barcode: dto.barcode,
      coverImageUrl: dto.coverImageUrl,
      language: dto.language,
      countryCode: dto.countryCode,
      extras: dto.extras,
      mediaCondition: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.mediaCondition),
      instrument: null,
      composition: null,
      rpm: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.rpm?.toString()),
      spars: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.spars),
      soundType: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.soundType),
      vinylColor: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.vinylColor),
      vinylWeight: _stringOrNull(dto.media.isEmpty ? null : dto.media.first.vinylWeight),
      genres: _stringList(dto.raw['genres']),
      creators: contributors,
      identifiers: List<dynamic>.unmodifiable(dto.identifiers),
      media: [for (final media in dto.media) MusicMedia.fromDto(media)],
    );
  }
}

String? _artistFromContributions(List<Map<String, dynamic>> contributions) {
  for (final contribution in contributions) {
    final role = contribution['role']?.toString().toLowerCase() ?? '';
    if (!role.contains('artist') &&
        !role.contains('performer') &&
        !role.contains('band') &&
        !role.contains('ensemble')) {
      continue;
    }
    final name = contribution['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
  }
  for (final contribution in contributions) {
    final name = contribution['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
  }
  return null;
}

int? _parseInt(String value) => int.tryParse(value.trim());

String? _stringOrNull(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty)
        entry.toString().trim(),
  ];
}
