import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/media/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/media/video/catalog/video_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class VideoCatalogMapper {
  const VideoCatalogMapper._();

  static VideoCatalogItem mapDtoToVideo(CatalogItemDto dto) {
    final v = dto.video;

    final work = VideoWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      releaseDate: dto.releaseDate,
      originalLanguage: dto.language,
      genres: dto.genres ?? const [],
    );

    final technical = VideoTechnicalMetadata(
      runtimeMinutes: v?.runtimeMinutes,
      color: v?.color,
      screenRatio: v?.screenRatio,
      audioTracks: v?.audioTracks,
      subtitles: v?.subtitles,
      ageRating: dto.ageRating ?? v?.ageRating,
      audienceRating: dto.audienceRating ?? v?.audienceRating,
    );

    final releases = dto.editions.map((edition) {
      final audioTracksStr = edition.metadata?['audio_tracks'] as String? ??
          dto.video?.audioTracks;
      final audioTracks = audioTracksStr != null && audioTracksStr.isNotEmpty
          ? [audioTracksStr]
          : const <String>[];
      final subtitlesStr =
          edition.metadata?['subtitles'] as String? ?? dto.video?.subtitles;
      final subtitles = subtitlesStr != null && subtitlesStr.isNotEmpty
          ? [subtitlesStr]
          : const <String>[];

      final media = edition.discs
          .map((disc) => VideoMediaRef(
                id: '${edition.id}:disc:${disc.discNumber}',
                title: disc.discName,
                formatLabel: disc.discFormat,
                discNumber: disc.discNumber,
                audioTracks: audioTracks,
                subtitles: subtitles,
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
          runtimeMinutes: dto.video?.runtimeMinutes,
          color: dto.video?.color,
          screenRatio: dto.video?.screenRatio,
          audioTracks: audioTracks.isNotEmpty ? audioTracks.first : null,
          subtitles: subtitles.isNotEmpty ? subtitles.first : null,
          ageRating: dto.video?.ageRating,
          audienceRating: dto.video?.audienceRating,
          nrDiscs: edition.discs.length,
        ),
      );
    }).toList();

    return VideoCatalogItem(
      id: dto.id,
      work: work,
      technical: technical,
      releases: releases,
    );
  }

  static VideoCatalogItem mapMetadataItemToVideo(LibraryMetadataItem item) {
    return VideoCatalogItem.fromMetadataItem(item);
  }
}
