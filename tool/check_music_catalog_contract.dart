import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractPath = 'tool/core_contracts/music-catalog-v1.json';
const _manifestPath = 'tool/core_contracts/contract-manifest.json';
const _dtoPath =
    'lib/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';

Future<void> main() async {
  final contractBytes = await File(_contractPath).readAsBytes();
  final actualHash = sha256.convert(contractBytes).toString();
  final manifest = _readJson(_manifestPath);
  if (manifest['musicCatalogHash'] != actualHash) {
    throw StateError(
        'The pinned Music contract hash does not match its manifest.');
  }

  final contract =
      jsonDecode(utf8.decode(contractBytes)) as Map<String, dynamic>;
  final definitions = contract[r'$defs'] as Map<String, dynamic>;
  final dtoSource = await File(_dtoPath).readAsString();
  final schemas = <String, String>{
    'CatalogMusicItemResponse': 'CatalogMusicItemDto',
    'CatalogMusicDiscResponse': 'CatalogMusicDiscDto',
    'CatalogMusicTrackResponse': 'CatalogMusicTrackDto',
  };

  for (final entry in schemas.entries) {
    final schema = definitions[entry.key];
    if (schema is! Map<String, dynamic>) {
      throw StateError('The pinned Music contract is missing ${entry.key}.');
    }
    final properties = schema['properties'];
    if (properties is! Map<String, dynamic>) {
      throw StateError('${entry.key} has no properties.');
    }
    final classSource = _classSource(dtoSource, entry.value);
    for (final property in properties.keys) {
      final dartName = _camelCase(property);
      if (property != 'kind' &&
          !RegExp('\\b${RegExp.escape(dartName)}\\b').hasMatch(classSource)) {
        throw StateError(
          '${entry.key}.$property is missing from ${entry.value}.',
        );
      }
      if (!classSource.contains("json['$property']")) {
        throw StateError(
          '${entry.value} does not decode the ${entry.key}.$property field.',
        );
      }
    }
  }
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

String _classSource(String source, String className) {
  final start = source.indexOf('final class $className');
  if (start < 0) throw StateError('DTO class $className was not found.');
  final next = source.indexOf('\nfinal class ', start + 1);
  return source.substring(start, next < 0 ? source.length : next);
}

String _camelCase(String value) => value.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
