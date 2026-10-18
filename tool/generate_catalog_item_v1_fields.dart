import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/catalog-item-v1.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _outputPath = 'lib/core/api/generated/catalog_item_v1_fields.dart';

Future<void> main(List<String> args) async {
  final contractBytes = await File(_contractPath).readAsBytes();
  final manifest = jsonDecode(await File(_manifestPath).readAsString())
      as Map<String, dynamic>;
  final contractHash = sha256.convert(contractBytes).toString();
  if (manifest['catalogItemV1Hash'] != contractHash) {
    throw const FormatException(
      'Pinned Catalog Item v1 schema hash does not match contract-manifest.json.',
    );
  }

  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  if (contract['schemaVersion'] != 1 ||
      contract['contractVersion'] != '1.0.0') {
    throw const FormatException('Unsupported Catalog Item contract version.');
  }
  final kinds = contract['kinds'] as Map<String, dynamic>;
  final source = _formatSource(_generate(kinds, contractHash));
  final output = File(_outputPath);
  if (args.contains('--check')) {
    if (!await output.exists() || await output.readAsString() != source) {
      stderr.writeln('Generated Catalog Item v1 field definitions are stale.');
      exitCode = 1;
    }
    return;
  }
  await output.parent.create(recursive: true);
  await output.writeAsString(source);
}

String _generate(Map<String, dynamic> kinds, String hash) {
  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: $_contractPath')
    ..writeln('// Contract SHA-256: $hash')
    ..writeln("const catalogItemV1SchemaVersion = 1;")
    ..writeln("const catalogItemV1ContractVersion = '1.0.0';")
    ..writeln()
    ..writeln(
        '/// One Catalog Item field: its key, the title Core gives it and, for a')
    ..writeln('/// list of objects, the object lists each element contains.')
    ..writeln('class CatalogItemV1Field {')
    ..writeln(
        '  const CatalogItemV1Field(this.key, {this.title, this.children = const []});')
    ..writeln()
    ..writeln('  final String key;')
    ..writeln('  final String? title;')
    ..writeln('  final List<CatalogItemV1Field> children;')
    ..writeln('}')
    ..writeln()
    ..writeln(
        'const Map<String, List<CatalogItemV1Field>> catalogItemV1FieldsByKind = {');

  for (final kindName in kinds.keys.toList()..sort()) {
    final kindSchema = kinds[kindName] as Map<String, dynamic>;
    out.writeln("  '$kindName': [");
    _writeFields(out, kindSchema['properties'] as Map<String, dynamic>, '    ');
    out.writeln('  ],');
  }
  out.writeln('};');
  return out.toString();
}

/// Writes every property in [properties]; children are kept only for lists of
/// objects, which are the parts a client can include or skip as a whole.
void _writeFields(
    StringBuffer out, Map<String, dynamic> properties, String indent) {
  for (final key in properties.keys.toList()..sort()) {
    final schema = properties[key] as Map<String, dynamic>;
    final title = schema['title'] as String?;
    final children = <String, dynamic>{
      for (final entry in (_objectListItemProperties(schema) ?? {}).entries)
        if (_objectListItemProperties(entry.value as Map<String, dynamic>) !=
            null)
          entry.key: entry.value,
    };
    final args = [
      "'$key'",
      if (title != null) 'title: ${_dartString(title)}',
    ].join(', ');
    if (children.isEmpty) {
      out.writeln('${indent}CatalogItemV1Field($args),');
      continue;
    }
    out.writeln('${indent}CatalogItemV1Field($args, children: [');
    _writeFields(out, children, '$indent  ');
    out.writeln('$indent]),');
  }
}

/// The element properties of [schema] when it is a (nullable) list of objects.
Map<String, dynamic>? _objectListItemProperties(Map<String, dynamic> schema) {
  for (final variant in _variants(schema)) {
    if (variant['type'] != 'array' || variant['items'] is! Map) continue;
    for (final item in _variants(variant['items'] as Map<String, dynamic>)) {
      if (item['type'] == 'object' && item['properties'] is Map) {
        return item['properties'] as Map<String, dynamic>;
      }
    }
  }
  return null;
}

List<Map<String, dynamic>> _variants(Map<String, dynamic> schema) => [
      for (final variant in (schema['anyOf'] as List<dynamic>? ?? const []))
        variant as Map<String, dynamic>,
      schema,
    ];

String _dartString(String value) =>
    "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";

String _formatSource(String source) {
  // The emitted map has a stable format; keep generation synchronous so --check
  // can compare exact bytes without managing temporary process state.
  return source;
}
