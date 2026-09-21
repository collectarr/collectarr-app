import 'package:collectarr_app/core/models/catalog_media_kind.dart';

final class CanonicalCorrectionField {
  const CanonicalCorrectionField({
    required this.key,
    required this.label,
    required this.valueType,
    required this.scope,
    required this.entityType,
    this.writable = true,
  });

  final String key;
  final String label;
  final String valueType;
  final String scope;
  final String entityType;
  final bool writable;

  factory CanonicalCorrectionField.fromJson(Map<String, dynamic> json) {
    return CanonicalCorrectionField(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      valueType: json['value_type']?.toString() ?? 'string',
      scope: json['scope']?.toString() ?? '',
      entityType: json['entity_type']?.toString() ?? '',
      writable: json['writable'] as bool? ?? true,
    );
  }
}

final class CanonicalCorrectionTarget {
  const CanonicalCorrectionTarget({
    required this.kind,
    required this.entityType,
    required this.entityId,
    required this.scope,
    required this.revision,
    required this.hash,
    required this.fields,
    required this.fieldSchema,
  });

  final CatalogMediaKind kind;
  final String entityType;
  final String entityId;
  final String scope;
  final String revision;
  final String hash;
  final Map<String, dynamic> fields;
  final List<CanonicalCorrectionField> fieldSchema;

  factory CanonicalCorrectionTarget.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    final rawSchema = json['field_schema'];
    return CanonicalCorrectionTarget(
      kind: catalogMediaKindFromApiValue(json['kind']?.toString()),
      entityType: json['entity_type']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      scope: json['scope']?.toString() ?? '',
      revision: json['revision']?.toString() ?? '',
      hash: json['hash']?.toString() ?? '',
      fields: rawFields is Map
          ? <String, dynamic>{
              for (final entry in rawFields.entries)
                entry.key.toString(): entry.value,
            }
          : const <String, dynamic>{},
      fieldSchema: rawSchema is List
          ? [
              for (final value in rawSchema)
                if (value is Map<String, dynamic>)
                  CanonicalCorrectionField.fromJson(value),
            ]
          : const <CanonicalCorrectionField>[],
    );
  }
}
