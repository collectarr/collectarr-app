import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:flutter/foundation.dart';

typedef LibraryAdminProposalFieldReader = String Function(
  LibraryMetadataCorrectionValues values,
);

typedef LibraryAdminProposalFieldWriter = void Function(
  LibraryMetadataCorrectionValues values,
  String rawValue,
);

typedef LibraryAdminCorrectionValueReader = Object? Function(
  AdminMetadataItem item,
);

typedef LibraryAdminCorrectionParser = Object? Function(String rawValue);

typedef LibraryAdminCorrectionFormatter = String Function(Object? value);

typedef LibraryAdminCorrectionComparator = bool Function(
  Object? left,
  Object? right,
);

typedef LibraryAdminCorrectionSaver = Future<void> Function(
  AdminMetadataItem item,
  Object? value,
  LibraryAdminCorrectionWriter writer,
);

/// Narrow write boundary supplied by the Admin host. A kind can route a field
/// to a catalog item or a related canonical entity without teaching Admin the
/// field's meaning.
final class LibraryAdminCorrectionWriter {
  const LibraryAdminCorrectionWriter({
    required this.updateCatalogFields,
    required this.updateRelatedFields,
  });

  final Future<void> Function(Map<String, Object?> fields) updateCatalogFields;
  final Future<void> Function(
    String relatedEntityId,
    Map<String, Object?> fields,
  ) updateRelatedFields;
}

/// One editable canonical field declared by its owning kind.
final class LibraryAdminCorrectionField {
  const LibraryAdminCorrectionField({
    required this.presentation,
    required this.read,
    this.parse,
    this.format,
    this.equals,
    this.save,
    this.usesPhysicalFormatPicker = false,
    this.required = false,
  });

  final SharedMetadataFieldDescriptor presentation;
  final LibraryAdminCorrectionValueReader read;
  final LibraryAdminCorrectionParser? parse;
  final LibraryAdminCorrectionFormatter? format;
  final LibraryAdminCorrectionComparator? equals;
  final LibraryAdminCorrectionSaver? save;
  final bool usesPhysicalFormatPicker;
  final bool required;

  String get key => presentation.key;

  LibraryAdminCorrectionField withPresentation(
    SharedMetadataFieldDescriptor value,
  ) =>
      LibraryAdminCorrectionField(
        presentation: value,
        read: read,
        parse: parse,
        format: format,
        equals: equals,
        save: save,
        usesPhysicalFormatPicker: usesPhysicalFormatPicker,
        required: required,
      );

  bool valuesEqual(Object? left, Object? right) =>
      equals?.call(left, right) ??
      switch (presentation.valueType) {
        SharedMetadataFieldValueType.partialDate =>
          PartialDate.tryParse(left) == PartialDate.tryParse(right),
        SharedMetadataFieldValueType.stringList =>
          listEquals(_adminStringValues(left), _adminStringValues(right)),
        _ => _adminCorrectionValuesEqual(left, right),
      };

  String displayValue(Object? value) =>
      format?.call(value) ??
      (presentation.valueType == SharedMetadataFieldValueType.json &&
              value != null
          ? const JsonEncoder.withIndent('  ').convert(value)
          : _formatAdminCorrectionValue(value));
}

LibraryAdminCorrectionField adminCorrectionField({
  required String key,
  required String label,
  required SharedMetadataEditTab tab,
  required LibraryAdminCorrectionValueReader read,
  SharedMetadataFieldInputType inputType = SharedMetadataFieldInputType.text,
  SharedMetadataFieldValueType valueType = SharedMetadataFieldValueType.text,
  String? hintText,
  int minLines = 1,
  int maxLines = 1,
  LibraryAdminCorrectionParser? parse,
  LibraryAdminCorrectionFormatter? format,
  LibraryAdminCorrectionComparator? equals,
  LibraryAdminCorrectionSaver? save,
  bool usesPhysicalFormatPicker = false,
  bool required = false,
}) {
  return LibraryAdminCorrectionField(
    presentation: SharedMetadataFieldDescriptor(
      key: key,
      label: label,
      tab: tab,
      inputType: inputType,
      valueType: valueType,
      hintText: hintText,
      minLines: minLines,
      maxLines: maxLines,
    ),
    read: read,
    parse: parse,
    format: format,
    equals: equals,
    save: save,
    usesPhysicalFormatPicker: usesPhysicalFormatPicker,
    required: required,
  );
}

