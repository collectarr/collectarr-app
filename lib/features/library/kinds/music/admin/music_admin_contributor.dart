import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';

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

List<Map<String, dynamic>> _musicCorrectionTracks(AdminMetadataItem item) {
  final discs = item.canonicalFieldValues['discs'];
  if (discs is! List) return const [];
  return [
    for (final discValue in discs)
      if (discValue is Map)
        for (final trackValue in (discValue['tracks'] as List? ?? const []))
          if (trackValue is Map)
            {
              ...Map<String, dynamic>.from(trackValue),
              'disc_number': discValue['disc_number'],
            },
  ];
}

String _formatCorrectionMusicTracks(Object? value) {
  final values = LibraryMetadataCorrectionValues.fromSerialized({
    'tracks': value,
  });
  return _readMusicTracks(values);
}

List<Map<String, dynamic>> _parseCorrectionMusicTracks(String rawValue) {
  final values = LibraryMetadataCorrectionValues.fromSerialized({});
  _writeMusicTracks(values, rawValue);
  return _musicTrackRows(values.read('tracks'));
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

/// Music owns its track correction editor and compact track-list codec.
class MusicAdminContributor implements LibraryAdminContributor {
  const MusicAdminContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  List<LibraryAdminProposalField> get proposalFields => [
        adminTextProposalField(key: 'subtitle', label: 'Subtitle'),
        adminTextProposalField(key: 'artist', label: 'Artist'),
        adminTextProposalField(key: 'label', label: 'Label'),
        adminTextProposalField(key: 'format', label: 'Format'),
        adminTextProposalField(
          key: 'catalog_number',
          label: 'Catalog number',
        ),
        adminTextProposalField(key: 'barcode', label: 'Barcode'),
        adminStringListProposalField(
          key: 'genres',
          label: 'Genre (comma separated)',
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
        adminCorrectionField(
          key: 'tracks',
          label: 'Tracks (title | artist | disc | pos | duration)',
          tab: SharedMetadataEditTab.relations,
          read: _musicCorrectionTracks,
          valueType: SharedMetadataFieldValueType.json,
          inputType: SharedMetadataFieldInputType.multiline,
          minLines: 3,
          maxLines: 8,
          parse: _parseCorrectionMusicTracks,
          format: _formatCorrectionMusicTracks,
          save: (item, value, writer) => writer.updateCatalogFields({
            'tracks': value,
          }),
        ),
        adminUrlListCorrectionField(
          key: 'external_links',
          label: 'External links',
          linkKind: 'external',
          read: (item) => item.canonicalFieldValues['external_links'],
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
