import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:flutter_test/flutter_test.dart';

/// Maps a core registry `value_type` to the app's [SharedMetadataFieldValueType].
SharedMetadataFieldValueType _appValueType(String coreValueType) {
  return switch (coreValueType) {
    'string_list' => SharedMetadataFieldValueType.stringList,
    'integer' => SharedMetadataFieldValueType.integer,
    'number' => SharedMetadataFieldValueType.number,
    'boolean' => SharedMetadataFieldValueType.boolean,
    'partial_date' => SharedMetadataFieldValueType.partialDate,
    // Shared metadata kinds render as text or list controls in the app.
    _ => SharedMetadataFieldValueType.text,
  };
}

/// Core editable fields that the app renders with dedicated widgets instead of
/// a scalar descriptor in [kAdminMetadataScalarFields].
const Set<String> _appHandledSpecially = {
  'physical_format', // release physical-format dropdown
  'tracks', // structured tracks/discs editor
};

void main() {
  late MetadataFieldSchema schema;

  setUpAll(() {
    final raw = File(
      'tool/core_contracts/metadata-field-schema.json',
    ).readAsStringSync();
    schema = MetadataFieldSchema.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('core field schema fixture parses into the app model', () {
    expect(schema.schemaVersion, 2);
    expect(schema.fields, isNotEmpty);
    expect(schema.sections, contains('item'));
    expect(schema.sections, isNot(contains('internal')));
  });

  test('every app scalar field is backed by a core registry field', () {
    final coreKeys = schema.fields.map((f) => f.key).toSet();
    final appKeys = kAdminMetadataScalarFields.map((f) => f.key).toSet()
      ..remove('series_tags'); // app-only relation list, not a catalog column
    final orphanAppKeys = appKeys.difference(coreKeys);
    expect(
      orphanAppKeys,
      isEmpty,
      reason: 'App edit fields must exist in the core registry '
          '(single source of truth). Orphans: $orphanAppKeys',
    );
  });

  test('every editable core field is rendered or explicitly handled', () {
    final appKeys = kAdminMetadataScalarFields.map((f) => f.key).toSet();
    for (final field in schema.fields.where((field) => field.editable)) {
      if (_appHandledSpecially.contains(field.key)) continue;
      expect(
        appKeys.contains(field.key),
        isTrue,
        reason: 'Core editable field "${field.key}" is missing from the app '
            'edit contract. Add it to kAdminMetadataScalarFields or '
            '_appHandledSpecially.',
      );
    }
  });

  test('core editable field keys match the app edit contract exactly', () {
    final coreKeys = schema.fields
        .where((field) => field.editable)
        .map((field) => field.key)
        .toSet()
      ..addAll(_appHandledSpecially);
    final appKeys = kLibraryEditableFieldKeys.toSet();
    expect(
      appKeys,
      equals(coreKeys),
      reason:
          'Diff: app-core=${appKeys.difference(coreKeys)}, core-app=${coreKeys.difference(appKeys)}',
    );
  });

  test('overlapping field value types agree with the core registry', () {
    final appByKey = {
      for (final field in kAdminMetadataScalarFields) field.key: field,
    };
    for (final field in schema.fields) {
      final appField = appByKey[field.key];
      if (appField == null) continue;
      expect(
        appField.valueType,
        _appValueType(field.valueType),
        reason: 'Value type drift for "${field.key}": app '
            '${appField.valueType} vs core ${field.valueType}',
      );
    }
  });

  test('generated edit fields preserve the exact per-tab display order', () {
    // Locks the rendered layout so the projection from core can never silently
    // reorder the admin/edit panel.
    const expectedOrder = <SharedMetadataEditTab, List<String>>{
      SharedMetadataEditTab.item: [
        'recommended_players',
        'best_players',
        'min_playtime_minutes',
        'max_playtime_minutes',
        'complexity_weight',
        'bgg_rating',
        'bgg_rating_count',
        'bgg_rank',
        'first_edition',
        'toy_subtype',
        'toy_type',
        'display_title',
        'artist',
        'sort_title',
        'original_release_date',
        'title',
        'original_title',
        'localized_title',
        'title_extension',
        'sort_key',
        'search_aliases',
        'item_number',
        'series_title',
        'edition_title',
        'release_date',
      ],
      SharedMetadataEditTab.publishing: [
        'runtime_minutes',
        'publishers',
        'imprint',
        'series_group',
        'page_count',
        'first_publication_date',
        'original_publication_date',
        'distributor',
        'edition_statement',
        'binding',
        'studio',
        'production_companies',
        'label',
        'packaging',
        'publisher',
        'subtitle',
        'barcode',
        'variant_name',
      ],
      SharedMetadataEditTab.technical: [
        'color',
        'nr_discs',
        'screen_ratio',
        'audio_tracks',
        'subtitles',
        'layers',
        'dimensions',
        'audio_length_minutes',
        'extra',
        'box_set',
        'catalog_number',
        'release_status',
      ],
      SharedMetadataEditTab.regional: [
        'languages',
        'original_language',
        'region',
        'country',
        'language',
        'age_rating',
        'audience_rating',
        'series_tags',
      ],
      SharedMetadataEditTab.artwork: [
        'back_cover_image_url',
        'crossover',
        'cover_image_url',
        'thumbnail_image_url',
        'synopsis',
        'plot_summary',
        'plot_description',
      ],
      SharedMetadataEditTab.relations: [
        'genres',
        'platforms',
        'identifiers',
        'contributors',
        'mechanics',
        'categories',
        'families',
        'expansions',
        'rankings',
        'designers',
        'artists',
        'themes',
        'characters',
        'expansion_for',
        'subjects',
        'company_roles',
        'franchise',
        'trailer_urls',
        'external_links',
      ],
    };
    for (final entry in expectedOrder.entries) {
      final actual = kAdminMetadataScalarFields
          .where((f) => f.tab == entry.key)
          .map((f) => f.key)
          .toList();
      expect(actual, entry.value, reason: 'Order drift in ${entry.key.label}');
    }
  });

  test('presentation overlay survives the projection', () {
    SharedMetadataFieldDescriptor byKey(String key) =>
        kAdminMetadataScalarFields.firstWhere((f) => f.key == key);
    expect(
      byKey('release_date').hintText,
      'YYYY, YYYY-MM, YYYY-MM-DD, or {"month": 5}',
    );
    expect(byKey('synopsis').inputType, SharedMetadataFieldInputType.multiline);
    expect(byKey('synopsis').minLines, 3);
    expect(byKey('synopsis').maxLines, 5);
    expect(byKey('external_links').maxLines, 6);
    expect(byKey('title').minLines, 1);
  });
}
