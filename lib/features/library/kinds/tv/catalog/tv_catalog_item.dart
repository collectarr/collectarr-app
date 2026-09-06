import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

/// TV-owned catalog snapshot used by the TV workspace and release browser.
///
/// This is intentionally separate from the Movie and Anime snapshots. The
/// release projection is still a lightweight catalog view; TV's canonical
/// series/season/episode domain remains in [TvSeries] and its hierarchy.
final class TvCatalogWorkMetadata {
  const TvCatalogWorkMetadata({
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

final class TvCatalogTechnicalMetadata {
  const TvCatalogTechnicalMetadata({
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

final class TvCatalogMediaRef {
  const TvCatalogMediaRef({
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

final class TvCatalogRelease {
  const TvCatalogRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.distributor,
    this.barcode,
    this.releaseDate,
    this.formatLabel,
    this.frontCoverUrl,
    this.media = const <TvCatalogMediaRef>[],
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
  final List<TvCatalogMediaRef> media;
  final TvCatalogTechnicalMetadata? videoDetails;
}

final class TvCatalogItem {
  const TvCatalogItem({
    required this.id,
    required this.work,
    required this.technical,
    required this.releases,
    this.trailerUrls = const [],
  });

  static TvCatalogItem fromDto(CatalogItem dto) =>
      TvCatalogMapper.mapDtoToTv(dto);

  final String id;
  final TvCatalogWorkMetadata work;
  final TvCatalogTechnicalMetadata technical;
  final List<TvCatalogRelease> releases;
  final List<dynamic> trailerUrls;

  String get title => work.title;
  CatalogSeriesDetails? get series => work.series;
  TvCatalogTechnicalMetadata get videoDetails => technical;
  List<TvCatalogRelease> get episodes => releases;
  TvCatalogRelease? get primaryRelease =>
      releases.isEmpty ? null : releases.first;
  String? get displayEpisodeLabel => primaryRelease?.title;
}

final class TvCatalogMapper {
  const TvCatalogMapper._();

  static TvCatalogItem mapDtoToTv(CatalogItem dto) {
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

    final work = TvCatalogWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      originalLanguage: language,
      genres: genres,
    );
    final technical = TvCatalogTechnicalMetadata(
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
            (disc) => TvCatalogMediaRef(
              id: '${edition.id}:disc:${disc.discNumber}',
              title: disc.discName,
              formatLabel: disc.discFormat,
              discNumber: disc.discNumber,
              audioTracks: audioTracksList,
              subtitles: subtitlesList,
            ),
          )
          .toList();

      return TvCatalogRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        distributor: edition.distributor,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
        media: media,
        videoDetails: TvCatalogTechnicalMetadata(
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

    return TvCatalogItem(
      id: dto.id,
      work: work,
      technical: technical,
      releases: releases,
      trailerUrls: dto.trailerUrls,
    );
  }

  static TvCatalogItem mapMetadataItemToTv(CatalogItem item) {
    return mapDtoToTv(CatalogItem.fromJson(item.toSyncPayload()));
  }

  static TvCatalogItem fromTvMetadataItem(CatalogItem item) {
    final metadata = item.kindMetadata;
    if (metadata is! TvSeriesMetadata) {
      throw ArgumentError.value(
        metadata,
        'item.kindMetadata',
        'Expected TvSeriesMetadata',
      );
    }
    return TvCatalogItem(
      id: item.id,
      work: TvCatalogWorkMetadata(
        title: metadata.title,
        originalTitle: metadata.originalTitle,
        synopsis: metadata.synopsis,
        releaseDate: metadata.firstAirDate,
        originalLanguage: metadata.originalLanguage,
        genres: metadata.genres,
        series: metadata.series,
      ),
      technical: TvCatalogTechnicalMetadata(
        runtimeMinutes: metadata.episodeRuntimeMinutes,
        ageRating: metadata.contentRating,
        audienceRating: metadata.contentRating,
      ),
      releases: [
        for (final release in metadata.releases)
          TvCatalogRelease(
            id: release.id,
            title: release.title,
            publisher: metadata.publisher,
            barcode: release.barcode,
            releaseDate: release.releaseDate,
            formatLabel: release.packaging,
            media: [
              for (var disc = 1; disc <= (release.discCount ?? 0); disc++)
                TvCatalogMediaRef(
                  id: '${release.id}:disc:$disc',
                  title: 'Disc $disc',
                  discNumber: disc,
                ),
            ],
          ),
      ],
      trailerUrls: metadata.links,
    );
  }
}
