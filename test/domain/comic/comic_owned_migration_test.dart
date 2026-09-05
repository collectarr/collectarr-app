import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backfills Comic owned and reading rows from v26 cache', () async {
    final directory =
        await Directory.systemTemp.createTemp('collectarr_comic_migration');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-comic-legacy',
            itemId: 'comic-legacy',
            kind: const Value('comic'),
            detailsJson: Value(jsonEncode({
              'grading_company': 'CGC',
              'key_comic': true,
              'key_reason': 'First appearance',
            })),
            rating: const Value(5),
            readStatus: const Value('completed'),
            startedAt: Value(DateTime.utc(2026, 1, 1)),
            finishedAt: Value(DateTime.utc(2026, 1, 2)),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        );
    await old.customStatement('PRAGMA user_version = 26');
    await old.close();

    final upgraded = LocalDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    final restored = await ComicOwnedRepository(upgraded).findById(
      const ComicOwnedItemId('owned-comic-legacy'),
    );
    expect(restored?.itemId, 'comic-legacy');
    expect(restored?.details.gradingCompany, 'CGC');
    expect(restored?.details.keyComic, isTrue);
    expect(restored?.reading.status, 'completed');
    expect(restored?.reading.rating, 5);
    expect(restored?.reading.finishedAt?.toUtc(), DateTime.utc(2026, 1, 2));
  });
}
