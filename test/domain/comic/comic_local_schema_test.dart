import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers Comic media and release Drift tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.comicMediaRows).insert(
          ComicMediaRowsCompanion.insert(
            id: 'comic-1',
            title: 'Saga',
          ),
        );
    await db.into(db.comicReleaseRows).insert(
          ComicReleaseRowsCompanion.insert(
            mediaId: 'comic-1',
            id: 'comic-1-release-1',
            title: 'Saga #1',
          ),
        );

    final media = await db.select(db.comicMediaRows).getSingle();
    final release = await db.select(db.comicReleaseRows).getSingle();

    expect(media.id, 'comic-1');
    expect(media.title, 'Saga');
    expect(release.mediaId, media.id);
    expect(release.id, 'comic-1-release-1');
  });
}
