import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:flutter/material.dart';

/// Compares canonical Music v2 edition, credit, disc, and track data.
List<Widget> buildMusicMetadataComparePanels(
  BuildContext context, {
  required Map<String, dynamic> localPayload,
  required Map<String, dynamic> serverPayload,
  required Color accent,
}) {
  return [
    MetadataDiffPanel(
      title: 'Music metadata (Local vs Server)',
      entries: _musicMetadataEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No metadata fields available.',
    ),
    MetadataDiffPanel(
      title: 'Album credits (Local vs Server)',
      entries: _creditEntries(
        _musicItem(localPayload)['credits'],
        _musicItem(serverPayload)['credits'],
      ),
      showOnlyDifferences: false,
      emptyText: 'No album credits available.',
    ),
    MetadataDiffPanel(
      title: 'Discs (Local vs Server)',
      entries: _discEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No discs available.',
    ),
  ];
}

List<MetadataDiffEntry> _musicMetadataEntries(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final localItem = _musicItem(local);
  final serverItem = _musicItem(server);
  return [
    _entry('Title', localItem['title'], serverItem['title']),
    _entry('Sort Title', localItem['sort_title'], serverItem['sort_title']),
    _entry('Artist', localItem['artist'], serverItem['artist']),
    _dateEntry('Original release date', localItem['original_release_date'],
        serverItem['original_release_date']),
    _entry('Subtitle', localItem['subtitle'], serverItem['subtitle']),
    _dateEntry(
        'Release Date', localItem['release_date'], serverItem['release_date']),
    _entry('Record label', localItem['label'], serverItem['label']),
    _entry(
      'Country',
      musicCountryName(localItem['country']?.toString()),
      musicCountryName(serverItem['country']?.toString()),
    ),
    _entry('Barcode', localItem['barcode'], serverItem['barcode']),
    _entry('Catalog number', localItem['catalog_number'],
        serverItem['catalog_number']),
    _entry('Packaging', localItem['packaging'], serverItem['packaging']),
    _listEntry('Genres', localItem['genres'], serverItem['genres']),
    _entry('Disc count', _discs(local).length, _discs(server).length),
    _entry('Track count', _trackCount(local), _trackCount(server)),
  ];
}

MetadataDiffEntry _entry(String label, Object? local, Object? server) =>
    MetadataDiffEntry(
      label: label,
      localValue: formatDiffText(local?.toString()),
      serverValue: formatDiffText(server?.toString()),
    );

MetadataDiffEntry _dateEntry(String label, Object? local, Object? server) =>
    MetadataDiffEntry(
      label: label,
      localValue: formatDiffText(_partialDateText(local)),
      serverValue: formatDiffText(_partialDateText(server)),
    );

MetadataDiffEntry _listEntry(String label, Object? local, Object? server) =>
    MetadataDiffEntry(
      label: label,
      localValue: formatDiffList(_strings(local)),
      serverValue: formatDiffList(_strings(server)),
    );

List<MetadataDiffEntry> _creditEntries(Object? local, Object? server) {
  final localValues = _indexById(local, 'album credit');
  final serverValues = _indexById(server, 'album credit');
  final ids = <String>{...localValues.keys, ...serverValues.keys};
  return [
    for (final id in ids)
      MetadataDiffEntry(
        label: 'Credit $id',
        localValue: _creditText(localValues[id]),
        serverValue: _creditText(serverValues[id]),
      ),
  ];
}

String _creditText(Map<String, dynamic>? value) {
  if (value == null) return '—';
  final name = _text(value['name']) ?? '';
  final role = _text(value['role']) ?? '';
  final instruments = _strings(value['instruments']);
  final credit = role.isEmpty ? name : '$role: $name';
  return instruments.isEmpty ? credit : '$credit (${instruments.join(', ')})';
}

List<MetadataDiffEntry> _discEntries(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final localValues = _indexById(_discs(local), 'disc');
  final serverValues = _indexById(_discs(server), 'disc');
  final ids = <String>{...localValues.keys, ...serverValues.keys};
  return [
    for (final id in ids)
      MetadataDiffEntry(
        label: _discLabel(id, localValues[id] ?? serverValues[id]!),
        localValue: _discText(localValues[id]),
        serverValue: _discText(serverValues[id]),
      ),
  ];
}

String _discLabel(String id, Map<String, dynamic> value) {
  final number = _int(value['disc_number']);
  return number == null ? 'Disc $id' : 'Disc $number ($id)';
}

String _discText(Map<String, dynamic>? value) {
  if (value == null) return '—';
  final lines = <String>[];
  final title = _text(value['title']);
  final format = _text(value['format']);
  final family = _text(value['format_family']);
  if (title != null) lines.add('Title: $title');
  if (format != null || family != null) {
    lines.add('Format: ${[format, family].whereType<String>().join(' · ')}');
  }
  final sounds = _strings(value['sound_types']);
  if (sounds.isNotEmpty) lines.add('Sound: ${sounds.join(', ')}');
  final recordingDate = _partialDateText(value['recording_date']);
  if (recordingDate != null) lines.add('Recording date: $recordingDate');
  final locations = _strings(value['recording_locations']);
  if (locations.isNotEmpty) {
    lines.add('Recording locations: ${locations.join(', ')}');
  }
  if (value['is_live'] is bool) {
    lines
        .add('Recording type: ${value['is_live'] == true ? 'Live' : 'Studio'}');
  }
  final sparsCode = _text(value['spars_code']);
  if (sparsCode != null) lines.add('SPARS: $sparsCode');
  final credits = _maps(value['credits']);
  for (final credit in credits) {
    lines.add('Credit: ${_creditText(credit)}');
  }
  final tracks = _maps(value['tracks']);
  lines.add(
      'Tracks: ${tracks.where((track) => track['is_header'] != true).length}');
  final headers = tracks.where((track) => track['is_header'] == true).length;
  if (headers > 0) lines.add('Sections: $headers');
  return lines.join('\n');
}

Map<String, dynamic> _musicItem(Map<String, dynamic> value) {
  final nested = value['music'];
  return nested is Map ? Map<String, dynamic>.from(nested) : value;
}

List<Map<String, dynamic>> _discs(Map<String, dynamic> value) =>
    _maps(_musicItem(value)['discs']);

int _trackCount(Map<String, dynamic> group) {
  final discs = _discs(group);
  return discs.fold<int>(
    0,
    (total, disc) =>
        total +
        _maps(disc['tracks'])
            .where((track) => track['is_header'] != true)
            .length,
  );
}

Map<String, Map<String, dynamic>> _indexById(Object? values, String label) {
  final result = <String, Map<String, dynamic>>{};
  for (final value in _maps(values)) {
    final id = _text(value['id']);
    if (id == null) {
      throw FormatException('Music $label is missing its stable id.');
    }
    if (result.containsKey(id)) {
      throw FormatException('Duplicate Music $label id "$id".');
    }
    result[id] = value;
  }
  return result;
}

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const <Map<String, dynamic>>[];

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text
      ]
    : const <String>[];

String? _partialDateText(Object? value) {
  if (value is! Map) return _text(value);
  final year = _int(value['year']);
  final month = _int(value['month']);
  final day = _int(value['day']);
  if (year == null) return null;
  final yearText = year.toString().padLeft(4, '0');
  if (month == null) return yearText;
  final monthText = month.toString().padLeft(2, '0');
  if (day == null) return '$yearText-$monthText';
  return '$yearText-$monthText-${day.toString().padLeft(2, '0')}';
}

String? _text(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
