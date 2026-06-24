import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:flutter_test/flutter_test.dart';

/// Maps a core registry `value_type` to the app's [SharedMetadataFieldValueType].
SharedMetadataFieldValueType _appValueType(String coreValueType) {
  return switch (coreValueType) {
    'string_list' => SharedMetadataFieldValueType.stringList,
    'integer' => SharedMetadataFieldValueType.integer,
    'date' => SharedMetadataFieldValueType.date,
    // string / link_list / track_list render as text/list controls in the app.
    _ => SharedMetadataFieldValueType.text,
  };
}

/// Core editable fields that the app renders with dedicated widgets instead of
/// a scalar descriptor in [kAdminMetadataScalarFields].
const Set<String> _appHandledSpecially = {
  'physical_format', // release physical-format dropdown
  'track_count', // music track list widget
  'tracks', // music track list widget
};

void main() {
  late MetadataFieldSchema schema;

  setUpAll(() {
    final raw =
        File('test/fixtures/metadata_field_schema.json').readAsStringSync();
    schema = MetadataFieldSchema.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('core field schema fixture parses into the app model', () {
    expect(schema.schemaVersion, 1);
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
    for (final field in schema.fields) {
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

  test('normalized fields expose their normalized value type from core', () {
    final normalizedByKey = {
      for (final field in schema.fields)
        if (field.normalized) field.key: field.valueType,
    };
    for (final appField in kAdminMetadataScalarFields) {
      final coreType = normalizedByKey[appField.key];
      if (coreType == null) continue;
      expect(
        appField.normalizedValueType,
        coreType,
        reason: 'Normalized value type drift for "${appField.key}"',
      );
    }
  });
}
