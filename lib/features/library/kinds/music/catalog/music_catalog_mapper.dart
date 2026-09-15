import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';

/// Maps catalog transport into Music's canonical release-group graph.
///
/// The input is still a transport envelope because mixed catalog search and
/// older persisted payloads cross that boundary. The result is always the
/// concrete Music graph; no legacy metadata aggregate is created.
final class MusicCatalogMapper {
  const MusicCatalogMapper._();

  static MusicReleaseGroup mapDtoToMusic(CatalogItemDto dto) =>
      mapMetadataItemToMusic(dto);

  static MusicReleaseGroup mapMetadataItemToMusic(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is MusicReleaseGroup) return metadata;
    if (metadata is MusicRelease) return _groupFromRelease(metadata);
    return _fromPayload(item.payload, item);
  }

  static MusicReleaseGroup _fromPayload(
    Map<String, dynamic> payload,
    CatalogItemDto item,
  ) {
    // Some transport envelopes keep kind-specific fields under `music` while
    // the canonical graph uses release-group/release/medium/track fields at
    // the top level. Flatten that only at this transport boundary.
    final nestedMusic = payload['music'];
    final sourcePayload = nestedMusic is Map
        ? <String, dynamic>{
            ...payload,
            ...Map<String, dynamic>.from(nestedMusic),
          }
        : payload;
    final groupId = _text(sourcePayload['release_group_id']) ??
        _text(sourcePayload['id']) ??
        item.id;
    final isReleaseGroup =
        sourcePayload['entity_type'] == 'music_release_group';
    final rawReleases = _maps(sourcePayload['releases']);
    final releases = <MusicRelease>[];

    for (var index = 0; index < rawReleases.length; index++) {
      releases.add(
        _releaseFromPayload(
          rawReleases[index],
          groupId: groupId,
          fallbackId: '$groupId:release:${index + 1}',
          fallbackGroup: sourcePayload,
        ),
      );
    }

    if (releases.isEmpty) {
      for (final edition in item.editions) {
        releases.add(
          _releaseFromEdition(
            edition,
            groupId: groupId,
            fallbackGroup: sourcePayload,
          ),
        );
      }
    }

    if (!isReleaseGroup &&
        releases.isEmpty &&
        (sourcePayload['release_group_id'] != null ||
            sourcePayload['mediums'] is Iterable ||
            sourcePayload['medium_id'] != null)) {
      final release = MusicRelease.fromJson({
        ...sourcePayload,
        'release_group_id': sourcePayload['release_group_id'] ?? groupId,
        'id': sourcePayload['release_id'] ??
            sourcePayload['id'] ??
            '$groupId:release',
      });
      return _groupFromRelease(
        release,
        groupId: MusicReleaseGroupId(
          _text(sourcePayload['release_group_id']) ?? groupId,
        ),
        payload: sourcePayload,
      );
    }

    if (releases.isEmpty) {
      final tracks = _maps(sourcePayload['tracks']);
      if (tracks.isNotEmpty) {
        releases.add(
          _releaseFromPayload(
            {
              'id': '$groupId:release',
              'title': sourcePayload['title'],
              'tracks': tracks,
            },
            groupId: groupId,
            fallbackId: '$groupId:release',
            fallbackGroup: sourcePayload,
          ),
        );
      }
    }

    if (releases.isEmpty && !isReleaseGroup) {
      releases.add(
        _releaseFromPayload(
          sourcePayload,
          groupId: groupId,
          fallbackId: '$groupId:release',
          fallbackGroup: sourcePayload,
        ),
      );
    }

    final primary = releases.firstOrNull;
    final series = sourcePayload['series'];
    final seriesTitle = series is Map
        ? _text(series['series_title'] ?? series['title'] ?? series['name'])
        : null;
    return MusicReleaseGroup(
      id: MusicReleaseGroupId(groupId),
      title: _text(sourcePayload['title']) ?? item.title,
      sortTitle: _text(sourcePayload['sort_title']),
      artist: _text(
            sourcePayload['artist'] ??
                sourcePayload['artist_name'] ??
                sourcePayload['series_title'],
          ) ??
          seriesTitle ??
          _artistFromContributions(primary?.contributions),
      originalTitle:
          _text(sourcePayload['original_title'] ?? item.originalTitle),
      synopsis: _text(sourcePayload['synopsis'] ?? item.synopsis),
      originalReleaseDate: _date(sourcePayload['original_release_date']) ??
          _date(sourcePayload['release_date']),
      recordingDate: _date(sourcePayload['recording_date']),
      studio: _text(sourcePayload['studio']),
      isLive: sourcePayload['is_live'] as bool?,
      genres: _strings(sourcePayload['genres']),
      coverImageUrl:
          _text(sourcePayload['cover_image_url'] ?? item.coverImageUrl),
      coverImageKey: _text(sourcePayload['cover_image_key']),
      releases: releases,
      metadataJson: payload,
    );
  }

  static MusicRelease _releaseFromPayload(
    Map<String, dynamic> source, {
    required String groupId,
    required String fallbackId,
    required Map<String, dynamic> fallbackGroup,
  }) {
    final rawMediums = _maps(source['mediums']);
    if (rawMediums.isNotEmpty) {
      return MusicRelease.fromJson({
        'release_group_id': groupId,
        ...source,
        'id': source['id'] ?? fallbackId,
      });
    }

    final rawDiscs = _maps(source['discs']);
    final rawTracks = _maps(source['tracks']);
    final mediumSource =
        rawDiscs.isNotEmpty ? rawDiscs : _groupTracksByMedium(rawTracks);
    final releaseId = _text(source['id']) ?? fallbackId;
    final mediumType = _text(
      source['medium_type'] ??
          source['format'] ??
          source['physical_format'] ??
          fallbackGroup['medium_type'] ??
          fallbackGroup['physical_format'],
    );
    final mediums = [
      for (var index = 0; index < mediumSource.length; index++)
        _mediumFromPayload(
          mediumSource[index],
          releaseId: releaseId,
          fallbackNumber: index + 1,
          fallbackType: mediumType,
        ),
    ];

    return MusicRelease.fromJson({
      'id': releaseId,
      'release_group_id': groupId,
      'kind': 'music',
      'title':
          _text(source['title']) ?? _text(fallbackGroup['title']) ?? 'Release',
      if (_text(source['sort_title']) != null)
        'sort_title': source['sort_title'],
      if (_text(source['subtitle']) != null) 'subtitle': source['subtitle'],
      if (_text(source['release_type'] ?? source['type']) != null)
        'release_type': source['release_type'] ?? source['type'],
      if (_text(source['release_status']) != null)
        'release_status': source['release_status'],
      if (_date(source['release_date']) != null)
        'release_date': _date(source['release_date'])!.toIso8601String(),
      if (_text(source['publisher'] ?? source['label']) != null)
        'publisher': source['publisher'] ?? source['label'],
      if (_text(source['country_code'] ?? source['country']) != null)
        'country_code': source['country_code'] ?? source['country'],
      if (_text(source['language'] ?? source['release_language']) != null)
        'language': source['language'] ?? source['release_language'],
      if (_text(source['barcode']) != null) 'barcode': source['barcode'],
      if (_text(source['upc']) != null) 'upc': source['upc'],
      if (_text(source['catalog_number']) != null)
        'catalog_number': source['catalog_number'],
      if (_text(source['packaging']) != null) 'packaging': source['packaging'],
      if (_text(source['cover_image_url']) != null)
        'cover_image_url': source['cover_image_url'],
      if (_text(source['cover_image_key']) != null)
        'cover_image_key': source['cover_image_key'],
      if (source['contributions'] is Iterable)
        'contributions': source['contributions'],
      if (source['identifiers'] is Iterable)
        'identifiers': source['identifiers'],
      'mediums': mediums.map((medium) => medium.toJson()).toList(),
    });
  }

  static MusicRelease _releaseFromEdition(
    CatalogEditionDto edition, {
    required String groupId,
    required Map<String, dynamic> fallbackGroup,
  }) {
    final releaseId = edition.id;
    final mediums = [
      for (var index = 0; index < edition.discs.length; index++)
        _mediumFromPayload(
          edition.discs[index].toJson(),
          releaseId: releaseId,
          fallbackNumber: edition.discs[index].discNumber ?? index + 1,
          fallbackType: edition.physicalFormat,
        ),
    ];
    return MusicRelease.fromJson({
      'id': releaseId,
      'release_group_id': groupId,
      'title': edition.title,
      if (edition.publisher != null) 'publisher': edition.publisher,
      if (edition.upc != null) 'barcode': edition.upc,
      if (edition.releaseDate != null)
        'release_date': edition.releaseDate!.toIso8601String(),
      if (edition.language != null) 'language': edition.language,
      if (edition.physicalFormat != null) 'packaging': edition.physicalFormat,
      'mediums': mediums.map((medium) => medium.toJson()).toList(),
      if (_text(fallbackGroup['country_code'] ?? fallbackGroup['country']) !=
          null)
        'country_code':
            fallbackGroup['country_code'] ?? fallbackGroup['country'],
    });
  }

  static MusicMedium _mediumFromPayload(
    Map<String, dynamic> source, {
    required String releaseId,
    required int fallbackNumber,
    String? fallbackType,
  }) {
    final number = _int(source['medium_number'] ?? source['disc_number']) ??
        fallbackNumber;
    final mediumId = _text(source['id']) ?? '$releaseId:medium:$number';
    final rawTracks = _maps(source['tracks']);
    final tracks = [
      for (var index = 0; index < rawTracks.length; index++)
        _trackPayload(
          rawTracks[index],
          mediumId: mediumId,
          fallbackPosition: index + 1,
        ),
    ];
    return MusicMedium.fromJson({
      ...source,
      'id': mediumId,
      'release_id': releaseId,
      'medium_number': number,
      if (source['medium_type'] == null && fallbackType != null)
        'medium_type': fallbackType,
      'tracks': tracks,
    });
  }

  static Map<String, dynamic> _trackPayload(
    Map<String, dynamic> source, {
    required String mediumId,
    required int fallbackPosition,
  }) {
    final position = _text(source['position'] ?? source['number']) ??
        fallbackPosition.toString();
    final durationSeconds = _int(source['duration_seconds']);
    return {
      ...source,
      'id': source['id'] ?? '$mediumId:track:$position',
      'medium_id': mediumId,
      'position': position,
      'title': _text(source['title']) ?? 'Track $position',
      if (source['duration_ms'] == null && durationSeconds != null)
        'duration_ms': durationSeconds * 1000,
    };
  }

  static List<Map<String, dynamic>> _groupTracksByMedium(
    List<Map<String, dynamic>> tracks,
  ) {
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final track in tracks) {
      final medium = _int(track['medium_number'] ?? track['disc_number']) ?? 1;
      grouped.putIfAbsent(medium, () => []).add(track);
    }
    return [
      for (final entry in grouped.entries)
        {
          'medium_number': entry.key,
          'tracks': entry.value,
        },
    ];
  }

  static MusicReleaseGroup _groupFromRelease(
    MusicRelease release, {
    MusicReleaseGroupId? groupId,
    Map<String, dynamic>? payload,
  }) {
    return MusicReleaseGroup(
      id: groupId ?? release.releaseGroupId,
      title: _text(payload?['title']) ?? release.title,
      artist: _text(payload?['artist']),
      synopsis: _text(payload?['synopsis']),
      originalReleaseDate:
          _date(payload?['original_release_date']) ?? release.releaseDate,
      coverImageUrl:
          _text(payload?['cover_image_url']) ?? release.coverImageUrl,
      coverImageKey:
          _text(payload?['cover_image_key']) ?? release.coverImageKey,
      releases: [release],
      metadataJson: payload ?? release.metadataJson,
    );
  }

  static String? _artistFromContributions(
      List<MusicReleaseContribution>? values) {
    for (final value in values ?? const <MusicReleaseContribution>[]) {
      final name = value.displayName;
      if (name != null) return name;
    }
    return null;
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  static DateTime? _date(Object? value) =>
      DateTime.tryParse(value?.toString().trim() ?? '');

  static List<String> _strings(Object? value) => value is Iterable
      ? [
          for (final entry in value)
            if (_text(entry) case final text?) text
        ]
      : const <String>[];

  static List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
      ? [
          for (final entry in value)
            if (entry is Map) Map<String, dynamic>.from(entry),
        ]
      : const <Map<String, dynamic>>[];
}
