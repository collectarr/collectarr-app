import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

/// Maps one flat Core Music Catalog Item into the local Music domain model.
/// Discs and tracks remain contained children of this concrete album edition.
final class MusicCatalogMapper {
  const MusicCatalogMapper._();

  /// Encodes the local Music item using the Core Catalog Item shape.
  /// Local persistence fields such as `mediums` and timestamps do not belong
  /// in the Core payload; contained media is encoded as `discs` and `tracks`.
  static CatalogItemDto toCatalogItemDto(MusicAlbum album) {
    final music = <String, dynamic>{
      'id': album.id.value,
      'kind': 'music',
      'title': album.title,
      if (album.sortTitle != null) 'sort_title': album.sortTitle,
      if (album.subtitle != null) 'subtitle': album.subtitle,
      if (album.artist != null) 'artist': album.artist,
      if (album.artistCredits.isNotEmpty)
        'artist_credits': [
          for (final credit in album.artistCredits)
            {
              'id': credit.id,
              'name': credit.creditedName,
              if (credit.artistId != null) 'artist_id': credit.artistId,
              if (credit.joinPhrase != null) 'join_phrase': credit.joinPhrase,
              if (credit.sequence != null) 'sequence': credit.sequence,
            },
        ],
      if (album.originalReleaseDateParts != null) ...{
        'original_release_date': album.originalReleaseDateParts!.isoString,
        'original_release_date_parts': album.originalReleaseDateParts!.toJson(),
      } else if (album.originalReleaseDate != null)
        'original_release_date': album.originalReleaseDate!.toIso8601String(),
      if (album.recordingDateParts != null) ...{
        'recording_date': album.recordingDateParts!.isoString,
        'recording_date_parts': album.recordingDateParts!.toJson(),
      } else if (album.recordingDate != null)
        'recording_date': album.recordingDate!.toIso8601String(),
      if (album.releaseDateParts != null) ...{
        'release_date': album.releaseDateParts!.isoString,
        'release_date_parts': album.releaseDateParts!.toJson(),
      } else if (album.releaseDate != null)
        'release_date': album.releaseDate!.toIso8601String(),
      if (album.labels.isNotEmpty || album.publisher != null)
        'label': album.labels.firstOrNull?.labelName ?? album.publisher,
      if (album.mediumTypes.isNotEmpty) 'format': album.mediumTypes.first,
      if (album.barcode ?? album.upc case final barcode?) 'barcode': barcode,
      if (album.catalogNumber != null) 'catalog_number': album.catalogNumber,
      if (album.genres.isNotEmpty) 'genres': album.genres,
      if (album.packaging != null) 'packaging': album.packaging,
      if (album.studios.isNotEmpty) 'studios': album.studios,
      if (album.countryCode != null) 'country': album.countryCode,
      if (album.isLive != null) 'is_live': album.isLive,
      if (album.soundTypes.isNotEmpty ||
          album.mediums.any((medium) => medium.soundType != null))
        'sound_types': {
          ...album.soundTypes,
          for (final medium in album.mediums)
            if (medium.soundType case final value?) value,
        }.toList(),
      if (album.vinylColor != null) 'vinyl_color': album.vinylColor,
      if (album.vinylWeight != null) 'vinyl_weight': album.vinylWeight,
      if (album.rpm != null) 'rpm': album.rpm,
      if (album.extra != null) 'extra': album.extra,
      if (album.spars != null) 'spars': album.spars,
      if (album.boxSetTitle != null) 'box_set': album.boxSetTitle,
      if (_peopleForRole(album, 'Composer').isNotEmpty)
        'composers': _peopleForRole(album, 'Composer'),
      if (_peopleForRole(album, 'Conductor').isNotEmpty)
        'conductors': _peopleForRole(album, 'Conductor'),
      if (_peopleForRole(album, 'Songwriter').isNotEmpty)
        'songwriters': _peopleForRole(album, 'Songwriter'),
      if (_peopleForRole(album, 'Producer').isNotEmpty)
        'producers': _peopleForRole(album, 'Producer'),
      if (_peopleForRole(album, 'Engineer').isNotEmpty)
        'engineers': _peopleForRole(album, 'Engineer'),
      if (_peopleForRole(album, 'Musician').isNotEmpty)
        'musicians': _peopleForRole(album, 'Musician'),
      if (_namesForRole(album, 'Chorus').isNotEmpty)
        'choruses': _namesForRole(album, 'Chorus'),
      if (_namesForRole(album, 'Composition').isNotEmpty)
        'compositions': _namesForRole(album, 'Composition'),
      if (_namesForRole(album, 'Orchestra').isNotEmpty)
        'orchestras': _namesForRole(album, 'Orchestra'),
      if (album.externalLinks.isNotEmpty)
        'external_links':
            album.externalLinks.map((link) => link.toJson()).toList(),
      if (album.coverImageUrl != null) 'cover_image_url': album.coverImageUrl,
      if (album.backCoverImageUrl != null)
        'back_cover_image_url': album.backCoverImageUrl,
      if (album.thumbnailImageUrl != null)
        'thumbnail_image_url': album.thumbnailImageUrl,
      if (album.mediums.isNotEmpty)
        'discs': [
          for (final medium in album.mediums)
            {
              'id': medium.id.value,
              'disc_number': medium.mediumNumber,
              if (medium.title != null) 'title': medium.title,
              if (medium.matrixNumberSideA != null)
                'matrix_number_side_a': medium.matrixNumberSideA,
              if (medium.matrixNumberSideB != null)
                'matrix_number_side_b': medium.matrixNumberSideB,
              'tracks': [
                for (var index = 0; index < medium.tracks.length; index++)
                  {
                    'id': medium.tracks[index].id.value,
                    'position': medium.tracks[index].position,
                    'position_order': int.tryParse(
                          medium.tracks[index].position,
                        ) ??
                        index + 1,
                    'title': medium.tracks[index].title,
                    if (medium.tracks[index].artist != null)
                      'artist': medium.tracks[index].artist,
                    if (medium.tracks[index].durationMs != null)
                      'duration_ms': medium.tracks[index].durationMs,
                  },
              ],
            },
        ],
    };

    return CatalogItemDto.raw(
      id: album.id.value,
      mediaKind: CatalogMediaKind.music,
      common: CatalogCommonDto(
        title: album.title,
        originalTitle: album.originalTitle,
        coverImageUrl: album.coverImageUrl,
        thumbnailImageUrl: album.thumbnailImageUrl,
        releaseDate: album.releaseDate,
        releaseDateParts: album.releaseDateParts,
      ),
      payload: {'music': music},
    );
  }

