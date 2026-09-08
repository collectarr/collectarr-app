import 'dart:math' as math;

import 'package:collectarr_app/features/library/metadata/metadata_diff_panel.dart';
import 'package:flutter/material.dart';

List<Widget> buildMusicMetadataComparePanels(
  BuildContext context, {
  required Map<String, dynamic> localPayload,
  required Map<String, dynamic> serverPayload,
  required Color accent,
}) {
  return [
    MetadataDiffPanel(
      title: 'Metadata fields (Local vs Server)',
      entries: _musicMetadataEntries(localPayload, serverPayload),
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
      title: 'Discs (Local vs Server)',
      entries: _discEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No discs available.',
    ),
  ];
}

List<MetadataDiffEntry> _musicMetadataEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final localSeries = (localP['series'] as Map?) ?? localP;
  final serverSeries = (serverP['series'] as Map?) ?? serverP;
  final localPub = (localP['publishing'] as Map?) ?? localP;
  final serverPub = (serverP['publishing'] as Map?) ?? serverP;
  final localMusic = (localP['music'] as Map?) ?? localP;
  final serverMusic = (serverP['music'] as Map?) ?? serverP;

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
      label: 'Artist',
      localValue: formatDiffText(
          (localSeries['series_title'] ?? localSeries['seriesTitle'])
              ?.toString()),
      serverValue: formatDiffText(
          (serverSeries['series_title'] ?? serverSeries['seriesTitle'])
              ?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Subtitle',
      localValue: formatDiffText(localPub['subtitle']?.toString()),
      serverValue: formatDiffText(serverPub['subtitle']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Catalog number',
      localValue: formatDiffText(localMusic['catalog_number']?.toString()),
      serverValue: formatDiffText(serverMusic['catalog_number']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Release status',
      localValue: formatDiffText(localMusic['release_status']?.toString()),
      serverValue: formatDiffText(serverMusic['release_status']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Original release date',
      localValue: formatDiffDate(_parseDate(localMusic['original_release_date'])),
      serverValue:
          formatDiffDate(_parseDate(serverMusic['original_release_date'])),
    ),
    MetadataDiffEntry(
      label: 'Recording date',
      localValue: formatDiffDate(_parseDate(localMusic['recording_date'])),
      serverValue: formatDiffDate(_parseDate(serverMusic['recording_date'])),
    ),
    MetadataDiffEntry(
      label: 'RPM',
      localValue: formatDiffText(localMusic['rpm']?.toString()),
      serverValue: formatDiffText(serverMusic['rpm']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'SPARS',
      localValue: formatDiffText(localMusic['spars']?.toString()),
      serverValue: formatDiffText(serverMusic['spars']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Sound',
      localValue: formatDiffText(localMusic['sound_type']?.toString()),
      serverValue: formatDiffText(serverMusic['sound_type']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Vinyl color',
      localValue: formatDiffText(localMusic['vinyl_color']?.toString()),
      serverValue: formatDiffText(serverMusic['vinyl_color']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Vinyl weight',
      localValue: formatDiffText(localMusic['vinyl_weight']?.toString()),
      serverValue: formatDiffText(serverMusic['vinyl_weight']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Media condition',
      localValue: formatDiffText(localMusic['media_condition']?.toString()),
      serverValue: formatDiffText(serverMusic['media_condition']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Composition',
      localValue: formatDiffText(localMusic['composition']?.toString()),
      serverValue: formatDiffText(serverMusic['composition']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Instrument',
      localValue: formatDiffText(localMusic['instrument']?.toString()),
      serverValue: formatDiffText(serverMusic['instrument']?.toString()),
    ),
    MetadataDiffEntry(
      label: 'Live recording',
      localValue: (localMusic['is_live'] == true) ? 'Yes' : 'No',
      serverValue: (serverMusic['is_live'] == true) ? 'Yes' : 'No',
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

List<MetadataDiffEntry> _discEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final localMusic = (localP['music'] as Map?) ?? localP;
  final serverMusic = (serverP['music'] as Map?) ?? serverP;
  final localRawDiscs = (localMusic['discs'] as List?) ?? const [];
  final serverRawDiscs = (serverMusic['discs'] as List?) ?? const [];

  final localDiscs = <int, Map<String, dynamic>>{};
  for (final raw in localRawDiscs) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final num = (map['disc_number'] ?? map['discNumber']) as int? ?? 0;
      localDiscs[num] = map;
    }
  }

  final serverDiscs = <int, Map<String, dynamic>>{};
  for (final raw in serverRawDiscs) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final num = (map['disc_number'] ?? map['discNumber']) as int? ?? 0;
      serverDiscs[num] = map;
    }
  }

  final all = <int>{
    ...localDiscs.keys,
    ...serverDiscs.keys,
  }.toList()..sort();

  return [
    for (final discNumber in all)
      MetadataDiffEntry(
        label: 'Disc #$discNumber',
        localValue: _discText(localDiscs[discNumber]),
        serverValue: _discText(serverDiscs[discNumber]),
      ),
  ];
}

String _discText(Map<String, dynamic>? value) {
  if (value == null) {
    return '—';
  }
  final discNumber = value['disc_number'] ?? value['discNumber'];
  final discName =
      (value['disc_name'] ?? value['discName'] ?? '')?.toString().trim();
  final storageDevice =
      (value['storage_device'] ?? value['storageDevice'] ?? '')
          ?.toString()
          .trim();
  final slot = (value['slot'] ?? '')?.toString().trim();
  final matrixSideA =
      (value['matrix_side_a'] ?? value['matrixSideA'] ?? '')?.toString().trim();
  final matrixSideB =
      (value['matrix_side_b'] ?? value['matrixSideB'] ?? '')?.toString().trim();

  final lines = <String>[
    if (discName != null && discName.isNotEmpty) 'Title: $discName',
    if (storageDevice != null && storageDevice.isNotEmpty)
      'Storage: $storageDevice',
    if (slot != null && slot.isNotEmpty) 'Slot: $slot',
    if (matrixSideA != null && matrixSideA.isNotEmpty) 'Matrix A: $matrixSideA',
    if (matrixSideB != null && matrixSideB.isNotEmpty) 'Matrix B: $matrixSideB',
  ];
  return lines.isEmpty ? 'Disc #$discNumber' : lines.join('\n');
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}