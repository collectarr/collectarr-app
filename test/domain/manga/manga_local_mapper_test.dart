import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_signature_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Manga media row', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = MangaMedia(
      id: 'manga-1',
      title: 'Vagabond',
      sortTitle: 'Vagabond',
      description: 'A wandering swordsman searches for meaning.',
      firstPublicationDate: DateTime.utc(1998, 9, 3),
      originalLanguage: 'ja',
      originalPublicationDate: DateTime.utc(1998, 9, 3),
      status: 'hiatus',
      subtitle: 'The Definitive Edition',
      chapters: const [
        {'id': 'chapter-1', 'number': 1},
      ],
      characterAppearances: const [
        {'name': 'Miyamoto Musashi'},
      ],
      contributions: const [
        {'name': 'Takehiko Inoue', 'role': 'author'},
      ],
      identifiers: const [
        {'type': 'isbn', 'value': '978-1569317075'},
      ],
      series: const [
        {'id': 'series-1', 'title': 'Vagabond'},
      ],
      rawPayload: const {'source': 'core'},
    );

    await db.into(db.mangaMediaRows).insert(MangaLocalMapper.toMediaRow(media));
    final restored = MangaLocalMapper.fromMediaRow(
      await db.select(db.mangaMediaRows).getSingle(),
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.description, media.description);
    expect(restored.firstPublicationDate?.toUtc(), media.firstPublicationDate);
    expect(restored.originalLanguage, media.originalLanguage);
    expect(
      restored.originalPublicationDate?.toUtc(),
      media.originalPublicationDate,
    );
    expect(restored.status, media.status);
    expect(restored.subtitle, media.subtitle);
    expect(restored.chapters, media.chapters);
    expect(restored.characterAppearances, media.characterAppearances);
    expect(restored.contributions, media.contributions);
    expect(restored.identifiers, media.identifiers);
    expect(restored.series, media.series);
    expect(restored.rawPayload, media.rawPayload);
  });

  test('round trips all Manga owned details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const details = MangaOwnedDetails(
      grading: MangaGradingDetails(
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'MGC',
        graderNotes: 'Excellent condition',
        labelType: 'Modern',
        customLabel: 'Museum copy',
        pageQuality: 'White pages',
        certificationNumber: 'MGC-12345',
      ),
      signature: MangaSignatureDetails(signedBy: 'Takehiko Inoue'),
      obiStripPresent: true,
      slipcoverPresent: true,
      dustJacketPresent: true,
      dustJacketCondition: 'Like new',
      boxSetOuterCondition: 'Very good',
      insertsPresent: true,
      printing: '1st Print',
      localizedEdition: 'VIZ Media',
    );

    await db.into(db.mangaOwnedDetailsRows).insert(
          MangaLocalMapper.toOwnedDetailsRow('owned-1', details),
        );
    final restored = MangaLocalMapper.fromOwnedDetailsRow(
      await db.select(db.mangaOwnedDetailsRows).getSingle(),
    );

    expect(restored, details);
    expect(restored.grading.rawOrSlabbed, details.grading.rawOrSlabbed);
    expect(restored.gradingCompany, details.gradingCompany);
    expect(restored.grading.labelType, details.grading.labelType);
    expect(restored.grading.customLabel, details.grading.customLabel);
    expect(restored.grading.pageQuality, details.grading.pageQuality);
    expect(
      restored.grading.certificationNumber,
      details.grading.certificationNumber,
    );
    expect(restored.signedBy, details.signedBy);
    expect(restored.dustJacketCondition, details.dustJacketCondition);
    expect(restored.localizedEdition, details.localizedEdition);
  });

  test('requires persisted Manga media and owned detail identities', () {
    expect(
      () => MangaLocalMapper.toMediaRow(
        const MangaMedia(id: '', title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => MangaLocalMapper.toOwnedDetailsRow(
        '',
        const MangaOwnedDetails(),
      ),
      throwsStateError,
    );
  });
}
