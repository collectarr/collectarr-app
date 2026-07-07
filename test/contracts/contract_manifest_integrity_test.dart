import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Self-contained drift gate: verifies that the contract files copied into
/// `tool/core_contracts/` actually match the SHA-256 hashes recorded in the
/// local `contract-manifest.json`.
///
/// Unlike `contract_manifest_sync_test.dart` (which compares against the Core
/// repo and is a no-op when Core is absent, e.g. in CI), this test needs no
/// external repo and therefore runs everywhere. It catches partial/corrupt
/// `update_core_contracts.ps1` runs where the manifest and the payload files
/// drift out of sync.
void main() {
  const contractsDir = 'tool/core_contracts';

  const hashKeyByFile = <String, String>{
    'openapi.json': 'openApiHash',
    'metadata-field-schema.json': 'fieldSchemaHash',
    'active-kinds.json': 'activeKindsHash',
    'provider-support.json': 'providerSupportHash',
  };

  test('local contract files match the hashes recorded in the manifest', () {
    final manifestFile = File('$contractsDir/contract-manifest.json');
    expect(
      manifestFile.existsSync(),
      isTrue,
      reason: 'Missing $contractsDir/contract-manifest.json — run '
          'tool/update_core_contracts.ps1',
    );

    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;

    hashKeyByFile.forEach((fileName, hashKey) {
      final file = File('$contractsDir/$fileName');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Missing contract file $contractsDir/$fileName',
      );

      final expected = (manifest[hashKey] as String?)?.toLowerCase();
      expect(
        expected,
        isNotNull,
        reason: 'Manifest is missing hash field "$hashKey"',
      );

      final actual = sha256.convert(file.readAsBytesSync()).toString();
      expect(
        actual,
        expected,
        reason: 'Contract file $fileName drifted from manifest.$hashKey. '
            'Re-run tool/update_core_contracts.ps1 so the payload and manifest '
            'are copied together from Core.',
      );
    });
  });
}
