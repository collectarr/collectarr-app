import 'dart:convert';

import '../../models/catalog_media_kind.dart';

enum MetadataWriteTarget {
  coreCanonical('core_canonical'),
  coreCanonicalRelation('core_canonical_relation'),
  readonlyComputed('readonly_computed');

  const MetadataWriteTarget(this.apiValue);

  final String apiValue;

  static MetadataWriteTarget fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      throw FormatException('Metadata write target is required.');
    }
    for (final target in MetadataWriteTarget.values) {
      if (target.apiValue == normalized) {
        return target;
      }
    }
    throw FormatException('Unknown metadata write target: $value');
  }
}

class CatalogPhysicalFormat {
  const CatalogPhysicalFormat({
    required this.id,
    required this.label,
    required this.mediaFamily,
    required this.variantType,
    this.aliases = const [],
  });

  final String id;
  final String label;
  final String mediaFamily;
  final String variantType;
  final List<String> aliases;

  factory CatalogPhysicalFormat.fromJson(Map<String, dynamic> json) {
    return CatalogPhysicalFormat(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      mediaFamily: json['media_family'] as String? ?? '',
      variantType: json['variant_type'] as String? ?? '',
      aliases: [
        for (final alias in (json['aliases'] as List<dynamic>? ?? []))
          alias.toString(),
      ],
    );
  }
}

class CatalogMediaType {
  const CatalogMediaType({
    required this.kind,
    required this.singularLabel,
    required this.pluralLabel,
    this.routeSegments = const [],
    this.isTopLevel = true,
    this.physicalFormats = const [],
  });

  final String kind;
  final String singularLabel;
  final String pluralLabel;
  final List<String> routeSegments;
  final bool isTopLevel;
  final List<CatalogPhysicalFormat> physicalFormats;

  CatalogMediaKind get mediaKind => catalogMediaKindFromValue(kind);

  factory CatalogMediaType.fromJson(Map<String, dynamic> json) {
    return CatalogMediaType(
      kind: json['kind'] as String? ?? '',
      singularLabel: json['singular_label'] as String? ?? '',
      pluralLabel: json['plural_label'] as String? ?? '',
      routeSegments: [
        for (final segment in (json['route_segments'] as List<dynamic>? ?? []))
          segment.toString(),
      ],
      isTopLevel: json['is_top_level'] as bool? ?? true,
      physicalFormats: [
        for (final format in (json['physical_formats'] as List<dynamic>? ?? []))
          CatalogPhysicalFormat.fromJson(format as Map<String, dynamic>),
      ],
    );
  }
}

class MetadataNormalizedManifest {
  const MetadataNormalizedManifest({
    required this.schemaVersion,
    required this.commonFields,
    required this.kindFields,
    required this.valueTypes,
  });

  final int schemaVersion;
  final List<String> commonFields;
  final Map<String, List<String>> kindFields;
  final Map<String, String> valueTypes;

  factory MetadataNormalizedManifest.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schema_version'];
    final rawCommonFields = json['common_fields'];
    final rawKindFields = json['kind_fields'];
    final rawValueTypes = json['value_types'];
    if (schemaVersion is! int ||
        rawCommonFields is! List ||
        rawKindFields is! Map<String, dynamic> ||
        rawValueTypes is! Map<String, dynamic>) {
      throw const FormatException(
        'Metadata normalized manifest requires schema_version, '
        'common_fields, kind_fields, and value_types.',
      );
    }
    final commonFields = <String>[];
    for (final value in rawCommonFields) {
      if (value is! String) {
        throw const FormatException(
          'Metadata normalized manifest common_fields must contain strings.',
        );
      }
      commonFields.add(value);
    }
    final kindFields = <String, List<String>>{};
    for (final entry in rawKindFields.entries) {
      if (entry.value is! List ||
          (entry.value as List).any((value) => value is! String)) {
        throw FormatException(
          'Metadata normalized manifest kind_fields.${entry.key} '
          'must contain strings.',
        );
      }
      kindFields[entry.key] = (entry.value as List).cast<String>();
    }
    final valueTypes = <String, String>{};
    for (final entry in rawValueTypes.entries) {
      if (entry.value is! String) {
        throw FormatException(
          'Metadata normalized manifest value_types.${entry.key} '
          'must be a string.',
        );
      }
      valueTypes[entry.key] = entry.value as String;
    }
    return MetadataNormalizedManifest(
      schemaVersion: schemaVersion,
      commonFields: commonFields,
      kindFields: kindFields,
      valueTypes: valueTypes,
    );
  }
}

