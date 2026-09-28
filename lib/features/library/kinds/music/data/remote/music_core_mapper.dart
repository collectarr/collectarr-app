import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';

/// Converts the pinned Core Album v1 transport contract to App domain values.
final class MusicCoreMapper {
  const MusicCoreMapper._();

  static MusicAlbum fromCatalogItemV1(CatalogItemV1Dto dto) {
    final details = dto.details;
    if (details is! MusicCatalogDetailsV1Dto || details.kind != 'music') {
      throw FormatException(
        'Catalog item ${dto.id} does not contain Music album details.',
      );
    }
    for (final track in details.tracks) {
      if (track.albumId != dto.id) {
        throw FormatException(
          'Track ${track.position} on album ${dto.id} references '
          'album ${track.albumId}.',
        );
      }
    }
    return MusicAlbum(
      id: MusicAlbumId(dto.id),
      title: details.title,
      sortTitle: details.sortTitle,
      subtitle: details.subtitle,
      artists: [
        for (final value in details.artists)
          MusicAlbumArtist(name: value.name, sortName: value.sortName),
      ],
      releaseDate: details.releaseDate,
      originalReleaseDate: details.originalReleaseDate,
      recordingDate: details.recordingDate,
      labels: [
        for (final value in details.labels)
          MusicAlbumLabel(name: value.name, catalogNumber: value.catalogNumber),
      ],
      format: details.format,
      barcode: details.barcode,
      catalogNumber: details.catalogNumber,
      genres: details.genres,
      packaging: details.packaging,
      studio: details.studio,
      country: details.country,
      isLive: details.isLive,
      soundTypes: details.soundTypes,
      vinylColor: details.vinylColor,
      vinylWeight: double.tryParse(details.vinylWeight ?? ''),
      rpm: details.rpm,
      extras: details.extras,
      sparsCode: details.sparsCode,
      boxSet: details.boxSet,
      matrixNumberSideA: details.matrixNumberSideA,
      matrixNumberSideB: details.matrixNumberSideB,
      coverImageUrl: details.coverImageUrl,
      backCoverImageUrl: details.backCoverImageUrl,
      discTitles: [
        for (final value in details.discTitles)
          MusicAlbumDiscTitle(
            discNumber: value.discNumber,
            title: value.title,
          ),
      ],
      tracks: [
        for (final value in details.tracks)
          MusicAlbumTrack(
            albumId: MusicAlbumId(value.albumId),
            discNumber: value.discNumber,
            position: value.position,
            title: value.title,
            artist: value.artist,
            durationMs: value.durationMs,
          ),
      ],
      credits: [
        for (final value in details.credits)
          MusicAlbumCredit(
            role: value.role,
            sequence: value.sequence,
            creditedName: value.creditedName,
            joinPhrase: value.joinPhrase,
            instrument: value.instrument,
          ),
      ],
      links: [
        for (final value in details.links)
          MusicAlbumLink(
            position: value.position,
            url: value.url,
            title: value.title,
            description: value.description,
          ),
      ],
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static CatalogItemWriteV1Dto toCatalogItemWriteV1(MusicAlbum album) {
    final details = MusicCatalogWriteDetailsV1Dto.fromJson({
      ...album.toJson(),
      'kind': 'music',
    });
    return CatalogItemWriteV1Dto(details: details);
  }
}
