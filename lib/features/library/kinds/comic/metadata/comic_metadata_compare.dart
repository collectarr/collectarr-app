import 'dart:math' as math;

import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
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
      title: 'Details',
      entries: _comicMetadataEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No metadata fields available.',
    ),
    MetadataDiffPanel(
      title: 'Creators',
      entries: _creatorsEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No creators available.',
    ),
    MetadataDiffPanel(
      title: 'Characters',
      entries: _charactersEntries(localPayload, serverPayload),
      showOnlyDifferences: false,
      emptyText: 'No characters available.',
    ),
  ];
}

/// Core-owned issue fields under the editor's labels, Main then Details.
List<MetadataDiffEntry> _comicMetadataEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final local = ComicCatalogItem.fromJson(localP);
  final server = ComicCatalogItem.fromJson(serverP);
  final formats = AppFormats.current;
  String date(PartialDate? parts, DateTime? value) {
    final shown =
        parts ?? (value == null ? null : PartialDate.fromDateTime(value));
    return shown == null ? '' : formats.formatPartialDate(shown);
  }

  MetadataDiffEntry entry(
          String label, String? Function(ComicCatalogItem item) read) =>
      MetadataDiffEntry(
        label: label,
        localValue: read(local)?.trim() ?? '',
        serverValue: read(server)?.trim() ?? '',
      );

  return [
    entry('Series', (item) => item.seriesTitle),
    entry('Issue No.', (item) => item.issueNumber),
    entry('Variant', (item) => item.variant),
    entry('Variant Description', (item) => item.variantDescription),
    entry('Barcode', (item) => item.barcode),
    entry('Format', (item) => item.physicalFormat),
    entry('Series Group', (item) => item.seriesGroup),
    entry('Publisher', (item) => item.publisher),
    entry('Imprint', (item) => item.imprint),
    entry('Cover Date', (item) => date(item.coverDateParts, item.coverDate)),
    entry('Release Date',
        (item) => date(item.releaseDateParts, item.releaseDate)),
    entry(
        'Cover Price',
        (item) => item.coverPriceCents == null
            ? null
            : formats.formatMoney(item.coverPriceCents, item.currency)),
    entry('Crossover', (item) => item.crossover),
    entry('Story Arc',
        (item) => item.storyArcs.map((arc) => arc.name).nonNulls.join(', ')),
    entry('Title', (item) => item.title),
    entry('Subtitle', (item) => item.subtitle),
    entry('Country', (item) => item.country),
    entry('Language', (item) => item.language),
    entry('Age', (item) => item.publicationAge),
    entry('No. of Pages', (item) => item.pageCount?.toString()),
    entry('Genre', (item) => item.genres.join(', ')),
    entry('Plot', (item) => item.plotDescription ?? item.plotSummary),
  ];
}

List<MetadataDiffEntry> _creatorsEntries(
  Map<String, dynamic> localP,
  Map<String, dynamic> serverP,
) {
  final localCreators = [
    for (final creator in comicCreatorsFromJson(localP)) creator.toJson(),
  ];
  final serverCreators = [
    for (final creator in comicCreatorsFromJson(serverP)) creator.toJson(),
  ];
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
  final localCharacters = [
    for (final character in comicCharactersFromJson(localP)) character.toJson(),
  ];
  final serverCharacters = [
    for (final character in comicCharactersFromJson(serverP))
      character.toJson(),
  ];
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
