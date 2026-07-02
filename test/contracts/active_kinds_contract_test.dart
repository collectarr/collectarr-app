import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active kinds contract includes typed catalog kinds', () {
    final body = jsonDecode(
      File('tool/core_contracts/active-kinds.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(body['kinds'], containsAll(['book', 'game', 'boardgame']));
  });
}
