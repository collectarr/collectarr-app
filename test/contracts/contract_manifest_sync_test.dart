import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readManifest(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  test('app and core contract manifests stay in sync', () {
    final appManifest = File('tool/core_contracts/contract-manifest.json');
    final coreManifest = File(
      '${Directory.current.parent.path}\\collectarr-core\\contracts\\contract-manifest.json',
    );

    if (!appManifest.existsSync() || !coreManifest.existsSync()) {
      return;
    }

    final app = _readManifest(appManifest);
    final core = _readManifest(coreManifest);

    for (final key in <String>[
      'contractVersion',
      'openApiHash',
      'fieldSchemaHash',
      'activeKindsHash',
      'providerSupportHash',
    ]) {
      expect(app[key], core[key], reason: 'Manifest field $key drifted');
    }
  });
}
