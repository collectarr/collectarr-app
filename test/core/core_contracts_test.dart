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
      File('tool/core_contracts/metadata_field_schema.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['source_repo'], 'collectarr-core');
    expect(activeKinds['active_kinds'], hasLength(9));
    expect(fieldSchema['schema_version'], isA<int>());
    expect(fieldSchema['fields'], isNotEmpty);
  });
}
