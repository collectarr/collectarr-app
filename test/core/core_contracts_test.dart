import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core contracts bundle is seeded', () {
    final manifest = jsonDecode(
      File('tool/core_contracts/contract-manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final activeKinds = jsonDecode(
      File('tool/core_contracts/active-kinds.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final fieldSchema = jsonDecode(
      File('tool/core_contracts/metadata-field-schema.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['source_repo'], 'collectarr-core');
    expect(manifest['files'], contains('metadata-field-schema.json'));
    expect(activeKinds['kinds'], containsAll(['book', 'game', 'boardgame']));
    expect(fieldSchema['schema_version'], isA<int>());
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
