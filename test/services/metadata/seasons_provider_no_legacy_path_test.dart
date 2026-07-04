import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seasons provider uses typed tv reads instead of legacy item seasons', () async {
    final content = await File('lib/features/library/providers/seasons_provider.dart')
        .readAsString();

    expect(content, contains('tvSeriesSeasonsProvider'));
    expect(content, contains('getTvSeriesSeasonsDto'));
    expect(content, contains('seasonsByCatalogRefProvider'));
    expect(content, isNot(contains('getItemSeasons(')));
    expect(content, isNot(contains('/metadata/items/')));
  });
}
