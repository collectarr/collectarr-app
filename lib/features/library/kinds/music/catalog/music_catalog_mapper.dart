import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

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
        final tracks = disc.tracks.map((t) => MusicTrackRef(
          title: t.title,
          position: t.position,
          durationSeconds: t.durationSeconds,
          artist: t.artist ?? artistName,
          discNumber: disc.discNumber,
        )).toList();

        return MusicDiscRef(
          discNumber: disc.discNumber,
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

  static MusicCatalogItem mapWorkspaceEntryToMusic(LibraryWorkspaceEntry entry) {
    final musicDetails = entry.music;
    final artistName = entry.creators?.firstOrNull?['name']?.toString();

    final work = MusicWorkMetadata(
      title: entry.title,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      artist: artistName,
      genres: entry.genres ?? const [],
    );

    final recording = MusicRecordingMetadata(
      trackCount: musicDetails?.trackCount,
      studio: musicDetails?.studio,
      originalReleaseDate: musicDetails?.originalReleaseDate,
      recordingDate: musicDetails?.recordingDate,
      isLive: musicDetails?.isLive,
      composition: musicDetails?.composition,
    );

    final releases = entry.editions.map((edition) {
      final discs = edition.discs.map((disc) {
        final tracks = disc.tracks.map((t) => MusicTrackRef(
          title: t.title,
          position: t.position,
          durationSeconds: t.durationSeconds,
          artist: t.artist ?? artistName,
          discNumber: disc.discNumber,
        )).toList();

        return MusicDiscRef(
          discNumber: disc.discNumber,
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
        catalogNumber: musicDetails?.catalogNumber,
        upc: edition.upc,
        releaseDate: edition.releaseDate,
        releaseStatus: musicDetails?.releaseStatus,
        discs: discs,
      );
    }).toList();

    return MusicCatalogItem(
      id: entry.id,
      work: work,
      recording: recording,
      releases: releases,
    );
  }
}
