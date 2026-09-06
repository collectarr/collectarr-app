import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String relativePath) => File(relativePath).readAsStringSync();

String _extractSyncPayloadBody(String content) {
  final signature = content.indexOf('Map<String, dynamic> toSyncPayload()');
  expect(signature, greaterThanOrEqualTo(0));

  final openingBrace = content.indexOf('{', signature);
  expect(openingBrace, greaterThan(signature));

  var depth = 0;
  for (var index = openingBrace; index < content.length; index++) {
    switch (content[index]) {
      case '{':
        depth++;
      case '}':
        depth--;
        if (depth == 0) {
          return content.substring(openingBrace + 1, index);
        }
    }
  }

  fail('Could not find the end of toSyncPayload()');
}

void main() {
  test('ref-based models no longer accept itemId in constructors', () {
    final ownedItem = _read('lib/core/models/owned_item.dart');
    final wishlistItem = _read('lib/core/models/wishlist_item.dart');
    final trackingEntry = _read('lib/core/models/tracking_entry.dart');

    expect(ownedItem, isNot(contains('String? itemId,')));
    expect(wishlistItem, isNot(contains('String? itemId,')));
    expect(trackingEntry, isNot(contains('String? itemId,')));
  });

  test('sync payloads use catalog_ref instead of item_id', () {
    final customEpisode = _read('lib/core/models/custom_episode.dart');
    final watchSession = _read('lib/core/models/watch_session.dart');
    final trackingUnit = _read('lib/core/models/tracking_unit.dart');

    expect(
        _extractSyncPayloadBody(customEpisode), isNot(contains("'item_id'")));
    expect(_extractSyncPayloadBody(watchSession), isNot(contains("'item_id'")));
    expect(_extractSyncPayloadBody(trackingUnit), isNot(contains("'item_id'")));
  });
}
