import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
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
    _normalizeAlbumDetails(sourcePayload);
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
    final seriesMap = series is Map
        ? Map<String, dynamic>.from(series)
        : const <String, dynamic>{};
    return MusicReleaseGroup(
      id: MusicReleaseGroupId(groupId),
      title: _text(sourcePayload['title']) ?? item.title,
      sortTitle: _text(sourcePayload['sort_title']),
      artist: _text(
            sourcePayload['artist'] ?? sourcePayload['artist_name'],
          ) ??
          _text(seriesMap['series_title'] ?? seriesMap['artist']) ??
          _artistFromContributions(primary?.contributions),
      originalTitle:
          _text(sourcePayload['original_title'] ?? item.originalTitle),
      originalReleaseDate: _date(sourcePayload['original_release_date']) ??
          _date(sourcePayload['release_date']),
      recordingDate: _date(sourcePayload['recording_date']),
      studio: _text(sourcePayload['studio']),
      isLive: sourcePayload['is_live'] as bool?,
      genres: _strings(sourcePayload['genres']),
      coverImageUrl:
          _text(sourcePayload['cover_image_url'] ?? item.coverImageUrl),
      coverImageKey: _text(sourcePayload['cover_image_key']),
      externalLinks: _externalLinks(sourcePayload),
      localCoverImagePath: _text(sourcePayload['local_cover_image_path']),
      localBackImagePath: _text(sourcePayload['local_back_image_path']),
      localThumbnailImagePath:
          _text(sourcePayload['local_thumbnail_image_path']),
      releases: releases,
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
      final fallbackType = _releaseMediumType(source, fallbackGroup);
      return MusicRelease.fromJson(
        _releasePayload(
          source,
          groupId: groupId,
          fallbackId: fallbackId,
          fallbackGroup: fallbackGroup,
          mediums: [
            for (var index = 0; index < rawMediums.length; index++)
              {
                ...rawMediums[index],
                if (index == 0 &&
                    _text(rawMediums[index]['medium_type']) == null &&
                    fallbackType != null)
                  'medium_type': fallbackType,
              },
          ],
        ),
      );
    }

    final rawDiscs = _maps(source['discs']);
    final rawTracks = _maps(source['tracks']);
    final groupedTracks = _groupTracksByMedium(
      rawTracks,
      discTitles: _maps(source['disc_titles']),
    );
    final trackCount =
        _int(source['track_count'] ?? fallbackGroup['track_count']);
    final mediumType = _releaseMediumType(source, fallbackGroup);
    final mediumSource = rawDiscs.isNotEmpty
        ? rawDiscs
        : groupedTracks.isNotEmpty
            ? groupedTracks
            : trackCount == null && mediumType == null
                ? const <Map<String, dynamic>>[]
                : [
                    {
                      if (trackCount != null) 'track_count': trackCount,
                      if (mediumType != null) 'medium_type': mediumType,
                    },
                  ];
    final releaseId = _text(source['id']) ?? fallbackId;
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
      ..._releasePayload(
        source,
        groupId: groupId,
        fallbackId: fallbackId,
        fallbackGroup: fallbackGroup,
      ),
      'id': releaseId,
      'mediums': mediums.map((medium) => medium.toJson()).toList(),
    });
  }

  static String? _releaseMediumType(
    Map<String, dynamic> source,
    Map<String, dynamic> fallbackGroup,
  ) =>
      _text(
        source['medium_type'] ??
            source['format'] ??
            source['physical_format'] ??
            source['physical_format_label'] ??
            source['variant'] ??
            fallbackGroup['medium_type'] ??
            fallbackGroup['format'] ??
            fallbackGroup['physical_format'] ??
            fallbackGroup['physical_format_label'] ??
            fallbackGroup['variant'],
      );

  static Map<String, dynamic> _releasePayload(
    Map<String, dynamic> source, {
    required String groupId,
    required String fallbackId,
    required Map<String, dynamic> fallbackGroup,
    List<Map<String, dynamic>>? mediums,
  }) {
    final releaseType = _text(source['release_type'] ?? source['type']);
    final releaseStatus = _text(
      source['release_status'] ?? fallbackGroup['release_status'],
    );
    final packaging = _text(source['packaging'] ?? fallbackGroup['packaging']);
    final releaseDate = _date(
      source['release_date'] ?? fallbackGroup['release_date'],
    );
    final sourceTitle = _text(source['title']);
    final groupTitle = _text(fallbackGroup['title']);
    final editionTitle = _text(fallbackGroup['edition_title']);
    final fallbackSeries = fallbackGroup['series'];
    final fallbackSeriesMap = fallbackSeries is Map
        ? Map<String, dynamic>.from(fallbackSeries)
        : const <String, dynamic>{};
    final subtitle = _text(
      source['subtitle'] ??
          source['edition_title'] ??
          fallbackGroup['edition_title'] ??
          fallbackSeriesMap['volume_name'],
    );
    final title = editionTitle != null &&
            (sourceTitle == null || sourceTitle == groupTitle)
        ? editionTitle
        : sourceTitle ?? editionTitle ?? groupTitle ?? 'Release';
    return {
      ...source,
      'id': _text(source['id']) ?? fallbackId,
      'release_group_id': groupId,
      'kind': 'music',
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (releaseType != null) 'release_type': releaseType,
      if (releaseStatus != null) 'release_status': releaseStatus,
      if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
      if (packaging != null) 'packaging': packaging,
      if (mediums != null) 'mediums': mediums,
      if (mediums != null)
        'medium_types':
            _strings(mediums.map((medium) => medium['medium_type'])),
      if (_text(source['publisher'] ??
              source['label'] ??
              fallbackGroup['publisher'])
          case final publisher?)
        'publisher': publisher,
      if (_text(source['country_code'] ??
              source['country'] ??
              fallbackGroup['country_code'] ??
              fallbackGroup['country'])
          case final country?)
        'country_code': country,
      if (_text(source['language'] ??
              source['release_language'] ??
              fallbackGroup['language'])
          case final language?)
        'language': language,
      if (_text(source['barcode'] ?? fallbackGroup['barcode'])
          case final barcode?)
        'barcode': barcode,
      if (_text(source['upc'] ?? fallbackGroup['upc']) case final upc?)
        'upc': upc,
      if (_text(source['catalog_number'] ?? fallbackGroup['catalog_number'])
          case final catalogNumber?)
        'catalog_number': catalogNumber,
      if (_text(source['cover_image_url'] ?? fallbackGroup['cover_image_url'])
          case final coverImageUrl?)
        'cover_image_url': coverImageUrl,
      if (_text(source['cover_image_key'] ?? fallbackGroup['cover_image_key'])
          case final coverImageKey?)
        'cover_image_key': coverImageKey,
      if (source['external_links'] != null)
        'external_links': source['external_links'],
      if (source['trailer_urls'] != null)
        'trailer_urls': source['trailer_urls'],
      if (source['box_set'] == null && fallbackGroup['box_set'] != null)
        'box_set': fallbackGroup['box_set'],
      if (source['box_set_ref'] == null && fallbackGroup['box_set_ref'] != null)
        'box_set_ref': fallbackGroup['box_set_ref'],
      if (source['box_set_position'] == null &&
          fallbackGroup['box_set_position'] != null)
        'box_set_position': fallbackGroup['box_set_position'],
    };
  }

  static MusicRelease _releaseFromEdition(
    CatalogEditionDto edition, {
    required String groupId,
    required Map<String, dynamic> fallbackGroup,
  }) {
    final releaseId = edition.id;
    final fallbackTracks = _maps(fallbackGroup['tracks']);
    final mediums = edition.discs.isNotEmpty
        ? [
            for (var index = 0; index < edition.discs.length; index++)
              _mediumFromPayload(
                edition.discs[index].toJson(),
                releaseId: releaseId,
                fallbackNumber: edition.discs[index].discNumber ?? index + 1,
                fallbackType: edition.physicalFormat,
              ),
          ]
        : fallbackTracks.isEmpty
            ? const <MusicMedium>[]
            : [
                _mediumFromPayload(
                  {
                    'medium_number': 1,
                    'tracks': fallbackTracks,
                  },
                  releaseId: releaseId,
                  fallbackNumber: 1,
                  fallbackType: edition.physicalFormat,
                ),
              ];
    return MusicRelease.fromJson({
      'id': releaseId,
      'release_group_id': groupId,
      'title': edition.title,
      if (edition.format != null) 'release_type': edition.format,
      if (edition.publisher != null) 'publisher': edition.publisher,
      if (edition.upc != null) 'barcode': edition.upc,
      if (_text(fallbackGroup['catalog_number']) case final catalogNumber?)
        'catalog_number': catalogNumber,
      if (_text(fallbackGroup['release_status']) case final releaseStatus?)
        'release_status': releaseStatus,
      if (edition.releaseDateParts != null)
        'release_date_parts': edition.releaseDateParts!.toJson(),
      if (edition.releaseDate != null)
        'release_date': edition.releaseDate!.toIso8601String(),
      if (edition.language != null) 'language': edition.language,
      if (edition.physicalFormat != null)
        'medium_types': [edition.physicalFormat],
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
      if (_text(source['artist']) != null) 'artist': source['artist'],
      if (source['duration_ms'] == null && durationSeconds != null)
        'duration_ms': durationSeconds * 1000,
    };
  }

  static List<Map<String, dynamic>> _groupTracksByMedium(
    List<Map<String, dynamic>> tracks, {
    List<Map<String, dynamic>> discTitles = const [],
  }) {
    final grouped = <int, List<Map<String, dynamic>>>{};
    final titlesByDisc = <int, String>{
      for (final value in discTitles)
        if (_int(value['disc_number']) case final number?)
          if (_text(value['title']) case final title?) number: title,
    };
    for (final number in titlesByDisc.keys) {
      grouped.putIfAbsent(number, () => <Map<String, dynamic>>[]);
    }
    for (final track in tracks) {
      final medium = _int(track['medium_number'] ?? track['disc_number']) ?? 1;
      grouped.putIfAbsent(medium, () => []).add(track);
    }
    final orderedDiscNumbers = grouped.keys.toList()..sort();
    return [
      for (final discNumber in orderedDiscNumbers)
        {
          'medium_number': discNumber,
          if (titlesByDisc[discNumber] case final title?) 'title': title,
          'tracks': grouped[discNumber]!,
        },
    ];
  }

  /// Accepts the flattened MusicAlbum v1 details at the old local catalog
  /// boundary while the remaining Music persistence/workspace path is being
  /// moved off release-group aggregates.
  static void _normalizeAlbumDetails(Map<String, dynamic> source) {
    final artists = _maps(source['artists']);
    final labels = _maps(source['labels']);
    if (_text(source['artist']) == null && artists.isNotEmpty) {
      source['artist'] = artists
          .map((artist) => _text(artist['name']))
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .join(', ');
    }
    final primaryLabel = labels.firstOrNull;
    if (_text(source['publisher']) == null && primaryLabel != null) {
      source['publisher'] = primaryLabel['name'];
    }
    if (_text(source['catalog_number']) == null && primaryLabel != null) {
      source['catalog_number'] = primaryLabel['catalog_number'];
    }
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
      originalReleaseDate:
          _date(payload?['original_release_date']) ?? release.releaseDate,
      originalReleaseDateParts: PartialDate.tryParse(
            payload?['original_release_date_parts'] ??
                payload?['original_release_date'],
          ) ??
          release.releaseDateParts,
      coverImageUrl:
          _text(payload?['cover_image_url']) ?? release.coverImageUrl,
      coverImageKey:
          _text(payload?['cover_image_key']) ?? release.coverImageKey,
      externalLinks:
          payload == null ? release.externalLinks : _externalLinks(payload),
      releases: [release],
      localCoverImagePath: _text(payload?['local_cover_image_path']),
      localBackImagePath: _text(payload?['local_back_image_path']),
      localThumbnailImagePath: _text(payload?['local_thumbnail_image_path']),
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

  static List<MusicExternalLink> _externalLinks(Map<String, dynamic> payload) {
    final raw = [
      ..._maps(payload['external_links']),
      ..._maps(payload['trailer_urls']),
    ];
    final seen = <String>{};
    final links = <MusicExternalLink>[];
    for (final value in raw) {
      final url = _text(value['url']);
      if (url == null || !seen.add(url)) continue;
      links.add(MusicExternalLink.fromJson(value));
    }
    return links;
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