LibraryAdminCorrectionField adminPhysicalFormatCorrectionField({
  required String key,
  required LibraryAdminCorrectionValueReader read,
}) {
  return adminCorrectionField(
    key: key,
    label: key,
    tab: SharedMetadataEditTab.publishing,
    read: read,
    usesPhysicalFormatPicker: true,
  );
}

LibraryAdminCorrectionField adminCorrectionFieldValueOverride({
  required String key,
  required LibraryAdminCorrectionValueReader read,
  bool required = false,
}) =>
    adminCorrectionField(
      key: key,
      label: key,
      tab: SharedMetadataEditTab.item,
      read: read,
      required: required,
    );

LibraryAdminCorrectionField adminUrlListCorrectionField({
  required String key,
  required String label,
  required LibraryAdminCorrectionValueReader read,
  required String linkKind,
}) {
  return adminCorrectionField(
    key: key,
    label: label,
    tab: SharedMetadataEditTab.artwork,
    read: read,
    valueType: SharedMetadataFieldValueType.stringList,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 2,
    maxLines: 5,
    parse: (raw) {
      final links = <Map<String, Object?>>[];
      for (final line in raw.split('\n')) {
        final url = line.trim();
        if (url.isEmpty) continue;
        final uri = Uri.tryParse(url);
        if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
          throw FormatException('Invalid URL in $label: $url');
        }
        links.add({'url': url, 'kind': linkKind});
      }
      return links;
    },
    format: (value) {
      if (value is! List) return '';
      return value
          .map((entry) {
            if (entry is TrailerLinkDto) return entry.url;
            if (entry is Map) return entry['url']?.toString() ?? '';
            return entry.toString();
          })
          .where((url) => url.isNotEmpty)
          .join('\n');
    },
    equals: (left, right) {
      List<String> urls(Object? value) {
        if (value is! List) return const [];
        return [
          for (final entry in value)
            if (entry is TrailerLinkDto)
              entry.url
            else if (entry is Map && entry['url'] != null)
              entry['url'].toString(),
        ];
      }

      return listEquals(urls(left), urls(right));
    },
  );
}

LibraryAdminCorrectionField adminRelatedListCorrectionField({
  required String key,
  required String label,
  required String relatedFieldKey,
  required String? Function(AdminMetadataItem item) relatedEntityId,
  required LibraryAdminCorrectionValueReader read,
}) {
  return adminCorrectionField(
    key: key,
    label: label,
    tab: SharedMetadataEditTab.relations,
    read: read,
    valueType: SharedMetadataFieldValueType.stringList,
    inputType: SharedMetadataFieldInputType.multiline,
    minLines: 2,
    maxLines: 4,
    parse: (raw) => _adminStringValues(raw.split(',')),
    format: (value) => _adminStringValues(value).join(', '),
    save: (item, value, writer) async {
      final entityId = relatedEntityId(item);
      if (entityId == null || entityId.isEmpty) {
        throw StateError('This item has no related entity to update.');
      }
      await writer.updateRelatedFields(
        entityId,
        {relatedFieldKey: _adminStringValues(value)},
      );
    },
  );
}

