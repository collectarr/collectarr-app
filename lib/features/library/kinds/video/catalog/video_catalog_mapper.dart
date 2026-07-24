import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

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
      final media = edition.discs.map((disc) => VideoMediaRef(
        id: '${edition.id}:disc:${disc.discNumber}',
        title: disc.discName,
        formatLabel: disc.discFormat,
        discNumber: disc.discNumber,
      )).toList();

      return VideoRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        distributor: edition.distributor,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
        media: media,
      );
    }).toList();

    return VideoCatalogItem(
      id: dto.id,
      work: work,
      technical: technical,
      releases: releases,
    );
  }

  static VideoCatalogItem mapWorkspaceEntryToVideo(LibraryWorkspaceEntry entry) {
    final v = entry.video;

    final work = VideoWorkMetadata(
      title: entry.title,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      releaseDate: entry.releaseDate,
      originalLanguage: entry.language,
      genres: entry.genres ?? const [],
    );

    final technical = VideoTechnicalMetadata(
      runtimeMinutes: v?.runtimeMinutes,
      color: v?.color,
      screenRatio: v?.screenRatio,
      audioTracks: v?.audioTracks,
      subtitles: v?.subtitles,
      ageRating: entry.ageRating ?? v?.ageRating,
      audienceRating: entry.audienceRating ?? v?.audienceRating,
    );

    final releases = entry.editions.map((edition) {
      final media = edition.discs.map((disc) => VideoMediaRef(
        id: '${edition.id}:disc:${disc.discNumber}',
        title: disc.discName,
        formatLabel: disc.discFormat,
        discNumber: disc.discNumber,
      )).toList();

      return VideoRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        distributor: edition.distributor,
        barcode: edition.upc ?? edition.isbn,
        releaseDate: edition.releaseDate,
        formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
        media: media,
      );
    }).toList();

    return VideoCatalogItem(
      id: entry.id,
      work: work,
      technical: technical,
      releases: releases,
    );
  }
}
