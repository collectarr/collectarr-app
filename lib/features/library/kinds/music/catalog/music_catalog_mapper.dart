import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class MusicCatalogMapper {
  const MusicCatalogMapper._();

  static MusicCatalogItem mapDtoToMusic(CatalogItemDto dto) {
    final payload = dto.toSyncPayload();
    final music = (payload['music'] as Map?) ?? payload;
    final creators =
        (payload['creators'] as List?)?.cast<Map<String, dynamic>>();
    final artistName = creators?.firstOrNull?['name']?.toString();
    final genres =
        (payload['genres'] as List?)?.map((e) => e.toString()).toList() ??
            const [];

    final work = MusicWorkMetadata(
      title: dto.title,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      artist: artistName,
      genres: genres,
    );

    final origDate = music['original_release_date'] != null
        ? DateTime.tryParse(music['original_release_date'].toString())
        : null;
    final recDate = music['recording_date'] != null
        ? DateTime.tryParse(music['recording_date'].toString())
        : null;

    final recording = MusicRecordingMetadata(
      trackCount: music['track_count'] is num
          ? (music['track_count'] as num).toInt()
          : null,
      studio: music['studio']?.toString(),
      originalReleaseDate: origDate,
      recordingDate: recDate,
      isLive: music['is_live'] as bool?,
      composition: music['composition']?.toString(),
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
        catalogNumber: music['catalog_number']?.toString(),
        upc: edition.upc,
        releaseDate: edition.releaseDate,
        releaseStatus: music['release_status']?.toString(),
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
          catalogNumber:
              release.catalogNumber ?? (music?['catalog_number'] as String?),
          upc: release.barcode ?? metadata.barcode,
          releaseDate: release.releaseDate,
          releaseStatus: music?['release_status'] as String?,
          discs: discs,
        );
      }).toList();
    } else if (item.editions.isNotEmpty) {
      releases = item.editions.map((edition) {
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
          catalogNumber: music?['catalog_number'] as String?,
          upc: edition.upc ?? metadata.barcode,
          releaseDate: edition.releaseDate,
          releaseStatus: music?['release_status'] as String?,
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
          catalogNumber: music?['catalog_number'] as String?,
          upc: metadata.barcode,
          releaseDate: metadata.originalReleaseDate,
          releaseStatus: music?['release_status'] as String?,
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
        studio: (music?['studio'] as String?) ?? metadata.studio,
        originalReleaseDate: metadata.originalReleaseDate,
        recordingDate: metadata.recordingDate,
        isLive: metadata.isLive,
        composition: music?['composition'] as String?,
      ),
      releases: releases,
    );
  }
}
