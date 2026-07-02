import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core contracts bundle matches manifest hashes', () {
    final manifest = jsonDecode(
      File('tool/core_contracts/contract-manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final activeKinds = jsonDecode(
      File('tool/core_contracts/active-kinds.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final fieldSchema = jsonDecode(
      File('tool/core_contracts/metadata-field-schema.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['contractVersion'], '1.0.0');
    expect(manifest['coreCommit'], isA<String>());
    expect(manifest['openApiHash'], _fileHash('tool/core_contracts/openapi.json'));
    expect(
      manifest['fieldSchemaHash'],
      _fileHash('tool/core_contracts/metadata-field-schema.json'),
    );
    expect(
      manifest['activeKindsHash'],
      _fileHash('tool/core_contracts/active-kinds.json'),
    );
    expect(
      manifest['providerSupportHash'],
      _fileHash('tool/core_contracts/provider-support.json'),
    );

    expect(
      Set<String>.from(activeKinds['kinds'] as List<dynamic>),
      equals({
        'comic',
        'manga',
        'anime',
        'book',
        'game',
        'boardgame',
        'movie',
        'tv',
        'music',
      }),
    );
    expect(fieldSchema['contractVersion'], '1.0.0');
    expect(fieldSchema['fields'], isNotEmpty);
    final fields =
        (fieldSchema['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
    Map<String, dynamic>? fieldFor(String key, String kind) {
      for (final field in fields) {
        if (field['key'] == key && field['kind'] == kind) {
          return field;
        }
      }
      return null;
    }

    expect(fieldFor('title', 'game')?['writeTarget'], 'core_canonical');
    expect(fieldFor('physical_format_label', 'game')?['writeTarget'],
        'readonly_computed');
  });
}

String _fileHash(String path) {
  return sha256.convert(File(path).readAsBytesSync()).toString();
}
