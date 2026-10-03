import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

/// Converts the Core Music document at the API boundary into the Music domain
/// aggregate. The domain aggregate remains the only typed representation of
/// album, disc, and track fields in App.
final class MusicCatalogMapper {
  const MusicCatalogMapper._();

  /// Encodes the local Music item using Core's flattened catalog document.
  /// Local-only fields such as file paths and timestamps are not sent to Core.
  static CatalogItemDto toCatalogItemDto(MusicAlbum album) {
    final music = <String, dynamic>{
      'id': album.id.value,
      'kind': CatalogMediaKind.music.apiValue,
      'revision': album.revision,
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
              if (credit.sortName != null) 'sort_name': credit.sortName,
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
      if (album.publisher != null) 'label': album.publisher,
      if (album.format ?? album.mediumTypes.firstOrNull case final format?)
        'format': format,
      if (album.barcode ?? album.upc case final barcode?) 'barcode': barcode,
      if (album.catalogNumber != null) 'catalog_number': album.catalogNumber,
      if (album.genres.isNotEmpty) 'genres': album.genres,
      if (album.packaging != null) 'packaging': album.packaging,
      if (album.studios.isNotEmpty) 'studios': album.studios,
      if (album.countryCode != null) 'country': album.countryCode,
      if (album.isLive != null) 'is_live': album.isLive,
      if (album.soundTypes.isNotEmpty) 'sound_types': album.soundTypes,
      if (album.vinylColor != null) 'vinyl_color': album.vinylColor,
      if (album.vinylWeight != null) 'vinyl_weight': album.vinylWeight,
      if (album.rpm != null) 'rpm': album.rpm,
      if (album.extra != null) 'extra': album.extra,
      if (album.spars != null) 'spars': album.spars,
      if (album.boxSet != null) 'box_set': album.boxSet,
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
                  if (!medium.tracks[index].isHeader)
                    _trackToCatalogData(medium.tracks[index], index),
              ],
            },
        ],
    };

    return CatalogItemDto.raw(
      id: album.id.value,
      mediaKind: CatalogMediaKind.music,
      kindData: music,
    );
  }

  static Map<String, Object?> _trackToCatalogData(
          MusicTrack track, int index) =>
      {
        'id': track.id.value,
        'position': track.position,
        'position_order':
            track.positionOrder ?? int.tryParse(track.position) ?? index + 1,
        'title': track.title,
        if (track.artist != null) 'artist': track.artist,
        if (track.durationMs != null) 'duration_ms': track.durationMs,
      };

  static MusicAlbum mapDtoToMusic(CatalogItemDto dto) =>
      mapMetadataItemToMusic(dto);

  static MusicAlbum mapMetadataItemToMusic(CatalogItemDto item) =>
      fromCatalogPayload(catalogTransportPayloadFor(item));

  /// Decodes the flat Core Music item or the domain's own serialized shape.
  /// `discs` → `mediums` is the only structural API/domain translation.
  static MusicAlbum fromCatalogPayload(Map<String, dynamic> payload) {
    if (payload['mediums'] is List) {
      return MusicAlbum.fromJson(payload);
    }

    final catalogPayload = Map<String, dynamic>.from(payload)
      ..remove('snapshot_version');
    const coreFields = <String>{
      'id',
      'kind',
      'revision',
      'title',
      'sort_title',
      'subtitle',
      'artist',
      'artist_credits',
      'original_release_date',
      'original_release_date_parts',
      'recording_date',
      'recording_date_parts',
      'release_date',
      'release_date_parts',
      'label',
      'format',
      'barcode',
      'catalog_number',
      'genres',
      'packaging',
      'studios',
      'country',
      'is_live',
      'sound_types',
      'vinyl_color',
      'vinyl_weight',
      'rpm',
      'extra',
      'spars',
      'box_set',
      'composers',
      'conductors',
      'choruses',
      'compositions',
      'orchestras',
      'songwriters',
      'producers',
      'engineers',
      'musicians',
      'external_links',
      'cover_image_url',
      'back_cover_image_url',
      'thumbnail_image_url',
      'discs',
    };
    final unsupported = catalogPayload.keys.where(
      (key) => !coreFields.contains(key),
    );
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized Music Catalog Item field "${unsupported.first}".',
      );
    }

    final id = _text(catalogPayload['id']);
    if (id == null || id.isEmpty) {
      throw const FormatException('Music Catalog Item requires an id.');
    }
    if (_text(catalogPayload['kind']) case final kind? when kind != 'music') {
      throw FormatException('Expected a Music Catalog Item, received $kind.');
    }
    final discs = _maps(catalogPayload['discs']);
    const discFields = <String>{
      'id',
      'disc_number',
      'title',
      'matrix_number_side_a',
      'matrix_number_side_b',
      'tracks',
    };
    const trackFields = <String>{
      'id',
      'position',
      'position_order',
      'title',
      'artist',
      'duration_ms',
    };
    for (final disc in discs) {
      final unsupportedDiscFields = disc.keys.where(
        (key) => !discFields.contains(key),
      );
      if (unsupportedDiscFields.isNotEmpty) {
        throw FormatException(
          'Unrecognized Music disc field "${unsupportedDiscFields.first}".',
        );
      }
      for (final track in _maps(disc['tracks'])) {
        final unsupportedTrackFields = track.keys.where(
          (key) => !trackFields.contains(key),
        );
        if (unsupportedTrackFields.isNotEmpty) {
          throw FormatException(
            'Unrecognized Music track field "${unsupportedTrackFields.first}".',
          );
        }
      }
    }
    final contributionRows = <Map<String, dynamic>>[];
    for (final role in const [
      'composers',
      'conductors',
      'songwriters',
      'producers',
      'engineers',
      'musicians',
      'choruses',
      'compositions',
      'orchestras',
    ]) {
      final values = catalogPayload[role];
      if (values is! Iterable) continue;
      final normalizedRole = _roleLabel(role);
      for (final value in values) {
        final person = value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{'name': value};
        final name = _text(person['name'] ?? person['credited_name']);
        final artistId = _text(person['artist_id'] ?? person['person_id']);
        if (name == null && artistId == null) continue;
        final sequence =
            _int(person['sequence']) ?? contributionRows.length + 1;
        contributionRows.add({
          'id': _text(person['contribution_id'] ?? person['id']) ??
              '$id:$role:$sequence',
          'album_id': id,
          'person_id': artistId ?? name,
          'role': _text(person['role']) ?? normalizedRole,
          'sequence': sequence,
          if (name != null) 'name': name,
          if (_text(person['sort_name']) case final sortName?)
            'sort_name': sortName,
          if (_text(person['image_url']) case final imageUrl?)
            'image_url': imageUrl,
        });
      }
    }

    final localPayload = <String, dynamic>{
      ...catalogPayload,
      'country_code': catalogPayload['country'],
      'publisher': catalogPayload['label'],
      'medium_types': catalogPayload['format'] == null
          ? const <String>[]
          : [catalogPayload['format']],
      'contributions': contributionRows,
      'mediums': [
        for (final disc in discs)
          {
            ...disc,
            'id': _text(disc['id']) ?? '$id:disc:${disc['disc_number']}',
            'album_id': id,
            'medium_number': disc['medium_number'] ?? disc['disc_number'],
            'medium_type': disc['medium_type'] ?? payload['format'],
            'tracks': _tracksForDisc(disc, id),
          },
      ],
    };
    return MusicAlbum.fromJson(localPayload);
  }

  static String _roleLabel(String key) => switch (key) {
        'composers' => 'Composer',
        'conductors' => 'Conductor',
        'songwriters' => 'Songwriter',
        'producers' => 'Producer',
        'engineers' => 'Engineer',
        'musicians' => 'Musician',
        'choruses' => 'Chorus',
        'compositions' => 'Composition',
        'orchestras' => 'Orchestra',
        _ => key,
      };
}

List<Map<String, Object?>> _peopleForRole(MusicAlbum album, String role) => [
      for (final contribution in album.contributions)
        if (contribution.role.toLowerCase() == role.toLowerCase())
          {
            'id': contribution.id.value,
            'person_id': contribution.personId,
            'name': contribution.displayName ?? contribution.personId,
            if (contribution.sortName != null)
              'sort_name': contribution.sortName,
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

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const <Map<String, dynamic>>[];

List<Map<String, dynamic>> _tracksForDisc(
  Map<String, dynamic> disc,
  String albumId,
) {
  final discNumber = _int(disc['disc_number'] ?? disc['medium_number']) ?? 1;
  final discId = _text(disc['id']) ?? '$albumId:disc:$discNumber';
  final tracks = _maps(disc['tracks']);
  return [
    for (var index = 0; index < tracks.length; index++)
      {
        ...tracks[index],
        'id': _text(tracks[index]['id']) ??
            '$albumId:disc:$discNumber:track:${index + 1}',
        'medium_id': discId,
        'position_order': _int(tracks[index]['position_order']) ?? index + 1,
      },
  ];
}

String? _text(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

int? _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString().trim() ?? '');