List<String> _adminStringValues(Object? value) {
  if (value is String) value = value.split(RegExp(r'[,;\n]'));
  if (value is! Iterable) return const [];
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

bool _adminCorrectionValuesEqual(Object? left, Object? right) {
  if (left is DateTime && right is DateTime) {
    return left.toUtc() == right.toUtc();
  }
  if (left is PartialDate && right is PartialDate) {
    return left == right;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_adminCorrectionValuesEqual(left[index], right[index])) return false;
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_adminCorrectionValuesEqual(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}

String _formatAdminCorrectionValue(Object? value) {
  if (value == null) return '';
  if (value is PartialDate) return value.isoString ?? '';
  if (value is DateTime) {
    final date = value.toUtc();
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  if (value is List) {
    return value.map((entry) => entry?.toString() ?? '').join(', ');
  }
  return value.toString();
}

/// Structural description of one kind-owned admin proposal field.
///
/// The values object is a provider boundary representation. A kind owns the key,
/// display semantics, and codec; the Admin feature only owns the editor host.
class LibraryAdminProposalField {
  const LibraryAdminProposalField({
    required this.key,
    required this.label,
    required this.read,
    required this.write,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String key;
  final String label;
  final int minLines;
  final int maxLines;
  final LibraryAdminProposalFieldReader read;
  final LibraryAdminProposalFieldWriter write;
}

/// A metadata field that the owning kind allows users to override locally.
///
/// The host only renders this structural option. The field identity is
/// created by the kind contributor, so generic Library UI never invents a
/// semantic field path or assumes that every kind has the same fields.
class LibraryMetadataOverrideField {
  const LibraryMetadataOverrideField({
    required this.id,
    required this.label,
  });

  final MetadataFieldId id;
  final String label;
}

/// Semantic admin contribution supplied by one library kind.
///
/// Admin may render the fields structurally, but it must not interpret their
/// serialized keys or decide which kind-specific fields are applicable.
abstract interface class LibraryAdminContributor {
  CatalogMediaKind get kind;

  List<LibraryAdminProposalField> get proposalFields;

  List<LibraryAdminCorrectionField> get correctionFields;

  Map<String, Object?> serializeCoverCorrection({
    required String? coverImageUrl,
    required String? thumbnailImageUrl,
  });

  List<LibraryMetadataOverrideField> get metadataOverrideFields;
}

/// Resolves the editable correction form directly from Core's per-kind field
/// schema. Kinds only override fields that need a kind-owned codec or writer.
List<LibraryAdminCorrectionField> adminCorrectionFieldsForKind({
  required MetadataFieldSchema schema,
  required CatalogMediaKind kind,
  required LibraryAdminContributor contributor,
}) {
  final overrides = {
    for (final field in contributor.correctionFields) field.key: field,
  };
  final fields = <LibraryAdminCorrectionField>[];
  for (final spec in schema.fieldsForKind(kind.apiValue)) {
    final ownership = spec.ownershipByKind[kind.apiValue];
    if (!spec.editable || ownership == null) continue;
    if (ownership.writeTarget != MetadataWriteTarget.coreCanonical &&
        ownership.writeTarget != MetadataWriteTarget.coreCanonicalRelation) {
      continue;
    }
    if (ownership.scope == MetadataFieldScope.ownedCopy ||
        ownership.scope == MetadataFieldScope.trackingRecord) {
      continue;
    }
    final presentation = _adminCorrectionPresentationFromSchema(spec);
    final override = overrides.remove(spec.key);
    if (override != null) {
      fields.add(override.withPresentation(presentation));
      continue;
    }
    fields.add(_adminCorrectionFieldFromSchema(spec, presentation));
  }
  return fields;
}

SharedMetadataFieldDescriptor _adminCorrectionPresentationFromSchema(
  MetadataFieldSpec field,
) {
  final valueType = switch (field.valueType) {
    'number' || 'decimal' || 'float' => SharedMetadataFieldValueType.number,
    'integer' => SharedMetadataFieldValueType.integer,
    'boolean' || 'bool' => SharedMetadataFieldValueType.boolean,
    'partial_date' => SharedMetadataFieldValueType.partialDate,
    'string_list' || 'link_list' => SharedMetadataFieldValueType.stringList,
    'string' => SharedMetadataFieldValueType.text,
    _ => SharedMetadataFieldValueType.json,
  };
  final inputType = valueType == SharedMetadataFieldValueType.json
      ? SharedMetadataFieldInputType.multiline
      : switch (field.input) {
          'number' => SharedMetadataFieldInputType.number,
          'multiline' || 'list' => SharedMetadataFieldInputType.multiline,
          _ => SharedMetadataFieldInputType.text,
        };
  final tab = switch (field.section) {
    'publishing' => SharedMetadataEditTab.publishing,
    'technical' => SharedMetadataEditTab.technical,
    'regional' => SharedMetadataEditTab.regional,
    'artwork' => SharedMetadataEditTab.artwork,
    'relations' => SharedMetadataEditTab.relations,
    _ => SharedMetadataEditTab.item,
  };
  return SharedMetadataFieldDescriptor(
    key: field.key,
    label: field.label,
    tab: tab,
    inputType: inputType,
    valueType: valueType,
    hintText: field.valueType == 'partial_date'
        ? 'YYYY, YYYY-MM, YYYY-MM-DD, or {"month": 5}'
        : null,
    minLines: inputType == SharedMetadataFieldInputType.multiline ? 2 : 1,
    maxLines: inputType == SharedMetadataFieldInputType.multiline ? 5 : 1,
  );
}

LibraryAdminCorrectionField _adminCorrectionFieldFromSchema(
  MetadataFieldSpec field,
  SharedMetadataFieldDescriptor presentation,
) {
  return LibraryAdminCorrectionField(
    presentation: presentation,
    read: (item) => item.canonicalFieldValues[field.key],
    required: field.required,
  );
}

String readAdminProposalText(
  LibraryMetadataCorrectionValues values,
  String key,
) =>
    values.read(key)?.toString() ?? '';

void writeAdminProposalText(
  LibraryMetadataCorrectionValues values,
  String key,
  String rawValue,
) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    values.remove(key);
  } else {
    values.write(key, value);
  }
}

String readAdminProposalStringList(
  LibraryMetadataCorrectionValues values,
  String key,
) {
  final value = values.read(key);
  if (value is! List) {
    return '';
  }
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .join(', ');
}

void writeAdminProposalStringList(
  LibraryMetadataCorrectionValues values,
  String key,
  String rawValue,
) {
  final items = rawValue
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  if (items.isEmpty) {
    values.remove(key);
  } else {
    values.write(key, items);
  }
}

LibraryAdminProposalField adminTextProposalField({
  required String key,
  required String label,
  int minLines = 1,
  int maxLines = 1,
}) {
  return LibraryAdminProposalField(
    key: key,
    label: label,
    minLines: minLines,
    maxLines: maxLines,
    read: (payload) => readAdminProposalText(payload, key),
    write: (payload, rawValue) =>
        writeAdminProposalText(payload, key, rawValue),
  );
}

LibraryAdminProposalField adminStringListProposalField({
  required String key,
  required String label,
}) {
  return LibraryAdminProposalField(
    key: key,
    label: label,
    read: (payload) => readAdminProposalStringList(payload, key),
    write: (payload, rawValue) =>
        writeAdminProposalStringList(payload, key, rawValue),
  );
}

String readAdminProposalExternalLinks(
  LibraryMetadataCorrectionValues values,
  String key,
) {
  final value = values.read(key);
  if (value is! List) {
    return '';
  }
  return [
    for (final row in value)
      if (row is Map && row['url']?.toString().trim().isNotEmpty == true)
        [
          row['label']?.toString() ?? '',
          row['url']?.toString() ?? '',
          row['kind']?.toString() ?? '',
          row['description']?.toString() ?? '',
        ].join(' | '),
  ].join('\n');
}

void writeAdminProposalExternalLinks(
  LibraryMetadataCorrectionValues values,
  String key,
  String rawValue,
) {
  final rows = <Map<String, Object?>>[];
  final lines = rawValue.split('\n');
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    if (line.isEmpty) {
      continue;
    }
    final columns =
        line.split('|').map((value) => value.trim()).toList(growable: false);
    final label = columns.length > 1 ? columns.first : '';
    final url = columns.length > 1 ? columns[1] : columns.first;
    final kind = columns.length > 2 ? columns[2] : '';
    final description = columns.length > 3 ? columns[3] : '';
    if (url.isEmpty) {
      throw FormatException(
        'External links line ${index + 1} is invalid: URL is required',
      );
    }
    final uri = Uri.tryParse(url);
    final scheme = uri?.scheme.toLowerCase();
    final isWebUrl = uri != null &&
        uri.hasScheme &&
        (scheme == 'http' || scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      throw FormatException(
        'External links line ${index + 1} has invalid URL "$url" (use full http/https URL)',
      );
    }
    rows.add({
      if (label.isNotEmpty) 'label': label,
      'url': url,
      if (kind.isNotEmpty) 'kind': kind,
      if (description.isNotEmpty) 'description': description,
    });
  }
  if (rows.isEmpty) {
    values.remove(key);
  } else {
    values.write(key, rows);
  }
}

LibraryAdminProposalField adminExternalLinksProposalField({
  required String key,
}) {
  return LibraryAdminProposalField(
    key: key,
    label: 'External links (label | url | kind | description)',
    minLines: 2,
    maxLines: 4,
    read: (payload) => readAdminProposalExternalLinks(payload, key),
    write: (payload, rawValue) =>
        writeAdminProposalExternalLinks(payload, key, rawValue),
  );
}
