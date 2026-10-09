import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/catalog-item-v2.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _outputPath = 'lib/core/api/generated/catalog_item_v2_fields.dart';

Future<void> main(List<String> args) async {
  final contractBytes = await File(_contractPath).readAsBytes();
  final manifest = jsonDecode(await File(_manifestPath).readAsString())
      as Map<String, dynamic>;
  final contractHash = sha256.convert(contractBytes).toString();
  if (manifest['catalogItemV2Hash'] != contractHash) {
    throw const FormatException(
      'Pinned Catalog Item v2 schema hash does not match contract-manifest.json.',
    );
  }

  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  if (contract['schemaVersion'] != 2 ||
      contract['contractVersion'] != '2.0.0') {
    throw const FormatException('Unsupported Catalog Item contract version.');
  }
  final kinds = contract['kinds'] as Map<String, dynamic>;
  final source = _formatSource(_generate(kinds, contractHash));
  final output = File(_outputPath);
  if (args.contains('--check')) {
    if (!await output.exists() || await output.readAsString() != source) {
      stderr.writeln('Generated Catalog Item v2 field definitions are stale.');
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
    ..writeln("const catalogItemV2SchemaVersion = 2;")
    ..writeln("const catalogItemV2ContractVersion = '2.0.0';")
    ..writeln()
    ..writeln('const Map<String, Set<String>> catalogItemV2FieldsByKind = {');

  for (final kindName in kinds.keys.toList()..sort()) {
    final kindSchema = kinds[kindName] as Map<String, dynamic>;
    final properties = kindSchema['properties'] as Map<String, dynamic>;
    final fields = properties.keys.toList()..sort();
    out.writeln("  '$kindName': {");
    for (final field in fields) {
      out.writeln("    '$field',");
    }
    out.writeln('  },');
  }
  out.writeln('};');
  return out.toString();
}

String _formatSource(String source) {
  // The emitted map has a stable format; keep generation synchronous so --check
  // can compare exact bytes without managing temporary process state.
  return source;
}