/// A single editable canonical metadata field, sourced from the core registry
/// (`app/catalog/metadata_fields.py`) via
/// `GET /api/v1/metadata/field-schema`.
///
/// This is the single source of truth the admin edit panel and the app edit
/// dialog render from; the local [kAdminMetadataScalarFields] contract is kept
/// consistent with it by `shared_metadata_editing_contract_test.dart`.
class MetadataFieldSpec {
  const MetadataFieldSpec({
    required this.key,
    required this.valueType,
    required this.label,
    required this.common,
    required this.typed,
    required this.normalized,
    required this.editable,
    required this.section,
    required this.input,
    required this.kinds,
    this.required = false,
    this.writeTargetsByKind = const {},
  });

  final String key;
  final String valueType;
  final String label;
  final bool common;
  final bool typed;
  final bool normalized;
  final bool editable;
  final bool required;
  final String section;
  final String input;
  final List<String> kinds;
  final Map<String, MetadataWriteTarget> writeTargetsByKind;

  factory MetadataFieldSpec.fromJson(Map<String, dynamic> json) {
    final key = _requiredString(json, 'key');
    final valueType = _requiredString(json, 'value_type');
    final label = _requiredString(json, 'label');
    final section = _requiredString(json, 'section');
    final input = _requiredString(json, 'input');
    final common = json['common'];
    final typed = json['typed'];
    final normalized = json['normalized'];
    final editable = json['editable'];
    if (common is! bool ||
        typed is! bool ||
        normalized is! bool ||
        editable is! bool) {
      throw FormatException('Metadata field "$key" has invalid flags.');
    }
    final required = json['required'];
    if (required != null && required is! bool) {
      throw FormatException('Metadata field "$key" has invalid required flag.');
    }
    final rawKinds = json['kinds'];
    if (rawKinds != null &&
        (rawKinds is! List || rawKinds.any((kind) => kind is! String))) {
      throw FormatException('Metadata field "$key" has invalid kinds.');
    }
    final rawOwnership = json['ownership_by_kind'];
    if (rawOwnership != null && rawOwnership is! Map<String, dynamic>) {
      throw FormatException(
        'Metadata field "$key" has invalid ownership_by_kind.',
      );
    }
    return MetadataFieldSpec(
      key: key,
      valueType: valueType,
      label: label,
      common: common,
      typed: typed,
      normalized: normalized,
      editable: editable,
      required: required as bool? ?? false,
      section: section,
      input: input,
      kinds: [
        for (final value in (rawKinds as List<dynamic>? ?? const [])) value as String,
      ],
      writeTargetsByKind: {
        for (final entry
            in (rawOwnership as Map<String, dynamic>? ?? const {}).entries)
          entry.key: MetadataWriteTarget.fromApiValue(
            _requiredString(
              _requiredMap(entry.value, 'ownership_by_kind.${entry.key}'),
              'write_target',
            ),
          ),
      },
    );
  }

  MetadataWriteTarget? writeTargetForKind(String kind) =>
      writeTargetsByKind[kind];
}

/// The unified field schema returned by `GET /api/v1/metadata/field-schema`.
class MetadataFieldSchema {
  const MetadataFieldSchema({
    required this.schemaVersion,
    required this.fields,
    required this.kindFields,
    required this.sections,
  });

  final int schemaVersion;
  final List<MetadataFieldSpec> fields;
  final Map<String, List<String>> kindFields;
  final List<String> sections;

  /// Specs applicable to [kind] (common fields plus that kind's fields).
  List<MetadataFieldSpec> fieldsForKind(String kind) {
    final keys = kindFields[kind]?.toSet() ?? const <String>{};
    return [
      for (final field in fields)
        if (field.common ||
            (field.kinds.contains(kind) && keys.contains(field.key)))
          field,
    ];
  }

