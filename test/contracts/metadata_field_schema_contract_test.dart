import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('metadata field schema contract exposes routing metadata', () {
    final manifest = jsonDecode(
      File('tool/core_contracts/contract-manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final body = jsonDecode(
      File('tool/core_contracts/metadata-field-schema.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final fields =
        (body['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
    Map<String, dynamic>? fieldFor(String key, String kind) {
      for (final field in fields) {
        if (field['key'] == key && field['kind'] == kind) {
          return field;
        }
      }
      return null;
    }

    expect(
      manifest['fieldSchemaHash'],
      sha256
          .convert(
            File('tool/core_contracts/metadata-field-schema.json')
                .readAsBytesSync(),
          )
          .toString(),
    );
    expect(fieldFor('title', 'game')?['writeTarget'], 'core_canonical');
    expect(fieldFor('physical_format_label', 'game')?['writeTarget'],
        'readonly_computed');
    expect(fieldFor('platforms', 'game')?['scope'], 'platform');
    expect(fieldFor('platforms', 'boardgame')?['scope'], 'work');
  });
}
