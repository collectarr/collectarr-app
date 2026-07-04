import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String relativePath) => File(relativePath).readAsStringSync();

String _extractSyncPayloadBody(String content) {
  final match = RegExp(
    r'Map<String, dynamic> toSyncPayload\(\)\s*\{\s*return \{\s*([\s\S]*?)\s*\};\s*\}',
    multiLine: true,
  ).firstMatch(content);
  expect(match, isNotNull);
  return match!.group(1)!;
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

    expect(_extractSyncPayloadBody(customEpisode), isNot(contains("'item_id'")));
    expect(_extractSyncPayloadBody(watchSession), isNot(contains("'item_id'")));
    expect(_extractSyncPayloadBody(trackingUnit), isNot(contains("'item_id'")));
  });
}
