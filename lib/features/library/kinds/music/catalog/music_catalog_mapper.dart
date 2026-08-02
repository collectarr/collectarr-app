import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class MusicCatalogMapper {
  const MusicCatalogMapper._();

  static MusicCatalogItem mapDtoToMusic(CatalogItemDto dto) {
    final music = dto.music;
    final artistName = dto.creators?.firstOrNull?['name']?.toString();

    final work = MusicWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      artist: artistName,
      genres: dto.genres ?? const [],
    );

    final recording = MusicRecordingMetadata(
      trackCount: music?.trackCount,
      studio: music?.studio,
      originalReleaseDate: music?.originalReleaseDate,
      recordingDate: music?.recordingDate,
      isLive: music?.isLive,
      composition: music?.composition,
    );

    final releases = dto.editions.map((edition) {
      final discs = edition.discs.map((disc) {
        final tracks = disc.tracks
            .map((t) => MusicTrackRef(
                  title: t.title ?? '',
                  position: int.tryParse(t.position ?? ''),
                  durationSeconds: t.durationSeconds,
                  artist: t.artist ?? artistName,
                  discNumber: disc.discNumber,
                ))
            .toList();

        return MusicDiscRef(
          discNumber: disc.discNumber ?? 0,
          discName: disc.discName,
          discFormat: disc.discFormat,
          trackCount: disc.trackCount,
          mediaCondition: disc.mediaCondition,
          tracks: tracks,
        );
      }).toList();

      return MusicRelease(
        id: edition.id,
        title: edition.title,
        artist: artistName,
        publisher: edition.publisher,
        catalogNumber: music?.catalogNumber,
        upc: edition.upc,
        releaseDate: edition.releaseDate,
        releaseStatus: music?.releaseStatus,
        discs: discs,
      );
    }).toList();

    return MusicCatalogItem(
      id: dto.id,
      work: work,
      recording: recording,
      releases: releases,
    );
  }

  static MusicCatalogItem mapMetadataItemToMusic(LibraryMetadataItem item) {
    return mapDtoToMusic(CatalogItemDto(
      id: item.id,
      mediaKind: item.mediaKind,
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      publisher: item.publisher,
      genres: item.genres,
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      creators: item.creators,
      music: item.music,
      series: item.series,
      publishing: item.publishing,
      editions: item.editions,
    ));
  }
}