  static MusicAlbum mapDtoToMusic(CatalogItemDto dto) =>
      mapMetadataItemToMusic(dto);

  static MusicAlbum mapMetadataItemToMusic(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is MusicAlbum) return metadata;
    if (metadata is CatalogMusicItemDto) return _fromTypedDto(metadata);

    final payload = catalogTransportPayloadFor(item);
    final nestedMusic = payload['music'];
    final musicPayload = nestedMusic is Map
        ? <String, dynamic>{
            ...Map<String, dynamic>.from(nestedMusic),
            'id': item.id,
            'kind': 'music',
          }
        : <String, dynamic>{...payload, 'id': item.id, 'kind': 'music'};
    return _fromTypedDto(CatalogMusicItemDto.fromJson(musicPayload));
  }

  static MusicAlbum _fromTypedDto(CatalogMusicItemDto item) {
    final discPayloads = <Map<String, dynamic>>[];
    for (final disc in item.discs) {
      final mediumId = '${item.id}:disc:${disc.discNumber}';
      discPayloads.add({
        'id': mediumId,
        'album_id': item.id,
        'medium_number': disc.discNumber,
        if (disc.title != null) 'title': disc.title,
        if (disc.matrixNumberSideA != null)
          'matrix_number_side_a': disc.matrixNumberSideA,
        if (disc.matrixNumberSideB != null)
          'matrix_number_side_b': disc.matrixNumberSideB,
        if (item.format != null) 'medium_type': item.format,
        'tracks': [
          for (final track in disc.tracks)
            {
              'id': track.id,
              'medium_id': mediumId,
              'position': track.position,
              'title': track.title,
              if (track.artist != null) 'artist': track.artist,
              if (track.durationMs != null) 'duration_ms': track.durationMs,
            },
        ],
      });
    }

    return MusicAlbum.fromJson({
      'id': item.id,
      'kind': 'music',
      'title': item.title,
      if (item.sortTitle != null) 'sort_title': item.sortTitle,
      if (item.subtitle != null) 'subtitle': item.subtitle,
      if (item.artist != null) 'artist': item.artist,
      if (item.originalReleaseDate != null)
        'original_release_date': item.originalReleaseDate,
      if (item.originalReleaseDateParts != null)
        'original_release_date_parts': item.originalReleaseDateParts,
      if (item.recordingDate != null) 'recording_date': item.recordingDate,
      if (item.recordingDateParts != null)
        'recording_date_parts': item.recordingDateParts,
      if (item.releaseDate != null) 'release_date': item.releaseDate,
      if (item.releaseDateParts != null)
        'release_date_parts': item.releaseDateParts,
      if (item.label != null) 'publisher': item.label,
      if (item.format != null) 'medium_types': [item.format],
      if (item.barcode != null) 'barcode': item.barcode,
      if (item.catalogNumber != null) 'catalog_number': item.catalogNumber,
      if (item.genres.isNotEmpty) 'genres': item.genres,
      if (item.packaging != null) 'packaging': item.packaging,
      if (item.studios.isNotEmpty) 'studios': item.studios,
      if (item.country != null) 'country_code': item.country,
      if (item.isLive != null) 'is_live': item.isLive,
      if (item.soundTypes.isNotEmpty) 'sound_types': item.soundTypes,
      if (item.vinylColor != null) 'vinyl_color': item.vinylColor,
      if (item.vinylWeight != null) 'vinyl_weight': item.vinylWeight,
      if (item.rpm != null) 'rpm': item.rpm,
      if (item.extra != null) 'extra': item.extra,
      if (item.spars != null) 'spars': item.spars,
      if (item.boxSet != null) 'box_set_name': item.boxSet,
      if (item.artistCredits.isNotEmpty) 'artist_credits': item.artistCredits,
      if (item.externalLinks.isNotEmpty) 'external_links': item.externalLinks,
      if (item.coverImageUrl != null) 'cover_image_url': item.coverImageUrl,
      if (item.backCoverImageUrl != null)
        'back_cover_image_url': item.backCoverImageUrl,
      if (item.thumbnailImageUrl != null)
        'thumbnail_image_url': item.thumbnailImageUrl,
      'contributions': _contributions(item),
      'mediums': discPayloads,
    });
  }

  static List<Map<String, Object?>> _contributions(CatalogMusicItemDto item) {
    final result = <Map<String, Object?>>[];
    void add(String role, Iterable<Map<String, Object?>> people) {
      for (final person in people) {
        final name = _text(
          person['name'] ?? person['display_name'] ?? person['credited_name'],
        );
        final personId = _text(person['person_id'] ?? person['id']) ?? name;
        if (personId == null) continue;
        result.add({
          'id': _text(person['contribution_id']) ??
              '${item.id}:$role:${result.length + 1}',
          'album_id': item.id,
          'person_id': personId,
          'role': _text(person['role']) ?? role,
          'sequence': result.length + 1,
          if (name != null) 'name': name,
          if (_text(person['image_url']) case final imageUrl?)
            'image_url': imageUrl,
        });
      }
    }

    add('Composer', item.composers);
    add('Conductor', item.conductors);
    add('Songwriter', item.songwriters);
    add('Producer', item.producers);
    add('Engineer', item.engineers);
    add('Musician', item.musicians);
    for (final role in [
      ('Chorus', item.choruses),
      ('Composition', item.compositions),
      ('Orchestra', item.orchestras),
    ]) {
      add(
        role.$1,
        [
          for (var index = 0; index < role.$2.length; index++)
            <String, Object?>{'name': role.$2[index]},
        ],
      );
    }
    return result;
  }
}

List<Map<String, Object?>> _peopleForRole(MusicAlbum album, String role) => [
      for (final contribution in album.contributions)
        if (contribution.role.toLowerCase() == role.toLowerCase())
          {
            'id': contribution.id.value,
            'person_id': contribution.personId,
            'name': contribution.displayName ?? contribution.personId,
            'role': contribution.role,
            if (contribution.imageUrl != null)
              'image_url': contribution.imageUrl,
          },
    ];

List<String> _namesForRole(MusicAlbum album, String role) => [
      for (final contribution in album.contributions)
        if (contribution.role.toLowerCase() == role.toLowerCase())
          contribution.displayName ?? contribution.personId,
    ];

String? _text(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
