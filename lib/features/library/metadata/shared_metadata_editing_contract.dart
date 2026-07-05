import 'package:flutter/material.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/metadata_fields.g.dart';

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

SharedMetadataEditTab _tabFromSection(String section) {
  return switch (section) {
    'publishing' => SharedMetadataEditTab.publishing,
    'technical' => SharedMetadataEditTab.technical,
    'regional' => SharedMetadataEditTab.regional,
    'artwork' => SharedMetadataEditTab.artwork,
    'relations' => SharedMetadataEditTab.relations,
    _ => SharedMetadataEditTab.item,
  };
}

SharedMetadataFieldValueType _valueTypeFromName(String name) {
  return switch (name) {
    'integer' => SharedMetadataFieldValueType.integer,
    'date' => SharedMetadataFieldValueType.date,
    'stringList' => SharedMetadataFieldValueType.stringList,
    _ => SharedMetadataFieldValueType.text,
  };
}

SharedMetadataFieldInputType _inputTypeFromName(String name) {
  return switch (name) {
    'number' => SharedMetadataFieldInputType.number,
    'multiline' => SharedMetadataFieldInputType.multiline,
    _ => SharedMetadataFieldInputType.text,
  };
}

/// App-owned presentation nuances overlaid on the generated field set. Keyed by
/// field key; fields not listed render as single-line inputs with no hint.
const Map<String, ({String? hint, int minLines, int maxLines})>
    _kFieldPresentation = {
  'release_date': (hint: 'YYYY-MM-DD', minLines: 1, maxLines: 1),
  'synopsis': (hint: null, minLines: 3, maxLines: 5),
  'plot_summary': (hint: null, minLines: 2, maxLines: 4),
  'plot_description': (hint: null, minLines: 3, maxLines: 5),
  'trailer_urls': (hint: null, minLines: 2, maxLines: 6),
  'external_links': (hint: null, minLines: 2, maxLines: 6),
};

/// The admin/edit scalar fields, projected from the core registry
/// ([kGeneratedMetadataFields]) plus the app-owned presentation overlay above.
/// This is the single source of truth shared by the app edit dialog and the
/// admin metadata correction panel; re-run
/// `python -m scripts.export_app_edit_fields` in collectarr-core to refresh.
final List<SharedMetadataFieldDescriptor> kAdminMetadataScalarFields = [
  for (final field in kGeneratedMetadataFields)
    SharedMetadataFieldDescriptor(
      key: field.key,
      label: field.label,
      tab: _tabFromSection(field.section),
      inputType: _inputTypeFromName(field.inputType),
      valueType: _valueTypeFromName(field.valueType),
      normalizedValueType: field.normalizedValueType,
      hintText: _kFieldPresentation[field.key]?.hint,
      minLines: _kFieldPresentation[field.key]?.minLines ?? 1,
      maxLines: _kFieldPresentation[field.key]?.maxLines ?? 1,
    ),
];

/// Complete app edit contract: scalar fields plus app-rendered special cases.
///
/// This is the key set the Flutter edit dialog is expected to support.
final List<String> kLibraryEditableFieldKeys = [
  // Scalar fields.
  ..._kAdminMetadataScalarFieldKeys,
  // App-rendered special cases that still need to match the core schema.
  'physical_format',
  'track_count',
  'tracks',
];

final List<String> _kAdminMetadataScalarFieldKeys =
    [for (final field in kAdminMetadataScalarFields) field.key];

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

SharedMetadataFieldDescriptor? sharedMetadataFieldByKey(String key) {
  for (final field in kAdminMetadataScalarFields) {
    if (field.key == key) {
      return field;
    }
  }
  return null;
}

List<SharedMetadataFieldDescriptor> sharedMetadataFieldsForTab(
  SharedMetadataEditTab tab, {
  Iterable<SharedMetadataFieldDescriptor>? fields,
}) {
  final source = fields ?? kAdminMetadataScalarFields;
  return [
    for (final field in source)
      if (field.tab == tab) field,
  ];
}

Map<SharedMetadataEditTab, List<SharedMetadataFieldDescriptor>>
    groupSharedMetadataFieldsByTab({
  Iterable<SharedMetadataFieldDescriptor>? fields,
}) {
  final source = fields ?? kAdminMetadataScalarFields;
  return {
    for (final tab in SharedMetadataEditTab.values)
      tab: sharedMetadataFieldsForTab(tab, fields: source),
  };
}

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
