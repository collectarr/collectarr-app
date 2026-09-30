import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

/// Maps one flat Core Music Catalog Item into the local Music domain model.
/// Discs and tracks remain contained children of this concrete album edition.
final class MusicCatalogMapper {
  const MusicCatalogMapper._();

  static MusicRelease mapDtoToMusic(CatalogItemDto dto) =>
      mapMetadataItemToMusic(dto);

  static MusicRelease mapMetadataItemToMusic(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is MusicRelease) return metadata;
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

  static MusicRelease _fromTypedDto(CatalogMusicItemDto item) {
    final discPayloads = <Map<String, dynamic>>[];
    for (final disc in item.discs) {
      final mediumId = '${item.id}:disc:${disc.discNumber}';
      discPayloads.add({
        'id': mediumId,
        'release_id': item.id,
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

    return MusicRelease.fromJson({
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
          'release_id': item.id,
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

String? _text(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