  factory MetadataFieldSchema.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('contractVersion')) {
      return MetadataFieldSchema.fromPinnedContractJson(json);
    }
    final rawKindFields = json['kind_fields'];
    final rawFields = json['fields'];
    if (json['schema_version'] is! int ||
        rawKindFields is! Map<String, dynamic> ||
        rawFields is! List) {
      throw const FormatException(
        'Metadata field schema requires schema_version, fields, and kind_fields.',
      );
    }
    final fields = [
      for (final value in rawFields)
        MetadataFieldSpec.fromJson(
          _requiredMap(value, 'fields[]'),
        ),
    ];
    final rawSections = json['sections'];
    if (rawSections != null &&
        (rawSections is! List ||
            rawSections.any((section) => section is! String))) {
      throw const FormatException(
        'Metadata field schema sections must contain strings.',
      );
    }
    final sections = rawSections == null
        ? <String>{
            for (final field in fields)
              if (field.section != 'internal') field.section,
          }
        : <String>{for (final value in rawSections as List) value as String};
    final kindFields = <String, List<String>>{};
    for (final entry in rawKindFields.entries) {
      if (entry.key.isEmpty ||
          entry.value is! List ||
          (entry.value as List).any((value) => value is! String)) {
        throw FormatException(
          'Metadata field schema kind_fields.${entry.key} is invalid.',
        );
      }
      kindFields[entry.key] = (entry.value as List).cast<String>();
    }
    return MetadataFieldSchema(
      schemaVersion: json['schema_version'] as int,
      fields: fields,
      kindFields: kindFields,
      sections: sections.toList(growable: false),
    );
  }

  factory MetadataFieldSchema.fromPinnedContractJson(
    Map<String, dynamic> json,
  ) {
    final version = json['contractVersion'];
    final match = version is String
        ? RegExp(r'^(\d+)\.').firstMatch(version)
        : null;
    final rows = json['fields'];
    if (match == null || rows is! List) {
      throw const FormatException(
        'Pinned metadata field contract requires contractVersion and fields.',
      );
    }

    final grouped = <String, Map<String, dynamic>>{};
    final kindFields = <String, Set<String>>{};
    for (var index = 0; index < rows.length; index++) {
      final raw = rows[index];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('Metadata field contract fields[$index] is invalid.');
      }
      final kind = raw['kind'];
      final key = raw['key'];
      final valueType = raw['valueType'];
      final label = raw['label'];
      if (kind is! String ||
          kind.trim().isEmpty ||
          catalogMediaKindFromApiValue(kind).isUnknown ||
          key is! String ||
          key.trim().isEmpty ||
          valueType is! String ||
          valueType.trim().isEmpty ||
          label is! String ||
          label.trim().isEmpty) {
        throw FormatException(
          'Metadata field contract fields[$index] requires kind, key, valueType, and label.',
        );
      }
      final common = raw['common'];
      final typed = raw['typed'];
      final normalized = raw['normalized'];
      final editable = raw['editable'];
      if (common is! bool ||
          typed is! bool ||
          normalized is! bool ||
          editable is! bool) {
        throw FormatException(
          'Metadata field contract fields[$index] has invalid boolean flags.',
        );
      }
      final section = raw['section'];
      final input = raw['input'];
      final required = raw['required'];
      if (section is! String ||
          section.trim().isEmpty ||
          input is! String ||
          input.trim().isEmpty ||
          (required != null && required is! bool)) {
        throw FormatException(
          'Metadata field contract fields[$index] requires section and input.',
        );
      }

      final signature = jsonEncode([
        key,
        valueType,
        label,
        common,
        typed,
        normalized,
        editable,
        required == true,
        section,
        input,
      ]);
      final spec = grouped.putIfAbsent(signature, () => {
            'key': key,
            'value_type': valueType,
            'label': label,
            'common': common,
            'typed': typed,
            'normalized': normalized,
            'editable': editable,
            'required': required == true,
            'section': section,
            'input': input,
            'kinds': <String>[],
            'ownership_by_kind': <String, dynamic>{},
          });
      final kindsForSpec = spec['kinds'] as List<String>;
      if (kindsForSpec.contains(kind)) {
        throw FormatException(
          'Metadata field contract fields[$index] duplicates "$key" for "$kind".',
        );
      }
      kindsForSpec.add(kind);
      kindFields.putIfAbsent(kind, () => <String>{}).add(key);

      final writeTarget = raw['writeTarget'];
      if (writeTarget is! String) {
        throw FormatException(
          'Metadata field contract fields[$index] is missing writeTarget.',
        );
      }
      (spec['ownership_by_kind'] as Map<String, dynamic>)[kind] = {
        'write_target': writeTarget,
      };
    }

    final fields = [
      for (final raw in grouped.values)
        MetadataFieldSpec.fromJson(raw),
    ];
    final sections = <String>{
      for (final field in fields)
        if (field.section != 'internal') field.section,
    };
    return MetadataFieldSchema(
      schemaVersion: int.parse(match.group(1)!),
      fields: fields,
      kindFields: {
        for (final entry in kindFields.entries)
          entry.key: entry.value.toList(growable: false),
      },
      sections: sections.toList(growable: false),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Metadata contract requires a non-empty $key.');
  }
  return value;
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Metadata contract $field must be an object.');
  }
  return value;
}
