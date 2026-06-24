import 'package:flutter/material.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';

enum SharedMetadataEditTab {
  item('Item'),
  publishing('Publishing'),
  technical('Technical'),
  regional('Regional'),
  artwork('Artwork & copy'),
  relations('Relations & lists');

  const SharedMetadataEditTab(this.label);

  final String label;
}

enum SharedMetadataFieldInputType { text, number, multiline }

enum SharedMetadataFieldValueType {
  text,
  integer,
  date,
  stringList,
}

@immutable
class SharedMetadataFieldDescriptor {
  const SharedMetadataFieldDescriptor({
    required this.key,
    required this.label,
    required this.tab,
    this.inputType = SharedMetadataFieldInputType.text,
    this.valueType = SharedMetadataFieldValueType.text,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.compactWidth,
    this.normalizedValueType,
  });

  final String key;
  final String label;
  final SharedMetadataEditTab tab;
  final SharedMetadataFieldInputType inputType;
  final SharedMetadataFieldValueType valueType;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final double? compactWidth;
  final String? normalizedValueType;
}

const List<SharedMetadataFieldDescriptor> kAdminMetadataScalarFields = [
  SharedMetadataFieldDescriptor(
    key: 'title',
    label: 'Title',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'original_title',
    label: 'Original title',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'localized_title',
    label: 'Localized title',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'title_extension',
    label: 'Title extension',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'sort_key',
    label: 'Sort key',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'search_aliases',
    label: 'Search aliases',
    tab: SharedMetadataEditTab.item,
    valueType: SharedMetadataFieldValueType.stringList,
  ),
  SharedMetadataFieldDescriptor(
    key: 'item_number',
    label: 'Item number',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'edition_title',
    label: 'Edition title',
    tab: SharedMetadataEditTab.item,
  ),
  SharedMetadataFieldDescriptor(
    key: 'release_date',
    label: 'Release date',
    tab: SharedMetadataEditTab.item,
    valueType: SharedMetadataFieldValueType.date,
    hintText: 'YYYY-MM-DD',
  ),
  SharedMetadataFieldDescriptor(
    key: 'publisher',
    label: 'Publisher',
    tab: SharedMetadataEditTab.publishing,
  ),
  SharedMetadataFieldDescriptor(
    key: 'imprint',
    label: 'Imprint',
    tab: SharedMetadataEditTab.publishing,
  ),
  SharedMetadataFieldDescriptor(
    key: 'subtitle',
    label: 'Subtitle',
    tab: SharedMetadataEditTab.publishing,
  ),
  SharedMetadataFieldDescriptor(
    key: 'series_group',
    label: 'Series group',
    tab: SharedMetadataEditTab.publishing,
  ),
  SharedMetadataFieldDescriptor(
    key: 'barcode',
    label: 'Barcode',
    tab: SharedMetadataEditTab.publishing,
  ),
  SharedMetadataFieldDescriptor(
    key: 'variant_name',
    label: 'Primary variant',
    tab: SharedMetadataEditTab.publishing,
  ),
  SharedMetadataFieldDescriptor(
    key: 'page_count',
    label: 'Page count',
    tab: SharedMetadataEditTab.publishing,
    inputType: SharedMetadataFieldInputType.number,
    valueType: SharedMetadataFieldValueType.integer,
  ),
  SharedMetadataFieldDescriptor(
    key: 'runtime_minutes',
    label: 'Runtime minutes',
    tab: SharedMetadataEditTab.publishing,
    inputType: SharedMetadataFieldInputType.number,
    valueType: SharedMetadataFieldValueType.integer,
  ),
  SharedMetadataFieldDescriptor(
    key: 'color',
    label: 'Color',
    tab: SharedMetadataEditTab.technical,
    normalizedValueType: 'string',
  ),
  SharedMetadataFieldDescriptor(
    key: 'nr_discs',
    label: 'Number of discs',
    tab: SharedMetadataEditTab.technical,
    inputType: SharedMetadataFieldInputType.number,
    valueType: SharedMetadataFieldValueType.integer,
    normalizedValueType: 'integer',
  ),
  SharedMetadataFieldDescriptor(
    key: 'screen_ratio',
    label: 'Screen ratio',
    tab: SharedMetadataEditTab.technical,
    normalizedValueType: 'string',
  ),
  SharedMetadataFieldDescriptor(
    key: 'audio_tracks',
    label: 'Audio tracks',
    tab: SharedMetadataEditTab.technical,
    normalizedValueType: 'string',
  ),
  SharedMetadataFieldDescriptor(
    key: 'subtitles',
    label: 'Subtitles',
    tab: SharedMetadataEditTab.technical,
    normalizedValueType: 'string',
  ),
  SharedMetadataFieldDescriptor(
    key: 'layers',
    label: 'Layers',
    tab: SharedMetadataEditTab.technical,
    normalizedValueType: 'string',
  ),
  SharedMetadataFieldDescriptor(
    key: 'catalog_number',
    label: 'Catalog number',
    tab: SharedMetadataEditTab.technical,
  ),
  SharedMetadataFieldDescriptor(
    key: 'release_status',
    label: 'Release status',
    tab: SharedMetadataEditTab.technical,
  ),
  SharedMetadataFieldDescriptor(
    key: 'country',
    label: 'Country',
    tab: SharedMetadataEditTab.regional,
  ),
  SharedMetadataFieldDescriptor(
    key: 'language',
    label: 'Language',
    tab: SharedMetadataEditTab.regional,
  ),
  SharedMetadataFieldDescriptor(
    key: 'age_rating',
    label: 'Age rating',
    tab: SharedMetadataEditTab.regional,
  ),
  SharedMetadataFieldDescriptor(
    key: 'audience_rating',
    label: 'Audience rating',
    tab: SharedMetadataEditTab.regional,
    normalizedValueType: 'string',
  ),
  SharedMetadataFieldDescriptor(
    key: 'series_tags',
    label: 'Series tags',
    tab: SharedMetadataEditTab.regional,
    valueType: SharedMetadataFieldValueType.stringList,
  ),
  SharedMetadataFieldDescriptor(
    key: 'cover_image_url',
    label: 'Cover URL',
    tab: SharedMetadataEditTab.artwork,
  ),
  SharedMetadataFieldDescriptor(
    key: 'thumbnail_image_url',
    label: 'Thumbnail URL',
    tab: SharedMetadataEditTab.artwork,
  ),
  SharedMetadataFieldDescriptor(
    key: 'synopsis',
    label: 'Synopsis',
    tab: SharedMetadataEditTab.artwork,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 3,
    maxLines: 5,
  ),
  SharedMetadataFieldDescriptor(
    key: 'crossover',
    label: 'Crossover',
    tab: SharedMetadataEditTab.artwork,
  ),
  SharedMetadataFieldDescriptor(
    key: 'plot_summary',
    label: 'Plot summary',
    tab: SharedMetadataEditTab.artwork,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 2,
    maxLines: 4,
  ),
  SharedMetadataFieldDescriptor(
    key: 'plot_description',
    label: 'Plot description',
    tab: SharedMetadataEditTab.artwork,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 3,
    maxLines: 5,
  ),
  SharedMetadataFieldDescriptor(
    key: 'genres',
    label: 'Genres',
    tab: SharedMetadataEditTab.relations,
    valueType: SharedMetadataFieldValueType.stringList,
    normalizedValueType: 'string_list',
  ),
  SharedMetadataFieldDescriptor(
    key: 'platforms',
    label: 'Platforms',
    tab: SharedMetadataEditTab.relations,
    valueType: SharedMetadataFieldValueType.stringList,
    normalizedValueType: 'string_list',
  ),
  SharedMetadataFieldDescriptor(
    key: 'trailer_urls',
    label: 'Trailer URLs',
    tab: SharedMetadataEditTab.relations,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 2,
    maxLines: 6,
  ),
  SharedMetadataFieldDescriptor(
    key: 'external_links',
    label: 'External links',
    tab: SharedMetadataEditTab.relations,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 2,
    maxLines: 6,
  ),
];

