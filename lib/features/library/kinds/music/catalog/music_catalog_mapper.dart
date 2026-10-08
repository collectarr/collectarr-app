import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
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
  static CatalogItemDto toCatalogItemDto(
    MusicAlbum album, {
    CatalogItemRef? ref,
  }) {
    final itemRef = ref ?? album.id;
    if (itemRef == null || itemRef.kind != CatalogMediaKind.music) {
      throw StateError('Encoding a Music Catalog Item requires its Core ID.');
    }
    final music = <String, dynamic>{
      'id': itemRef.id,
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
        'original_release_date': album.originalReleaseDateParts!.toJson(),
      },
      if (album.recordingDateParts != null) ...{
        'recording_date': album.recordingDateParts!.toJson(),
      },
      if (album.releaseDateParts != null) ...{
        'release_date': album.releaseDateParts!.toJson(),
      },
      if (album.publisher != null) 'label': album.publisher,
      if (album.barcode case final barcode?) 'barcode': barcode,
      if (album.catalogNumber != null) 'catalog_number': album.catalogNumber,
      if (album.genres.isNotEmpty) 'genres': album.genres,
      if (album.packaging != null) 'packaging': album.packaging,
      if (album.studios.isNotEmpty) 'studios': album.studios,
      if (album.countryCode != null) 'country': album.countryCode,
      if (album.isLive != null) 'is_live': album.isLive,
      'extra': album.extra,
      if (album.sparsCode != null) 'spars_code': album.sparsCode,
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
      if (album.discs.isNotEmpty)
        'discs': [
          for (final disc in album.discs)
            {
              'id': disc.id.value,
              'disc_number': disc.discNumber,
              if (disc.title != null) 'title': disc.title,
              if (disc.formatFamily != null)
                'format_family': disc.formatFamily!.value,
              if (disc.format != null) 'format': disc.format,
              if (disc.soundTypes.isNotEmpty) 'sound_types': disc.soundTypes,
              if (disc.color != null) 'color': disc.color,
              if (disc.vinylWeightGrams != null)
                'vinyl_weight_grams': disc.vinylWeightGrams,
              if (disc.rpm != null) 'rpm': disc.rpm,
              if (disc.matrixNumber != null) 'matrix_number': disc.matrixNumber,
              if (disc.matrixNumberSideA != null)
                'matrix_number_side_a': disc.matrixNumberSideA,
              if (disc.matrixNumberSideB != null)
                'matrix_number_side_b': disc.matrixNumberSideB,
              'tracks': [
                for (var index = 0; index < disc.tracks.length; index++)
                  _trackToCatalogData(disc.tracks[index], index),
              ],
            },
        ],
    };

    return CatalogItemDto.raw(
      id: itemRef.id,
      mediaKind: itemRef.kind,
      kindData: music,
    );
  }

  static Map<String, Object?> _trackToCatalogData(
          MusicTrack track, int index) =>
      {
        'id': track.id.value,
        'position': track.position,
        'position_order': index + 1,
        'title': track.title,
        'is_header': track.isHeader,
        'indent_level': track.indentLevel,
        if (track.parentHeaderId != null)
          'parent_header_id': track.parentHeaderId,
        if (!track.isHeader && track.artist != null) 'artist': track.artist,
        if (!track.isHeader && track.durationMs != null)
          'duration_ms': track.durationMs,
      };

  static MusicAlbum mapDtoToMusic(CatalogItemDto dto) =>
      mapMetadataItemToMusic(dto);

  /// Local entries retain the complete domain snapshot, including timestamps,
  /// track headers and local artwork. Core documents use the API field names.
  static MusicAlbum mapMetadataItemToMusic(CatalogItemDto item) {
    final payload = catalogTransportPayloadFor(item);
    return switch (item.origin) {
      CatalogItemOrigin.privateLocal => MusicAlbum.fromJson(
          Map<String, dynamic>.from(payload)
            ..remove('id')
            ..remove('kind'),
        ),
      CatalogItemOrigin.core => fromCatalogPayload(payload),
    };
  }

  static CatalogItemDto toLocalCatalogItemDto(
    MusicAlbum album, {
    String? id,
  }) {
    final localId = id ?? album.id?.id;
    if (localId == null || localId.trim().isEmpty) {
      throw StateError('Encoding a local Music item requires its entry ID.');
    }
    final localData = Map<String, dynamic>.from(album.toJson())
      ..remove('id')
      ..remove('kind');
    return CatalogItemDto.raw(
      id: localId,
      mediaKind: CatalogMediaKind.music,
      kindData: localData,
      origin: CatalogItemOrigin.privateLocal,
    );
  }

  /// Decodes the flat Core Music item. Local snapshots use MusicAlbum.fromJson.
  /// `discs` → `discs` is the only structural API/domain translation.
  static MusicAlbum fromCatalogPayload(Map<String, dynamic> payload) {
    final catalogPayload = Map<String, dynamic>.from(payload);
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
      'recording_date',
      'release_date',
      'label',
      'barcode',
      'catalog_number',
      'genres',
      'packaging',
      'studios',
      'country',
      'is_live',
      'extra',
      'spars_code',
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
    final discs = _requiredMaps(catalogPayload['discs'], path: 'Music discs');
    for (var discIndex = 0; discIndex < discs.length; discIndex++) {
      final disc = discs[discIndex];
      if (disc['id'] is! String ||
          (disc['id'] as String).trim().isEmpty ||
          disc['disc_number'] is! int) {
        throw FormatException(
          'Music disc ${discIndex + 1} is missing its canonical identity.',
        );
      }
      final tracks = _requiredMaps(
        disc['tracks'],
        path: 'Music disc ${discIndex + 1} tracks',
      );
      for (var trackIndex = 0; trackIndex < tracks.length; trackIndex++) {
        final track = tracks[trackIndex];
        if (track['id'] is! String ||
            (track['id'] as String).trim().isEmpty ||
            track['position'] is! String ||
            track['position_order'] is! int ||
            (track['position_order'] as int) < 0 ||
            track['title'] is! String ||
            (track['title'] as String).trim().isEmpty ||
            track['is_header'] is! bool ||
            track['indent_level'] is! int) {
          throw FormatException(
            'Music disc ${discIndex + 1} track ${trackIndex + 1} is missing '
            'canonical identity or ordering fields.',
          );
        }
      }
    }
    const discFields = <String>{
      'id',
      'disc_number',
      'title',
      'format_family',
      'format',
      'sound_types',
      'color',
      'vinyl_weight_grams',
      'rpm',
      'matrix_number',
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
      'is_header',
      'parent_header_id',
      'indent_level',
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
          'person_id': artistId ?? name,
          'role': _text(person['role']) ?? normalizedRole,
          'sequence': sequence,
          if (name != null) 'name': name,
          if (_text(person['sort_name']) case final sortName?)
            'sort_name': sortName,
          if (_text(person['instrument']) case final instrument?)
            'instrument': instrument,
          if (_text(person['image_url']) case final imageUrl?)
            'image_url': imageUrl,
        });
      }
    }

    final localPayload = <String, dynamic>{
      ...catalogPayload,
      'country_code': catalogPayload['country'],
      'publisher': catalogPayload['label'],
      'contributions': contributionRows,
      'discs': [
        for (final disc in discs)
          {
            ...disc,
            'disc_number': disc['disc_number'],
            'tracks': _requiredMaps(
              disc['tracks'],
              path: 'Music disc ${disc['disc_number']} tracks',
            ),
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
            'name': contribution.displayName ?? contribution.personId,
            if (contribution.sortName != null)
              'sort_name': contribution.sortName,
            if (contribution.instrument != null)
              'instrument': contribution.instrument,
          },
    ];

List<String> _namesForRole(MusicAlbum album, String role) => [
      for (final contribution in album.contributions)
        if (contribution.role.toLowerCase() == role.toLowerCase())
          contribution.displayName ?? contribution.personId,
    ];

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : int.tryParse(value?.toString().trim() ?? '');

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];

List<Map<String, dynamic>> _requiredMaps(
  Object? value, {
  required String path,
}) {
  if (value is! Iterable) {
    throw FormatException('$path must be a list.');
  }
  final result = <Map<String, dynamic>>[];
  var index = 0;
  for (final entry in value) {
    if (entry is! Map) {
      throw FormatException('$path entry ${index + 1} must be an object.');
    }
    result.add(Map<String, dynamic>.from(entry));
    index++;
  }
  return result;
}
