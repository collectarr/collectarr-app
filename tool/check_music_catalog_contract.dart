import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/music-catalog-v1.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _mapperPath =
    'lib/features/library/kinds/music/catalog/music_catalog_mapper.dart';

Future<void> main() async {
  final contractBytes = await File(_contractPath).readAsBytes();
  final actualHash = sha256.convert(contractBytes).toString();
  final manifest = _readJson(_manifestPath);
  if (manifest['musicCatalogHash'] != actualHash) {
    throw StateError(
      'The pinned Music contract hash does not match its manifest.',
    );
  }

  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  final definitions = contract[r'$defs'] as Map<String, dynamic>;
  final mapper = await File(_mapperPath).readAsString();

  _assertContractFieldsMatchMapper(
    definitions,
    mapper,
    schemaName: 'CatalogMusicItemResponse',
    allowlistName: 'coreFields',
  );
  _assertContractFieldsMatchMapper(
    definitions,
    mapper,
    schemaName: 'CatalogMusicDiscResponse',
    allowlistName: 'discFields',
  );
  _assertContractFieldsMatchMapper(
    definitions,
    mapper,
    schemaName: 'CatalogMusicTrackResponse',
    allowlistName: 'trackFields',
  );
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void _assertContractFieldsMatchMapper(
  Map<String, dynamic> definitions,
  String mapper, {
  required String schemaName,
  required String allowlistName,
}) {
  final schema = definitions[schemaName];
  if (schema is! Map<String, dynamic>) {
    throw StateError('The pinned Music contract is missing $schemaName.');
  }
  final properties = schema['properties'];
  if (properties is! Map<String, dynamic>) {
    throw StateError('$schemaName has no properties.');
  }

  final allowlist = _stringSet(mapper, allowlistName);
  final contractFields = properties.keys.toSet();
  final missing = contractFields.difference(allowlist)..remove('kind');
  final unsupported = allowlist.difference(contractFields);
  if (missing.isNotEmpty || unsupported.isNotEmpty) {
    final details = <String>[];
    if (missing.isNotEmpty) {
      details.add('missing ${missing.toList()..sort()}');
    }
    if (unsupported.isNotEmpty) {
      details.add('unsupported ${unsupported.toList()..sort()}');
    }
    throw StateError(
      '$allowlistName differs from $schemaName: ${details.join('; ')}.',
    );
  }
}

Set<String> _stringSet(String source, String name) {
  final declaration = RegExp(
    'const\\s+$name\\s*=\\s*<String>\\s*\\{([^}]*)\\}',
    multiLine: true,
  ).firstMatch(source);
  if (declaration == null) {
    throw StateError('The Music mapper has no $name allowlist.');
  }
  return RegExp(r"'([^']+)'")
      .allMatches(declaration.group(1)!)
      .map((match) => match.group(1)!)
      .toSet();
}