const List<SharedMetadataFieldDescriptor> kProposalCorrectionFields = [
  SharedMetadataFieldDescriptor(
    key: 'title',
    label: 'Series / title',
    tab: SharedMetadataEditTab.item,
    compactWidth: 340,
  ),
  SharedMetadataFieldDescriptor(
    key: 'item_number',
    label: 'Issue #',
    tab: SharedMetadataEditTab.item,
    compactWidth: 120,
  ),
  SharedMetadataFieldDescriptor(
    key: 'publisher',
    label: 'Publisher',
    tab: SharedMetadataEditTab.publishing,
    compactWidth: 220,
  ),
  SharedMetadataFieldDescriptor(
    key: 'release_year',
    label: 'Year',
    tab: SharedMetadataEditTab.publishing,
    inputType: SharedMetadataFieldInputType.number,
    compactWidth: 100,
  ),
  SharedMetadataFieldDescriptor(
    key: 'barcode',
    label: 'Barcode / UPC',
    tab: SharedMetadataEditTab.publishing,
    inputType: SharedMetadataFieldInputType.number,
    compactWidth: 220,
  ),
  SharedMetadataFieldDescriptor(
    key: 'variant',
    label: 'Variant',
    tab: SharedMetadataEditTab.publishing,
    compactWidth: 220,
  ),
  SharedMetadataFieldDescriptor(
    key: 'source_url',
    label: 'Source URL',
    tab: SharedMetadataEditTab.relations,
    compactWidth: 540,
  ),
  SharedMetadataFieldDescriptor(
    key: 'notes',
    label: 'What should change?',
    tab: SharedMetadataEditTab.relations,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 5,
    maxLines: 5,
    compactWidth: 540,
  ),
];

