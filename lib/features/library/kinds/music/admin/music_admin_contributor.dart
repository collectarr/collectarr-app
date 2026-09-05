import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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

String _readMusicTracks(Map<String, dynamic> payload) {
  return _musicTrackRows(payload['tracks'])
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

void _writeMusicTracks(Map<String, dynamic> payload, String rawValue) {
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
    payload.remove('tracks');
  } else {
    payload['tracks'] = rows;
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
        adminExternalLinksProposalField(),
      ];
}
