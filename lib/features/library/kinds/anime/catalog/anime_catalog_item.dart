import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

/// Anime-owned catalog snapshot used by the Anime workspace and release
/// browser. Anime keeps this projection independent from TV even where the
/// physical video fields have the same wire representation.
final class AnimeCatalogWorkMetadata {
  const AnimeCatalogWorkMetadata({
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

final class AnimeCatalogTechnicalMetadata {
  const AnimeCatalogTechnicalMetadata({
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

final class AnimeCatalogMediaRef {
  const AnimeCatalogMediaRef({
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

  List<dynamic> get episodes => const [];
}

final class AnimeCatalogRelease {
  const AnimeCatalogRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.distributor,
    this.barcode,
    this.releaseDate,
    this.formatLabel,
    this.frontCoverUrl,
    this.media = const <AnimeCatalogMediaRef>[],
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
  final List<AnimeCatalogMediaRef> media;
  final AnimeCatalogTechnicalMetadata? videoDetails;
}

final class AnimeCatalogItem {
  const AnimeCatalogItem({
    required this.id,
    required this.work,
    required this.technical,
    required this.releases,
    this.trailerUrls = const [],
  });

  static AnimeCatalogItem fromDto(CatalogItem dto) =>
      AnimeCatalogMapper.mapDtoToAnime(dto);

  final String id;
  final AnimeCatalogWorkMetadata work;
  final AnimeCatalogTechnicalMetadata technical;
  final List<AnimeCatalogRelease> releases;
  final List<dynamic> trailerUrls;

  String get title => work.title;
  CatalogSeriesDetails? get series => work.series;
  AnimeCatalogTechnicalMetadata get videoDetails => technical;
  List<AnimeCatalogRelease> get episodes => releases;
  AnimeCatalogRelease? get primaryRelease =>
      releases.isEmpty ? null : releases.first;
  String? get displayEpisodeLabel => primaryRelease?.title;
}

final class AnimeCatalogMapper {
  const AnimeCatalogMapper._();

  static AnimeCatalogItem mapDtoToAnime(CatalogItem dto) {
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

    final work = AnimeCatalogWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      originalLanguage: language,
      genres: genres,
    );
    final technical = AnimeCatalogTechnicalMetadata(
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
            (disc) => AnimeCatalogMediaRef(
              id: '${edition.id}:disc:${disc.discNumber}',
              title: disc.discName,
              formatLabel: disc.discFormat,
              discNumber: disc.discNumber,
              audioTracks: audioTracksList,
              subtitles: subtitlesList,
            ),
          )
          .toList();

      return AnimeCatalogRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        distributor: edition.distributor,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
        media: media,
        videoDetails: AnimeCatalogTechnicalMetadata(
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

    return AnimeCatalogItem(
      id: dto.id,
      work: work,
      technical: technical,
      releases: releases,
      trailerUrls: dto.trailerUrls,
    );
  }

  static AnimeCatalogItem mapMetadataItemToAnime(CatalogItem item) {
    return mapDtoToAnime(CatalogItem.fromJson(item.toSyncPayload()));
  }
}
