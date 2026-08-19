import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/media/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/media/video/catalog/video_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class VideoWorkMetadata {
  const VideoWorkMetadata({
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

class VideoTechnicalMetadata {
  const VideoTechnicalMetadata({
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

class VideoCatalogItem {
  const VideoCatalogItem({
    required this.id,
    required this.work,
    required this.technical,
    required this.releases,
    this.trailerUrls = const [],
  });

  static VideoCatalogItem fromDto(CatalogItemDto dto) =>
      VideoCatalogMapper.mapDtoToVideo(dto);

  factory VideoCatalogItem.fromMetadataItem(LibraryMetadataItem item) {
    final v = item.video;
    return VideoCatalogItem(
      id: item.id,
      work: VideoWorkMetadata(
        title: item.title,
        originalTitle: item.originalTitle,
        synopsis: item.synopsis,
        releaseDate: item.releaseDate,
        originalLanguage: item.language,
        genres: item.genres ?? const [],
        series: item.series,
      ),
      technical: VideoTechnicalMetadata(
        runtimeMinutes: v?.runtimeMinutes,
        color: v?.color,
        screenRatio: v?.screenRatio,
        audioTracks: v?.audioTracks,
        subtitles: v?.subtitles,
        ageRating: item.ageRating ?? v?.ageRating,
        audienceRating: item.audienceRating ?? v?.audienceRating,
      ),
      releases: item.editions
          .map((edition) => VideoRelease(
                id: edition.id,
                title: edition.title,
                publisher: edition.publisher,
                distributor: edition.distributor,
                barcode: edition.upc ?? edition.isbn,
                releaseDate: edition.releaseDate,
                formatLabel:
                    edition.physicalFormatLabel ?? edition.physicalFormat,
                media: edition.discs
                    .map((disc) => VideoMediaRef(
                          id: '${edition.id}:disc:${disc.discNumber}',
                          title: disc.discName,
                          formatLabel: disc.discFormat,
                          discNumber: disc.discNumber,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }

  final String id;
  final VideoWorkMetadata work;
  final VideoTechnicalMetadata technical;
  final List<VideoRelease> releases;
  final List<dynamic> trailerUrls;

  String get title => work.title;
  CatalogSeriesDetails? get series => work.series;
  VideoTechnicalMetadata get videoDetails => technical;
  List<VideoRelease> get episodes => releases;
  VideoRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
}
