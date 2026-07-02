import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider support contract stays synced to core bundle', () {
    final body = jsonDecode(
      File('tool/core_contracts/provider-support.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final providers =
        (body['providers'] as List<dynamic>).cast<Map<String, dynamic>>();
    final byName = {
      for (final provider in providers) provider['name'] as String: provider
    };

    expect(byName['igdb']?['supportedKinds'], contains('game'));
    expect(byName['bgg']?['supportedKinds'], contains('boardgame'));
    expect(byName['musicbrainz']?['supportedKinds'], contains('music'));
  });
}
