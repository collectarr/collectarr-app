import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers Manga media and owned details Drift tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.mangaMediaRows).insert(
          MangaMediaRowsCompanion.insert(
            id: 'manga-1',
            title: 'Vagabond',
          ),
        );
    await db.into(db.mangaOwnedDetailsRows).insert(
          MangaOwnedDetailsRowsCompanion.insert(
            ownedItemId: 'owned-1',
            obiStripPresent: const Value(true),
          ),
        );

    final media = await db.select(db.mangaMediaRows).getSingle();
    final ownedDetails = await db.select(db.mangaOwnedDetailsRows).getSingle();

    expect(media.id, 'manga-1');
    expect(media.title, 'Vagabond');
    expect(ownedDetails.ownedItemId, 'owned-1');
    expect(ownedDetails.obiStripPresent, isTrue);
  });
}
