import 'dart:math' as math;

import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:flutter/material.dart';

List<Widget> buildComicMetadataComparePanels(
  BuildContext context, {
  required Map<String, dynamic> localPayload,
  required Map<String, dynamic> serverPayload,
  required Color accent,
}) {
  return [
    MetadataDiffPanel(
      title: 'Metadata fields (Local vs Server)',
      entries: _comicMetadataEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No metadata fields available.',
    ),
    MetadataDiffPanel(
      title: 'Creators (Local vs Server)',
      entries: _creatorsEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No creators available.',
    ),
    MetadataDiffPanel(
      title: 'Characters (Local vs Server)',
      entries: _charactersEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No characters available.',
    ),
  ];
}

List<MetadataDiffEntry> _comicMetadataEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final localSeries = (localP['series'] as Map?) ?? localP;
  final serverSeries = (serverP['series'] as Map?) ?? serverP;
  final localPub = (localP['publishing'] as Map?) ?? localP;
  final serverPub = (serverP['publishing'] as Map?) ?? serverP;

  return [
    MetadataDiffEntry(
      label: 'Title',
      localValue: formatDiffText(localP['title']?.toString()),
      serverValue: formatDiffText(serverP['title']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Sort key',
      localValue: formatDiffText(localP['sort_key']?.toString()),
      serverValue: formatDiffText(serverP['sort_key']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Publisher',
      localValue: formatDiffText(localP['publisher']?.toString()),
      serverValue: formatDiffText(serverP['publisher']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Release date',
      localValue: formatDiffDate(_parseDate(localP['release_date'])),
      serverValue: formatDiffDate(_parseDate(serverP['release_date'])),
    ),
    MetadataDiffEntry(
      label: 'Variant',
      localValue: formatDiffText(localP['variant']?.toString()),
      serverValue: formatDiffText(serverP['variant']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Edition title',
      localValue: formatDiffText(localP['edition_title']?.toString()),
      serverValue: formatDiffText(serverP['edition_title']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Barcode',
      localValue: formatDiffText(localP['barcode']?.toString()),
      serverValue: formatDiffText(serverP['barcode']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Country',
      localValue: formatDiffText(localP['country']?.toString()),
      serverValue: formatDiffText(serverP['country']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Language',
      localValue: formatDiffText(localP['language']?.toString()),
      serverValue: formatDiffText(serverP['language']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Genres',
      localValue: formatDiffList(
          (localP['genres'] as List?)?.map((e) => e.toString())),
      serverValue: formatDiffList(
          (serverP['genres'] as List?)?.map((e) => e.toString())),
    ),
    MetadataDiffEntry(
      label: 'Story arcs',
      localValue: formatDiffList(
          (localP['story_arcs'] as List?)?.map((e) => e.toString())),
      serverValue: formatDiffList(
          (serverP['story_arcs'] as List?)?.map((e) => e.toString())),
    ),
    MetadataDiffEntry(
      label: 'Series',
      localValue: formatDiffText(
          (localSeries['series_title'] ?? localSeries['seriesTitle'])
              ?.toString()),
      serverValue: formatDiffText(
          (serverSeries['series_title'] ?? serverSeries['seriesTitle'])
              ?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Issue number',
      localValue: formatDiffText(
          (localP['item_number'] ?? localP['itemNumber'])?.toString()),
      serverValue: formatDiffText(
          (serverP['item_number'] ?? serverP['itemNumber'])?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Cover date',
      localValue: formatDiffDate(_parseDate(localP['cover_date'])),
      serverValue: formatDiffDate(_parseDate(serverP['cover_date'])),
    ),
    MetadataDiffEntry(
      label: 'Imprint',
      localValue: formatDiffText(localPub['imprint']?.toString()),
      serverValue: formatDiffText(serverPub['imprint']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Page count',
      localValue: formatDiffText(localPub['page_count']?.toString()),
      serverValue: formatDiffText(serverPub['page_count']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Plot summary',
      localValue: formatDiffText(localP['plot_summary']?.toString()),
      serverValue: formatDiffText(serverP['plot_summary']?.toString()),
    ),
  ];
}

List<MetadataDiffEntry> _creatorsEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final localCreators =
      (localP['creators'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
  final serverCreators =
      (serverP['creators'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
  final count = math.max(localCreators.length, serverCreators.length);
  return [
    for (var i = 0; i < count; i++)
      MetadataDiffEntry(
        label: 'Creator #${i + 1}',
        localValue:
            _creatorText(i < localCreators.length ? localCreators[i] : null),
        serverValue:
            _creatorText(i < serverCreators.length ? serverCreators[i] : null),
      ),
  ];
}

String _creatorText(Map<String, dynamic>? value) {
  if (value == null) {
    return '—';
  }
  final role = value['role']?.toString().trim();
  final name = value['name']?.toString().trim();
  if (name == null || name.isEmpty) {
    return formatDiffText(role);
  }
  if (role == null || role.isEmpty) {
    return name;
  }
  return '$role - $name';
}

List<MetadataDiffEntry> _charactersEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final localCharacters = _characterList(localP);
  final serverCharacters = _characterList(serverP);
  final count = math.max(localCharacters.length, serverCharacters.length);
  return [
    for (var i = 0; i < count; i++)
      MetadataDiffEntry(
        label: 'Character #${i + 1}',
        localValue: _characterText(
          i < localCharacters.length ? localCharacters[i] : null,
        ),
        serverValue: _characterText(
          i < serverCharacters.length ? serverCharacters[i] : null,
        ),
      ),
  ];
}

List<Map<String, dynamic>> _characterList(Map<String, dynamic> payload) {
  final details =
      (payload['character_details'] as List?)?.cast<Map<String, dynamic>>();
  if (details != null && details.isNotEmpty) {
    return details;
  }
  final chars =
      (payload['characters'] as List?)?.map((e) => e.toString()).toList();
  return [
    for (final name in chars ?? const <String>[])
      <String, dynamic>{
        'name': name,
      },
  ];
}

String _characterText(Map<String, dynamic>? value) {
  if (value == null) {
    return '—';
  }
  final name = value['name']?.toString().trim();
  final realName = value['real_name']?.toString().trim();
  if (name == null || name.isEmpty) {
    return formatDiffText(realName);
  }
  if (realName == null || realName.isEmpty) {
    return name;
  }
  return '$name ($realName)';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}