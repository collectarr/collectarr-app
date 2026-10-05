import 'dart:math' as math;

import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:flutter/material.dart';

/// Compares flat Music Catalog Item fields and contained disc data.
///
/// The editor and domain never consume these maps. They are decoded only for
/// the server-compare presentation, where a map is the actual wire format.
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
      title: 'Release contributions (Local vs Server)',
      entries: _contributionEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No contributions available.',
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
    _listEntry('Studio', localItem['studios'], serverItem['studios']),
    _dateEntry('Original release date', localItem['original_release_date'],
        serverItem['original_release_date']),
    _dateEntry('Recording date', localItem['recording_date'],
        serverItem['recording_date']),
    _entry('Subtitle', localItem['subtitle'], serverItem['subtitle']),
    _dateEntry(
        'Release Date', localItem['release_date'], serverItem['release_date']),
    _entry('Record label', localItem['label'] ?? localItem['publisher'],
        serverItem['label']),
    _entry('Format', localItem['format'], serverItem['format']),
    _entry(
      'Country',
      musicCountryName(
        (localItem['country'] ?? localItem['country_code'])?.toString(),
      ),
      musicCountryName(serverItem['country']?.toString()),
    ),
    _entry('Barcode', localItem['barcode'], serverItem['barcode']),
    _entry('Catalog number', localItem['catalog_number'],
        serverItem['catalog_number']),
    _entry('Packaging', localItem['packaging'], serverItem['packaging']),
    _listEntry('Genres', localItem['genres'], serverItem['genres']),
    _entry('Live recording', localItem['is_live'] == true ? 'Yes' : 'No',
        serverItem['is_live'] == true ? 'Yes' : 'No'),
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
      localValue: formatDiffDate(_date(local)),
      serverValue: formatDiffDate(_date(server)),
    );

MetadataDiffEntry _listEntry(String label, Object? local, Object? server) =>
    MetadataDiffEntry(
      label: label,
      localValue: formatDiffList(_strings(local)),
      serverValue: formatDiffList(_strings(server)),
    );

List<MetadataDiffEntry> _contributionEntries(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final localValues = _maps(_musicItem(local)['contributions']);
  final serverValues = _maps(_musicItem(server)['contributions']);
  final count = math.max(localValues.length, serverValues.length);
  return [
    for (var index = 0; index < count; index++)
      MetadataDiffEntry(
        label: 'Contribution #${index + 1}',
        localValue: _contributionText(
          index < localValues.length ? localValues[index] : null,
        ),
        serverValue: _contributionText(
          index < serverValues.length ? serverValues[index] : null,
        ),
      ),
  ];
}

String _contributionText(Map<String, dynamic>? value) {
  if (value == null) return '—';
  final name = _text(value['name']);
  final role = _text(value['role']);
  if (name == null) return formatDiffText(role);
  return role == null ? name : '$role - $name';
}

List<MetadataDiffEntry> _discEntries(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final localValues = _discs(local);
  final serverValues = _discs(server);
  final localByNumber = <int, Map<String, dynamic>>{
    for (final disc in localValues) _int(disc['disc_number']) ?? 0: disc,
  };
  final serverByNumber = <int, Map<String, dynamic>>{
    for (final disc in serverValues) _int(disc['disc_number']) ?? 0: disc,
  };
  final numbers = <int>{...localByNumber.keys, ...serverByNumber.keys}.toList()
    ..sort();
  return [
    for (final number in numbers)
      MetadataDiffEntry(
        label: 'Disc #$number',
        localValue: _discText(localByNumber[number]),
        serverValue: _discText(serverByNumber[number]),
      ),
  ];
}

String _discText(Map<String, dynamic>? value) {
  if (value == null) return '—';
  final lines = <String>[];
  final title = _text(value['title']);
  final tracks = _maps(value['tracks']);
  if (title != null) lines.add('Title: $title');
  lines.add('Tracks: ${tracks.length}');
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
    (total, disc) => total + _maps(disc['tracks']).length,
  );
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

String? _text(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');
