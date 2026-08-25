import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class VideoCatalogMapper {
  const VideoCatalogMapper._();

  static VideoCatalogItem mapDtoToVideo(CatalogItemDto dto) {
    final payload = dto.toSyncPayload();
    final v = (payload['video'] as Map?) ?? payload;

    final runtimeMinutes = v['runtime_minutes'] is num
        ? (v['runtime_minutes'] as num).toInt()
        : null;
    final color = v['color']?.toString();
    final screenRatio =
        (v['screen_ratio'] ?? v['screenRatio'])?.toString();
    final audioTracks =
        (v['audio_tracks'] ?? v['audioTracks'])?.toString();
    final subtitles = v['subtitles']?.toString();
    final ageRating =
        (payload['age_rating'] ?? v['age_rating'])?.toString();
    final audienceRating =
        (payload['audience_rating'] ?? v['audience_rating'])?.toString();
    final language =
        (payload['language'] ?? payload['original_language'])?.toString();
    final genres = (payload['genres'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    final work = VideoWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      originalLanguage: language,
      genres: genres,
    );

    final technical = VideoTechnicalMetadata(
      runtimeMinutes: runtimeMinutes,
      color: color,
      screenRatio: screenRatio,
      audioTracks: audioTracks,
      subtitles: subtitles,
      ageRating: ageRating,
      audienceRating: audienceRating,
    );

    final releases = dto.editions.map((edition) {
      final audioTracksStr = edition.metadata?['audio_tracks'] as String? ??
          audioTracks;
      final audioTracksList =
          audioTracksStr != null && audioTracksStr.isNotEmpty
              ? [audioTracksStr]
              : const <String>[];
      final subtitlesStr =
          edition.metadata?['subtitles'] as String? ?? subtitles;
      final subtitlesList =
          subtitlesStr != null && subtitlesStr.isNotEmpty
              ? [subtitlesStr]
              : const <String>[];

      final media = edition.discs
          .map((disc) => VideoMediaRef(
                id: '${edition.id}:disc:${disc.discNumber}',
                title: disc.discName,
                formatLabel: disc.discFormat,
                discNumber: disc.discNumber,
                audioTracks: audioTracksList,
                subtitles: subtitlesList,
              ))
          .toList();

      return VideoRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        distributor: edition.distributor,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
        media: media,
        videoDetails: VideoTechnicalMetadata(
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

    return VideoCatalogItem(
      id: dto.id,
      work: work,
      technical: technical,
      releases: releases,
      trailerUrls: dto.trailerUrls,
    );
  }

  static VideoCatalogItem mapMetadataItemToVideo(LibraryMetadataItem item) {
    return mapDtoToVideo(CatalogItemDto.fromJson(item.toSyncPayload()));
  }
}
