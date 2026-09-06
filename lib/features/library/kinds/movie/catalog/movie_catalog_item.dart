import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Movie-owned catalog snapshot used by the Movie workspace and release
/// browser. This intentionally duplicates the TV/Anime technical shape while
/// those kinds complete their own vertical snapshots.
final class MovieCatalogWorkMetadata {
  const MovieCatalogWorkMetadata({
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.releaseDate,
    this.originalLanguage,
    this.genres = const [],
    this.series,
  });

  final String title;
  final String? originalTitle;
  final String? synopsis;
  final DateTime? releaseDate;
  final String? originalLanguage;
  final List<String> genres;
  final CatalogSeriesDetails? series;
}

final class MovieCatalogTechnicalMetadata {
  const MovieCatalogTechnicalMetadata({
    this.runtimeMinutes,
    this.color,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.ageRating,
    this.audienceRating,
    this.nrDiscs,
  });

  final int? runtimeMinutes;
  final String? color;
  final String? screenRatio;
  final int? nrDiscs;
  final String? audioTracks;
  final String? subtitles;
  final String? ageRating;
  final String? audienceRating;
}

final class MovieCatalogMediaRef {
  const MovieCatalogMediaRef({
    required this.id,
    this.title,
    this.formatLabel,
    this.discNumber,
    this.audioTracks = const [],
    this.subtitles = const [],
  });

  final String id;
  final String? title;
  final String? formatLabel;
  final int? discNumber;
  final List<String> audioTracks;
  final List<String> subtitles;
}

final class MovieCatalogRelease {
  const MovieCatalogRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.distributor,
    this.barcode,
    this.releaseDate,
    this.formatLabel,
    this.frontCoverUrl,
    this.media = const <MovieCatalogMediaRef>[],
    this.videoDetails,
  });

  final String id;
  final String title;
  final String? publisher;
  final String? distributor;
  final String? barcode;
  final DateTime? releaseDate;
  final String? formatLabel;
  final String? frontCoverUrl;
  final List<MovieCatalogMediaRef> media;
  final MovieCatalogTechnicalMetadata? videoDetails;
}

final class MovieCatalogItem {
  const MovieCatalogItem({
    required this.id,
    required this.work,
    required this.technical,
    required this.releases,
    this.trailerUrls = const [],
  });

  static MovieCatalogItem fromDto(CatalogItem dto) =>
      MovieCatalogMapper.mapDtoToMovie(dto);

  final String id;
  final MovieCatalogWorkMetadata work;
  final MovieCatalogTechnicalMetadata technical;
  final List<MovieCatalogRelease> releases;
  final List<dynamic> trailerUrls;

  String get title => work.title;
  CatalogSeriesDetails? get series => work.series;
  MovieCatalogTechnicalMetadata get videoDetails => technical;
  MovieCatalogRelease? get primaryRelease =>
      releases.isEmpty ? null : releases.first;
  String? get displayReleaseLabel => primaryRelease?.title;
}

final class MovieCatalogMapper {
  const MovieCatalogMapper._();

  static MovieCatalogItem mapDtoToMovie(CatalogItem dto) {
    final payload = dto.toSyncPayload();
    final videoPayload = (payload['video'] as Map?) ?? payload;

    final runtimeMinutes = videoPayload['runtime_minutes'] is num
        ? (videoPayload['runtime_minutes'] as num).toInt()
        : null;
    final color = videoPayload['color']?.toString();
    final screenRatio =
        (videoPayload['screen_ratio'] ?? videoPayload['screenRatio'])
            ?.toString();
    final audioTracks =
        (videoPayload['audio_tracks'] ?? videoPayload['audioTracks'])
            ?.toString();
    final subtitles = videoPayload['subtitles']?.toString();
    final ageRating =
        (payload['age_rating'] ?? videoPayload['age_rating'])?.toString();
    final audienceRating =
        (payload['audience_rating'] ?? videoPayload['audience_rating'])
            ?.toString();
    final language =
        (payload['language'] ?? payload['original_language'])?.toString();
    final genres = (payload['genres'] as List?)
            ?.map((entry) => entry.toString())
            .toList() ??
        const <String>[];

    final work = MovieCatalogWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      originalLanguage: language,
      genres: genres,
    );
    final technical = MovieCatalogTechnicalMetadata(
      runtimeMinutes: runtimeMinutes,
      color: color,
      screenRatio: screenRatio,
      audioTracks: audioTracks,
      subtitles: subtitles,
      ageRating: ageRating,
      audienceRating: audienceRating,
    );

    final releases = dto.editions.map((edition) {
      final editionAudioTracks =
          edition.metadata?['audio_tracks'] as String? ?? audioTracks;
      final audioTracksList =
          editionAudioTracks != null && editionAudioTracks.isNotEmpty
              ? [editionAudioTracks]
              : const <String>[];
      final editionSubtitles =
          edition.metadata?['subtitles'] as String? ?? subtitles;
      final subtitlesList =
          editionSubtitles != null && editionSubtitles.isNotEmpty
              ? [editionSubtitles]
              : const <String>[];
      final media = edition.discs
          .map(
            (disc) => MovieCatalogMediaRef(
              id: '${edition.id}:disc:${disc.discNumber}',
              title: disc.discName,
              formatLabel: disc.discFormat,
              discNumber: disc.discNumber,
              audioTracks: audioTracksList,
              subtitles: subtitlesList,
            ),
          )
          .toList();

      return MovieCatalogRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        distributor: edition.distributor,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
        media: media,
        videoDetails: MovieCatalogTechnicalMetadata(
          runtimeMinutes: runtimeMinutes,
          color: color,
          screenRatio: screenRatio,
          audioTracks: audioTracks,
          subtitles: subtitles,
          ageRating: ageRating,
          audienceRating: audienceRating,
          nrDiscs: edition.discs.length,
        ),
      );
    }).toList();

    return MovieCatalogItem(
      id: dto.id,
      work: work,
      technical: technical,
      releases: releases,
      trailerUrls: dto.trailerUrls,
    );
  }

  static MovieCatalogItem mapMetadataItemToMovie(CatalogItem item) {
    return mapDtoToMovie(CatalogItem.fromJson(item.toSyncPayload()));
  }
}
