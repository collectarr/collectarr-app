import 'dart:math' as math;

import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:flutter/material.dart';

/// Compares the serialized Music release-group graph at the transport boundary.
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
      title: 'Mediums (Local vs Server)',
      entries: _mediumEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No mediums available.',
    ),
  ];
}

List<MetadataDiffEntry> _musicMetadataEntries(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final localRelease = _release(local);
  final serverRelease = _release(server);
  return [
    _entry('Title', local['title'], server['title']),
    _entry('Sort title', local['sort_title'], server['sort_title']),
    _entry('Original title', local['original_title'], server['original_title']),
    _entry('Artist', local['artist'], server['artist']),
    _entry('Studio', local['studio'], server['studio']),
    _dateEntry('Original release date', local['original_release_date'],
        server['original_release_date']),
    _dateEntry(
        'Recording date', local['recording_date'], server['recording_date']),
    _entry('Release title', localRelease['title'], serverRelease['title']),
    _entry('Subtitle', localRelease['subtitle'], serverRelease['subtitle']),
    _entry('Release type', localRelease['release_type'],
        serverRelease['release_type']),
    _entry('Release status', localRelease['release_status'],
        serverRelease['release_status']),
    _dateEntry('Release date', localRelease['release_date'],
        serverRelease['release_date']),
    _entry(
        'Record label', localRelease['publisher'], serverRelease['publisher']),
    _entry(
        'Country',
        musicCountryName(localRelease['country_code']?.toString()),
        musicCountryName(serverRelease['country_code']?.toString())),
    _entry('Language', localRelease['language'], serverRelease['language']),
    _entry('Barcode', localRelease['barcode'], serverRelease['barcode']),
    _entry('UPC', localRelease['upc'], serverRelease['upc']),
    _entry('Catalog number', localRelease['catalog_number'],
        serverRelease['catalog_number']),
    _entry('Packaging', localRelease['packaging'], serverRelease['packaging']),
    _listEntry('Genres', local['genres'], server['genres']),
    _entry('Live recording', local['is_live'] == true ? 'Yes' : 'No',
        server['is_live'] == true ? 'Yes' : 'No'),
    _entry('Release count', _maps(local['releases']).length,
        _maps(server['releases']).length),
    _entry('Medium count', _mediums(local).length, _mediums(server).length),
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
  final localValues = _maps(_release(local)['contributions']);
  final serverValues = _maps(_release(server)['contributions']);
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

List<MetadataDiffEntry> _mediumEntries(
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final localValues = _mediums(local);
  final serverValues = _mediums(server);
  final localByNumber = <int, Map<String, dynamic>>{
    for (final medium in localValues)
      _int(medium['medium_number']) ?? 0: medium,
  };
  final serverByNumber = <int, Map<String, dynamic>>{
    for (final medium in serverValues)
      _int(medium['medium_number']) ?? 0: medium,
  };
  final numbers = <int>{...localByNumber.keys, ...serverByNumber.keys}.toList()
    ..sort();
  return [
    for (final number in numbers)
      MetadataDiffEntry(
        label: 'Medium #$number',
        localValue: _mediumText(localByNumber[number]),
        serverValue: _mediumText(serverByNumber[number]),
      ),
  ];
}

String _mediumText(Map<String, dynamic>? value) {
  if (value == null) return '—';
  final lines = <String>[];
  final title = _text(value['title']);
  final type = _text(value['medium_type']);
  final tracks = _maps(value['tracks']);
  if (title != null) lines.add('Title: $title');
  if (type != null) lines.add('Type: $type');
  lines.add('Tracks: ${_int(value['track_count']) ?? tracks.length}');
  return lines.join('\n');
}

Map<String, dynamic> _release(Map<String, dynamic> group) {
  final releases = _maps(group['releases']);
  return releases.isEmpty ? group : releases.first;
}

List<Map<String, dynamic>> _mediums(Map<String, dynamic> group) =>
    _maps(_release(group)['mediums']);

int _trackCount(Map<String, dynamic> group) {
  final mediums = _mediums(group);
  return mediums.fold<int>(
    0,
    (total, medium) =>
        total + (_int(medium['track_count']) ?? _maps(medium['tracks']).length),
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
