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
    final catalogItem = jsonDecode(
      File('tool/core_contracts/catalog-item-v1.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['contractVersion'], '1.0.0');
    expect(manifest['coreCommit'], isA<String>());
    expect(
        manifest['openApiHash'], _fileHash('tool/core_contracts/openapi.json'));
    expect(
      manifest['catalogItemHash'],
      _fileHash('tool/core_contracts/catalog-item-v1.json'),
    );
    expect(
      manifest['activeKindsHash'],
      _fileHash('tool/core_contracts/active-kinds.json'),
    );
    final coreManifest =
        File(r'..\collectarr-core\contracts\contract-manifest.json');
    if (coreManifest.existsSync()) {
      expect(manifest, jsonDecode(coreManifest.readAsStringSync()));
    }

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
    expect(catalogItem['schemaVersion'], 1);
    expect(catalogItem['roots'], contains('itemWrite'));
    expect(catalogItem[r'$defs'], isNotEmpty);
  });
}

String _fileHash(String path) {
  return sha256.convert(File(path).readAsBytesSync()).toString();
}
