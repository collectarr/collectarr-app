import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
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
    final rawMetadata = item.kindMetadata;
    final MusicCatalogMetadata metadata;
    if (rawMetadata is MusicCatalogMetadata) {
      metadata = rawMetadata;
    } else {
      metadata = MusicCatalogMetadata.fromJson(rawMetadata.toSyncPayload());
    }
    final music = metadata.music;
    final catalogItem = item.toCatalogItem();
    final List<MusicRelease> releases;
    if (metadata.releases.isNotEmpty) {
      releases = metadata.releases.map((release) {
        final discsByNumber = <int, List<MusicTrackMetadata>>{};
        for (final track in release.tracks) {
          discsByNumber.putIfAbsent(track.disc, () => []).add(track);
        }
        final discs = discsByNumber.entries.map((entry) {
          final tracks = entry.value
              .map((track) => MusicTrackRef(
                    title: track.title,
                    position: int.tryParse(track.number),
                    durationSeconds: track.durationSeconds,
                    artist: track.artist ?? metadata.artist,
                    discNumber: entry.key,
                  ))
              .toList();
          return MusicDiscRef(
            discNumber: entry.key,
            trackCount: tracks.length,
            tracks: tracks,
          );
        }).toList();
        return MusicRelease(
          id: release.id,
          title: release.title,
          artist: metadata.artist,
          publisher: release.label ?? metadata.publisher,
          catalogNumber: release.catalogNumber ?? music?.catalogNumber,
          upc: release.barcode ?? metadata.barcode,
          releaseDate: release.releaseDate,
          releaseStatus: music?.releaseStatus,
          discs: discs,
        );
      }).toList();
    } else if (catalogItem.editions.isNotEmpty) {
      releases = catalogItem.editions.map((edition) {
        final discs = edition.discs.map((disc) {
          final tracks = disc.tracks
              .map((t) => MusicTrackRef(
                    title: t.title ?? '',
                    position: int.tryParse(t.position ?? ''),
                    durationSeconds: t.durationSeconds,
                    artist: t.artist ?? metadata.artist,
                    discNumber: disc.discNumber ?? 1,
                  ))
              .toList();
          return MusicDiscRef(
            discNumber: disc.discNumber ?? 1,
            trackCount: disc.trackCount,
            tracks: tracks,
          );
        }).toList();
        return MusicRelease(
          id: edition.id,
          title: edition.title,
          artist: metadata.artist,
          publisher: edition.publisher ?? metadata.publisher,
          catalogNumber: music?.catalogNumber,
          upc: edition.upc ?? metadata.barcode,
          releaseDate: edition.releaseDate,
          releaseStatus: music?.releaseStatus,
          discs: discs,
        );
      }).toList();
    } else if (metadata.tracks.isNotEmpty) {
      final discsByNumber = <int, List<CatalogTrackDto>>{};
      for (final track in metadata.tracks) {
        final discNum = track.discNumber ?? 1;
        discsByNumber.putIfAbsent(discNum, () => []).add(track);
      }
      final discs = discsByNumber.entries.map((entry) {
        final tracks = entry.value
            .map((track) => MusicTrackRef(
                  title: track.title ?? '',
                  position: int.tryParse(track.position ?? ''),
                  durationSeconds: track.durationSeconds,
                  artist: track.artist ?? metadata.artist,
                  discNumber: entry.key,
                ))
            .toList();
        return MusicDiscRef(
          discNumber: entry.key,
          trackCount: tracks.length,
          tracks: tracks,
        );
      }).toList();
      releases = [
        MusicRelease(
          id: '${item.id}-release',
          title: metadata.title,
          artist: metadata.artist,
          publisher: metadata.publisher,
          catalogNumber: music?.catalogNumber,
          upc: metadata.barcode,
          releaseDate: metadata.originalReleaseDate,
          releaseStatus: music?.releaseStatus,
          discs: discs,
        ),
      ];
    } else {
      releases = const [];
    }
    return MusicCatalogItem(
      id: item.id,
      work: MusicWorkMetadata(
        title: metadata.title,
        originalTitle: null,
        synopsis: metadata.synopsis,
        artist: metadata.artist,
        genres: metadata.genres,
      ),
      recording: MusicRecordingMetadata(
        trackCount: metadata.trackCount,
        studio: music?.studio ?? metadata.studio,
        originalReleaseDate: metadata.originalReleaseDate,
        recordingDate: metadata.recordingDate,
        isLive: metadata.isLive,
        composition: music?.composition,
      ),
      releases: releases,
    );
  }
}