TextInputType? sharedFieldKeyboardType(SharedMetadataFieldDescriptor field) {
  return switch (field.inputType) {
    SharedMetadataFieldInputType.number => TextInputType.number,
    _ => null,
  };
}

@immutable
class SharedMetadataContractDrift {
  const SharedMetadataContractDrift({
    required this.missingInCore,
    required this.extraInCore,
    required this.typeMismatches,
  });

  final Set<String> missingInCore;
  final Set<String> extraInCore;
  final Set<String> typeMismatches;

  bool get isInSync =>
      missingInCore.isEmpty && extraInCore.isEmpty && typeMismatches.isEmpty;

  int get mismatchCount =>
      missingInCore.length + extraInCore.length + typeMismatches.length;
}

const Set<String> kSharedMetadataManifestCoreOnlyKeys = {
  'track_count',
  'tracks',
};

SharedMetadataContractDrift compareSharedContractWithManifest(
  MetadataNormalizedManifest manifest,
) {
  final expectedTypes = <String, String>{
    for (final field in kAdminMetadataScalarFields)
      if (field.normalizedValueType != null)
        field.key: field.normalizedValueType!,
  };
  final expectedKeys = expectedTypes.keys.toSet();
  final manifestKeys = <String>{
    ...manifest.commonFields,
    ...manifest.kindFields.values.expand((fields) => fields),
  };
  final missingInCore = expectedKeys.difference(manifestKeys);
  final extraInCore = manifest.valueTypes.keys
      .toSet()
      .difference(expectedKeys)
      .difference(kSharedMetadataManifestCoreOnlyKeys);
  final typeMismatches = <String>{};
  for (final entry in expectedTypes.entries) {
    final actual = manifest.valueTypes[entry.key];
    if (actual != null && actual != entry.value) {
      typeMismatches.add(entry.key);
    }
  }
  return SharedMetadataContractDrift(
    missingInCore: missingInCore,
    extraInCore: extraInCore,
    typeMismatches: typeMismatches,
  );
}
