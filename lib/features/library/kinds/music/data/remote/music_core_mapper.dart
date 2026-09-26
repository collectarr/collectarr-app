import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';

/// Converts the pinned Core Album v1 transport contract to App domain values.
final class MusicCoreMapper {
  const MusicCoreMapper._();

  static MusicAlbum fromAlbumDto(MusicAlbumDto dto) => MusicAlbum(
        id: MusicAlbumId(dto.id),
        title: dto.title,
        sortTitle: dto.sortTitle,
        subtitle: dto.subtitle,
        artists: [
          for (final value in dto.artists)
            MusicAlbumArtist(name: value.name, sortName: value.sortName),
        ],
        releaseDate: dto.releaseDateParts,
        originalReleaseDate: dto.originalReleaseDate,
        recordingDate: dto.recordingDate,
        labels: [
          for (final value in dto.labels)
            MusicAlbumLabel(
                name: value.name, catalogNumber: value.catalogNumber),
        ],
        format: dto.format,
        barcode: dto.barcodeValue,
        catalogNumber: dto.catalogNumber,
        genres: dto.genres,
        packaging: dto.packaging,
        studio: dto.studio,
        country: dto.country,
        isLive: dto.isLive,
        soundTypes: dto.soundTypes,
        vinylColor: dto.vinylColor,
        vinylWeight: double.tryParse(dto.vinylWeight ?? ''),
        rpm: dto.rpm,
        extras: dto.extras,
        sparsCode: dto.sparsCode,
        boxSet: dto.boxSet,
        matrixNumberSideA: dto.matrixNumberSideA,
        matrixNumberSideB: dto.matrixNumberSideB,
        coverImageUrl: dto.coverImageUrlValue,
        backCoverImageUrl: dto.backCoverImageUrl,
        discTitles: [
          for (final value in dto.discTitles)
            MusicAlbumDiscTitle(
              discNumber: value.discNumber,
              title: value.title,
            ),
        ],
        tracks: [
          for (final value in dto.tracks)
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
          for (final value in dto.credits)
            MusicAlbumCredit(
              role: value.role,
              sequence: value.sequence,
              creditedName: value.creditedName,
              joinPhrase: value.joinPhrase,
              instrument: value.instrument,
            ),
        ],
        links: [
          for (final value in dto.links)
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

  static MusicAlbumWriteDto toWriteDto(MusicAlbum album) => MusicAlbumWriteDto(
        title: album.title,
        sortTitle: album.sortTitle,
        subtitle: album.subtitle,
        artists: [
          for (final value in album.artists)
            MusicAlbumArtistDto(name: value.name, sortName: value.sortName),
        ],
        releaseDate: album.releaseDate,
        originalReleaseDate: album.originalReleaseDate,
        recordingDate: album.recordingDate,
        labels: [
          for (final value in album.labels)
            MusicAlbumLabelDto(
                name: value.name, catalogNumber: value.catalogNumber),
        ],
        format: album.format,
        barcode: album.barcode,
        catalogNumber: album.catalogNumber,
        genres: album.genres,
        packaging: album.packaging,
        studio: album.studio,
        country: album.country,
        isLive: album.isLive,
        soundTypes: album.soundTypes,
        vinylColor: album.vinylColor,
        vinylWeight: album.vinylWeight,
        rpm: album.rpm,
        extras: album.extras,
        sparsCode: album.sparsCode,
        boxSet: album.boxSet,
        matrixNumberSideA: album.matrixNumberSideA,
        matrixNumberSideB: album.matrixNumberSideB,
        coverImageUrl: album.coverImageUrl,
        backCoverImageUrl: album.backCoverImageUrl,
        discTitles: [
          for (final value in album.discTitles)
            MusicAlbumDiscTitleDto(
              discNumber: value.discNumber,
              title: value.title,
            ),
        ],
        tracks: [
          for (final value in album.tracks)
            MusicAlbumTrackInputDto(
              discNumber: value.discNumber,
              position: value.position,
              title: value.title,
              artist: value.artist,
              durationMs: value.durationMs,
            ),
        ],
        credits: [
          for (final value in album.credits)
            MusicAlbumCreditDto(
              role: value.role,
              sequence: value.sequence,
              creditedName: value.creditedName,
              joinPhrase: value.joinPhrase,
              instrument: value.instrument,
            ),
        ],
        links: [
          for (final value in album.links)
            MusicAlbumLinkDto(
              position: value.position,
              url: value.url,
              title: value.title,
              description: value.description,
            ),
        ],
      );
}
