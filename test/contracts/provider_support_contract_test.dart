import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider support contract stays synced to core bundle', () {
    final manifest = jsonDecode(
      File('tool/core_contracts/contract-manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final body = jsonDecode(
      File('tool/core_contracts/provider-support.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final providers =
        (body['providers'] as List<dynamic>).cast<Map<String, dynamic>>();
    final byName = {
      for (final provider in providers) provider['name'] as String: provider
    };

    expect(
      manifest['providerSupportHash'],
      sha256
          .convert(
            File('tool/core_contracts/provider-support.json').readAsBytesSync(),
          )
          .toString(),
    );
    expect(
      byName.keys.toSet(),
      containsAll(<String>[
        'comicvine',
        'gcd',
        'hardcover',
        'igdb',
        'anilist',
        'mangadex',
        'openlibrary',
        'musicbrainz',
        'tmdb',
        'bgg',
      ]),
    );
    expect(byName['igdb']?['supportedKinds'], contains('game'));
    expect(byName['bgg']?['supportedKinds'], contains('boardgame'));
    expect(byName['musicbrainz']?['supportedKinds'], contains('music'));
  });
}
