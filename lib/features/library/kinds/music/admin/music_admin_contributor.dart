import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';

List<Map<String, dynamic>> _musicTrackRows(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final row in value)
      if (row is Map) Map<String, dynamic>.from(row),
  ];
}

String _readMusicTracks(LibraryMetadataCorrectionValues values) {
  return _musicTrackRows(values.read('tracks'))
      .map(
        (track) => [
          track['title']?.toString() ?? '',
          track['artist']?.toString() ?? '',
          track['disc_number']?.toString() ?? '',
          track['position']?.toString() ?? '',
          track['duration_seconds']?.toString() ?? '',
        ].join(' | '),
      )
      .join('\n');
}

void _writeMusicTracks(
  LibraryMetadataCorrectionValues values,
  String rawValue,
) {
  final rows = <Map<String, dynamic>>[];
  final lines = rawValue.split('\n');
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    if (line.isEmpty) {
      continue;
    }
    final columns =
        line.split('|').map((value) => value.trim()).toList(growable: false);
    final title = columns.isEmpty ? '' : columns.first;
    if (title.isEmpty) {
      throw FormatException(
        'Tracks line ${index + 1} is invalid: title is required before "|"',
      );
    }
    final track = <String, dynamic>{'title': title};
    if (columns.length > 1 && columns[1].isNotEmpty) {
      track['artist'] = columns[1];
    }
    _writeMusicTrackInteger(
      track,
      columns,
      index,
      column: 2,
      key: 'disc_number',
      label: 'disc number',
    );
    _writeMusicTrackInteger(
      track,
      columns,
      index,
      column: 3,
      key: 'position',
      label: 'position',
    );
    _writeMusicTrackInteger(
      track,
      columns,
      index,
      column: 4,
      key: 'duration_seconds',
      label: 'duration',
    );
    rows.add(track);
  }
  if (rows.isEmpty) {
    values.remove('tracks');
  } else {
    values.write('tracks', rows);
  }
}

void _writeMusicTrackInteger(
  Map<String, dynamic> track,
  List<String> columns,
  int lineIndex, {
  required int column,
  required String key,
  required String label,
}) {
  if (columns.length <= column || columns[column].isEmpty) {
    return;
  }
  final parsed = int.tryParse(columns[column]);
  if (parsed == null) {
    throw FormatException(
      'Tracks line ${lineIndex + 1} has invalid $label "${columns[column]}"',
    );
  }
  track[key] = parsed;
}

/// Music owns track proposal editing and its compact provider-payload codec.
class MusicAdminContributor implements LibraryAdminContributor {
  const MusicAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  List<LibraryAdminProposalField> get proposalFields => [
        adminTextProposalField(key: 'item_number', label: 'Item number'),
        adminTextProposalField(key: 'subtitle', label: 'Subtitle'),
        adminTextProposalField(key: 'publisher', label: 'Publisher'),
        adminTextProposalField(
          key: 'synopsis',
          label: 'Synopsis',
          minLines: 2,
          maxLines: 3,
        ),
        adminStringListProposalField(
          key: 'genres',
          label: 'Genres (comma separated)',
        ),
        LibraryAdminProposalField(
          key: 'tracks',
          label: 'Tracks (title | artist | disc | pos | duration)',
          minLines: 2,
          maxLines: 5,
          read: _readMusicTracks,
          write: _writeMusicTracks,
        ),
        adminExternalLinksProposalField(key: 'external_links'),
      ];

  @override
  List<LibraryAdminCorrectionField> get correctionFields => [
        adminCorrectionFieldValueOverride(
          key: 'edition_title',
          read: (item) =>
              item.primaryEdition?.title ??
              item.canonicalFieldValues['edition_title'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'release_date',
          read: (item) =>
              item.primaryEdition?.releaseDateParts ??
              item.primaryEdition?.releaseDate ??
              item.coverDate ??
              item.canonicalFieldValues['release_date'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'publisher',
          read: (item) =>
              item.primaryEdition?.publisher ??
              item.publisher ??
              item.canonicalFieldValues['publisher'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'subtitle',
          read: (item) =>
              item.publishing?.subtitle ??
              item.canonicalFieldValues['subtitle'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'barcode',
          read: (item) =>
              item.primaryVariant?.barcode ??
              item.barcode ??
              item.canonicalFieldValues['barcode'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'variant_name',
          read: (item) =>
              item.primaryVariant?.name ??
              item.canonicalFieldValues['variant_name'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'catalog_number',
          read: (item) =>
              item.music?.catalogNumber ??
              item.canonicalFieldValues['catalog_number'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'release_status',
          read: (item) =>
              item.music?.releaseStatus ??
              item.canonicalFieldValues['release_status'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'genres',
          read: (item) => item.genres.isNotEmpty
              ? item.genres
              : item.canonicalFieldValues['genres'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'cover_image_url',
          read: (item) =>
              item.primaryVariant?.coverImageUrl ??
              item.canonicalFieldValues['cover_image_url'],
        ),
        adminCorrectionFieldValueOverride(
          key: 'thumbnail_image_url',
          read: (item) =>
              item.primaryVariant?.thumbnailImageUrl ??
              item.canonicalFieldValues['thumbnail_image_url'],
        ),
        adminPhysicalFormatCorrectionField(
          key: 'physical_format',
          read: (item) =>
              item.primaryEdition?.physicalFormat ??
              item.primaryEdition?.physicalFormatLabel ??
              item.canonicalFieldValues['physical_format'],
        ),
        adminRelatedListCorrectionField(
          key: 'series_tags',
          label: 'Series tags',
          relatedFieldKey: 'tags',
          relatedEntityId: (item) => item.series?.seriesId,
          read: (item) =>
              item.series?.tags ?? item.canonicalFieldValues['series_tags'],
        ),
        adminUrlListCorrectionField(
          key: 'external_links',
          label: 'External links',
          linkKind: 'external',
          read: (item) => item.externalLinks,
        ),
      ];
  @override
  Map<String, Object?> serializeCoverCorrection({
    required String? coverImageUrl,
    required String? thumbnailImageUrl,
  }) =>
      {
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };
  @override
  List<LibraryMetadataOverrideField> get metadataOverrideFields => [
        const LibraryMetadataOverrideField(
          id: MetadataFieldId(
            kind: CatalogMediaKind.music,
            value: 'title',
          ),
          label: 'Title',
        ),
        for (final field in proposalFields)
          LibraryMetadataOverrideField(
            id: MetadataFieldId(
              kind: CatalogMediaKind.music,
              value: field.key,
            ),
            label: field.label,
          ),
      ];
}
