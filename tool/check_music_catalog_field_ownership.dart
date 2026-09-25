import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/music-catalog-v1.json';
const _contractManifestPath = 'tool/core_contracts/contract-manifest.json';
const _ownershipPath = 'tool/music_catalog_field_ownership.json';
const _localTablesPath =
    'lib/features/library/kinds/music/data/local/music_local_tables.dart';

Future<void> main() async {
  final contractBytes = await File(_contractPath).readAsBytes();
  final contractHash = sha256.convert(contractBytes).toString();
  final contractManifest = _readJson(_contractManifestPath);
  final ownership = _readJson(_ownershipPath);
  final pinnedHash = contractManifest['musicCatalogHash'];
  if (pinnedHash != contractHash || ownership['contractHash'] != contractHash) {
    throw StateError('Music catalog contract hash is not pinned consistently.');
  }

  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  final definitions = contract[r'$defs'] as Map<String, dynamic>;
  final fields = ownership['fields'] as Map<String, dynamic>;
  final expected = <String>{};
  for (final entry in definitions.entries) {
    if (!entry.key.startsWith('Music') && entry.key != 'PartialDateValue') {
      continue;
    }
    final schema = entry.value as Map<String, dynamic>;
    final properties = schema['properties'];
    if (properties is! Map<String, dynamic>) continue;
    for (final property in properties.keys) {
      expected.add('${entry.key}.$property');
    }
  }

  final missing = expected.difference(fields.keys.toSet());
  final stale = fields.keys.toSet().difference(expected);
  if (missing.isNotEmpty || stale.isNotEmpty) {
    throw StateError(
      'Music field ownership entries differ from the pinned contract. '
      'Missing: $missing. Stale: $stale.',
    );
  }

  final localTablesSource = await File(_localTablesPath).readAsString();
  for (final entry in fields.entries) {
    final fieldId = entry.key;
    final mapping = entry.value as Map<String, dynamic>;
    final owner = mapping['owner'];
    if (owner is! String || owner.trim().isEmpty) {
      throw StateError('$fieldId must declare an owner.');
    }
    _checkDomain(fieldId, mapping['domain']);
    _checkPersistence(fieldId, mapping['persistence'], localTablesSource);
  }

  final enums = ownership['enums'] as Map<String, dynamic>;
  for (final enumName in ['ExternalProvider', 'ItemKind']) {
    final expectedValues =
        ((definitions[enumName] as Map<String, dynamic>)['enum'] as List)
            .cast<String>();
    final values = (enums[enumName] as List?)?.cast<String>() ?? const [];
    if (!_sameValues(expectedValues, values)) {
      throw StateError('$enumName values differ from the pinned contract.');
    }
  }
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void _checkDomain(String fieldId, Object? rawDomain) {
  if (rawDomain is! Map<String, dynamic>) {
    throw StateError('$fieldId must identify its App domain mapping.');
  }
  final path = rawDomain['file'];
  final members = rawDomain['members'];
  if (path is! String || members is! List || members.isEmpty) {
    throw StateError('$fieldId must include a domain file and member.');
  }
  final sourceFile = File(path);
  if (!sourceFile.existsSync()) {
    throw StateError('$fieldId domain file does not exist: $path');
  }
  final source = sourceFile.readAsStringSync();
  for (final member in members.cast<String>()) {
    final pattern = RegExp('\\b${RegExp.escape(member)}\\b');
    if (!pattern.hasMatch(source)) {
      throw StateError(
          '$fieldId domain member `$member` was not found in $path.');
    }
  }
}

void _checkPersistence(
  String fieldId,
  Object? rawPersistence,
  String localTablesSource,
) {
  if (rawPersistence is! Map<String, dynamic>) {
    throw StateError('$fieldId must declare its persistence mapping.');
  }
  final tables =
      (rawPersistence['tables'] as List?)?.cast<String>() ?? const [];
  final columns =
      (rawPersistence['columns'] as List?)?.cast<String>() ?? const [];
  final reason = rawPersistence['reason'];
  if (tables.isEmpty || columns.isEmpty) {
    if (reason is! String || reason.trim().isEmpty) {
      throw StateError('$fieldId has no persistence mapping or explanation.');
    }
    return;
  }
  for (final table in tables) {
    final className = _pascalCase(table);
    final declaration = RegExp(
      'class $className extends Table \\{([\\s\\S]*?)\\n\\}',
    ).firstMatch(localTablesSource);
    if (declaration == null) {
      throw StateError(
          '$fieldId table `$table` is not declared in Music Drift.');
    }
    final source = declaration.group(1)!;
    for (final column in columns) {
      final getter = _camelCase(column);
      if (!RegExp('get ${RegExp.escape(getter)}\\b').hasMatch(source)) {
        throw StateError(
          '$fieldId Drift column `$table.$column` was not found.',
        );
      }
    }
  }
}

String _pascalCase(String value) => value
    .split('_')
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join();

String _camelCase(String value) {
  final parts = value.split('_');
  return parts.first +
      parts
          .skip(1)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
          .join();
}

bool _sameValues(List<String> left, List<String> right) =>
    left.length == right.length && left.toSet().containsAll(right);
