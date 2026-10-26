import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_core_contract_sync.dart';

void main() {
  final manifest = {
    'contractVersion': '1.0.0',
    'coreCommit': 'pinned-commit',
    'openApiHash': 'openapi',
    'fieldSchemaHash': 'fields',
    'catalogItemV1Hash': 'catalog',
    'musicCatalogV1Hash': 'music',
    'activeKindsHash': 'kinds',
  };

  test('contract comparison requires an explicit Core manifest', () {
    final errors = StringBuffer();
    expect(checkCoreContractSync([], errors: errors), 2);
    expect(errors.toString(), contains('explicit Core manifest'));
  });

  test('contract comparison ignores generation time but checks every pin', () {
    expect(
        coreContractDifferences(
            manifest, {...manifest, 'generatedAt': 'later'}),
        isEmpty);
    for (final key in manifest.keys) {
      expect(coreContractDifferences(manifest, {...manifest, key: 'different'}),
          contains(contains(key)));
    }
    expect(coreContractDifferences({}, {}), isNotEmpty);
  });

  test('explicit files are checked and missing or malformed inputs fail', () {
    final root =
        Directory.systemTemp.createTempSync('collectarr-contract-sync-');
    addTearDown(() => root.deleteSync(recursive: true));
    final app = File('${root.path}/app.json')
      ..writeAsStringSync(jsonEncode(manifest));
    final core = File('${root.path}/core.json')
      ..writeAsStringSync(jsonEncode(manifest));
    final args = ['--app-manifest', app.path, '--core-manifest', core.path];
    expect(checkCoreContractSync(args, output: StringBuffer()), 0);
    core.writeAsStringSync(
        jsonEncode({...manifest, 'coreCommit': 'other-commit'}));
    expect(checkCoreContractSync(args, errors: StringBuffer()), 1);
    core.writeAsStringSync('[]');
    expect(checkCoreContractSync(args, errors: StringBuffer()), 2);
    core.deleteSync();
    expect(checkCoreContractSync(args, errors: StringBuffer()), 2);
  });
}
