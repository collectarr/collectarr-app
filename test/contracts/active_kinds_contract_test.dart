import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active kinds contract includes typed catalog kinds', () {
    final body = jsonDecode(
      File('tool/core_contracts/active-kinds.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(
      Set<String>.from(body['kinds'] as List<dynamic>),
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
  });
}
