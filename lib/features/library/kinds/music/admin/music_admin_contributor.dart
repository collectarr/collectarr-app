import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:uuid/uuid.dart';

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
          _durationSeconds(track['duration_ms']),
          track['is_header'] == true ? 'true' : 'false',
        ].join(' | '),
      )
      .join('\n');
}

List<Map<String, dynamic>> _completeMusicCorrectionTracks(
  Object? value, {
  required Object? existingRows,
}) {
  final rows = _musicTrackRows(value);
  final existing = _musicTrackRows(existingRows);
  final oldDiscs = <int, String>{};
  final oldTracksByPosition = <String, List<Map<String, dynamic>>>{};
  for (final track in existing) {
    final discNumber = int.tryParse(track['disc_number']?.toString() ?? '');
    final discId = track['disc_id']?.toString();
    if (discNumber == null || discId == null || discId.isEmpty) continue;
    oldDiscs[discNumber] = discId;
    final key = '$discNumber|${track['position'] ?? ''}';
    oldTracksByPosition.putIfAbsent(key, () => []).add(track);
  }

  final discIds = <int, String>{...oldDiscs};
  final orderByDisc = <int, int>{};
  return [
    for (var index = 0; index < rows.length; index++)
      () {
        final row = rows[index];
        final discNumber = int.tryParse(row['disc_number']?.toString() ?? '');
        if (discNumber == null || discNumber < 1) {
          throw FormatException(
            'Tracks line ${index + 1} must include a positive disc number.',
          );
        }
        final position = row['position']?.toString().trim() ?? '';
        final title = row['title']?.toString().trim() ?? '';
        final candidates = oldTracksByPosition['$discNumber|$position'];
        Map<String, dynamic>? oldTrack;
        if (candidates != null && candidates.isNotEmpty) {
          final matchIndex = candidates.indexWhere(
            (candidate) => candidate['title']?.toString() == title,
          );
          if (matchIndex >= 0) {
            oldTrack = candidates.removeAt(matchIndex);
          }
        }
        if (oldTrack == null) {
          for (final entry in oldTracksByPosition.entries) {
            if (!entry.key.startsWith('$discNumber|')) continue;
            final matchIndex = entry.value.indexWhere(
              (candidate) => candidate['title']?.toString() == title,
            );
            if (matchIndex >= 0) {
              oldTrack = entry.value.removeAt(matchIndex);
              break;
            }
          }
        }
        if (oldTrack == null && candidates != null && candidates.isNotEmpty) {
          oldTrack = candidates.removeAt(0);
        }
        final isHeader = row['is_header'] == true;
        if (!isHeader && position.isEmpty) {
          throw FormatException(
            'Tracks line ${index + 1} must include a position.',
          );
        }
        final discId = oldTrack?['disc_id']?.toString() ??
            discIds.putIfAbsent(discNumber, () => const Uuid().v4());
        discIds[discNumber] = discId;
        final positionOrder = orderByDisc[discNumber] ?? 0;
        orderByDisc[discNumber] = positionOrder + 1;
        return {
          'id': oldTrack?['id']?.toString() ?? const Uuid().v4(),
          'disc_id': discId,
          'disc_number': discNumber,
          'position': isHeader ? '' : position,
          'position_order': positionOrder,
          'title': title,
          if (row['artist'] != null) 'artist': row['artist'],
          if (row['duration_ms'] != null) 'duration_ms': row['duration_ms'],
          'is_header': isHeader,
          'parent_header_id': oldTrack?['parent_header_id'],
          'indent_level': oldTrack?['indent_level'] ?? 0,
        };
      }(),
  ];
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
              'disc_id': discValue['id'],
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
  _writeMusicTracks(values, rawValue, completeRows: false);
  return _musicTrackRows(values.read('tracks'));
}

void _writeMusicTracks(
  LibraryMetadataCorrectionValues values,
  String rawValue, {
  bool completeRows = true,
}) {
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
    track['position'] = columns.length > 3 ? columns[3] : '';
    _writeMusicTrackDuration(track, columns, index);
    final isHeader = columns.length > 5 ? columns[5].toLowerCase() : 'false';
    if (isHeader != 'true' && isHeader != 'false') {
      throw FormatException(
        'Tracks line ${index + 1} has invalid header flag "$isHeader"',
      );
    }
    track['is_header'] = isHeader == 'true';
    rows.add(track);
  }
  if (rows.isEmpty) {
    values.remove('tracks');
  } else {
    values.write(
      'tracks',
      completeRows
          ? _completeMusicCorrectionTracks(
              rows,
              existingRows: values.read('tracks'),
            )
          : rows,
    );
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

void _writeMusicTrackDuration(
  Map<String, dynamic> track,
  List<String> columns,
  int lineIndex,
) {
  if (columns.length <= 4 || columns[4].isEmpty) return;
  final seconds = double.tryParse(columns[4]);
  if (seconds == null || !seconds.isFinite || seconds < 0) {
    throw FormatException(
      'Tracks line ${lineIndex + 1} has invalid duration "${columns[4]}"',
    );
  }
  track['duration_ms'] = (seconds * 1000).round();
}

String _durationSeconds(Object? value) {
  if (value is! int) return '';
  final seconds = (value / 1000).toStringAsFixed(3);
  return seconds
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
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
        adminStringListProposalField(
          key: 'extra',
          label: 'Extra (comma separated)',
        ),
        LibraryAdminProposalField(
          key: 'tracks',
          label: 'Tracks (title | artist | disc | pos | duration | header)',
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
          key: 'extra',
          label: 'Extra',
          tab: SharedMetadataEditTab.technical,
          read: (item) => item.canonicalFieldValues['extra'],
          valueType: SharedMetadataFieldValueType.stringList,
          inputType: SharedMetadataFieldInputType.multiline,
          minLines: 2,
          maxLines: 4,
          parse: (raw) => raw
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(growable: false),
          format: (value) => value is Iterable
              ? value.map((entry) => entry.toString()).join(', ')
              : '',
          save: (item, value, writer) =>
              writer.updateCatalogFields({'extra': value}),
        ),
        adminCorrectionField(
          key: 'tracks',
          label: 'Tracks (title | artist | disc | pos | duration | header)',
          tab: SharedMetadataEditTab.relations,
          read: _musicCorrectionTracks,
          valueType: SharedMetadataFieldValueType.json,
          inputType: SharedMetadataFieldInputType.multiline,
          minLines: 3,
          maxLines: 8,
          parse: _parseCorrectionMusicTracks,
          format: _formatCorrectionMusicTracks,
          save: (item, value, writer) => writer.updateCatalogFields({
            'tracks': _completeMusicCorrectionTracks(
              value,
              existingRows: _musicCorrectionTracks(item),
            ),
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
