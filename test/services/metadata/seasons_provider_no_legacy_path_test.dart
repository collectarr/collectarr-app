import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seasons provider uses typed tv reads instead of legacy item seasons',
      () async {
    final content = await File(
      'lib/features/library/kinds/tv/provider/tv_legacy_seasons_provider.dart',
    ).readAsString();

    expect(content, contains('tvSeasonsBySeriesProvider'));
    expect(content, contains('tvSeasonsBySeriesRefProvider'));
    expect(content, contains('seasonsByCatalogRefProvider'));
    expect(content, isNot(contains('getItemSeasons(')));
    expect(content, isNot(contains('itemSeasonsProvider')));
    expect(content, isNot(contains('/metadata/items/')));
    expect(content, isNot(contains('collectarr_api.models.dart')));
  });
}
